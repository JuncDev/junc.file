import herd.junc.core {

	MetricWriter,
	MetricSet
}


class MetricWriterImpl() satisfies MetricWriter {
	
	shared actual void writeMetric( MetricSet metrics ) {		
		print( "\nMetric at timestamp ``system.milliseconds``" );
		print( "GAUGES:" );
		for ( gauge in metrics.gauges ) {
			print( "``gauge.name`` = ``gauge.measure() else "<null>"``" );
		}
		print( "COUNTERS:" );
		for ( counter in metrics.counters ) {
			print( "``counter.name`` = ``counter.measure()``" );
		}
		print( "AVERAGES:" );
		for ( average in metrics.averages ) {
			print( "``average.name`` = ``formatFloat( average.measure(), 2, 2 )``" );
		}
		print( "METERS:" );
		for ( meter in metrics.meters ) {
			print( "``meter.name`` = ``formatFloat( meter.measure(), 2, 2 )``" );
		}
		print( "" );
	}
	
}
