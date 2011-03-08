package mohu.mvcs {
	import mohu.mvcs.controller.CommandMap;
	import mohu.mvcs.injection.IInjector;
	import mohu.mvcs.injection.Injector;
	import mohu.mvcs.view.MediatorMap;

	import flash.display.DisplayObjectContainer;

	/**
	 * @author Tim Kendrick
	 */
	public class Context {

		private static const INJECT_CONTEXT_METADATA_TAG:String = "context";
		private static const INJECT_HUB_METADATA_TAG:String = "hub";
		private static const INJECT_VIEW_COMPONENT_METADATA_TAG:String = "view";
		private static const INJECT_MESSAGE_METADATA_TAG:String = "message";
		
		private var _hub:Hub;
		
		private var _injector:IInjector;

		private var _mediatorMap:MediatorMap;

		private var _commandMap:CommandMap;

		public function Context(hub:Hub, contextView:DisplayObjectContainer = null, injector:IInjector = null) {
			_hub = hub;
			
			_injector = injector || new Injector();

			_mediatorMap = new MediatorMap(contextView, _injector, INJECT_VIEW_COMPONENT_METADATA_TAG);

			_commandMap = new CommandMap(_injector, INJECT_MESSAGE_METADATA_TAG);
			
			if (!_injector.hasMetadataMapping(INJECT_CONTEXT_METADATA_TAG)) _injector.mapMetadataInstance(INJECT_CONTEXT_METADATA_TAG, this);

			if (!_injector.hasMetadataMapping(INJECT_HUB_METADATA_TAG)) _injector.mapMetadataInstance(INJECT_HUB_METADATA_TAG, _hub);
			
			if (!_injector.hasClassMapping(IInjector)) _injector.mapClassInstance(IInjector, _injector);
		}
		
		public function get injector():IInjector {
			return _injector;
		}
		
		public function get mediatorMap():MediatorMap {
			return _mediatorMap;
		}
		
		public function get commandMap():CommandMap {
			return _commandMap;
		}
		
		public function get contextView():DisplayObjectContainer {
			return _mediatorMap.contextView;
		}
		
		public function set contextView(value:DisplayObjectContainer):void {
			_mediatorMap.contextView = value;
		}
		
		public function get hub():Hub {
			return _hub;
		}
	}
}
