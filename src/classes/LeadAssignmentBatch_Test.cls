@IsTest
private class LeadAssignmentBatch_Test {

    @isTest static void testBatchAssignment() {
    DecsOnD.TestUtils.initializeTestSetup();
        DecsOnD__Policy__c policy = DecsOnD.TestUtils.createTestPolicy('Lead', 'Assignment', true);
        DecsOnD.TestUtils util = new DecsOnD.TestUtils();
        LeadAssignmentHelper.mockPolicyResponse = util.getMockDecisionPointConfig(Lead.sObjectType).toJSON(true);

        Map<Id,Lead> insertedLeads = new Map<Id,Lead>([Select Id from Lead]);
        List<Id> leadIds = new List<Id>(insertedLeads.keySet());
        // Do not throw exception on error
        LeadAssignmentHelper helper = new LeadAssignmentHelper(false);
        // Assignment will fail since we can't make an actual callout
        String jsonResponse = null;
        for (integer i=0;i<insertedLeads.size();i++) {
            if (jsonResponse==null) {
                jsonResponse = '[';
            } else {
                jsonResponse += ',';
            }
            jsonResponse += '{"status": "OK"}';
        }
        jsonResponse += ']';
        LeadAssignmentHelper.mockDecisionResponseBatch = jsonResponse;
        
        LeadAssignmentBatch lab = new LeadAssignmentBatch(leadIds);
        Test.startTest();
        Database.executeBatch(lab,1);
        Test.stopTest();
    }

    @testSetup static void setupTestData() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        settings.URL__c = 'http://testurl';
        insert settings;
        
        List<Lead> leadsToInsert = new List<Lead>();
        Lead l = new Lead();
        l.Status = 'New';
        l.LastName = 'LastName';
        l.Company = 'who cares';
        l.Industry = 'Other';
        l.Affiliate_Lead_ID__c = 'AZQ1000';
        l.Partner_ID__c = '00QK00000078z6zNCC';
        l.FirstName = 'Krishna';
        l.LastName = 'Tatta';
        l.Phone = '1111111111';
        l.Email = 'test@tester.com';
        l.Lead_Source_Detail__c = 'Test detail';
        l.City = 'Irving';
        l.State = 'TX';
        l.Country = 'US';
        l.LeadSource = 'Verizon';
        l.Affiliate_Sales_Email__c = 'firstrep@email.com';
        l.Affiliate_Sales_Email_2__c = 'secondrep@email.com';
        l.Affiliate_Area__c = 'AB';
        l.Affiliate_Region__c = 'test';
        l.Affiliate_Sales_Phone__c = '1111111111';
        l.Affiliate_Sales_Phone_2__c = '2222222222';
        l.SOS_Owner__c = userinfo.getUserId();
        leadsToInsert.add(l);
        
/*        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.LastName = 'LastName';
        l1.Company = 'who cares who cares who cares who cares who cares who cares';
        //l1.title = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        l1.Industry = 'Other';
        l1.Affiliate_Lead_ID__c = 'AZQ1026';
        l1.Partner_ID__c = '00QK00000056y5yMBB';
        l1.FirstName = 'Krishna';
        l1.LastName = 'Tatta';
        l1.Phone = '1111111111';
        l1.Email = 'test@tester.com';
        l1.Lead_Source_Detail__c = 'Test detail';
        l1.City = 'Irving';
        l1.State = 'TX';
        l1.Country = 'US';
        l1.LeadSource = 'Verizon';
        l1.Affiliate_Sales_Email__c = 'firstrep@email.com';
        l1.Affiliate_Sales_Email_2__c = 'secondrep@email.com';
        l1.Affiliate_Area__c = 'AB';
        l1.Affiliate_Region__c = 'test';
        l1.Affiliate_Sales_Phone__c = '1111111111';
        l1.Affiliate_Sales_Phone_2__c = '2222222222';
        l1.SOS_Owner__c = userinfo.getUserId();
        leadsToInsert.add(l1);
*/
        insert leadsToInsert;
        
    }
}