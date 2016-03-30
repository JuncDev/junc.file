import herd.asynctest {
	sequential,
	TestSuite,
	TestInitContext,
	AsyncTestContext
}
import herd.junc.core {
	Railway,
	startJuncCore,
	JuncOptions
}
import herd.junc.api.monitor {
	LogWriter,
	Priority
}
import ceylon.test {
	test
}
import herd.junc.api {
	Message,
	JuncTrack
}
import herd.junc.file.data {
	FileWriteResponse,
	FileWriteRequest,
	FileReadRequest,
	FileReadResponse,
	FileAddress,
	FileInfoRequest,
	FileSocket,
	FileMessage,
	FileInfoResponse
}
import herd.asynctest.match {
	EqualTo,
	EqualObjects
}


sequential
shared class FileTest() satisfies TestSuite {
	
	Integer monitorPeriodSeconds = 1;
	
	FileAddress fileAddress = FileAddress( "../fileTest.txt" );

	SimpleStation station = SimpleStation();
	variable Railway? railway = null;
	
	Byte[] bytesToFile = [Byte(1), Byte(2), Byte(3)];
	Integer totalBytes = bytesToFile.size;
	
	shared actual void dispose() {
		if ( exists r = railway ) {
			railway = null;
			r.forceMetricWriting();
			r.stop();
		}
	}
	
	shared actual void initialize( TestInitContext initContext ) {
		startJuncCore(
			JuncOptions {
				monitorPeriod = monitorPeriodSeconds;
			}
		).onComplete (
			(Railway railway) {
				this.railway = railway;
				
				railway.addLogWriter (
					object satisfies LogWriter {
						shared actual void writeLogMessage (
							String identifier,
							Priority priority,
							String message,
							Throwable? throwable
						) {
							String str = if ( exists t = throwable ) then " with error ``t.message```" else "";
							print( "``priority``: ``identifier`` sends '``message``'``str``" );
						}
					}
				);
				
				railway.addMetricWriter( MetricWriterImpl() );
				
				railway.deployStation( station ).onComplete (
					(Object obj) => initContext.proceed(),
					(Throwable reason) => initContext.abort( reason, "station deploying" )
				);
			}
		);
	}
	
	
	
	void fileInfo (
		AsyncTestContext context,
		JuncTrack track,
		FileSocket socket
	) {
		socket.publish (
			track.createMessage(
				FileInfoRequest(),
				(Message<FileInfoResponse, FileInfoRequest> msg) {
					socket.close();
					context.succeed( "file info -> ``msg.body``" );
					context.complete();
				},
				(Throwable err) {
					socket.close();
					context.fail( err, "first file read" );
					context.complete();
				}
			)
		);
	}
	
	void readFromFile (
		AsyncTestContext context,
		JuncTrack track,
		FileSocket socket
	) {
		socket.publish (
			track.createMessage(
				FileReadRequest( 0, totalBytes ),
				(Message<FileReadResponse, FileReadRequest> msg) {
					context.assertThat (
						msg.body.bytes.size, EqualTo( totalBytes ), "number of first read bytes", true
					);
					context.assertThat (
						msg.body.bytes, EqualObjects( bytesToFile ), "first read bytes", true 
					);
					msg.reply (
						track.createMessage (
							FileReadRequest( totalBytes, totalBytes ),
							(Message<FileReadResponse, FileReadRequest> msg) {
								context.assertThat (
									msg.body.bytes.size, EqualTo( totalBytes ), "number of second read bytes", true
								);
								context.assertThat (
									msg.body.bytes, EqualObjects( bytesToFile ), "second read bytes", true
								);
								if ( exists r = railway ) {
									r.forceMetricWriting();
								}
								fileInfo( context, track, socket );
							},
							(Throwable err) {
								socket.close();
								context.fail( err, "second file read" );
								context.complete();
							}
						)
					);
				},
				(Throwable err) {
					socket.close();
					context.fail( err, "first file read" );
					context.complete();
				}
			)
		);
	}
	
	void writeToFile( AsyncTestContext context ) (
		FileSocket socket
	) {
		"Test is not correctly initialized."
		assert( exists track = station.track );
		
		socket.publish (
			track.createMessage (
				FileWriteRequest( 0, bytesToFile, true ),
				(Message<FileWriteResponse, FileWriteRequest> msg) {
					context.assertThat (
						msg.body.totalBytes, EqualTo( totalBytes ), "number of first written bytes", true
					);
					msg.reply (
						track.createMessage (
							FileWriteRequest( totalBytes, bytesToFile, true ),
							(Message<FileWriteResponse, FileWriteRequest> msg) {
								context.assertThat (
									msg.body.totalBytes, EqualTo( totalBytes ), "number of second written bytes", true
								);
								readFromFile( context, track, socket );
							},
							(Throwable err) {
								context.fail( err, "second file write" );
								context.complete();
							}
						)
					);
				},
				(Throwable err) {
					context.fail( err, "first file write" );
					context.complete();
				}
			)
		);
		
	}
	
	
	shared test void fileWriteAndRead( AsyncTestContext context ) {
		"Test is not correctly initialized."
		assert( exists track = station.track );
		
		context.start();
		
		track.connect<Nothing, FileMessage, FileAddress> (
			fileAddress
		).onComplete (
			writeToFile( context ),
			(Throwable err) {
				context.fail(err, "``fileAddress`` connection");
				context.complete();
			}
		);
	}
	
}
