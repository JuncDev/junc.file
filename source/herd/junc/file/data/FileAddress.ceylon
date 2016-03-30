import herd.junc.api {
	JuncAddress
}


"_Junc_ address to connect to a file."
by( "Lis" )
shared class FileAddress (
	"Name of the file." shared String fileName,
	"Size of the buffer used for read / write operations." shared Integer fileBufferSize = 1024
)
		extends JuncAddress()
{
	
	shared actual Boolean equals( Object that ) {
		if ( is FileAddress that ) {
			return fileName == that.fileName;
		}
		else {
			return false;
		}
	}
	
	shared actual String string => "junc file://" + fileName;
	
	shared actual Integer calculateHash() => 17 + 41 * ( 41 * "junc file://".hash + fileName.hash );
	
}
