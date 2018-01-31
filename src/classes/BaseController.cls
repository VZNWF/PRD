public abstract class BaseController {

	public String getParameter(String name) {
		return getParameter(name, null);
	}

	public String getParameter(String name, String defaultValue) {
		String value = ApexPages.currentPage().getParameters().get(name);
		return value == null ? defaultValue : value;
	}

	public void setParameter(String name, String value) {
		ApexPages.currentPage().getParameters().put(name, value);
	}

	public void addConfirmMessage(String message) {
		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Confirm, message); 
		ApexPages.addMessage(errorMessage);
	}

	public void addErrorMessage(String message) {
		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, message); 
		ApexPages.addMessage(errorMessage);
	}

	public void addInfoMessage(String message) {
		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Info, message); 
		ApexPages.addMessage(errorMessage);
	}

	public Boolean getHasErrorMessages() {
		return ApexPages.hasMessages(ApexPages.Severity.Error);	
	}

}