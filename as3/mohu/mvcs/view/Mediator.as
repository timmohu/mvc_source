package mohu.mvcs.view {
	import mohu.mvcs.Context;
	import mohu.mvcs.injection.IInjectable;
	import mohu.mvcs.injection.IInjector;

	import flash.display.DisplayObject;

	/**
	 * @author Tim Kendrick
	 */
	public class Mediator implements IInjectable {

		[Inject("view")]
		public var viewComponent:DisplayObject;

		[Inject("context")]
		public var context:Context;

		[Inject]
		public var injector:IInjector;

		public function onRegister():void {
			
		}
		
		public function onRemove():void {
			
		}
		
	}
}
