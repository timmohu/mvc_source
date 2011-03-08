package mohu.mvcs.controller {
	import mohu.messages.Message;
	import mohu.mvcs.Context;
	import mohu.mvcs.injection.IInjectable;
	import mohu.mvcs.injection.IInjector;

	/**
	 * @author Tim Kendrick
	 */
	public class Command implements IInjectable {

		[Inject("message")]
		public var message:Message;

		[Inject("context")]
		public var context:Context;

		[Inject]
		public var injector:IInjector;

		public function onRegister():void {
			
		}

		public function execute():void {
			
		}
	}
}
