
"astract operation with file - read or write, or combined (several operations performed simultaneously)"
by( "Lis" )
abstract class FileOperation() of CombinedOperation | ReadOperation | WriteOperation
{
	"Performs file operation.  Returns `true` if operation is completed and `false` otherwise"
	shared formal Boolean perform();
	
	shared variable FileOperation? next = null;
}
