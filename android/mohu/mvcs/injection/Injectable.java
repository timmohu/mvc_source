package mohu.mvcs.injection;


public class Injectable implements IInjectable {

	private IInjector _injector;

	public Injectable() {
		
	}

	@Override
	public void onRegister() {
		
	}

	public IInjector getInjector() {
		return _injector;
	}

	public IInjector setInjector(IInjector injector) {
		return _injector = injector;
	}

}
