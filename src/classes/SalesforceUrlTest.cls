@isTest
private class SalesforceUrlTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		SalesforceUrl sfurl = new SalesforceUrl();
		System.assertEquals(sfurl.getSfUrl(), URL.getSalesforceBaseUrl().toExternalForm());

	}
	
}