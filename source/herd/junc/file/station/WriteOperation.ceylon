import java.lang {
	ByteArray
}
import herd.junc.file.data {

	WriteRequestMessage,
	FileWriteResponse
}


"Performs writing to file."
throws( `class AssertionError`, "Buffer size is less or equal to zero." )
by( "Lis" )
class WriteOperation (
	"File used with operation" ReadWriteFile file,
	"Request on file writing." WriteRequestMessage request
)
		extends FileOperation()
{
	
	"position to start writing from"
	variable Integer position = request.body.position;
	if ( position.negative ) {
		try {
			position = file.length;
		}
		catch ( Throwable err ) {
			request.reject( err );
			position = -1;
		}
	}
	
	Integer size = request.body.bytes.size;
	variable Integer byteIndex = 0;
	Byte[] bytes = request.body.bytes;
	
	ByteArray writeBuffer = ByteArray( file.bufferSize, Byte( 0 ) );
	
	
	shared actual Boolean perform() {
		if ( position.negative ) {
			request.reply( file.writeMessage( FileWriteResponse( byteIndex ) ) );
			return true;
		}
		
		Integer writeSize = if ( size - byteIndex > file.bufferSize ) then file.bufferSize else size - byteIndex;
		if ( writeSize.positive ) {
			try {
				// copy to buffer
				variable Integer index = 0;
				while ( index < writeSize, exists byte = bytes[byteIndex ++] ) {
					writeBuffer.set( index ++, byte );
				}
				
				// write to file
				file.write( position, writeBuffer, index );
				position += index;
				
				if ( byteIndex >= size ) {
					if ( request.body.truncate ) {
						file.truncate( position );
					}
					request.reply( file.writeMessage( FileWriteResponse( byteIndex ) ) );
					return true;
				}
				else {
					return false;
				}
			}
			catch ( Throwable err ) {
				request.reject( err );
				return true;
			}
		}
		else {
			request.reply( file.writeMessage( FileWriteResponse( byteIndex ) ) );
			return true;
		}
	}
	
}
