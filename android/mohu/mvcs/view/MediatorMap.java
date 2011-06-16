package mohu.mvcs.view;

import java.util.HashMap;
import java.util.HashSet;

import mohu.messages.Message;
import mohu.messages.MessageHandler;
import mohu.mvcs.injection.IInjector;


public class MediatorMap extends MessageHandler {
	
	private IInjector _injector;
	
	private HashMap<Class<? extends IView>, Class<? extends Mediator>> _mediatorMap;
	private HashMap<IView, Mediator> _activeMediators;
	private HashSet<Class<? extends Mediator>> _autoRemoveMediators;
	
	public MediatorMap(IInjector injector) {
		_injector = injector;
		
		_mediatorMap = new HashMap<Class<? extends IView>, Class<? extends Mediator>>();
		_activeMediators = new HashMap<IView, Mediator>();
	}
	
	public void mapView(Class<? extends IView> viewClass, Class<? extends Mediator> mediatorClass) {
		this.mapView(viewClass, mediatorClass, true);
	}
	
	public void mapView(Class<? extends IView> viewClass, Class<? extends Mediator> mediatorClass, boolean autoRemove) {
		if (viewClass == null) throw new NullPointerException("No view class specified");
		if (mediatorClass == null) throw new NullPointerException("No mediator class specified");
		if (_mediatorMap.containsKey(viewClass)) throw new NullPointerException("View class " + viewClass.getName() + " is already mapped to " + _mediatorMap.get(viewClass).getName());
		_mediatorMap.put(viewClass, mediatorClass);
		if (autoRemove) _autoRemoveMediators.add(mediatorClass);
	}
	
	public boolean unmapView(Class<? extends IView> viewClass) {
		return (_mediatorMap.remove(viewClass) != null);
	}

	public boolean hasMediator(Class<? extends IView> viewClass) {
		return (_mediatorMap.containsKey(viewClass));
	}
	
	public Mediator createMediator(IView viewComponent, Class<? extends Mediator> mediatorClass) {
		return this.createMediator(viewComponent, mediatorClass, true);
	}
	public Mediator createMediator(IView viewComponent, Class<? extends Mediator> mediatorClass, boolean autoRemove) {
		if (_activeMediators.containsKey(viewComponent)) throw new IllegalArgumentException("View component " + viewComponent + " is already being mediated by " + _activeMediators.get(viewComponent));
		Mediator mediator;
		try {
			mediator = mediatorClass.newInstance();
		} catch (Exception e) {
			throw new RuntimeException("Failed to instantiate class " + mediatorClass);
		}
		return this.registerMediator(viewComponent, mediator, autoRemove);
	}
	
	public Mediator registerMediator(IView viewComponent, Mediator mediator) {
		return this.registerMediator(viewComponent, mediator, true);
	}
	
	public Mediator registerMediator(IView viewComponent, Mediator mediator, boolean autoRemove) {
		if (viewComponent == null) throw new NullPointerException("No view component specified");
		if (mediator == null) throw new NullPointerException("No mediator specified");
		if (_activeMediators.containsKey(viewComponent)) throw new NullPointerException("View component " + viewComponent + " is already being mediated by " + _activeMediators.get(viewComponent));
		_activeMediators.put(viewComponent, mediator);
		if (autoRemove) viewComponent.onRemoved().addListener(this);
		_injector.mapClassInstance(IView.class, viewComponent);
		_injector.injectInto(mediator, false);
		_injector.unmapClass(IView.class);
		mediator.onRegister();
		return mediator;
	}

	public Mediator removeMediator(IView viewComponent) {
		Mediator mediator = _activeMediators.get(viewComponent);
		if (mediator == null) return null; 
		_activeMediators.remove(viewComponent);
		mediator.onRemove();
		return mediator;
	}

	@Override
	public void handle(Message message) {
		IView viewComponent = (IView)message.getCurrentTarget();
		viewComponent.onRemoved().removeListener(this);
		this.removeMediator(viewComponent);
	}

}
