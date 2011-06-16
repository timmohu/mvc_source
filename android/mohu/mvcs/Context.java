package mohu.mvcs;

import mohu.mvcs.controller.CommandMap;
import mohu.mvcs.injection.IInjector;
import mohu.mvcs.injection.Injector;
import mohu.mvcs.view.MediatorMap;

public class Context {
	
	private Hub _hub;
	
	private IInjector _injector;

	private MediatorMap _mediatorMap;

	private CommandMap _commandMap;

	public Context(Hub hub) {
		this(hub, null);
	}
	
	public Context(Hub hub, IInjector injector) {
		_hub = hub;
		
		_injector = (injector != null ? injector : new Injector());

		_mediatorMap = new MediatorMap(_injector);

		_commandMap = new CommandMap(_injector);
		
		if (!_injector.hasClassMapping(Context.class)) _injector.mapClassInstance(Context.class, this);
		if (!_injector.hasClassMapping(this.getClass())) _injector.mapClassInstance(this.getClass(), this);

		if (!_injector.hasClassMapping(Hub.class)) _injector.mapClassInstance(Hub.class, _hub);
		if (!_injector.hasClassMapping(hub.getClass())) _injector.mapClassInstance(hub.getClass(), _hub);
		
		if (!_injector.hasClassMapping(IInjector.class)) _injector.mapClassInstance(IInjector.class, _injector);
	}
	
	public IInjector getInjector() {
		return _injector;
	}
	
	public MediatorMap getMediatorMap() {
		return _mediatorMap;
	}
	
	public CommandMap getCommandMap() {
		return _commandMap;
	}
	
	public Hub getHub() {
		return _hub;
	}
}
