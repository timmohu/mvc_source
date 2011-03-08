package mohu.mvcs.view;
import haxe.io.Error;

/**
 * ...
 * @author Tim Kendrick
 */

class ViewController implements IViewController {
	
	public var view(default, null):Dynamic;
	
	public function new(view:Dynamic) {
		this.view = view;
	}
	
}