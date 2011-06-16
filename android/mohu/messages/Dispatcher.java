package mohu.messages;

import java.util.ArrayList;
import java.util.HashSet;

public class Dispatcher extends MessageHandler {
	
	private Object _target;
	private ArrayList<MessageHandler> _listeners;
	private HashSet<MessageHandler> _runOnceListeners;
	
	public Dispatcher(Object target) {
		_target = target;
		
		_listeners = new ArrayList<MessageHandler>();
		_runOnceListeners = new HashSet<MessageHandler>();
	}
	
	public void addListener(MessageHandler listener) {
		this.addListener(listener, false);
	}
	
	public void addListener(MessageHandler listener, boolean runOnce) {
		if (listener == null) throw new NullPointerException("No listener specified");
		if (_listeners.contains(listener)) {
			if (!runOnce && _runOnceListeners.contains(listener)) _runOnceListeners.remove(listener);
			return;
		}
		_listeners.add(listener);
		if (runOnce) _runOnceListeners.add(listener);
	}
	
	public boolean hasListener(MessageHandler listener) {
		return _listeners.contains(listener);
	}
	
	public boolean removeListener(MessageHandler listener) {
		if (!_listeners.contains(listener)) return false;
		_listeners.remove(listener);
		_runOnceListeners.remove(listener);
		return true;
	}
	
	public void removeAllListeners() {
		_listeners = new ArrayList<MessageHandler>();
		_runOnceListeners = new HashSet<MessageHandler>();
	}
	
	public void dispatch() {
		this.dispatch(null, null);
	}
	
	public void dispatch(Message message) {
		this.dispatch(message, null);
	}
	
	public void dispatch(Message message, Object customTarget) {
		if (message == null) message = new Message();
		if (_listeners.isEmpty()) return;
		Object target = (customTarget != null ? customTarget : (message.getTarget() != null ? message.getTarget() : _target));
		message = (Message)message.clone();
		message._target = target;
		message._currentTarget = _target;
		message._dispatcher = this;
		for (int i = 0; i < _listeners.size(); i++) {
			MessageHandler listener = _listeners.get(i);
			if (_runOnceListeners.contains(listener)) {
				_runOnceListeners.remove(listener);
				_listeners.remove(i--);
			}
			listener.handle(message);
		}
		return;
	}

	@Override
	public void handle(Message message) {
		this.dispatch(message, null);
	}
	
	public Object getTarget() {
		return _target;
	}
	
	public Object setTarget(Object value) {
		return _target = value;
	}
}
