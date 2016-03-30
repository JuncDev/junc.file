import herd.junc.api {
	Station,
	Promise,
	JuncTrack,
	Junc
}


"Station to operate with files."
by( "Lis" )
shared class FileStation (
	"Name of `Counter` used to monitor number of opened files."
	String fileCounterName = "files",
	"Name of write to storage meter.  Meter measures writing in bytes/s."
	String writeMeterName = "write to storage, bytes/s",
	"Name of read from storage meter.  Meter measures reading in bytes/s."
	String readMeterName = "read from storage, bytes/s",
	"Default size of buffer used in file read / write operations.  
	 Can be overriden using `FileAddress.bufferSize`."
	Integer defaultBufferSize = 1024
)
		satisfies Station
{
	shared actual Promise<Object> start( JuncTrack track, Junc junc ) {
		return track.registerConnector (
			FileConnector (
				junc, track, fileCounterName, writeMeterName, readMeterName, defaultBufferSize
			)
		);
	}
	
}
