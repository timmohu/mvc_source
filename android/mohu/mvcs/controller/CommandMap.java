package mohu.mvcs.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import mohu.messages.Dispatcher;
import mohu.messages.Message;
import mohu.messages.MessageHandler;
import mohu.mvcs.injection.IInjector;



public class CommandMap extends MessageHandler {
	
	private IInjector _injector;
	
	private HashMap<Dispatcher, ArrayList<Class<? extends Command>>> _commandMap;
	private HashMap<Dispatcher, HashSet<Class<? extends Command>>> _runOnceCommands;
	
	public CommandMap(IInjector injector) {

		_injector = injector;
		
		_commandMap = new HashMap<Dispatcher, ArrayList<Class<? extends Command>>>();
		_runOnceCommands = new HashMap<Dispatcher, HashSet<Class<? extends Command>>>();
	}
	
	public boolean hasCommand(Dispatcher dispatcher, Class<? extends Command> command) {
		return (_commandMap.containsKey(dispatcher) && (_commandMap.get(dispatcher).contains(command)));
	}
	
	public void mapCommand(Dispatcher dispatcher, Class<? extends Command> command) {
		this.mapCommand(dispatcher, command, false);
	}
	
	public void mapCommand(Dispatcher dispatcher, Class<? extends Command> command, boolean runOnce) {
		if (dispatcher == null) throw new NullPointerException("No dispatcher specified");
		if (command == null) throw new NullPointerException("No command specified");

		ArrayList<Class<? extends Command>> dispatcherCommands = _commandMap.get(dispatcher);
		if (dispatcherCommands == null) {
			dispatcherCommands = new ArrayList<Class<? extends Command>>();
			_commandMap.put(dispatcher, dispatcherCommands);
			dispatcher.addListener(this);
		}

		if (_commandMap.get(dispatcher).contains(command)) {
			if (!runOnce && _runOnceCommands.containsKey(dispatcher) && _runOnceCommands.get(dispatcher).contains(command)) _runOnceCommands.get(dispatcher).remove(command);
			return;
		}
		
		_commandMap.get(dispatcher).add(command);
		
		if (runOnce) {
			HashSet<Class<? extends Command>> dispatcherRunOnceCommands = _runOnceCommands.get(dispatcher);
			if (dispatcherRunOnceCommands == null) _runOnceCommands.put(dispatcher, dispatcherRunOnceCommands = new HashSet<Class<? extends Command>>());
			dispatcherRunOnceCommands.add(command);
		}
	}
	
	public boolean unmapCommand(Dispatcher dispatcher, Class<? extends Command> command) {
		if (dispatcher == null) throw new NullPointerException("No dispatcher specified");
		if (command == null) throw new NullPointerException("No command specified");
		if (!_commandMap.containsKey(dispatcher)) return false;

		ArrayList<Class<? extends Command>> dispatcherCommands = _commandMap.get(dispatcher);
		if (!dispatcherCommands.remove(command)) return false;
		
		if (_runOnceCommands.containsKey(dispatcher) && _runOnceCommands.get(dispatcher).contains(command)) {
			_runOnceCommands.get(dispatcher).remove(command);
			if (_runOnceCommands.get(dispatcher).isEmpty()) _runOnceCommands.remove(dispatcher);
		}

		if (_commandMap.get(dispatcher).isEmpty()) {
			_commandMap.remove(dispatcher);
			dispatcher.removeListener(this);
		}
		
		return true;
	}
	
	public void handle(Message message) {
		Dispatcher dispatcher = message.getDispatcher();
	
		ArrayList<Class<? extends Command>> commandClasses = _commandMap.get(dispatcher);
		ArrayList<Command> commands = new ArrayList<Command>();
		_injector.mapClassInstance(Message.class, message);
		for (int i = 0; i < commandClasses.size(); i++) {
			Class<? extends Command> commandClass = commandClasses.get(i);
			if (_runOnceCommands.containsKey(dispatcher) && _runOnceCommands.get(dispatcher).contains(commandClass)) {
				unmapCommand(dispatcher, commandClass);
				i--;
			}
			Command commandInstance;
			try {
				commandInstance = commandClass.newInstance();
			} catch (Exception e) {
				throw new RuntimeException("Failed to instantiate class " + commandClass);
			}
			_injector.injectInto(commandInstance, false);
			commands.add(commandInstance);
		}
		_injector.unmapClass(Message.class);
		
		for (Command command : commands) {
			command.onRegister();
			command.execute();
		}
	}

}
