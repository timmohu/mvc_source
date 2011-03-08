package mohu.mvcs.view;

import mohu.messages.Dispatcher;

/**
 * ...
 * @author Tim Kendrick
 */

interface IContextView {
	
	var view(default, null):Dynamic;

	var onViewAdded(default, null):Dispatcher;
	var onViewRemoved(default, null):Dispatcher;
	
}