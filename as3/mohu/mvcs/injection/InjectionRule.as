package mohu.mvcs.injection {

	/**
	 * @author Tim Kendrick
	 */
	public class InjectionRule implements IInjectionRule {

		private var _suppliedClass:Class;
		private var _singleton:Boolean;
		private var _instance:*;

		public function InjectionRule(suppliedClass:Class , singleton:Boolean , instance:* = null) {	
			_singleton = singleton;
			_suppliedClass = suppliedClass;
			_instance = instance;
		}
		
		public function createInstance():* {
			var instance:* = _instance || new _suppliedClass();
			if (_singleton) _instance = instance;
			return instance;
		}
		
		public function get instance():* {
			return _instance;
		}
	}
}
