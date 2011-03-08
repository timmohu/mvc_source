package mohu.mvcs.injection;

import haxe.rtti.Meta;

/**
 * ...
 * @author Tim Kendrick
 */

class Injector implements IInjector {

	private var _classInjectionRules:Hash<IInjectionRule>;
	private var _metadataInjectionRules:Hash<IInjectionRule>;
	
	public function new() {
		_classInjectionRules = new Hash<IInjectionRule>();
		_metadataInjectionRules = new Hash<IInjectionRule>();
	}
	
	public function mapClassInstance(requestedClass:Class<Dynamic>, instance:Dynamic):Dynamic {
		if (requestedClass == null) throw "No class specified";
		if (instance == null) throw "No instance specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		if (_classInjectionRules.exists(requestedClassName)) throw "An injection mapping already exists for class " + requestedClassName;
		_classInjectionRules.set(requestedClassName, new InjectionRule(instance.constructor, true, instance));
		return instance;
	}
	
	public function mapClass(requestedClass:Class<Dynamic>, ?suppliedClass:Class<Dynamic> = null):Void {
		if (requestedClass == null) throw "No class specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		if (_classInjectionRules.exists(requestedClassName)) throw "An injection mapping already exists for class " + requestedClassName;
		if (suppliedClass == null) suppliedClass = requestedClass;
		_classInjectionRules.set(requestedClassName, new InjectionRule(suppliedClass, false));
	}
	
	public function mapClassSingleton(requestedClass:Class<Dynamic>, ?suppliedClass:Class<Dynamic> = null):Void {
		if (requestedClass == null) throw "No class specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		if (_classInjectionRules.exists(requestedClassName)) throw "An injection mapping already exists for class " + requestedClassName;
		if (suppliedClass == null) suppliedClass = requestedClass;
		_classInjectionRules.set(requestedClassName, new InjectionRule(suppliedClass, true));
	}
	
	public function mapClassRule(requestedClass:Class<Dynamic>, rule:IInjectionRule):Dynamic {
		if (requestedClass == null) throw "No class specified";
		if (rule == null) throw "No rule specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		if (_classInjectionRules.exists(requestedClassName)) throw "An injection mapping already exists for class " + requestedClassName;
		_classInjectionRules.set(requestedClassName, rule);
	}
	
	public function unmapClass(requestedClass:Class<Dynamic>):Void {
		if (requestedClass == null) throw "No class specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		_classInjectionRules.remove(requestedClassName);
	}
	
	public function hasClassMapping(requestedClass:Class<Dynamic>):Bool {
		return _classInjectionRules.exists(Type.getClassName(requestedClass));
	}
	
	public function getClassInstance(requestedClass:Class<Dynamic>):Dynamic {
		if (requestedClass == null) throw "No class specified";
		var requestedClassName:String = Type.getClassName(requestedClass);
		var rule:IInjectionRule = _classInjectionRules.get(requestedClassName);
		if (rule == null) throw "No injection mapping specified for class " + requestedClassName;
		return (rule.instance != null ? rule.instance : injectInto(rule.createInstance()));
	}
	
	public function mapMetadataInstance(tag:String, instance:Dynamic):Void {
		if (tag == null) throw "No tag specified";
		if (instance == null) throw "No instance specified";
		if (_metadataInjectionRules.exists(tag)) throw "An injection mapping already exists for metadata tag '" + tag + "'";
		_metadataInjectionRules.set(tag, new InjectionRule(instance.constructor, true, instance));
	}
	
	public function mapMetadataClass(tag:String, suppliedClass:Class<Dynamic>):Void {
		if (tag == null) throw "No tag specified";
		if (suppliedClass == null) throw "No class specified";
		if (_metadataInjectionRules.exists(tag)) throw "An injection mapping already exists for metadata tag '" + tag + "'";
		_metadataInjectionRules.set(tag, new InjectionRule(suppliedClass, false));
	}
	
	public function mapMetadataSingleton(tag:String, suppliedClass:Class<Dynamic>):Void {
		if (tag == null) throw "No tag specified";
		if (suppliedClass == null) throw "No class specified";
		if (_metadataInjectionRules.exists(tag)) throw "An injection mapping already exists for metadata tag '" + tag + "'";
		_metadataInjectionRules.set(tag, new InjectionRule(suppliedClass, true));
	}
	
	public function mapMetadataRule(tag:String, rule:IInjectionRule):Dynamic {
		if (tag == null) throw "No tag specified";
		if (rule == null) throw "No rule specified";
		if (_metadataInjectionRules.exists(tag)) throw "An injection mapping already exists for metadata tag '" + tag + "'";
		_metadataInjectionRules.set(tag, rule);
	}
	
	public function getMetadataInstance(tag:String):Dynamic {
		if (tag == null) throw "No tag specified";
		var rule:IInjectionRule = _metadataInjectionRules.get(tag);
		if (rule == null) throw "No injection mapping specified for tag " + tag;
		return (rule.instance != null ? rule.instance : injectInto(rule.createInstance()));
	}
	
	public function hasMetadataMapping(tag:String):Bool {
		return (_metadataInjectionRules.exists(tag));
	}
	
	public function unmapMetadata(tag:String):Void {
		_metadataInjectionRules.remove(tag);
	}
	
	public function injectInto(instance:Dynamic, ?register:Bool = true):Dynamic {
		if (instance == null) throw "No instance specified";
		
		var instanceClass:Class<Dynamic> = Type.getClass(instance);
		var instanceClassName:String = Type.getClassName(instanceClass);
		
		var metadata:Dynamic = Meta.getFields(instanceClass);
		
		var metadataFieldNames:Array<String> = Reflect.fields(metadata);
		var metadataFieldValues:Array<Dynamic> = new Array<Dynamic>();
		
		for (metadataFieldName in metadataFieldNames) metadataFieldValues.push(Reflect.field(metadata, metadataFieldName));
		
		var superClass:Class<Dynamic> = instanceClass;
		while ((superClass = Type.getSuperClass(superClass)) != null) {
			var superClassMetadata:Dynamic = Meta.getFields(superClass);
			var superClassMetadataFieldNames:Array<String> = Reflect.fields(superClassMetadata);
			for (superClassMetadataFieldName in superClassMetadataFieldNames) {
				metadataFieldNames.push(superClassMetadataFieldName);
				metadataFieldValues.push(Reflect.field(superClassMetadata, superClassMetadataFieldName));
			}
		}
		
		var instanceClassInfo:String = null;
		var i:Int = -1;
		for (metadataFieldName in metadataFieldNames) {
			var fieldMetadata:Dynamic = metadataFieldValues[++i];
			if (!Reflect.hasField(fieldMetadata, "inject")) continue;
			var tag:String = Reflect.field(fieldMetadata, "inject");
			var rule:IInjectionRule;
			if (tag != null) {
				rule = _metadataInjectionRules.get(tag);
			} else {
				if (instanceClassInfo == null) {
					instanceClassInfo = untyped instanceClass.__rtti;
					var superClass:Class<Dynamic> = instanceClass;
					while ((superClass = Type.getSuperClass(superClass)) != null) instanceClassInfo += untyped superClass.__rtti;
				}
				if (instanceClassInfo == null) throw "Unable to get field types - class " + instanceClassName + " must implement haxe.rtti.Infos";
				var search:EReg = new EReg("<" + metadataFieldName + " public=\"1\"[^>]*><c path=\"(.*?)\"", "");
				if (!search.match(instanceClassInfo)) throw "Unable to determine type of field " + instanceClassName + "::" + metadataFieldName;
				rule = _classInjectionRules.get(search.matched(1));
			}
			if (rule == null) throw "Cannot satisfy injection dependencies for " + instanceClassName + "::" + metadataFieldName;
			var injectee:Dynamic = (rule.instance != null ? rule.instance : injectInto(rule.createInstance()));
			Reflect.setField(instance, metadataFieldName, injectee);
		}
		
		if (register && Std.is(instance, IInjectable)) cast(instance, IInjectable).onRegister();
		
		return instance;
	}
	
}