
"Request to file."
by( "Lis" )
shared abstract class FileRequest()
		of FileInfoRequest | FileReadRequest | FileWriteRequest
{}


"File info request."
see( `class FileInfoResponse` )
tagged( "file info" )
by( "Lis" )
shared final class FileInfoRequest()
	extends FileRequest()
{}


"Read from file request."
see( `class FileReadResponse` )
tagged( "file read" )
by( "Lis" )
shared final class FileReadRequest (
	"Position to read from." shared Integer position,
	"Total number of bytes to be read.  
	 Reading has to be performed up to end if < 0."
	shared Integer size
)
		extends FileRequest()
{}


"Write to file request."
see( `class FileWriteResponse` )
tagged( "file write" )
by( "Lis" )
shared final class FileWriteRequest (
	"Position to write to."
	shared Integer position, 
	"Bytes to be writing."
	shared Byte[] bytes,
	"If `true` file size is truncated to `position + bytes.size`."
	shared Boolean truncate = false
)
		extends FileRequest()
{}
