package mohu.mvcs.injection;

/**
 * ...
 * @author Tim Kendrick
 */

class InjectionRule implements IInjectionRule {

	public var instance(getInstance, null):Dynamic;
	
	private var _suppliedClass:Class<Dynamic>;
	private var _singleton:Bool;
	private var _instance:Dynamic;
	
	public function new(suppliedClass:Class<Dynamic>, singleton:Bool, ?instance:Dynamic) {
		_suppliedClass = suppliedClass;
		_singleton = singleton;
		_instance = instance;
	}
	
	public function createInstance():Dynamic {
		var instance:Dynamic = (_instance != null ? _instance : Type.createInstance(_suppliedClass, []));
		if (_singleton) _instance = instance;
		return instance;
	}
	
	private function getInstance():Dynamic {
		return _instance;
	}
	
}