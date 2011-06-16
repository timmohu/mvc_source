package mohu.mvcs.controller;

import java.util.HashSet;

import mohu.messages.Dispatcher;
import mohu.messages.Message;
import mohu.messages.MessageHandler;


public class AsyncCommand extends Command {

	private static final HashSet<AsyncCommand> ACTIVE_COMMANDS = new HashSet<AsyncCommand>();
	
	private Dispatcher _onCompleted;
	
	public AsyncCommand() {
		
		_onCompleted = new Dispatcher(this);
		_onCompleted.addListener(new MessageHandler() {
			@Override
			public void handle(Message message) {
				_handleCompleted(message);
			}
		});
			
		ACTIVE_COMMANDS.add(this);
	}

	private void _handleCompleted(Message message) {
		ACTIVE_COMMANDS.remove(this);
	}

	public Dispatcher onCompleted() {
		return _onCompleted;
	}
}
