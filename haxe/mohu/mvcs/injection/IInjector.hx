package mohu.mvcs.injection;

/**
 * ...
 * @author Tim Kendrick
 */

interface IInjector {

	function mapClassInstance(requestedClass:Class<Dynamic>, instance:Dynamic):Dynamic;
	
	function mapClass(requestedClass:Class<Dynamic>, suppliedClass:Class<Dynamic> = null):Void;
	
	function mapClassSingleton(requestedClass:Class<Dynamic>, suppliedClass:Class<Dynamic> = null):Void;
	
	function mapClassRule(requestedClass:Class<Dynamic>, rule:IInjectionRule):Dynamic;
	
	function unmapClass(requestedClass:Class<Dynamic>):Void;
	
	function hasClassMapping(requestedClass:Class<Dynamic>):Bool;
	
	function getClassInstance(requestedClass:Class<Dynamic>):Dynamic;
	
	function mapMetadataInstance(tag:String, instance:Dynamic):Void;
	
	function mapMetadataClass(tag:String, suppliedClass:Class<Dynamic>):Void;
	
	function mapMetadataSingleton(tag:String, suppliedClass:Class<Dynamic>):Void;
	
	function unmapMetadata(tag:String):Void;

	function hasMetadataMapping(tag:String):Bool;
	
	function getMetadataInstance(tag:String):Dynamic;
	
	function injectInto(instance:Dynamic, ?register:Bool = true):Dynamic;
	
}