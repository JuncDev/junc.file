
"Response to file request."
by( "Lis" )
shared abstract class FileResponse()
		of FileInfoResponse | FileReadResponse | FileWriteResponse
{}


"Response to [[FileInfoRequest]]."
tagged( "file info" )
by( "Lis" )
shared final class FileInfoResponse (
	"File name." shared String fileName,
	"The store to which the file belongs to." shared String storeName,
	"Name of the directory containing the file." shared String directoryName,
	"Absolute path." shared String absolutePath,
	"The principal name of the owner of the file." shared String owner,
	"The size of this file, in bytes." shared Integer size,
	"The timestamp of the last modification of this file." shared Integer lastModifiedMilliseconds,
	"Determine if this file is considered hidden." shared Boolean hidden,
	"Determine the content type of this file, if possible." shared String? contentType
)
		extends FileResponse()
{
	shared actual String string
			=> "File: name ``absolutePath``, owner ``owner``, size ``size``";
}


"Response to [[FileReadRequest]]."
tagged( "file read" )
by( "Lis" )
shared final class FileReadResponse (
	"Bytes read from file." shared Byte[] bytes
)
		extends FileResponse()
{}


"Response to [[FileWriteRequest]]."
tagged( "file write" )
by( "Lis" )
shared final class FileWriteResponse (
	"Total number of bytes have been written." shared Integer totalBytes 
)
		extends FileResponse()
{}

