package mohu.messages;

public class Message {

	Dispatcher _dispatcher;
	Object _currentTarget;
	Object _target;
	
	public Message() {
		
	}
	
	public Message clone() {
		if (this.getClass() != Message.class) throw new RuntimeException("All Message subclasses must override the clone() method");
		return new Message();
	}

	public Object getTarget() {
		return _target;
	}

	public Object getCurrentTarget() {
		return _currentTarget;
	}

	public Dispatcher getDispatcher() {
		return _dispatcher;
	}

}
