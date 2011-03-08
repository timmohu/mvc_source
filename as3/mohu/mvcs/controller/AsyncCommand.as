package mohu.mvcs.controller {
	import mohu.messages.Dispatcher;
	import flash.utils.Dictionary;
	import mohu.mvcs.controller.Command;
	
	/**
	 * @author Tim Kendrick
	 */
	public class AsyncCommand extends Command {
		
		private static const ACTIVE_COMMANDS:Dictionary = new Dictionary(false);
		
		private var _onCompleted:Dispatcher;
		
		public function AsyncCommand() {
			_onCompleted = new Dispatcher(this);
			_onCompleted.addListener(_handleCompleted);
			
			ACTIVE_COMMANDS[this] = true;
		}

		private function _handleCompleted():void {
			delete ACTIVE_COMMANDS[this];
		}

		public function get onCompleted():Dispatcher {
			return _onCompleted;
		}
	}
}
