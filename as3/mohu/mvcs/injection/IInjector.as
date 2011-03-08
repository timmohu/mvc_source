package mohu.mvcs.injection {

	/**
	 * @author Tim Kendrick
	 */
	public interface IInjector {

		function mapClassInstance(requestedClass:Class, instance:*):*;
		
		function mapClass(requestedClass:Class, suppliedClass:Class = null):void;

		function mapClassSingleton(requestedClass:Class, suppliedClass:Class = null):void;
		
		function mapClassRule(requestedClass:Class, rule:IInjectionRule):*;

		function unmapClass(requestedClass:Class):void;

		function hasClassMapping(requestedClass:Class):Boolean;

		function getClassInstance(requestedClass:Class):*;

		function mapMetadataInstance(tag:String, instance:*):void;

		function mapMetadataClass(tag:String, suppliedClass:Class):void;
		
		function mapMetadataSingleton(tag:String, suppliedClass:Class):void;
		
		function mapMetadataRule(tag:String, rule:IInjectionRule):*;

		function unmapMetadata(tag:String):void;
		
		function hasMetadataMapping(tag:String):Boolean;
		
		function getMetadataInstance(tag:String):*;

		function injectInto(instance:*, register:Boolean = true):*;
	}
}
