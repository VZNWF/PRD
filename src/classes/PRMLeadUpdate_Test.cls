@isTest(SeeAllData=True)
private class PRMLeadUpdate_Test {
    @isTest static void testPRMLeadUpdate() {
        List<Id> leads = new List<Id>();
        List<Id> opportunities = new List<Id>();
        Lead lead = testUtils.createLead();
        leads.add(lead.Id);
        Account account = testUtils.createAccount();
        //Opportunity opportunity = testUtils.createOpportunity(account);
       Opportunity opportunity=new Opportunity();
       if(opportunities==null && opportunities.size()<=0 ){
            
            opportunity.Name='Test Opty';
            opportunity.AccountId=account.Id;
            opportunity.closeDate=System.Today();
            opportunity.StageName='Telogis';
            opportunity.Type='Upgrade';
            opportunity.LeadSource='PR';
            opportunity.Specific_Lead_Source__c ='00 Best Fleets 2015';
            opportunity.Existing_AVL_User__c='No';
            insert opportunity;
            opportunities.add(opportunity.id);
            
        }

        PRMLeadUpdate testPRMLU = new PRMLeadUpdate();
        PRMLeadUpdate.updateLeads(new Set<Id> {lead.Id}, new Set<Id> {opportunity.Id}, true);
        
        lead.SOS_Owner__c = UserInfo.getUserId();
        DataBase.update(lead,false);

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
    Test.startTest();
      Database.LeadConvertResult lcr = Database.convertLead(lc);
     // string convertedOppId = lcr.getOpportunityId();
     
       Test.stopTest();
    }

    @istest static void setupSettings() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        settings.URL__c = 'http://testurl';
        settings.Lead_Summary_Last_Updated__c = DateTime.now().AddMinutes(-5);
        settings.Number_of_Leads_To_Update__c = 2;
        DataBase.insert(settings,false);
        
    }
}