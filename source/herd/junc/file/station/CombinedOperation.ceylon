
"combination of file operations - several operations performed simultaneously"
by( "Lis" )
class CombinedOperation() extends FileOperation() 
{
	class OperationItem( shared FileOperation operation ) {
		shared variable OperationItem? next = null;
		shared variable OperationItem? previous = null;
	}
	
	variable OperationItem? head = null;
	
	
	shared void combine( FileOperation operation ) {
		OperationItem item = OperationItem( operation );
		item.next = head;
		if ( exists h = head ) { h.previous = item; }
		head = item;
	}
	
	shared actual Boolean perform() {
		variable OperationItem? h = head;
		while ( exists item = h ) {
			h = item.next;
			if ( item.operation.perform() ) {
				// operation completed - remove it
				if ( exists prev = item.previous ) {
					 prev.next = item.next;
					 if ( exists next = item.next ) {
					 	next.previous = prev;
					 }
				}
				else if ( exists next = item.next ) {
					next.previous = null;
					head = next;
				}
				else {
					head = null;
				}
			}
		}
		return !head exists;
	}
	
}
