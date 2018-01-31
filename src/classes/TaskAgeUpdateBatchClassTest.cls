/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TaskAgeUpdateBatchClassTest {

	static testMethod void myUnitTest() {
			//query the Task Age Metadata
		Task_Age_Config__mdt taskAgeMtdLst=new Task_Age_Config__mdt();
		taskAgeMtdLst=[Select DeveloperName, MasterLabel, IsActive__c, Preliminary_Milestones__c, Final_Milestones__c, Start_Time__c, End_Time__c, Work_Days_per_Week__c, Work_Hours_per_Day__c from Task_Age_Config__mdt where isActive__c=True limit 1];
        
        //Populate the predefined config, dynamically to assign it to the test records
        String leadSource = taskAgeMtdLst.MasterLabel;
        List<String> preMileStone = taskAgeMtdLst.Preliminary_Milestones__c.split(',');
        List<String> finMileStone = taskAgeMtdLst.Final_Milestones__c.split(',');
		
		//Create Lead
		Lead l = new Lead();
		l.FirstName = 'Test';
		l.LastName = 'Record 12/19/2016';
		l.Email = 'test'+system.now().getTime()+'@testmail.com.vz';
		l.LeadSource = leadSource;
		l.specific_lead_source__c = 'MVF';
		l.Company = 'Company '+system.now().getTime();
		insert l;
		Test.setCreatedDate(l.id, system.today().addDays(-5));
		//Assert Statements
		//Lead tmpLead=[Select Id, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c from Lead where Id =: l.Id];
		//system.assertEquals(null, l.Age_to_First_Attempt__c);
		//system.assertEquals(null, l.Age_to_Connect__c);
		
		//Create Task1 with the status in Premiliminary Milestone
		Task t1 = new task();
		t1.Subject = preMileStone[0];
		t1.ActivityDate = System.today();
		t1.Status = 'Completed';
		t1.Type = 'Call';
		t1.Activity_Type__c = 'Leads';
		t1.Professional_Services_Type__c = 'Call Customer';
		t1.WhoId = l.Id;
		insert t1;
		Test.setCreatedDate(t1.Id, system.today().addDays(-4));
		
		//Assert Statements
		//tmpLead=[Select Id, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id from Tasks) from Lead where Id =: t1.WhoId];
		//system.assertEquals(tmpLead.tasks.size(), tmpLead.Number_of_Attempts__c);
	
		//Create Task2 with the status in Premiliminary Milestone
		Task t2 = new task();
		t2.Subject = preMileStone[0];
		t2.ActivityDate = System.today();
		t2.Status = 'Completed';
		t2.Type = 'Call';
		t2.Activity_Type__c = 'Leads';
		t2.Professional_Services_Type__c = 'Call Customer';
		t2.WhoId = l.Id;
		insert t2;
		Test.setCreatedDate(t2.Id, system.today().addDays(-3));
		//Assert Statements
		//tmpLead=[Select Id, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id from Tasks) from Lead where Id =: t2.WhoId];
		//system.assertEquals(tmpLead.tasks.size(), tmpLead.Number_of_Attempts__c);
		
		//Create Task3 with the status in Final Milestone
		Task t3 = new task();
		t3.Subject = finMileStone[0];
		t3.ActivityDate = System.today();
		t3.Status = 'Completed';
		t3.Type = 'Call';
		t3.Activity_Type__c = 'Leads';
		t3.Professional_Services_Type__c = 'Call Customer';
		t3.WhoId = l.Id;
		insert t3;
		Test.setCreatedDate(t3.Id, system.today().addDays(-2));
    
        
        ID batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass(leadSource, 'Update', ' LIMIT 1'));
        batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass(leadSource, 'Reset', ' LIMIT 1'));
        
    }
}