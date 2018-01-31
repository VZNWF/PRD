@isTest(SeeAllData=True)
private class PRMLeadUpdateBatchTest {

    @isTest static void testPRMLeadUpdateBatch() {
        List<Id> leads = new List<Id>();
        List<Id> opportunities = new List<Id>();
        Lead lead = testUtils.createLead();
        leads.add(lead.Id);
        Account account = testUtils.createAccount();
        Opportunity opportunity = testUtils.createOpportunity(account);
        opportunities.add(opportunity.Id);
        PRMLeadUpdateBatch batch = new PRMLeadUpdateBatch(leads,opportunities,true);
        test.startTest();
        Id batchId = database.executeBatch(batch);
        test.stopTest();
        system.assertEquals(1, batch.insertedLeadIds.size());
        system.assertEquals(1, batch.updatedOppIds.size());
    }

    @istest static void setupSettings() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        settings.URL__c = 'http://testurl';
        settings.Lead_Summary_Last_Updated__c = DateTime.now().AddMinutes(-5);
        settings.Number_of_Leads_To_Update__c = 2;
        //insert settings;
        DataBase.insert(settings,false);
        
    }
}