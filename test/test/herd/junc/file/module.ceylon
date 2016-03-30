import ceylon.test {

	testExecutor
}
import herd.asynctest {

	AsyncTestExecutor
}


testExecutor( `class AsyncTestExecutor` )
native("jvm")
module test.herd.junc.file "0.1.0" {
	shared import herd.junc.api "0.1.0";
	shared import ceylon.test "1.2.2";
	shared import herd.asynctest "0.5.1";
	shared import herd.junc.core "0.1.0";
	shared import herd.junc.file.station "0.1.0";
	shared import herd.junc.file.data "0.1.0";
}
