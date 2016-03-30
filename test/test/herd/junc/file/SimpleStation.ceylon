import herd.junc.api {
	Junc,
	JuncTrack,
	Station,
	Promise
}
import herd.junc.file.station {
	FileStation
}


class SimpleStation() satisfies Station
{
	variable Junc? juncCache = null;
	variable JuncTrack? trackCache = null;
	
	shared Junc? junc => juncCache;
	shared JuncTrack? track => trackCache;
	
	
	shared actual Promise<Object> start( JuncTrack track, Junc junc ) {
		juncCache = junc;
		trackCache = track;
		return junc.deployStation( FileStation(), track.context );
	}
	
}
