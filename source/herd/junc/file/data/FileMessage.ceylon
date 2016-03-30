import herd.junc.api {
	Message,
	JuncSocket
}


"File info request message."
tagged( "file info" )
shared alias InfoRequestMessage => Message<FileInfoRequest, FileInfoResponse>;

"File info response message."
tagged( "file info" )
shared alias InfoResponseMessage => Message<FileInfoResponse, FileInfoRequest>;

"File read request message."
tagged( "file read" )
shared alias ReadRequestMessage => Message<FileReadRequest, FileReadResponse>;

"File read response message."
tagged( "file read" )
shared alias ReadResponseMessage => Message<FileReadResponse, FileReadRequest>;

"File write request message."
tagged( "file write" )
shared alias WriteRequestMessage => Message<FileWriteRequest, FileWriteResponse>;

"File write response message."
tagged( "file write" )
shared alias WriteResponseMessage => Message<FileWriteResponse, FileWriteRequest>;


"File message."
shared alias FileMessage => InfoRequestMessage | ReadRequestMessage | WriteRequestMessage;


"Socket to connect to a file."
shared alias FileSocket => JuncSocket<Nothing, FileMessage>;
