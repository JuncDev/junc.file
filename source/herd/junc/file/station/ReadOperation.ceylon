import java.lang {
	ByteArray
}
import herd.junc.file.data {

	ReadRequestMessage,
	FileReadResponse
}
import ceylon.collection {

	ArrayList
}


"Performs reading from file."
throws( `class AssertionError`, "Buffer size is less or equal to zero." )
by( "Lis" )
class ReadOperation (
	"File used with operation" ReadWriteFile file,
	"File read request message." ReadRequestMessage request
)
		extends FileOperation()
{
	variable Integer position = request.body.position > 0 then request.body.position else 0;
	variable Integer size = request.body.size;  
	if ( !size.positive ) {
		try {
			size = file.length - position;
			if ( size.negative ) {
				request.reply( file.readMessage( FileReadResponse( [] ) ) );
				size = -1;
			}
		}
		catch ( Throwable err ) {
			request.reject( err );
			size = -1;
		}
	}
	
	ByteArray readBuffer = ByteArray( file.bufferSize, Byte( 0 ) );
	ArrayList<Byte> bytes = ArrayList<Byte>( size, 1.1 );
	
	
	shared actual Boolean perform() {
		if ( size.negative ) {
			request.reply( file.readMessage( FileReadResponse( bytes.sequence() ) ) );
			return true;
		}
		
		Integer readSize = if ( size > file.bufferSize ) then file.bufferSize else size;
		if ( readSize.positive ) {
			try {
				Integer rSize = file.read( position, readBuffer, readSize );
				if ( rSize.positive ) {
					position += rSize;
					size -= rSize;
					bytes.addAll( readBuffer.iterable.take( rSize ) );
				}
				else { size = 0; }
				
				if ( size.positive ) {
					return false;
				}
				else {
					request.reply( file.readMessage( FileReadResponse( bytes.sequence() ) ) );
					return true;
				}
			}
			catch ( Throwable err ) {
				request.reject( err );
				return true;
			}
		}
		else {
			request.reply( file.readMessage( FileReadResponse( bytes.sequence() ) ) );
			return true;
		}
	}
		
}
