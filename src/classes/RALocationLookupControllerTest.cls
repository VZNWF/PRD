/****************************************************************
Created: 20 Aug 2017
Author: Satish
Purpose : test class for the RALocationLookupController
Modifications:
******************************************************************/
@isTest()
private class RALocationLookupControllerTest {
    
    static testMethod void testCreateNewLocation() {
        Account a0 = new Account();
        a0.Name = 'Test Account1';
        a0.SOS_Owner__c = Userinfo.getUserId();
        a0.Acct_Type__c = 'End Customer';
        a0.Sub_Type__c = 'ENTERPRISE';
        a0.Total_Number_of_Vehicles__c = 10;
        a0.Seller_Key__c = '12346';
        a0.AccountNumber = 'TEST124';
        insert a0;      
               
        Account a = new Account();
        a.Name = 'Test Account';
        a.SOS_Owner__c = Userinfo.getUserId();
        a.Acct_Type__c = 'End Customer';
        a.Sub_Type__c = 'ENTERPRISE';
        a.Total_Number_of_Vehicles__c = 10;
        a.Seller_Key__c = '12345';
        a.AccountNumber = 'TEST123';
        a.ParentId = a0.Id;
        insert a;
        
        contact c = new contact();
        c.FirstName = 'FirstName';
        c.LastName = 'LastName';
        c.Email = 'Test@test1234321.com';
        c.AccountId = a.Id;
        insert c;
        
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
                
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Fleet_Account__c = a.Id;
        //ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;
        
        RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open'  );
        insert RALog;
        
        Test.startTest();
       //create location  record
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer', Customer__c = a.Id);
        insert loc;
        
        System.currentPageReference().getParameters().put('raLogId', RALog.Id); 
        RALocationLookupController addLocVar = new RALocationLookupController();
        addLocVar.searchString = 'Sam killmer';
        //System.assert(addLocVar.results.size() > 0);
        Test.stopTest();
    
        }
        
        static testMethod void testsearchLocation() {
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer');
        insert loc;
        Test.startTest();
        RALocationLookupController addLocVar = new RALocationLookupController();
        Test.stopTest();
    
        }
        static testMethod void testCall1(){
            RALocationLookupController ol = new RALocationLookupController();
            ol.saveLocation();
            ol.getFormTag();
            ol.getTextBox();
            ol.refreshTab();
            ol.search();
        }
}