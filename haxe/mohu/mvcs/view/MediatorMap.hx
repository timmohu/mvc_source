package mohu.mvcs.view;

import mohu.messages.Message;

import mohu.mvcs.injection.IInjector;

import mohu.mvcs.view.IContextView;
import mohu.mvcs.view.Mediator;

/**
 * ...
 * @author Tim Kendrick
 */

class MediatorMap {
	
	private var _contextView:IContextView;
	private var _injector:IInjector;
	private var _viewComponentMetadataTag:String;
	private var _mapSubclasses:Bool;
	
	private var _mediatorMappings:Array<MediatorMapping>;
	private var _activeMediators:Array<ActiveMediator>;
	
	public function new(contextView:IContextView, injector:IInjector, viewComponentMetadataTag:String, ?mapSubclasses:Bool = true) {
		_contextView = contextView;
		_injector = injector;
		_viewComponentMetadataTag = viewComponentMetadataTag;
		_mapSubclasses = mapSubclasses;
		
		_mediatorMappings = new Array<MediatorMapping>();
		_activeMediators = new Array<ActiveMediator>();
		
		_contextView.onViewAdded.addListener(handleViewAdded);
		_contextView.onViewRemoved.addListener(handleViewRemoved);
	}
	
	public function mapMediator(viewControllerClass:Class<IViewController>, mediatorClass:Class<Mediator>, ?autoCreate:Bool = true, ?autoRemove:Bool = true):Void {
		if (viewControllerClass == null) throw "No view class specified";
		if (mediatorClass == null) throw "No mediator class specified";
		for (mediatorMapping in _mediatorMappings) if (mediatorMapping.viewControllerClass == viewControllerClass) throw "View class " + Type.getClassName(viewControllerClass) + " is already mapped to " + Type.getClassName(mediatorMapping.mediatorClass);
		var mediatorMapping:MediatorMapping = {viewControllerClass: viewControllerClass, mediatorClass: mediatorClass, autoCreate: autoCreate, autoRemove: autoRemove};
		_mediatorMappings.push(mediatorMapping);
	}
	
	public function unmapMediator(viewControllerClass:Class<IViewController>):Void {
		if (viewControllerClass == null) throw "No view class specified";
		var i:Int = -1;
		while (++i < _mediatorMappings.length) {
			if (_mediatorMappings[i].viewControllerClass != viewControllerClass) continue;
			_mediatorMappings.splice(i, 1);
			break;
		}
	}
	
	public function hasMediatorClass(viewControllerClass:Class<IViewController>):Bool {
		if (viewControllerClass == null) throw "No view controller class specified";
		for (mediatorMapping in _mediatorMappings) if (mediatorMapping.viewControllerClass == viewControllerClass) return true;
		return false;
	}
	
	public function getMediatorClass(viewControllerClass:Class<IViewController>):Class<Mediator>{
		if (viewControllerClass == null) throw "No view controller class specified";
		for (mediatorMapping in _mediatorMappings) if (mediatorMapping.viewControllerClass == viewControllerClass) return mediatorMapping.mediatorClass;
		return null;
	}
	
	public function createMappedMediator(viewController:IViewController, ?autoRemove:Bool = true):Mediator {
		if (viewController == null) throw "No view controller specified";
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) throw "View controller " + Type.getClassName(Type.getClass(viewController)) + " is already being mediated by " +  Type.getClassName(Type.getClass(activeMediator.mediator));
		var viewControllerClass:Class<IViewController> = Type.getClass(viewController);
		for (mediatorMapping in _mediatorMappings) {
			if (!(mediatorMapping.viewControllerClass == viewControllerClass) && !(_mapSubclasses && Std.is(viewController, mediatorMapping.viewControllerClass))) continue;
			return createMediator(viewController, mediatorMapping.mediatorClass, mediatorMapping.autoRemove);
		}
		throw "Unable to find a mediatior mapping for view class " + Type.getClassName(viewControllerClass);
		return null;
	}

	public function createMediator(viewController:IViewController, mediatorClass:Class<Mediator>, ?autoRemove:Bool = true):Mediator {
		if (viewController == null) throw "No view controller specified";
		if (mediatorClass == null) throw "No mediator class specified";
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) throw "View controller " + Type.getClassName(Type.getClass(viewController)) + " is already being mediated by " +  Type.getClassName(Type.getClass(activeMediator.mediator));
		var mediator:Mediator = Type.createInstance(mediatorClass, []);
		return registerMediator(viewController, mediator, autoRemove);
	}
	
	public function registerMediator(viewController:IViewController, mediator:Mediator, ?autoRemove:Bool = true):Mediator {
		if (viewController == null) throw "No view controller specified";
		if (mediator == null) throw "No mediator specified";
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) throw "View controller " + Type.getClassName(Type.getClass(viewController)) + " is already being mediated by " +  Type.getClassName(Type.getClass(activeMediator.mediator));
		var activeMediator:ActiveMediator = {viewController:viewController, mediator: mediator, autoRemove:autoRemove};
		_activeMediators.push(activeMediator);
		_injector.mapMetadataInstance(_viewComponentMetadataTag, viewController);
		_injector.injectInto(mediator, false);
		_injector.unmapMetadata(_viewComponentMetadataTag);
		mediator.onRegister();
		return mediator;
	}
	
	public function removeMediator(viewController:IViewController):Mediator {
		if (viewController == null) throw "No view controller specified";
		var i:Int = -1;
		while (++i < _activeMediators.length) {
			var activeMediator:ActiveMediator = _activeMediators[i];
			if (activeMediator.viewController != viewController) continue;
			_activeMediators.splice(i, 1);
			activeMediator.mediator.onRemove();
			return activeMediator.mediator;
		}
		return null;
	}

	public function hasMediator(viewController:IViewController):Bool {
		if (viewController == null) throw "No view controller specified";
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) return true;
		return false;
	}
	
	public function getMediator(viewController:IViewController):Mediator{
		if (viewController == null) throw "No view controller specified";
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) return activeMediator.mediator;
		return null;
	}
	
	private function handleViewAdded(message:Message):Void {
		var viewController:IViewController = message.target;
		for (activeMediator in _activeMediators) if (activeMediator.viewController == viewController) return;
		var viewControllerClass:Class<IViewController> = Type.getClass(viewController);
		for (mediatorMapping in _mediatorMappings) {
			if (!(mediatorMapping.viewControllerClass == viewControllerClass) && !(_mapSubclasses && Std.is(viewController, mediatorMapping.viewControllerClass))) continue;
			if (mediatorMapping.autoCreate) createMediator(viewController, mediatorMapping.mediatorClass, mediatorMapping.autoRemove);
			break;
		}
		return;
	}

	private function handleViewRemoved(message:Message):Void {
		var viewController:IViewController = message.target;
		for (activeMediator in _activeMediators) {
			if (activeMediator.viewController != viewController) continue;
			if (activeMediator.autoRemove) removeMediator(message.currentTarget);
			return;
		}
	}
	
}

private typedef MediatorMapping = {
	
	var viewControllerClass:Class<IViewController>;
	var mediatorClass:Class<Mediator>;
	var autoCreate:Bool;
	var autoRemove:Bool;
	
}

private typedef ActiveMediator = {
	
	var viewController:IViewController;
	var mediator:Mediator;
	var autoRemove:Bool;
	
}