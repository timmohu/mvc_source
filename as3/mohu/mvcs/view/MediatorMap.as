package mohu.mvcs.view {
	import mohu.mvcs.injection.IInjector;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Tim Kendrick
	 */
	public class MediatorMap {

		public var viewComponentMetadataTag:String;
		public var mapSubclasses:Boolean;

		private var _injector:IInjector;

		private var _contextView:DisplayObjectContainer;

		private var _mediatorMap:Dictionary;
		private var _activeMediators:Dictionary;

		public function MediatorMap(contextView:DisplayObjectContainer, injector:IInjector, viewComponentMetadataTag:String, mapSubclasses:Boolean = true) {
			_injector = injector;
			
			this.viewComponentMetadataTag = viewComponentMetadataTag;
			this.mapSubclasses = mapSubclasses;

			_mediatorMap = new Dictionary(true);
			_activeMediators = new Dictionary(true);

			this.contextView = contextView;
		}

		public function mapView(viewClass:Class, mediatorClass:Class, autoCreate:Boolean = true, autoRemove:Boolean = true):void {
			if (!viewClass) throw new ArgumentError("No view class specified");
			if (!mediatorClass) throw new ArgumentError("No mediator class specified");
			if (_mediatorMap[viewClass]) throw new ArgumentError("View class " + getQualifiedClassName(viewClass) + " is already mapped to " + getQualifiedClassName(_mediatorMap[viewClass].mediatorClass));
			_mediatorMap[viewClass] = new MediatorMapping(mediatorClass, autoCreate, autoRemove);
		}
		
		public function unmapView(viewClass:Class):void {
			delete _mediatorMap[viewClass];
		}

		public function hasMediator(viewClass:Class):Boolean {
			return (_mediatorMap[viewClass] != null);
		}

		public function createMediator(viewComponent:DisplayObject, mediatorClass:Class, autoRemove:Boolean = true):Mediator {
			if (_activeMediators[viewComponent]) throw new ArgumentError("View component " + viewComponent + " is already being mediated by " + _activeMediators[viewComponent]);
			var mediator:Mediator = new mediatorClass();
			registerMediator(viewComponent, mediator, autoRemove);
			return mediator;
		}

		public function registerMediator(viewComponent:DisplayObject, mediator:Mediator, autoRemove:Boolean = true):void {
			if (!viewComponent) throw new ArgumentError("No view component specified");
			if (!mediator) throw new ArgumentError("No mediator specified");
			if (_activeMediators[viewComponent]) throw new ArgumentError("View component " + viewComponent + " is already being mediated by " + _activeMediators[viewComponent]);
			_activeMediators[viewComponent] = mediator;
			if (autoRemove) viewComponent.addEventListener(Event.REMOVED_FROM_STAGE, onAutoRemove, false, 0, true);
			_injector.mapMetadataInstance(viewComponentMetadataTag, viewComponent);
			_injector.injectInto(mediator, false);
			_injector.unmapMetadata(viewComponentMetadataTag);
			mediator.onRegister();
		}
		
		private function onAutoRemove(event:Event):void {
			event.currentTarget.removeEventListener(Event.REMOVED_FROM_STAGE, onAutoRemove, true);
			removeMediator(event.currentTarget as DisplayObject);
		}

		public function removeMediator(viewComponent:DisplayObject):Mediator {
			var mediator:Mediator = _activeMediators[viewComponent];
			if (!mediator) return null; 
			delete _activeMediators[viewComponent];
			mediator.onRemove();
			return mediator;
		}
		
		public function getMediator(viewComponent:DisplayObject):Mediator {
			return _activeMediators[viewComponent];
		}

		public function hasMediatorForView(viewComponent:DisplayObject):Boolean {
			return _activeMediators[(viewComponent as Object).constructor];
		}

		public function get contextView():DisplayObjectContainer {
			return _contextView;
		}

		public function set contextView(value:DisplayObjectContainer):void {
			if (_contextView == value) return;
			if (_contextView) _contextView.removeEventListener(Event.ADDED_TO_STAGE, onAdded, true);
			_contextView = value;
			if (_contextView) _contextView.addEventListener(Event.ADDED_TO_STAGE, onAdded, true, 0, true);
		}
		
		private function onAdded(event:Event):void {
			var displayObject:DisplayObject = event.target as DisplayObject;
			if (_activeMediators[displayObject]) return;
			var viewClass:Class = (displayObject as Object).constructor as Class;
			var mediatorMapping:MediatorMapping = _mediatorMap[viewClass];
			if (!mediatorMapping && mapSubclasses) for (var superClass : * in _mediatorMap) if (displayObject is superClass) mediatorMapping = _mediatorMap[superClass];
			if (mediatorMapping && mediatorMapping.autoCreate) createMediator(event.target as DisplayObject, mediatorMapping.mediatorClass, mediatorMapping.autoRemove);
		}
	}
}
