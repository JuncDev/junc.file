import herd.junc.api {
	JuncTrack,
	Message,
	JuncSocket
}

import java.io {
	RandomAccessFile
}
import herd.junc.file.data {

	ReadRequestMessage,
	WriteRequestMessage,
	InfoRequestMessage,
	FileWriteResponse,
	FileWriteRequest,
	FileReadRequest,
	FileReadResponse,
	FileInfoResponse,
	FileInfoRequest,
	FileMessage
}
import java.lang {

	ByteArray
}
import ceylon.file {

	Path,
	parsePath,
	File
}
import herd.junc.api.monitor {

	Meter
}


"Socket to provide file services."
shared alias FileServiceSocket => JuncSocket<FileMessage, Nothing>;


"File performing read / write operations.  
 May throw exceptions at initializer - see java RandomAccessFile."
throws( `class AssertionError`, "Default buffer size is less or equal to zero." )
by( "Lis" )
abstract class ReadWriteFile (
	"File name." String fileName,
	"Track the file operates on." JuncTrack track,
	"Size of the buffer used for reading operations." shared Integer bufferSize,
	"Meter to monitor writing in bytes/s." Meter writeMeter,
	"Meter to monitor reading in bytes/s." Meter readMeter
) {
	
	"File: default buffer size has to be positive."
	assert( bufferSize > 0 );
	
	RandomAccessFile file = RandomAccessFile( fileName, "rw" );
	
	Path path = parsePath( fileName ).absolutePath.normalizedPath;
	File pathFile;
	if ( is File pf = path.resource ) {
		pathFile = pf;
	}
	else {
		throw AssertionError( "Resource ``fileName`` must be a file." );
	}
	
	
	variable Integer connected = 0;
	shared Boolean empty => connected <= 0;
	
	variable FileOperation? head = null;
	variable FileOperation? tail = null;
	
	
	shared formal void doClose();
	
	
	void connectionClosed() {
		connected --;
		if ( empty ) {
			file.close();
			doClose();
		}
	}
	
	void processOperations() {
		variable FileOperation? h = head;
		while ( exists op = h ) {
			h = op.next;
			if ( op.perform() ) { head = h; }
			else { break; }
		}
		if ( head exists, !empty ) { track.context.execute( processOperations ); }
		else { head = null; tail = null; }
	}
	
	
	void onReadRequest( ReadRequestMessage request ) {
		ReadOperation operation = ReadOperation( this, request );
		if ( !empty ) {
			if ( exists t = tail ) {
				if ( is CombinedOperation c = t ) {
					c.combine( operation );
				}
				else {
					CombinedOperation c = CombinedOperation();
					c.combine( operation );
					t.next = c;
					tail = c;
				}
			}
			else {
				CombinedOperation c = CombinedOperation();
				c.combine( operation );
				head = c;
				tail = c;
				track.context.execute( processOperations );
			}
		}
	}
	
	void onWriteRequest( WriteRequestMessage request ) {
		WriteOperation operation = WriteOperation( this, request );
		if ( !empty ) {
			if ( exists t = tail ) {
				t.next = operation;
				tail = operation;
			}
			else {
				head = operation;
				tail = operation;
				track.context.execute( processOperations );
			}
		}
	}
	
	void onInfoRequest( InfoRequestMessage request ) {
		request.reply (
			track.createMessage<FileInfoResponse, FileInfoRequest> (
				FileInfoResponse (
					pathFile.name,
					pathFile.store.name,
					pathFile.directory.name,
					pathFile.path.string,
					pathFile.owner,
					pathFile.size,
					pathFile.lastModifiedMilliseconds,
					pathFile.hidden,
					pathFile.contentType
				),
				onInfoRequest
			)
		);
	}
	
	
	"Total number of bytes in the file."
	shared Integer length => file.length();
	
	"Truncates file to specified size."
	shared void truncate( Integer size ) => file.channel.truncate( size );
	
	"Reads data from `from` with total number of bytes of `len` and writes it to `bytes`."
	shared Integer read( Integer from, ByteArray bytes, Integer len ) {
		file.seek( from );
		value ret = file.read( bytes, 0, len );
		readMeter.tick( ret );
		return ret;
	}
	
	"Writes `bytes` to `to` with total number of bytes of `len`."
	shared void write( Integer to, ByteArray bytes, Integer len ) {
		file.seek( to );
		file.write( bytes, 0, len );
		writeMeter.tick( len );
	}
	
	"Creates new write message."
	shared Message<FileWriteResponse, FileWriteRequest> writeMessage( FileWriteResponse response ) {
		return track.createMessage<FileWriteResponse, FileWriteRequest> (
			response,
			onWriteRequest
		);
	}
	
	"Creates new read message."
	shared Message<FileReadResponse, FileReadRequest> readMessage( FileReadResponse response ) {
		return track.createMessage<FileReadResponse, FileReadRequest> (
			response,
			onReadRequest
		);
	}
	
	
	"Adds connection."
	shared void addConnection (
		"Socket to listen commands" FileServiceSocket socket
	) {
		connected ++;
		socket.onClose( connectionClosed );
		socket.onData( onReadRequest );
		socket.onData( onWriteRequest );
		socket.onData( onInfoRequest );
	}
	
}
