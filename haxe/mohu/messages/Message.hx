package mohu.messages;

/**
 * ...
 * @author Tim Kendrick
 */

class Message {
	
	public var target(getTarget, null):Dynamic;
	public var currentTarget(getCurrentTarget, null):Dynamic;
	public var dispatcher(getDispatcher, null):Dynamic;

	private var _target:Dynamic;
	private var _currentTarget:Dynamic;
	private var _dispatcher:Dispatcher;
	
	public function new() {
		
	}
	
	public function clone():Message {
		if (Type.getClass(this) != Message) throw "All Message subclasses must override the clone() method";
		return new Message();
	}
	
	private function getTarget():Dynamic {
		return _target;
	}
	
	private function getCurrentTarget():Dynamic {
		return _currentTarget;
	}
	
	private function getDispatcher():Dispatcher{
		return _dispatcher;
	}
	
}