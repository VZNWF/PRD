@isTest
private class PRMAPITest {

    static testMethod void myUnitTest() {
        PRMMockServiceImpl svc = new PRMMockServiceImpl();
        PRMAPI api = new PRMAPI(svc);
        HttpResponse response = api.execute('test', 'LeadDateReqResp');
        system.assertEquals(true, response.getBody().contains('LeadDateReqRespResponse'));
        PRMAPI realApi = new PRMAPI();
        HttpResponse realResponse = api.execute('test', 'LeadDateReqResp');
        system.assertEquals(0, realResponse.getStatusCode());
    }
}