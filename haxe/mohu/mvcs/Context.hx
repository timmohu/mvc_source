package mohu.mvcs;

import mohu.mvcs.controller.CommandMap;

import mohu.mvcs.injection.IInjector;
import mohu.mvcs.injection.Injector;

import mohu.mvcs.view.IContextView;
import mohu.mvcs.view.MediatorMap;

/**
 * ...
 * @author Tim Kendrick
 */

class Context implements haxe.rtti.Infos {
	
	private static inline var INJECT_CONTEXT_METADATA_TAG:String = "context";
	private static inline var INJECT_HUB_METADATA_TAG:String = "hub";
	private static inline var INJECT_VIEW_COMPONENT_METADATA_TAG:String = "view";
	private static inline var INJECT_MESSAGE_METADATA_TAG:String = "message";
	
	public var hub(default, null):Hub;
	public var injector(default, null):IInjector;
	public var mediatorMap(default, null):MediatorMap;
	public var commandMap(default, null):CommandMap;
	
	public function new(hub:Hub, ?contextView:IContextView = null, ?injector:IInjector = null) {
		this.hub = hub;
		this.injector = (injector == null ? new Injector() : injector);
		this.mediatorMap = new MediatorMap(contextView, this.injector, INJECT_VIEW_COMPONENT_METADATA_TAG);
		this.commandMap = new CommandMap(this.injector, INJECT_MESSAGE_METADATA_TAG);
		
		if (!this.injector.hasMetadataMapping(INJECT_CONTEXT_METADATA_TAG)) this.injector.mapMetadataInstance(INJECT_CONTEXT_METADATA_TAG, this);
		if (!this.injector.hasMetadataMapping(INJECT_HUB_METADATA_TAG)) this.injector.mapMetadataInstance(INJECT_HUB_METADATA_TAG, this.hub);
		if (!this.injector.hasClassMapping(IInjector)) this.injector.mapClassInstance(IInjector, this.injector);
	}
	
}