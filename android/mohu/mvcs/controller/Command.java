package mohu.mvcs.controller;

import mohu.messages.Message;
import mohu.mvcs.injection.Inject;
import mohu.mvcs.injection.Injectable;


public class Command extends Injectable {

	@Inject
	public Message message;
	
	public void execute() {
		
	}
}
