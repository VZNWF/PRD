@isTest
public with sharing class TaskTrigger_Test {
	public static testMethod void TaskTriggerTest() {
	
		//create a lead
		Lead lead = new Lead(LastName='Smith', Company='CodeScience',Title='code master', Industry='software', Phone='4155556677', email='test.smith@test.com', Status='New', Main_Unqualified_Reason__c ='Bogus Lead', Sub_Unqualified_Reason_1__c ='Other', Lead_Type__c='Other', Lead_Sub_Type__c='OTHER', Total_Number_of_Vehicles__c=0, LeadSource='Event', Specific_Lead_Source__c='Adroll' , Affiliate_Sales_Name__c = 'Jane Doe', Affiliate_Lead_ID__c='00Qe00000047Ged'  );
		insert lead;
		System.assert(lead.Id != null);
		Task task = new Task(Subject='test task', Priority='Normal', Type='Call' , WhoId = lead.Id, Description='My Test Description content', Status='Completed');
		insert task;
		System.assert(task.Id != null);
	}
    
    public static testMethod void testSendEmail(){

		Lead lead = new Lead(LastName='Smith', Company='CodeScience',Title='code master', Industry='software', Phone='4155556677', email='test.smith@test.com', Status='New', Main_Unqualified_Reason__c ='Bogus Lead', Sub_Unqualified_Reason_1__c ='Other', Lead_Type__c='Other', Lead_Sub_Type__c='OTHER', Total_Number_of_Vehicles__c=0, LeadSource='Event', Specific_Lead_Source__c='Adroll' , Affiliate_Sales_Name__c = 'Jane Doe', Affiliate_Lead_ID__c='00Qe00000047Ged' );
		insert lead;
		//assign task
		Task task = new Task(Subject='test task', Priority='Normal', Type='Call' , WhoId = lead.Id, Description='My Test Description content', Status='New', Email_Affilate_Rep__c = 'Yes');
		insert task;
		Task task2 = new Task(Subject='test task2', Priority='Normal', Type='Call' , WhoId = lead.Id, Description='My Test Description content', Status='Completed', Email_Affilate_Rep__c = 'Yes');
		insert task2;
		Account account = new Account(Name = 'test account');
		Contact contact = new Contact( AccountID = account.Id, FirstName = 'Test', LastName = 'User', email='testuser@example.com');
		insert contact;
		task.WhoId = contact.Id;
		task.status = 'Completed';
		update task;
	}

}