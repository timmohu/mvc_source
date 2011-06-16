package mohu.mvcs.injection;

public interface IInjector {

	public Object mapClassInstance(Class<?> requestedClass, Object instance);
	
	public void mapClass(Class<?> requestedClass);
	
	public void mapClass(Class<?> requestedClass, Class<?> suppliedClass);

	public void mapClassSingleton(Class<?> requestedClass);
	
	public void mapClassSingleton(Class<?> requestedClass, Class<?> suppliedClass);
	
	public void mapClassRule(Class<?> requestedClass, IInjectionRule rule);

	public boolean unmapClass(Class<?> requestedClass);

	public boolean hasClassMapping(Class<?> requestedClass);

	public Object getClassInstance(Class<?> requestedClass);

	public void mapMetadataInstance(String tag, Object instance);

	public void mapMetadataClass(String tag, Class<?> suppliedClass);
	
	public void mapMetadataSingleton(String tag, Class<?> suppliedClass);
	
	public void mapMetadataRule(String tag, IInjectionRule rule);

	public boolean unmapMetadata(String tag);
	
	public boolean hasMetadataMapping(String tag);
	
	public Object getMetadataInstance(String tag);

	public Object injectInto(Object instance);

	public Object injectInto(Object instance, boolean register);
}
