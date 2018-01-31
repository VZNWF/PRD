@isTest
private class PRMLeadTest {

    public static testMethod void testGetLeadsByDateTime() {
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
		settings.URL__c = 'http://testurl';
		insert settings;
		PRMLead prmLeadObj = new PRMLead(true);
		PRMLead.LeadOppHistoryWrapper wrapper = prmLeadObj.getLeadsByDateTime(DateTime.now().addDays(-10));
		system.assertEquals(2, wrapper.existingLeads.size());
    }
    
    public static testMethod void testgetLeadsByIds() {
    	 PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
		settings.URL__c = 'http://testurl';
		insert settings;
		PRMLead prmLeadObj = new PRMLead(true);
		PRMLead.LeadOppHistoryWrapper wrapper = prmLeadObj.getLeadsByIds();
		system.assertEquals(1, wrapper.newLeads.size());
		system.assertEquals('New',wrapper.newLeads[0].Status);
    }
    
    public static testMethod void testUpdateLeads() {
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
        insert l;
        
        List<Lead> queriedLeads = [Select Id, Affiliate_Lead_ID__c,Status_Last_Change__c,Partner_ID__c, NWF_Lead_Opp_Number__c, Status, Main_Unqualified_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone, Total_Number_of_Vehicles__c from Lead where Id =: l.Id limit 1];
        PRMMockServiceImpl.setConvertedLeadOppNumber(queriedLeads[0].NWF_lead_Opp_Number__c);
        PRMLead prmLeadObj = new PRMLead(true);
        PRMLead.leadOppHistoryWrapper wrapper = prmLeadObj.UpdateLeads(queriedLeads, null);
        system.assertEquals(1,wrapper.histories.size());
    }
    
    public static testMEthod void testShareLead() {
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
        insert l;
        
        List<Lead> queriedLeads = [Select Id, Affiliate_Lead_ID__c,Partner_ID__c, NWF_Lead_Opp_Number__c, Status, Main_Unqualified_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone, Total_Number_of_Vehicles__c from Lead where Id =: l.Id limit 1];
        PRMMockServiceImpl.setConvertedLeadOppNumber(queriedLeads[0].NWF_lead_Opp_Number__c);
        PRMLead prmLeadObj = new PRMLead(true);
        PRMLead.leadOppHistoryWrapper wrapper = prmLeadObj.shareLeads(queriedLeads, null);
        system.assertEquals(1,wrapper.histories.size());
    }
    
    public static testMethod void testGetInvalidReason() {
    	system.assertEquals('Customer Unresponsive', PRMLead.getInvalidReason('Non-Responsive', ''));
    	system.assertEquals('Duplicate Lead', PRMLead.getInvalidReason('Closed Duplicate', ''));
    	system.assertEquals('Existing Customer', PRMLead.getInvalidReason('Unqualified', 'Existing Customer'));
    	system.assertEquals('Feature Function', PRMLead.getInvalidReason('Unqualified', 'Feature Function'));
    	system.assertEquals('Customer Not Interested', PRMLead.getInvalidReason('Unqualified', 'No interest from the start'));
    	system.assertEquals('Feature Function', PRMLead.getInvalidReason('Closed Lost', 'Feature Function'));
    	system.assertEquals('Pilot Unsuccessful', PRMLead.getInvalidReason('Closed Lost', 'Pilot Unsuccessful'));
    }
    
    public static testMethod void testGetConvertLeadStatus() {
    	system.assertEquals('Won Maintenance',PRMLead.convertLeadStatus('Won Maintenance'));
    	system.assertEquals('Referrer Contacted',PRMLead.convertLeadStatus('Contacted Affiliate'));
    	system.assertEquals('Customer Contacted',PRMLead.convertLeadStatus('Nurture'));
    	system.assertEquals('Unqualified',PRMLead.convertLeadStatus('Unqualified'));
    	system.assertEquals('Qualified',PRMLead.convertLeadStatus('Qualified Opportunity'));
    	system.assertEquals('Unqualified',PRMLead.convertLeadStatus('Non-Responsive'));
    	system.assertEquals('Closed - Won (Maint)',PRMLead.convertLeadStatus('Closed Won'));
    	system.assertEquals('Closed - Lost',PRMLead.convertLeadStatus('Closed Lost'));
    	system.assertEquals('Unqualified',PRMLead.convertLeadStatus('Closed Duplicate'));
    }
}