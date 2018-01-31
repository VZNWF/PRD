/****************************************************************
Created: 25 Feb 2013
Author: Aaron Pettitt (CodeScience)
Purpose : methods to create test data
Modifications:
******************************************************************/
@isTest
public with sharing class TestUtils {

	public static Lead createLead(){
		Lead lead = new Lead(LastName = 'Test123432', Company='Test Company', Phone = '555-789-5947', Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '111111111111111', Main_Unqualified_Reason__c = 'Feature Function');
		insert lead;
		lead = [Select LastName,Status_Last_Change__c,Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead.Id];
		return lead;
	}
	
	public static Account createAccount(){
		RecordType acctRecordType = [Select Id from RecordType where Name = 'Sales Account' and SobjectType = 'Account'];
		User user = [Select Id from User Limit 1];
		Account account = new Account(Name = 'Test Account 234234', SOS_Owner__c = user.Id, Acct_Type__c = 'Other', Sub_Type__c = 'Other', Sales_Partner_Vertical__c = 'Other', Total_Number_of_Vehicles__c = 10);
		insert account;
		return account;
	}
	
	public static Opportunity createOpportunity(Account account){
		RecordType opRecordType = [Select Id from RecordType where Name = 'Sales Opportunity' and SobjectType = 'Opportunity'];
		Opportunity opportunity = new Opportunity(RecordTypeId = opRecordType.Id, Name = 'Test Opportunity', Lead_Opp_Number__c  = 'test number', AccountId = account.Id, Type = 'Existing Business', LeadSource = 'Other', Specific_Lead_Source__c = 'Other', CloseDate = Date.today().addDays(30), StageName = 'Initial Meeting / Demo', Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '00QK00000056y5yMBB', Main_Lost_Reason__c='Feature Function');
		insert opportunity;
		opportunity = [Select RecordTypeId,Stage_Last_Change__c,Name,Lead_Opp_Number__c, NWF_Lead_Opp_Number__c,Unit_Total_All_Opps__c, AccountId, Type,LeadSource,Specific_Lead_Source__c,CloseDate, StageName, Affiliate_Lead_ID__c, Partner_ID__c, Main_Lost_Reason__c, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone from Opportunity where Id=: opportunity.Id ];
		return opportunity;
	}
	
	public static Opportunity createChildOpportunity(Opportunity parentOpp,string childOppName) {
		RecordType opRecordType = [Select Id from RecordType where Name='Child Sales Opportunity' and SobjectType = 'Opportunity'];
		Opportunity childOpp  = new Opportunity(RecordTypeId = opRecordType.Id, Name= childOppName, Lead_Opp_Number__c = 'test number', AccountId = parentOpp.AccountId, Type='Existing Business',LeadSource='Other', Specific_Lead_Source__c=  'Other', CloseDate = Date.today().addDays(30), StageName = 'Pilot' );
		insert childOpp;
		return childOpp;
	}

	public static User createTestUser(boolean performInsert) {
		Profile sysAdmin = [Select Id from Profile where Name = 'System Administrator'];
		User u = new User(Alias = 'testUsr', Email='admintest@test.codescience.com', FirstName='TestUser',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = sysAdmin.Id, Phone = '888-555-1414',
            TimeZoneSidKey='America/Los_Angeles', UserName='admintest@test.codescience.com');
		if(performInsert) { insert u; }
		return u;
	}
}