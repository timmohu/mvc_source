package mohu.mvcs.injection;

public interface IInjectable {
	
	public void onRegister();
	
	public IInjector getInjector();

	public IInjector setInjector(IInjector injector);
	
}
