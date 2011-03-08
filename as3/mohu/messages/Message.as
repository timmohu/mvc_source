package mohu.messages {
	import flash.errors.IllegalOperationError;

	/**
	 * @author Tim Kendrick
	 */

	
	public class Message {
		
		internal var _dispatcher:Dispatcher;
		internal var _target:*;
		internal var _currentTarget:*;
		
		public function Message () {
			super();
		}
		
		public function clone():Message {
			if ((this as Object).constructor != Message) throw new IllegalOperationError("All Message subclasses must override the clone() method");
			return new Message();
		}
		
		public function get dispatcher():Dispatcher {
			return _dispatcher;
		}
		
		public function get target():* {
			return _target;
		}
		
		public function get currentTarget():* {
			return _currentTarget;
		}
		
	}
	
}
