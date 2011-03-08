package mohu.mvcs.view;

import mohu.mvcs.Context;

import mohu.mvcs.injection.IInjectable;
import mohu.mvcs.injection.IInjector;

/**
 * ...
 * @author Tim Kendrick
 */

class Mediator implements IInjectable {
	
	@inject("view") public var viewController(default, default):IViewController;
	
	@inject("context") public var context:Context;
	
	@inject public var injector:IInjector;
	
	public function onRegister():Void {
		
	}
	
	public function onRemove():Void {
		
	}
	
}