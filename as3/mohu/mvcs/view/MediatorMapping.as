package mohu.mvcs.view {

	/**
	 * @author Tim Kendrick
	 */
	public class MediatorMapping {

		public var mediatorClass:Class;
		public var autoCreate:Boolean;
		public var autoRemove:Boolean;

		public function MediatorMapping(mediatorClass:Class , autoCreate:Boolean , autoRemove:Boolean) {
			this.mediatorClass = mediatorClass;
			this.autoCreate = autoCreate;
			this.autoRemove = autoRemove;
		}
	}
}
