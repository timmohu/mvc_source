package mohu.mvcs.injection {
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Tim Kendrick
	 */
	public class Injector implements IInjector {
		
		private static const INJECT_METADATA_TAG:String = "Inject";

		private static const CLASS_METADATA_TAGS:Dictionary = new Dictionary();

		private var injectionRules:Dictionary;
		private var metadataInjectionRules:Object;

		public function Injector() {
			injectionRules = new Dictionary();
			metadataInjectionRules = {};
		}
		
		public function mapClassInstance(requestedClass:Class, instance:*):* {
			if (!requestedClass) throw new ArgumentError("No class specified");
			if (!instance) throw new ArgumentError("No instance specified");
			if (injectionRules[requestedClass]) throw new ArgumentError("An injection mapping already exists for class " + getQualifiedClassName(requestedClass));
			injectionRules[requestedClass] = new InjectionRule(instance.constructor, true, instance);
			return instance;
		}

		public function mapClass(requestedClass:Class, suppliedClass:Class = null):void {
			if (!requestedClass) throw new ArgumentError("No class specified");
			if (injectionRules[requestedClass]) throw new ArgumentError("An injection mapping already exists for class " + getQualifiedClassName(requestedClass));
			if (!suppliedClass) suppliedClass = requestedClass;
			injectionRules[requestedClass] = new InjectionRule(suppliedClass, false);
		}

		public function mapClassSingleton(requestedClass:Class, suppliedClass:Class = null):void {
			if (!requestedClass) throw new ArgumentError("No class specified");
			if (injectionRules[requestedClass]) throw new ArgumentError("An injection mapping already exists for class " + getQualifiedClassName(requestedClass));
			if (!suppliedClass) suppliedClass = requestedClass;
			injectionRules[requestedClass] = new InjectionRule(suppliedClass, true);
		}

		public function mapClassRule(requestedClass:Class, rule:IInjectionRule):* {
			if (!requestedClass) throw new ArgumentError("No class specified");
			if (!rule) throw new ArgumentError("No rule specified");
			if (injectionRules[requestedClass]) throw new ArgumentError("An injection mapping already exists for class " + getQualifiedClassName(requestedClass));
			injectionRules[requestedClass] = rule;
		}

		public function unmapClass(requestedClass:Class):void {
			delete injectionRules[requestedClass];
		}
		
		public function hasClassMapping(requestedClass:Class):Boolean {
			return (injectionRules[requestedClass] != null);
		}
		
		public function getClassInstance(requestedClass:Class):* {
			if (!requestedClass) throw new ArgumentError("No class specified");
			var rule:IInjectionRule = injectionRules[requestedClass];
			if (!rule) throw new ArgumentError("No injection mapping specified for class " + getQualifiedClassName(requestedClass));	
			return (rule.instance || injectInto(rule.createInstance()));
		}

		public function mapMetadataInstance(tag:String, instance:*):void {
			if (!tag) throw new ArgumentError("No tag specified");
			if (!instance) throw new ArgumentError("No instance specified");
			if (metadataInjectionRules[tag]) throw new ArgumentError("An injection mapping already exists for metadata tag '" + tag + "'");
			metadataInjectionRules[tag] = new InjectionRule(instance.constructor, true, instance);
		}
		
		public function mapMetadataClass(tag:String, suppliedClass:Class):void {
			if (!tag) throw new ArgumentError("No tag specified");
			if (!suppliedClass) throw new ArgumentError("No class specified");
			if (metadataInjectionRules[tag]) throw new ArgumentError("An injection mapping already exists for metadata tag '" + tag + "'");
			metadataInjectionRules[tag] = new InjectionRule(suppliedClass, false);
		}

		public function mapMetadataSingleton(tag:String, suppliedClass:Class):void {
			if (!tag) throw new ArgumentError("No tag specified");
			if (!suppliedClass) throw new ArgumentError("No class specified");
			if (metadataInjectionRules[tag]) throw new ArgumentError("An injection mapping already exists for metadata tag '" + tag + "'");
			metadataInjectionRules[tag] = new InjectionRule(suppliedClass, true);
		}

		public function mapMetadataRule(tag:String, rule:IInjectionRule):* {
			if (!tag) throw new ArgumentError("No tag specified");
			if (!rule) throw new ArgumentError("No rule specified");
			if (metadataInjectionRules[tag]) throw new ArgumentError("An injection mapping already exists for metadata tag '" + tag + "'");
			metadataInjectionRules[tag] = rule;
		}
		
		public function getMetadataInstance(tag:String):* {
			if (!tag) throw new ArgumentError("No tag specified");
			var rule:IInjectionRule = metadataInjectionRules[tag];
			if (!rule) throw new ArgumentError("No injection mapping specified for tag " + tag);	
			return (rule.instance || injectInto(rule.createInstance()));
		}

		public function hasMetadataMapping(tag:String):Boolean {
			return (metadataInjectionRules[tag] != null);
		}
		
		public function unmapMetadata(tag:String):void {
			delete metadataInjectionRules[tag];
		}

		public function injectInto(instance:*, register:Boolean = true):* {
			var instanceClass:Class = instance.constructor;
			var classTags:Object = CLASS_METADATA_TAGS[instanceClass] || (CLASS_METADATA_TAGS[instanceClass] = getClassMetadataTags(instanceClass));
			for (var variable : String in classTags) {
				var rule:IInjectionRule = (classTags[variable] is String ? metadataInjectionRules[classTags[variable] as String] : injectionRules[classTags[variable] as Class]);
				if (!rule) throw new Error("Cannot satisfy injection dependencies for " + getQualifiedClassName(instanceClass) + "::" + variable);
				instance[variable] = (rule.instance || injectInto(rule.createInstance()));
			}
			if (register && (instance is IInjectable)) (instance as IInjectable).onRegister();
			return instance;
		}

		private function getClassMetadataTags(instanceClass:Class):Object {
			var classTags:Object = [];
			var typeSchema:XML = describeType(instanceClass);
			for each (var variable : XML in typeSchema.factory.variable) {
				if (variable.metadata.(@name == INJECT_METADATA_TAG).length() == 0) continue;
				var tag:XML = variable.metadata.(@name == INJECT_METADATA_TAG)[0];
				classTags[variable.@name] = (tag.arg.(@key == "").length() > 0 ? tag.arg.(@key == "").@value.toString() : getDefinitionByName(variable.@type.toString()));
			}
			return classTags;
		}
	}
}
