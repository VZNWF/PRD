@isTest
private class BaseController_Test {
	
	@isTest static void testBaseController() {
		PageReference productManagerPage = Page.ProductManager;
		Test.setCurrentPage(productManagerPage);
		BaseControllerMock controller = new BaseControllerMock();

		string testParamVal = controller.getParameter('testParam','defaultValue');
		System.assertEquals('defaultValue',testParamVal);

		controller.setParameter('testParam','changedValue');
		testParamVal = controller.getParameter('testParam');
		System.assertEquals('changedValue',testParamVal);

		controller.createInfoMessage('Test Info Message');
		controller.createConfirmMessage('Test Confirm Message');
		controller.createErrorMessage('Test Error Message');
		System.assert(controller.hasErrorMessages());
	}
	
}