package mohu.mvcs.view;

import mohu.mvcs.injection.Inject;
import mohu.mvcs.injection.Injectable;

public class Mediator extends Injectable {
	
	@Inject
	public IView view;

	public void onRemove() {
		
	}

}
