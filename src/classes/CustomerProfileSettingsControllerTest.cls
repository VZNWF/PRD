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
private class CustomerProfileSettingsControllerTest {

	@TestSetup
	static void testDataSetup(){
		//Customer Profile Settings record
        Customer_Profile_Settings__c cps = new Customer_Profile_Settings__c();
        cps.Apex_Scheduler_Cron_Expression__c = '* * * * * *';
        cps.Case_Filter_Criteria__c = '';
        cps.Case_Recordtype_Name__c = 'Case Reason';
        cps.Contacts_Filter_Criteria__c = 'Email!=null';
        cps.Email_receipients__c = 'siva.adapa@verizon.com';
        cps.Has_Cron_Expression_Changed__c = false;
        cps.Is_Active__c = true;
        cps.zCase_Reason_SubReason_String1__c = '[{"timeFrame":365,"selectedSubReasonSet":["Credit Request"],"categoryBucket":"Billing & Finance","caseReason":"Finance"},{"timeFrame":183,"selectedSubReasonSet":["Complaint - Website"],"categoryBucket":"Product","caseReason":"General Inquiries"},{"timeFrame":183,"selectedSubReasonSet":["Failed Activation"],"categoryBucket":"Service & Support","caseReason":"Installation"}]';
    	insert cps;
    	
    	//Insert Test Account
    	Account a = new Account();
    	a.Name = 'Test Account';
    	insert a;
    	
    	//Insert Test Contact
    	Contact c = new Contact();
    	c.FirstName = 'Test First';
    	c.LastName = 'Test Last';
    	c.Email = 'Test@test.com';
    	c.AccountId = a.Id;  //Relate it to Account a
    	insert c;
    	
    	//Insert the Case
    	Case ca = new Case();
    	Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
    	ca.RecordTypeId = devRecordTypeId;
    	ca.Reason = 'Finance';
    	ca.Case_Sub_Reason__c = 'Credit Request';
    	ca.AccountId = a.Id;
    	ca.Is_Fleet_Same_As_Account__c = true;
    	ca.ContactId = c.Id;
    	insert ca;
    	
	}
	
    static testMethod void myUnitTest() {
        
    	Customer_Profile_Settings__c cps = [Select Id, Apex_Scheduler_Cron_Expression__c, Case_Filter_Criteria__c,Case_Recordtype_Name__c,Contacts_Filter_Criteria__c, 
    									Email_receipients__c, Has_Cron_Expression_Changed__c, Is_Active__c, zCase_Reason_SubReason_String1__c from Customer_Profile_Settings__c LIMIT 1];
    	
    	ApexPages.StandardController apSC = new ApexPages.StandardController(cps);
    	CustomerProfileSettingsController cpsc = new CustomerProfileSettingsController(apSC);
    	PageReference p = page.CustomerProfileSettings;
    	Test.setCurrentPage(p);
    	
    	cpsc.newRow();
    	cpsc.saveRow();
    	cpsc.reason = 'Finance';
    	cpsc.selectedSubReasonList.add(new SelectOption('Credit Request', 'Credit Request'));
    	cpsc.reasonWrapperObj.timeFrame = 365;
    	cpsc.reasonWrapperObj.categoryBucket = 'Billing & Finance';
     	cpsc.saveRow();
     	cpsc.fetchSubReasons();
    	cpsc.editMapKey = 'Finance_365_Billing & Finance';
    	cpsc.editRow();
    	//getter methods
    	cpsc.getCategoryValues();
    	cpsc.getTimeFrameValues();
    	
    	//Duplicate scenario
    	cpsc.newRow();
    	cpsc.reason = 'Finance';
    	cpsc.selectedSubReasonList.add(new SelectOption('Credit Request', 'Credit Request'));
    	cpsc.reasonWrapperObj.timeFrame = 365;
    	cpsc.reasonWrapperObj.categoryBucket = 'Billing & Finance';
    	cpsc.saveRow();
    	
    	//Edit save scenario
    	cpsc.editRow();
    	cpsc.reason = 'Finance';
    	cpsc.selectedSubReasonList.add(new SelectOption('Credit Request', 'Credit Request'));
    	cpsc.reasonWrapperObj.timeFrame = 183;
    	cpsc.reasonWrapperObj.categoryBucket = 'Billing & Finance';
    	cpsc.saveRow();
    	
    	cpsc.deleteRow();
    	cpsc.updateConfig();
    	cpsc.cancel();
    	
    	
    	
    }
    
    static testMethod void myUnitTest1() {
    	ContactCaseCountBatchUpdate c = new ContactCaseCountBatchUpdate('Update', null);
    	Id batchprocessid = Database.executeBatch(c);
    	
    	ContactCaseCountBatchScheduler sch = new ContactCaseCountBatchScheduler();
    	String cronExp = '0 0 * * * ?';
    	system.schedule('Test', cronExp, sch);
    }
}