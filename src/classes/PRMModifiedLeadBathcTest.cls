@isTest(SeeAllData=true)
private class PRMModifiedLeadBathcTest {

    static testMethod void myUnitTest() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        settings.URL__c = 'http://testurl';
        settings.Lead_Summary_Last_Updated__c = DateTime.now().AddMinutes(-5);
        settings.Num_of_Modified_Leads_To_Import__c = 2;
        DataBase.insert(settings,false);
        PRMModifiedLeadBatch batch = new PRMModifiedLeadBatch(true);
        
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
        
        Lead l1 = new Lead();
        l1.Status = 'New';
        l1.LastName = 'LastName';
        l1.Company = 'who cares';
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
        DataBase.insert(leadsToInsert,false);
        
        List<Lead> queriedLeads = [select Id, NWF_Lead_Opp_Number__c from Lead where Id =: l.Id or Id =: l1.Id];
        for(Lead ld : queriedLeads) {
            if(ld.Id == l.Id) {
                PRMMockServiceImpl.setLeadOppNumber(ld.NWF_lead_Opp_Number__c);
            }
            else if(ld.Id == l1.Id) {
                PRMMockServiceImpl.setConvertedLeadOppNumber(ld.NWF_lead_Opp_Number__c);
            }
        }  
        
        Database.Leadconvert lc = new Database.Leadconvert();
        lc.setLeadId(l.id);
        LeadStatus convertStatus = [select id,MasterLabel from LeadStatus where isConverted=true limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc);            
        string convertedOppId = lcr.getOpportunityId();           
     
        Id batchId = database.executeBatch(batch); 
        test.stopTest();    
        
    }
}