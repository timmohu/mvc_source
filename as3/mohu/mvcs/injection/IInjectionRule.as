package mohu.mvcs.injection {

	/**
	 * @author Tim Kendrick
	 */
	public interface IInjectionRule {

		function createInstance():*;
		
		function get instance():*;
	}
}
