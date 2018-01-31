/****************************************************************
Created: 20 Aug 2017
Author: Satish
Purpose : test class for the RALogDetailController
Modifications:
******************************************************************/
@isTest()
private class RALogDetailControllerTest {
    
    static testMethod void testCreateRALogDetail() {
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
        //a.ParentId = a0.Id;
        insert a;
        
         contact c = new contact();
        c.FirstName = 'FirstName';
        c.LastName = 'LastName';
        c.Email = 'Test@test1234321.com';
        c.AccountId = a.Id;
        insert c;
        
        List<Device__c> insMasDev = new List<Device__c>();
        Device__c md = new Device__c();
        md.Serial_Number__c = '5001';
        md.Customer_Number__c = 'TEST123';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        insMasDev.add(md1);
        insert insMasDev;
        
        List<Vehicle__c> insMasVeh = new List<Vehicle__c>();
        Vehicle__c mv = new Vehicle__c();
        mv.VIN__c = '111';
        mv.Vehicle_Id__c = 'Q1';
        insMasVeh.add(mv);
        
        Vehicle__c mv1 = new Vehicle__c();
        mv1.VIN__c = '112';
        mv1.Vehicle_Id__c = 'Q1';
        insMasVeh.add(mv1);
        insert insMasVeh;
        
        List<Vehicle_Device_Map__c> insVehDevAsc = new List<Vehicle_Device_Map__c>();
        Vehicle_Device_Map__c vda = new Vehicle_Device_Map__c();
        vda.Vehicle__c = mv.Id;
        vda.Device__c = md.Id;
        vda.Account__c = a.Id;
        vda.Name = 'Test Fleet';
        vda.Customer_Number__c = 'TEST123';
        vda.OracleToSQL_Status__c = 'I';
        insVehDevAsc.add(vda);
        
        Vehicle_Device_Map__c vda1 = new Vehicle_Device_Map__c();
        vda1.Vehicle__c = mv1.Id;
        vda1.Device__c = md.Id;
        vda1.Account__c = a.Id;
        vda1.Name = 'Test Fleet';
        vda1.Customer_Number__c = 'TEST123';
        vda1.OracleToSQL_Status__c = 'I';
        insVehDevAsc.add(vda1);
        insert insVehDevAsc;
        
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Fleet_Account__c = a.Id;
        //ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Possible RA';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));       
        controller.CreateRA();      
        
        RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open'  );
        insert RALog;
     
        
        Test.startTest();
        //create RAlog Details
        RA_Log_Detail__c RALogDet = new RA_Log_Detail__c(RA_Log_Id__c =RALog.Id);
        
        System.currentPageReference().getParameters().put('raLogId', RALog.Id); 
        RALogDetailController addRAlogDet = new RALogDetailController();
        addRAlogDet.raLogId = RALog.Id;
        addRAlogDet.getRALogDetails();
        //System.assert(addLocVar.results.size() > 0);
        Test.stopTest();
    
        }
 }