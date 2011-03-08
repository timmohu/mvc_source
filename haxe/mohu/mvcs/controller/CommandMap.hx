package mohu.mvcs.controller;

import mohu.messages.Dispatcher;
import mohu.messages.Message;

import mohu.mvcs.injection.IInjector;

/**
 * ...
 * @author Tim Kendrick
 */

class CommandMap {

	private var _injector:IInjector;
	private var _messageMetadataTag:String;
	
	private var _commandMappings:Array<CommandMapping>;
	
	public function new(injector:IInjector, messageMetadataTag:String) {
		_injector = injector;
		_messageMetadataTag = messageMetadataTag;
		
		_commandMappings = new Array<CommandMapping>();
	}
	
	public function hasCommand(dispatcher:Dispatcher, command:Class<Command>):Bool {
		if (dispatcher == null) throw "No dispatcher specified";
		if (command == null) throw "No command specified";
		for (commandMapping in _commandMappings) if ((commandMapping.dispatcher == dispatcher) && (commandMapping.command == command)) return true;
		return false;
	}
	
	public function mapCommand(dispatcher:Dispatcher, command:Class<Command>, ?runOnce:Bool = false):Void {
		if (dispatcher == null) throw "No dispatcher specified";
		if (command == null) throw "No command specified";
		for (commandMapping in _commandMappings) {
			if ((commandMapping.dispatcher != dispatcher) || (commandMapping.command != command)) continue;
			if (commandMapping.runOnce && !runOnce) commandMapping.runOnce = false;
			return;
		}
		var commandMapping:CommandMapping = {dispatcher: dispatcher, command: command, runOnce: runOnce};
		_commandMappings.push(commandMapping);
		dispatcher.addListener(handleMessageDispatched);
	}
	
	public function unmapCommand(dispatcher:Dispatcher, command:Class<Command>):Void {
		if (dispatcher == null) throw "No dispatcher specified";
		if (command == null) throw "No command specified";
		var i:Int = -1;
		while (i < _commandMappings.length) {
			var commandMapping:CommandMapping = _commandMappings[++i];
			if ((commandMapping.dispatcher != dispatcher) || (commandMapping.command != command)) continue;
			_commandMappings.splice(i, 1);
			commandMapping.dispatcher.removeListener(handleMessageDispatched);
			return;
		}
	}
	
	private function handleMessageDispatched(message:Message):Void {
		var dispatcher:Dispatcher = message.dispatcher;
		var commands:Array<Command> = new Array<Command>();
		
		_injector.mapMetadataInstance(_messageMetadataTag, message);
		for (commandMapping in _commandMappings) {
			if (commandMapping.dispatcher != dispatcher) continue;
			var command:Command = Type.createInstance(commandMapping.command, []);
			_injector.injectInto(command);
			commands.push(command);
		}
		_injector.unmapMetadata(_messageMetadataTag);
		
		for (command in commands) {
			command.onRegister();
			command.execute();
		}
	}
	
}

typedef CommandMapping = {
	
	var dispatcher:Dispatcher;
	var command:Class<Command>;
	var runOnce:Bool;
	
}