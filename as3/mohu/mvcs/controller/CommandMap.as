package mohu.mvcs.controller {
	import mohu.messages.Dispatcher;
	import mohu.messages.Message;
	import mohu.mvcs.injection.IInjector;

	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Tim Kendrick
	 */
	public class CommandMap {

		private static const VERIFIED_COMMAND_CLASSES:Dictionary = new Dictionary();

		public var messageMetadataTag:String;

		private var _injector:IInjector;

		private var _commandMap:Dictionary;
		private var _runOnceCommands:Dictionary;

		public function CommandMap(injector:IInjector, messageMetadataTag:String) {

			this.messageMetadataTag = messageMetadataTag;

			_injector = injector;

			_commandMap = new Dictionary(true);
			_runOnceCommands = new Dictionary(true);
		}

		public function hasCommand(dispatcher:Dispatcher, command:Class):Boolean {
			return (_commandMap[dispatcher] && (_commandMap[dispatcher].indexOf(command) != -1));
		}
		
		public function mapCommand(dispatcher:Dispatcher, command:Class, runOnce:Boolean = false):void {
			if (!dispatcher) throw new ArgumentError("No dispatcher specified");
			if (!command) throw new ArgumentError("No command specified");
			if (VERIFIED_COMMAND_CLASSES[command] == null) VERIFIED_COMMAND_CLASSES[command] = (describeType(command).factory[0].extendsClass.(@type == getQualifiedClassName(Command)).length() != 0);
			if (!VERIFIED_COMMAND_CLASSES[command]) throw new ArgumentError("Specified command class does not extend Command");

			if (!_commandMap[dispatcher]) {
				_commandMap[dispatcher] = new Vector.<Class>();
				dispatcher.addListener(onDispatchMessage);
			}

			if (_commandMap[dispatcher].indexOf(command) == -1) _commandMap[dispatcher].push(command);

			if (!_runOnceCommands[dispatcher]) _runOnceCommands[dispatcher] = new Dictionary(true);
			if ((_runOnceCommands[dispatcher][command] == null) || (_runOnceCommands[dispatcher][command] && !runOnce)) _runOnceCommands[dispatcher][command] = runOnce;
		}
		
		public function unmapCommand(dispatcher:Dispatcher, command:Class):void {
			if (!dispatcher) throw new ArgumentError("No dispatcher specified");
			if (!command) throw new ArgumentError("No command specified");
			if (_commandMap[dispatcher].indexOf(command) == -1) return;

			_commandMap[dispatcher].splice(_commandMap[dispatcher].indexOf(command), 1);
			delete _runOnceCommands[dispatcher][command];

			if (_commandMap[dispatcher].length == 0) {
				delete _commandMap[dispatcher];
				delete _runOnceCommands[dispatcher];
				dispatcher.removeListener(onDispatchMessage);
			}
		}

		private function onDispatchMessage(message:Message):void {
			var dispatcher:Dispatcher = message.dispatcher;

			var commands:Vector.<Command> = new Vector.<Command>();
			_injector.mapMetadataInstance(messageMetadataTag, message);
			for each (var commandClass : Class in _commandMap[dispatcher]) {
				if (_runOnceCommands[dispatcher][commandClass]) unmapCommand(dispatcher, commandClass);
				var commandInstance:Command = new commandClass();
				_injector.injectInto(commandInstance, false);
				commands.push(commandInstance);
			}
			_injector.unmapMetadata(messageMetadataTag);
			
			for each (var command : Command in commands) {
				command.onRegister();
				command.execute();
			}
		}
	}
}
