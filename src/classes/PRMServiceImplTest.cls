@isTest(SeeAllData=True)
private class PRMServiceImplTest {

    static testMethod void TestmakeRequest() {
        string request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'LeadDateReqResp');
        system.assertEquals(true, request.contains('QueryLeadsByLastUpdatedDateReq'));
        request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'LeadIDReqResp');
        system.assertEquals(true, request.contains('QueryLeadsByPartnerLeadIdReq'));
        request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'LeadStatusReqResp');
        system.assertEquals(true, request.contains('QueryLeadsByStatusReq'));
        request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'UpdateLeadsReqResp');
        system.assertEquals(true, request.contains('UpdateLeadsRequest'));
        request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'ShareLeadReqResp');
        system.assertEquals(true, request.contains('ShareLeadReq'));
    }
    
    static testMethod void TestbuildHttpRequest() {
        string request = PRMServiceImpl.makeRequest('<Request>testmessage</Request>', 'LeadDateReqResp');
        HttpRequest req = PRMServiceImpl.buildHttpRequest(request, 'testusername', 'testpw', 'http://test', 'LeadDateReqResp');
        system.assertEquals(true, req.getHeader('SOAPAction').contains('LeadDateReqResp'));
        req = PRMServiceImpl.buildHttpRequest(request, 'testusername', 'testpw', 'http://test', 'LeadIDReqResp');
        system.assertEquals(true, req.getHeader('SOAPAction').contains('LeadIDReqResp'));
        req = PRMServiceImpl.buildHttpRequest(request, 'testusername', 'testpw', 'http://test', 'LeadStatusReqResp');
        system.assertEquals(true, req.getHeader('SOAPAction').contains('LeadStatusReqResp'));
        req = PRMServiceImpl.buildHttpRequest(request, 'testusername', 'testpw', 'http://test', 'UpdateLeadsReqResp');
        system.assertEquals(true, req.getHeader('SOAPAction').contains('UpdateLeadsReqResp'));
        req = PRMServiceImpl.buildHttpRequest(request, 'testusername', 'testpw', 'http://test', 'ShareLeadReqResp');
        system.assertEquals(true, req.getHeader('SOAPAction').contains('ShareLeadReqResp'));
    }
    
    static testMethod void TestcreateFullToGetLeadsByID() {
        string xmlMessage = PRMServiceImpl.createFullToGetLeadsByID('testusername', 'testpw', 100);
        system.assertEquals(true, xmlMessage.contains('Max_Response_Records'));
    }
    
    static testMethod void testcreateFullXMLToGetLeadsByDate() {
        string xmlMessage = PRMServiceImpl.createFullXMLToGetLeadsByDate('testusername', 'testpw', system.now(), 100);
        system.assertEquals(true, xmlMessage.contains('LastUpdatedDate'));
    }
    
    static testMethod void testcreateFullXMLToUpdateLeads() {
        Lead l = TestUtils.createLead();
        l.Status = 'Non-Responsive';
        l.Main_Unqualified_Reason__c = 'Customer Unresponsive';
        l=[Select Owner.FirstName,Owner.LastName,Owner.Email,Lead.Partner_ID__c,Status,Status_Last_Change__c,NWF_Lead_Opp_Number__c,Phone,Owner.Phone from Lead where Id=:l.Id];
        List<Lead> leads = new List<Lead>();
        leads.add(l);
        Account acc = TestUtils.createAccount();
        Opportunity opp = TestUtils.createOpportunity(acc);
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
      
       Test.setMock(HttpCalloutMock.class, new SampleResponse());

        string xmlMessage= PRMServiceImpl.createFullXMLToUpdateLeads(leads, opps, 'testusername', 'testpw');
    

        system.assertEquals(true, xmlMessage.contains('ITW_Password'));
        system.assertEquals(true, xmlMessage.contains('Status'));
        system.assertEquals(true, xmlMessage.contains('M2M_Connection_Actual'));
        
       
        
    }
    
    static testMethod void testcreateFullXMLToShareLeads() {
        Lead l = TestUtils.createLead();
        l=[Select Owner.FirstName,Owner.LastName,Owner.Email,Lead.Partner_ID__c,Status,Status_Last_Change__c,NWF_Lead_Opp_Number__c,Phone,Owner.Phone from Lead where Id=:l.Id];
        List<Lead> leads = new List<Lead>();
        leads.add(l);
        Account acc = TestUtils.createAccount();
        Opportunity opp = TestUtils.createOpportunity(acc);
        List<Opportunity> opps = new List<Opportunity>();
        opps.add(opp);
      
        string xmlMessage = PRMServiceImpl.createFullXMLToUpdateLeads(leads, opps, 'testusername', 'testpw');
        AssignmentTestUtil.setMockDecisionPointConfigResponse(l.getsobjectType());   
      
        system.assertEquals(true, xmlMessage.contains('ITW_Password'));
        system.assertEquals(true, xmlMessage.contains('ITW_Username'));
        system.assertEquals(true, xmlMessage.contains('SFDC_Lead_Long_ID'));
        
        
    }
    
    static testMethod void testremoveFormatting() {
        string result = PRMServiceImpl.removeFormatting('(111)111-1111');
        system.assertEquals('1111111111', result);
    }
    
    static testMethod void testExecute() {
     HttpResponse response = PRMServiceImpl.execute('<Req>testmessage</Req>', 'LeadDateReqResp');
        system.assertEquals(null, response);
       
    }
    
    @istest static void setupSettings() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        settings.URL__c = 'http://testurl';
        settings.ITWUsername__c='test@gmail.com';
        settings.ITWPassword__c='test1234';
        //insert settings;
        DataBase.insert(settings,false);
    }

    
  public class SampleResponse implements HttpCalloutMock {

     public HTTPResponse respond(HTTPRequest req) {
                
            // fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('tESTED');
            res.setStatusCode(200);
            return res;
            
           }
  }
    
    
    
}