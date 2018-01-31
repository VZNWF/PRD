public with sharing class BaseControllerMock extends BaseController {
	public BaseControllerMock() {
		system.debug('In Constructor');
	}

	public void createConfirmMessage(String message) {
		addConfirmMessage(message);
	}

	public void createErrorMessage(String message) {
		addErrorMessage(message);
	}

	public void createInfoMessage(String message) {
		addInfoMessage(message);
	}

	public Boolean hasErrorMessages() {
		return getHasErrorMessages();
	}
}