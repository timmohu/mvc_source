package mohu.mvcs.controller;

import mohu.messages.Message;

import mohu.mvcs.Context;

import mohu.mvcs.injection.IInjectable;
import mohu.mvcs.injection.IInjector;

/**
 * ...
 * @author Tim Kendrick
 */

class Command implements IInjectable {

	@inject("message") public var message:Message;
	
	@inject("context") public var context:Context;
	
	@inject public var injector:IInjector;
	
	public function onRegister():Void {
		
	}
	
	public function execute():Void {
		
	}
	
}