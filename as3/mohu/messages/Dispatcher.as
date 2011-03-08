package mohu.messages {
	import flash.utils.Dictionary;

	/**
	 * @author Tim Kendrick
	 */

	
	public class Dispatcher {
		
		private var _target:*;
		private var _listeners:Vector.<Function>;
		private var _runOnceListeners:Dictionary;
		
		public function Dispatcher(target:Object) {
			super();
			_target = target;
			_listeners = new Vector.<Function>();
			_runOnceListeners = new Dictionary(true);
		}
		
		public function addListener(listener:Function, runOnce:Boolean = false):void {
			if (_listeners.indexOf(listener) != -1) {
				if (_runOnceListeners[listener] && !runOnce) delete _runOnceListeners[listener];
				return;
			}
			_listeners.push(listener);
			if (runOnce) _runOnceListeners[listener] = true;
		}
		
		public function hasListener(listener:Function):Boolean {
			return (_listeners.indexOf(listener) != -1);
		}
		
		public function removeListener(listener:Function):void {
			if (_listeners.indexOf(listener) == -1) return;
			_listeners.splice(_listeners.indexOf(listener), 1);
			if (_runOnceListeners[listener]) delete _runOnceListeners[listener];
		}
		
		public function removeAllListeners ( ) : void {
			_listeners = new Vector.<Function>();
			_runOnceListeners = new Dictionary(true);
		}
		
		public function dispatch(message:Message = null, customTarget:Object = null):void {
			if (!message) message = new Message();
			if (_listeners.length == 0) return;
			var target:Object = customTarget || message.target;
			message = message.clone();
			message._target = target || _target;
			message._currentTarget = _target;
			message._dispatcher = this;
			for (var i:int = 0; i < _listeners.length; i++) {
				var listener:Function = _listeners[i];
				if (_runOnceListeners[listener]) {
					delete _runOnceListeners[listener];
					_listeners.splice(i--, 1);
				}
				listener(message);
			}
			return;
		}
		
		public function get listeners():Vector.<Function> {
			return listeners.concat();
		}
		
		public function get numListeners():int {
			return listeners.length;
		}
		
	}
	
}
