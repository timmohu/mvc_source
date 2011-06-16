package mohu.mvcs.injection;

public class InjectionRule implements IInjectionRule {

	private Class<?> _suppliedClass;
	private boolean _singleton;
	private Object _instance;

	public InjectionRule(Class<?> suppliedClass, boolean singleton) {	
		this(suppliedClass, singleton, null);
	}
	
	public InjectionRule(Class<?> suppliedClass, boolean singleton, Object instance) {	
		_singleton = singleton;
		_suppliedClass = suppliedClass;
		_instance = instance;
	}

	@Override
	public Object createInstance() {
		Object instance = _instance;
		if (instance == null) {
			try {
				instance = _suppliedClass.newInstance();
			} catch (Exception e) {
				throw new RuntimeException("Failed to instantiate class " + _suppliedClass);
			}
		}
		if (_singleton) _instance = instance;
		return instance;
	}

	@Override
	public Object getInstance() {
		return _instance;
	}

}
