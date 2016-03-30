import ceylon.collection {
	HashMap
}

import herd.junc.api {
	Connector,
	Junc,
	JuncSocket,
	Promise,
	Context,
	InvalidServiceError,
	JuncTrack,
	Message
}
import herd.junc.file.data {

	FileAddress,
	FileMessage,
	FileInfoRequest,
	FileInfoResponse,
	FileReadRequest,
	FileReadResponse,
	FileWriteResponse,
	FileWriteRequest
}
import herd.junc.api.monitor {

	Counter,
	Meter
}


"Do connections to files."
by( "Lis" )
class FileConnector (
	Junc junc,
	JuncTrack track,
	"Monitoring total number of opened files." String fileCounterName,
	"Monitoring writing in bytes/s." String writeMeterName,
	"Monitoring reading in bytes/s." String readMeterName,
	Integer defaultBufferSize
)
		satisfies Connector<Nothing, FileMessage, FileAddress>
{
	
	Counter files = junc.monitor.counter( fileCounterName );
	Meter writeMeter = junc.monitor.meter( writeMeterName );
	Meter readMeter = junc.monitor.meter( readMeterName );
	
	HashMap<String, ReadWriteFile> openFiles = HashMap<String, ReadWriteFile>();
	
	
	class ReadWriteFileImpl( String fileName, Integer bufferSize )
			extends ReadWriteFile( fileName, track, bufferSize, writeMeter, readMeter )
	{
		shared actual void doClose() {
			files.decrement();
			openFiles.remove( fileName );
			junc.monitor.logInfo( "junc.file", "file ```fileName``` is closed" );
		}
	}
	
	
	ReadWriteFile getFile( String name, Integer bufferSize ) {
		if ( exists f = openFiles.get( name ) ) {
			return f;
		}
		else {
			ReadWriteFile f = ReadWriteFileImpl( name, bufferSize );
			junc.monitor.logInfo( "junc.file", "file ```name``` is opened" );
			files.increment();
			openFiles.put( name, f );
			return f;
		}
	}
	
	
	shared actual Promise<JuncSocket<Send, Receive>> connect<Send, Receive> (
		FileAddress address, Context clientContext
	)
			given Send of Anything
			given Receive
				of Message<FileInfoRequest, FileInfoResponse>
				|  Message<FileReadRequest, FileReadResponse>
				|  Message<FileWriteRequest, FileWriteResponse>
	{
		value socks = junc.socketPair<Nothing, FileMessage>( clientContext, track.context );
		if ( is JuncSocket<Send, Receive> ret = socks[0] ) {
			try {
				Integer bufferSize = if ( address.fileBufferSize > 0 ) then address.fileBufferSize else defaultBufferSize;
				value file = getFile( address.fileName, bufferSize );
				file.addConnection( socks[1] );
				return clientContext.resolvedPromise( ret );
			}
			catch ( Throwable err ) {
				return clientContext.rejectedPromise( err );
			}
		}
		else {
			return clientContext.rejectedPromise( InvalidServiceError() );
		}
	}
	
}
