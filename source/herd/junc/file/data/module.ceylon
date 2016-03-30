
"Objects used to exchange data with _file station_ within _Junc_.  
 _File station_ is implemented in `module herd.junc.file.station`.  
 
 [[FileAddress]] is used to connect to _file station_.
 
 
 ### File operations.
 
 Data exchanging with file is performed using `Message`.  
 Three request types to file is available:
 * [[FileInfoRequest]] requesting file info with response of [[FileInfoResponse]] 
 * [[FileReadRequest]] requesting reading from file with response of [[FileReadResponse]]
 * [[FileWriteRequest]] requesting writing to file with response of [[FileWriteResponse]]
 
 
 ### Operation order.
 
 * [[FileInfoRequest]] is performed immediately nevertheless the other operations are performed or not.
 * [[FileReadRequest]] waits current _file write_ operation but may be performed in parallel with another
   _file read operation_.
 * [[FileWriteRequest]] waits any other operations currently performed or are in waiting mode.
 
 
 ### Example.
 
 		// deploying file station
 		junc.deployStation(FileStation());
 		...
 		// connecting to the file
 		juncTrack.connect<Nothing, FileMessage, FileAddress> (
 			fileAddress // file address (path)
 		).onComplete (
 			(FileSocket socket) {
 				// writing to the file
 				socket.publish (
 					track.createMessage(FileWriteRequest(0, bytesToFile, true))
 				);
 				// reading from the file
 				socket.publish (
 					track.createMessage (
 						FileReadRequest(0, totalBytes),
 						(Message<FileReadResponse, FileReadRequest> msg) {
 							// msg.body.bytes contains read bytes
 							...
 						}
 					)
 				);
 			}
 		);
 
 "
by( "Lis" )
native("jvm")
module herd.junc.file.data "0.1.0" {
	shared import herd.junc.api "0.1.0";
}
