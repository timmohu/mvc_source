package mohu.mvcs.injection;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.util.HashMap;

public class Injector implements IInjector {
	
	private HashMap<Class<?>, IInjectionRule> _injectionRules;
	private HashMap<String, IInjectionRule> _metadataInjectionRules;
	
	public Injector() {
		_injectionRules = new HashMap<Class<?>, IInjectionRule>();
		_metadataInjectionRules = new HashMap<String, IInjectionRule>();
	}

	@Override
	public Object mapClassInstance(Class<?> requestedClass, Object instance) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		if (instance == null) throw new NullPointerException("No instance specified");
		if (_injectionRules.containsKey(requestedClass)) throw new IllegalArgumentException("An injection mapping already exists for class " + requestedClass.getName());
		_injectionRules.put(requestedClass, new InjectionRule(instance.getClass(), true, instance));
		return instance;
	}

	@Override
	public void mapClass(Class<?> requestedClass) {
		this.mapClass(requestedClass, requestedClass);
	}

	@Override
	public void mapClass(Class<?> requestedClass, Class<?> suppliedClass) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		if (suppliedClass == null) throw new NullPointerException("No suppliedClass specified");
		if (_injectionRules.containsKey(requestedClass)) throw new IllegalArgumentException("An injection mapping already exists for class " + requestedClass.getName());
		_injectionRules.put(requestedClass, new InjectionRule(suppliedClass, false));

	}

	@Override
	public void mapClassSingleton(Class<?> requestedClass) {
		this.mapClassSingleton(requestedClass, requestedClass);
	}

	@Override
	public void mapClassSingleton(Class<?> requestedClass, Class<?> suppliedClass) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		if (suppliedClass == null) throw new NullPointerException("No suppliedClass specified");
		if (_injectionRules.containsKey(requestedClass)) throw new IllegalArgumentException("An injection mapping already exists for class " + requestedClass.getName());
		_injectionRules.put(requestedClass, new InjectionRule(suppliedClass, true));

	}

	@Override
	public void mapClassRule(Class<?> requestedClass, IInjectionRule rule) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		if (rule == null) throw new NullPointerException("No rule specified");
		if (_injectionRules.containsKey(requestedClass)) throw new IllegalArgumentException("An injection mapping already exists for class " + requestedClass.getName());
		_injectionRules.put(requestedClass, rule);
	}

	@Override
	public boolean unmapClass(Class<?> requestedClass) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		return (_injectionRules.remove(requestedClass) != null);
	}

	@Override
	public boolean hasClassMapping(Class<?> requestedClass) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		return _injectionRules.containsKey(requestedClass);
	}

	@Override
	public Object getClassInstance(Class<?> requestedClass) {
		if (requestedClass == null) throw new NullPointerException("No requestedClass specified");
		IInjectionRule rule = _injectionRules.get(requestedClass);
		if (rule == null) throw new IllegalArgumentException("No injection mapping specified for class " + requestedClass.getName());
		Object instance = rule.getInstance();
		if (instance != null) return instance;
		instance = rule.createInstance();
		if (instance instanceof IInjectable) this.injectInto((IInjectable)rule);
		return instance;
	}

	@Override
	public void mapMetadataInstance(String tag, Object instance) {
		if (tag == null) throw new NullPointerException("No tag specified");
		if (instance == null) throw new NullPointerException("No instance specified");
		if (_metadataInjectionRules.containsKey(tag)) throw new IllegalArgumentException("An injection mapping already exists for tag '" + tag + "'");
		_metadataInjectionRules.put(tag, new InjectionRule(instance.getClass(), true, instance));
	}

	@Override
	public void mapMetadataClass(String tag, Class<?> suppliedClass) {
		if (tag == null) throw new NullPointerException("No tag specified");
		if (suppliedClass == null) throw new NullPointerException("No suppliedClass specified");
		if (_metadataInjectionRules.containsKey(tag)) throw new IllegalArgumentException("An injection mapping already exists for tag '" + tag + "'");
		_metadataInjectionRules.put(tag, new InjectionRule(suppliedClass, false));
	}

	@Override
	public void mapMetadataSingleton(String tag, Class<?> suppliedClass) {
		if (tag == null) throw new NullPointerException("No tag specified");
		if (suppliedClass == null) throw new NullPointerException("No suppliedClass specified");
		if (_metadataInjectionRules.containsKey(tag)) throw new IllegalArgumentException("An injection mapping already exists for tag '" + tag + "'");
		_metadataInjectionRules.put(tag, new InjectionRule(suppliedClass, true));
	}

	@Override
	public void mapMetadataRule(String tag, IInjectionRule rule) {
		if (tag == null) throw new NullPointerException("No tag specified");
		if (rule == null) throw new NullPointerException("No rule specified");
		if (_metadataInjectionRules.containsKey(tag)) throw new IllegalArgumentException("An injection mapping already exists for tag '" + tag + "'");
		_metadataInjectionRules.put(tag, rule);
	}

	@Override
	public boolean unmapMetadata(String tag) {
		if (tag == null) throw new NullPointerException("No tag specified");
		return (_injectionRules.remove(tag) != null);
	}

	@Override
	public boolean hasMetadataMapping(String tag) {
		if (tag == null) throw new NullPointerException("No tag specified");
		return _metadataInjectionRules.containsKey(tag);
	}

	@Override
	public Object getMetadataInstance(String tag) {
		if (tag == null) throw new NullPointerException("No tag specified");
		IInjectionRule rule = _metadataInjectionRules.get(tag);
		if (rule == null) throw new IllegalArgumentException("No injection mapping specified for tag '" + tag + "'");	
		Object instance = rule.getInstance();
		if (instance != null) return instance;
		instance = rule.createInstance();
		if (instance instanceof IInjectable) this.injectInto((IInjectable)instance);
		return instance;
	}

	@Override
	public Object injectInto(Object instance) {
		return this.injectInto(instance, true);
	}

	@Override
	public Object injectInto(Object instance, boolean register) {
		for (Field field : instance.getClass().getFields()) {
			Annotation annotation = field.getAnnotation(Inject.class);
			if (annotation == null) continue;
			Inject injectAnnotation = (Inject)annotation;
			IInjectionRule rule = (injectAnnotation.value().length() == 0 ? _injectionRules.get(field.getType()) : _metadataInjectionRules.get(injectAnnotation.value()));
			Object value = rule.getInstance();
			if (value == null) value = this.injectInto(rule.createInstance());
			try {
				field.set(instance, value);
			} catch (Exception e) {
				throw new RuntimeException("Failed to inject into field " + field.getName() + " of class " + instance.getClass().getName());
			}
		}
		if (instance instanceof IInjectable) {
			((IInjectable)instance).setInjector(this);
			if (register) ((IInjectable)instance).onRegister();
		}
		return instance;
	}

}
