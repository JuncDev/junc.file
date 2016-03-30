

"
 Contains _file station_, which provides access to file system within _Junc_.  
 `Module herd.junc.file.data` contains declarations used to exchange data with _file station_.
 
 
 #### Monitoring.
 
 Monitores overall rate of read / write operation as bytes per second.  
 Names of corresponding `Meters` are specified in [[FileStation]] parameters.
 
 
 #### Example.
 
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
module herd.junc.file.station "0.1.0" {
	shared import herd.junc.api "0.1.0";
	shared import herd.junc.file.data "0.1.0";
	shared import ceylon.collection "1.2.2";
	shared import ceylon.file "1.2.2";
}
