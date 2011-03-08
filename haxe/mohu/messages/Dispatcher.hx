package mohu.messages;

/**
 * @author Tim Kendrick
 */

class Dispatcher {
	
	public var target(getTarget, setTarget):Dynamic;
	public var listeners(getListeners, null):Array<Message->Void>;
	public var numListeners(getNumListeners, null):Int;
	
	private var _target:Dynamic;
	private var _listeners:Array<ListenerMapping>;

	public function new(target:Dynamic) {
		_target = target;
		_listeners = new Array<ListenerMapping>();
	}
	
	public function addListener(listener:Message->Void, ?runOnce:Bool = false):Void {
		if (listener == null) throw "No listener specified";
		for (listenerMapping in _listeners) {
			if (!Reflect.compareMethods(listenerMapping.listener, listener)) continue;
			if (listenerMapping.runOnce && !runOnce) listenerMapping.runOnce = false;
			return;
		}
		var listenerMapping:ListenerMapping = {listener: listener, runOnce: runOnce};
		_listeners.push(listenerMapping);
	}
	
	public function hasListener(listener:Message->Void):Bool {
		if (listener == null) throw "No listener specified";
		for (listenerMapping in _listeners) if (Reflect.compareMethods(listenerMapping.listener, listener)) return true;
		return false;
	}
	
	public function removeListener(listener:Message->Void):Void {
		if (listener == null) throw "No listener specified";
		var i:Int = -1;
		while (++i < _listeners.length) {
			if (!Reflect.compareMethods(_listeners[i].listener, listener)) continue;
			_listeners.splice(i--, 1);
			return;
		}
	}
	
	public function removeAllListeners():Void {
		_listeners = new Array<ListenerMapping>();
	}
	
	public function dispatch(?message:Message, ?customTarget:Dynamic):Void {
		if (_listeners.length == 0) return;
		if (message == null) message = new Message();
		var newMessage:DynamicMessage = message.clone();
		newMessage._target = (customTarget ? customTarget : (message.target ? message.target : _target));
		newMessage._currentTarget = _target;
		newMessage._dispatcher = this;
		var i:Int = -1;
		while (++i < _listeners.length) {
			var listenerMapping:ListenerMapping = _listeners[i];
			if (listenerMapping.runOnce) _listeners.splice(i--, 1);
			listenerMapping.listener(cast(newMessage, Message));
		}
		return;
	}
	
	public function redispatch(message:Message):Void {
		dispatch(message);
	}
	
	private function getTarget():Dynamic {
		return _target;
	}
	
	private function setTarget(value:Dynamic):Dynamic {
		return _target = value;
	}
		
	private function getListeners():Array<Message->Void> {
		var listeners:Array<Message->Void> = new Array<Message->Void>();
		for (listener in _listeners) listeners.push(listener.listener);
		return listeners;
	}
	
	public function getNumListeners():Int {
		return _listeners.length;
	}
	
}

private typedef ListenerMapping = {
	
	var listener:Message->Void;
	var runOnce:Bool;
	
}

private typedef DynamicMessage = {
	
	var target(getTarget, null):Dynamic;
	var currentTarget(getCurrentTarget, null):Dynamic;
	var dispatcher(getDispatcher, null):Dispatcher;
	
	private var _target:Dynamic;
	private var _currentTarget:Dynamic;
	private var _dispatcher:Dispatcher;
	
}