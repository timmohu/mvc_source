package mohu.mvcs.injection;

/**
 * ...
 * @author Tim Kendrick
 */

interface IInjectionRule {

	var instance(getInstance, null):Dynamic;
	
	function createInstance():Dynamic;
	
}