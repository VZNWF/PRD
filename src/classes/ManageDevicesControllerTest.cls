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
private class ManageDevicesControllerTest {

    static testMethod void myUnitTest() {
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
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Origin = 'Phone';
        ca.Reason = 'Fleet Assessment';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();
        
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();
        
        controller.fnReset();
        
        controller.fnAdd();
        controller.fnSubmit();
        
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
        for(ManageDevicesController.CaseDevices cvdr: controller.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            break;
        }
        controller.fnSubmit();
        controller.delDeviceId = md.Id;
        controller.fnDelete();
    }
    
        static testMethod void RATestDefectiveProduct() {
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
        md.Model_Type__c = '5200E3VD';   
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';   
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
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();
        
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();
        
        controller.fnReset();
        
        controller.fnAdd();
        controller.fnSubmit();
        
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
         test.startTest();
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
        //controller1.CreateOrder();
            
        PageReference pr1 = Page.ManageDevices;
        Test.setCurrentPage(pr1);
        ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));         
        controller2.CreateRA();
         test.stopTest();
    } 
    static testMethod void RATestDefectiveProduct1() {
       
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;
        
        case ca1 = new case();
        ca1.ContactId = c.Id;
        ca1.AccountId = a.Id;
        ca1.Is_Fleet_same_as_Account__c = true;
        ca1.RecordTypeId = caseReasRecordTypeId;
        ca1.Reason = 'RA';
        ca1.Case_Sub_Reason__c = 'Defective Product';
        ca1.RA_Type__c = 'Replace - Product (No return)';
        ca1.Origin = 'Phone';
        insert ca1;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();       
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();        
        controller.fnReset();      
        controller.fnAdd();
        controller.fnSubmit();
        
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
         test.startTest();
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
        controller1.CreateOrder();
        
        PageReference pr4 = Page.ManageDevices;
        Test.setCurrentPage(pr4);
        
        ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca1));
        controller2.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller2.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller2.fnAdd();       
        controller2.fnSearch();
        controller2.getFilterOptions();
        controller2.searchFilter = 'VehicleVIN';
        controller2.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller2.fnSearch();        
        controller2.fnReset();        
        controller2.fnAdd();
        controller2.fnSubmit();
        
        ManageDevicesController controller3 = new ManageDevicesController(new ApexPages.StandardController(ca1));
        for(ManageDevicesController.CaseDevices cvdr: controller3.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller3.fnSubmit();
        controller3.delDeviceId = md.Id;
        controller3.CreateRA();
        controller3.CreateOrder();
         test.stopTest();
    }
    
    static testMethod void RATestIncorrectPartOrdered() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;
            
        case ca1 = new case();
        ca1.ContactId = c.Id;
        ca1.AccountId = a.Id;
        ca1.Is_Fleet_same_as_Account__c = true;
        ca1.RecordTypeId = caseReasRecordTypeId;
        ca1.Reason = 'RA';
        ca1.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca1.RA_Type__c = 'Replace - Product (No return)';
        ca1.Origin = 'Phone';
        insert ca1;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
         test.startTest();
        controller.fnAdd();       
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();       
        controller.fnReset();        
        controller.fnAdd();
        controller.fnSubmit();
        
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
            
        PageReference pr1 = Page.RALogPage;
        Test.setCurrentPage(pr1);
        
        ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller2.fnAddRow();
        controller2.fnSaveNonSerialzed();
        controller2.UpdateRA();
        controller2.performValidations();
        controller2.deleteNonserialized();
        controller2.deleteSrialized();
        controller2.createOrder();
        controller2.SendEmail();
            
            PageReference pr4 = Page.ManageDevices;
        Test.setCurrentPage(pr4);
        
        ManageDevicesController controller3 = new ManageDevicesController(new ApexPages.StandardController(ca1));
        controller3.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller3.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller3.fnAdd();       
        controller3.fnSearch();
        controller3.getFilterOptions();
        controller3.searchFilter = 'VehicleVIN';
        controller3.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller3.fnSearch();        
        controller3.fnReset();        
        controller3.fnAdd();
        controller3.fnSubmit();
        
        ManageDevicesController controller4 = new ManageDevicesController(new ApexPages.StandardController(ca1));
        for(ManageDevicesController.CaseDevices cvdr: controller4.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller4.fnSubmit();
        controller4.delDeviceId = md.Id;
        controller4.CreateRA();
        controller4.CreateOrder();
         test.stopTest();
    }
    
    static testMethod void RATestPilotReturn() {
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        
        List<Device__c> insMasDev = new List<Device__c>();
        Device__c md = new Device__c();
        md.Serial_Number__c = '5001';
        md.Customer_Number__c = 'TEST123';
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Pilot Return';
        ca.RA_Type__c = 'Return - Product (New)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();       
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();        
        controller.fnReset();        
        controller.fnAdd();
        controller.fnSubmit();
        
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
         test.startTest();
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
        controller1.CreateOrder();
        controller1.getRALogDisplay();
        controller1.CancelRA();
         test.stopTest();
  }
    
    static testMethod void RATestPossibleRA() {
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
         test.startTest();
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));       
        controller.CreateRA();  
         test.stopTest();
    }
    
        static testMethod void RATestNonserialiseddeviceswithorder() {
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
            
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
              
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

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
             
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller1.CreateRA();
            
        PageReference pr1 = Page.RALogPage;
        Test.setCurrentPage(pr1);
        
        ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 2;
            Nonserial.Unit_under_warranty__c = 'Yes';
            Nonserial.RA_Location__c = Loc.Id;                     
        }      
            controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.CreateOrder();
            
            }
    
     static testMethod void RATestSerialiseddeviceswithorder() {
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
         
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        
        List<Device__c> insMasDev = new List<Device__c>();
        Device__c md = new Device__c();
        md.Serial_Number__c = '5001';
        md.Customer_Number__c = 'TEST123';
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
                
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();       
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();        
        controller.fnReset();
        controller.fnSubmit();
        controller.searchVehicle();
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
        for(RA_Log_Detail__c serial: controller1.lstCaseDevice){
            serial.RA_Type__c = 'Replace - Product (No return)';
            serial.Unit_Type_Needed_Serialised__c = '5200 GPS Only Non-Diagnostic Hardware (5200N3VD)';
            serial.Reason_Returned__c = 'B- High age (black bold messages)';
            serial.Unit_under_warranty__c = 'Yes';
            serial.RA_Location__c = Loc.Id;  
             break;
        } 
        
        controller1.UpdateRA();
        controller1.CreateOrder();
           PageReference pr1 = Page.RALogPage;
           Test.setCurrentPage(pr1);
         test.startTest();
         controller1.getDispositionList();
         controller1.getRALogDisplay();
         controller1.getNonserializedDevice();
         
         RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0   );
        insert RALog;
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
         
        for(RA_Log_Detail__c serial: controller2.lstCaseDevice){
            serial.RA_Type__c = 'Replace - Product (No return)';
           // serial.Unit_Type_Needed_Serialised__c = '5200 GPS Only Non-Diagnostic Hardware (5200N3VD)';
           serial.Unit_Type_Needed_Serialised__c = '5200E3VD GPS Extended (5200E3VD)';
            serial.Reason_Returned__c = 'B- High age (black bold messages)';
            serial.Unit_under_warranty__c = 'Yes';
            serial.RA_Location__c = Loc.Id;  
             break;
        } 
         controller2.UpdateRA();        
        controller2.CreateOrder();
        controller2.checkType();
        
       test.stopTest();
    }
    
    static testMethod void RATestDispositionTypeNo() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD'; 
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0  );
        insert RALog;
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 2;
            Nonserial.Unit_under_warranty__c = 'No';
            Nonserial.RA_Location__c = Loc.Id;                     
        }      
            controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.CreateOrder();
          
    } 
    
    static testMethod void RATestSendEmail() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0  );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 2;
            Nonserial.Unit_under_warranty__c = 'No';
            Nonserial.RA_Location__c = Loc.Id;                     
        }      
            controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.CreateOrder();
            controller2.SendEmail();
          
    } 
    
        static testMethod void RATestSendEmailwithNoWarranty() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open' , Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0 );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = null;
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 0;
            Nonserial.Unit_under_warranty__c = null;
            Nonserial.RA_Location__c = null;                     
        }      
            //controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.CreateOrder();
            controller2.SendEmail();         
    } 
    static testMethod void RATestSendEmailIncorectPartOrder() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0  );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = null;
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 0;
            Nonserial.Unit_under_warranty__c = 'Yes';
            Nonserial.RA_Location__c = null;                     
        }      
            //controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.assignUnitType();
            controller2.CreateOrder();
            controller2.SendEmail();         
    } 
    
     static testMethod void RATestSerialiseddeviceswithorderwithNoUnitTypeNeeded() {
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
         
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        
        List<Device__c> insMasDev = new List<Device__c>();
        Device__c md = new Device__c();
        md.Serial_Number__c = '5001';
        md.Customer_Number__c = 'TEST123';
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
                
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
        ManageDevicesController controller = new ManageDevicesController(new ApexPages.StandardController(ca));
        controller.searchTxtArea = md.Serial_Number__c+','+md1.Serial_Number__c+','+md1.Serial_Number__c+' \n '+md1.Serial_Number__c;
        for(ManageDevicesController.AllDevices vdr: controller.availableDeviceList){
            vdr.isSelected = true;
        }
        
        controller.fnAdd();       
        controller.fnSearch();
        controller.getFilterOptions();
        controller.searchFilter = 'VehicleVIN';
        controller.searchTxtArea = mv.VIN__c+','+mv.VIN__c+'\n'+mv1.VIN__c;
        controller.fnSearch();        
        controller.fnReset();
        controller.fnSubmit();
        controller.searchVehicle();
        ManageDevicesController controller1 = new ManageDevicesController(new ApexPages.StandardController(ca));
        for(ManageDevicesController.CaseDevices cvdr: controller1.selectedDeviceList){
            cvdr.strComments = 'Test Comment';
            cvdr.dispositionType  = 'RA';
            cvdr.unitUnderWrty = 'Yes';
            break;
        }
        controller1.fnSubmit();
        controller1.delDeviceId = md.Id;
        controller1.CreateRA();
        for(RA_Log_Detail__c serial: controller1.lstCaseDevice){
            serial.RA_Type__c = 'Replace - Product (No return)';
            serial.Unit_Type_Needed_Serialised__c = '5200 GPS Only Non-Diagnostic Hardware (5200N3VD)';
            serial.Reason_Returned__c = 'B- High age (black bold messages)';
            serial.Unit_under_warranty__c = 'Yes';
            serial.RA_Location__c = Loc.Id;  
             break;
        }         
        controller1.UpdateRA();
        controller1.CreateOrder();
           PageReference pr1 = Page.RALogPage;
           Test.setCurrentPage(pr1);
         test.startTest();
         controller1.getDispositionList();
         controller1.getRALogDisplay();
         controller1.getNonserializedDevice();
         
         RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c,Emailsent__c = true, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open' , Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0 );
        insert RALog;
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
         
        for(RA_Log_Detail__c serial: controller2.lstCaseDevice){
            serial.RA_Type__c = 'Replace - Product (No return)';
           // serial.Unit_Type_Needed_Serialised__c = '5200 GPS Only Non-Diagnostic Hardware (5200N3VD)';
           serial.Unit_Type_Needed_Serialised__c = null;
            serial.Reason_Returned__c = 'B- High age (black bold messages)';
            serial.Unit_under_warranty__c = 'Yes';
            serial.RA_Location__c = null;  
             break;
        } 
         controller2.UpdateRA(); 
        controller2.SendEmail();       
        controller2.CreateOrder();
        controller2.checkType();
        
       test.stopTest();
    }
       static testMethod void RATestSendEmailwithNoLocation() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0 );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 0;
            Nonserial.Unit_under_warranty__c = 'Yes';
            Nonserial.RA_Location__c = null;                     
        }      
            //controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.assignUnitType();
            controller2.CreateOrder();
            controller2.SendEmail();         
    }   
    
     static testMethod void RATestSendEmailwithNoQuantity() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0  );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = null;
            Nonserial.Unit_under_warranty__c = 'Yes';
            Nonserial.RA_Location__c = Loc.Id;                     
        }      
            //controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            controller2.assignUnitType();
            controller2.CreateOrder();
            controller2.SendEmail();         
    }  
    
     static testMethod void RATestSendEmailwithOrdAlreadyCreated() {
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
        md.Model_Type__c = '5200E3VD';
        insMasDev.add(md);
        
        Device__c md1 = new Device__c();
        md1.Serial_Number__c = '5002';
        md1.Customer_Number__c = 'TEST123';
        md1.Model_Type__c = '5200E3VD';
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
        
        Location__c Loc = new Location__c();        
        loc.Name='TestLoc121';
        loc.Customer__c = a.Id;
        insert Loc;
        Id caseReasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.RecordTypeId = caseReasRecordTypeId;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Incorrect Part Ordered';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca;

        PageReference pr = Page.ManageDevices;
        Test.setCurrentPage(pr);
        
       RA_Log__c RAlog = new RA_Log__c(Case_Id__c = ca.CaseNumber,RA_Type__c = ca.RA_Type__c, Case_Sub_Reason__c = ca.Case_Sub_Reason__c, Account_Name__c = ca.Account.Name , Case__c =ca.Id, RA_Status__c = 'Open', Units_in_RA_Non_Serialized__c = 0, Units_in_RA_Serialized__c = 0  );
        insert RALog;       
         ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller2 = new ManageDevicesController(new ApexPages.StandardController(ca));
            controller2.fnAddRow();            
            //controller2.fnSaveNonSerialzed();
       for(RA_Log_Detail__c Nonserial: controller2.lstNonRALogDetails ){    
            Nonserial.RA_Type__c = 'Replace - Product (No return)';
            Nonserial.Non_Serialized_devices__c ='(PARTS063) Satellite Antenna';
            Nonserial.Unit_Type_Needed_Non_Serialised__c = '(PARTS063) Satellite Antenna';
            Nonserial.Reason_Returned__c = 'B- High age (black bold messages)';
            Nonserial.Quantity__c = 2;
            Nonserial.Unit_under_warranty__c = 'No';
            Nonserial.RA_Location__c = Loc.Id;                     
        }                
            controller2.fnSaveNonSerialzed();
            controller2.UpdateRA();
            //controller2.NSUnitTypeNeeded();
            controller2.CreateOrder();
            controller2.SendEmail();           
        ApexPages.currentpage().getParameters().put('raLogId',RALog.Id);        
         ManageDevicesController controller3 = new ManageDevicesController(new ApexPages.StandardController(ca));
         controller3.CreateOrder();         
    }   
    
}