@isTest
public class VehicleLogUtility_Test {
    private static Account newAccount;
    private static Contact newContact;
    private static Orders__c newOrders;
    private static Location__c newLocation;
    private static ETA_Staging__c etaStaging;
    private static Order_Line_Item_Details__c newOLID;
    
    public static void createTestData(){
       
       List<InstallType__c> instTypeList = new List<InstallType__c>();
       instTypeList.add(new InstallType__c(Name='Install', Code__c='In'));
       instTypeList.add(new InstallType__c(Name='Swap', Code__c='Sw'));
       instTypeList.add(new InstallType__c(Name='Training', Code__c='Tr'));
       instTypeList.add(new InstallType__c(Name='Transfer', Code__c='Xf'));
       insert instTypeList;
        
        
        User user = new User();
        user.ProfileId = UserInfo.getProfileId();
        user.Username = 'test' + System.currentTimeMillis() + '@test.com';
        user.LastName = 'Test';
        user.Email = 'test@test.com';
        user.Alias = 'Test';
        user.CommunityNickname = 'UserWithRoleTest';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        insert user;
        
       OrderICuser__c OrderCS = new OrderICuser__c();
       OrderCS.Name = 'Test';
       OrderCS.Email__c = 'test@test.com';
       insert OrderCS;
        
       newAccount = new Account();  
       newAccount.Name = 'TestAccount';        
       newAccount.Installation_Coordinator__c = user.Id;  
       insert newAccount ;
       
       newContact = new Contact();  
       newContact.FirstName = 'TestFirst';  
       newContact.LastName = 'TestLast';   
       newContact.Email = 'Test@First.com';     
       insert newContact;
       
       
       newOrders = new Orders__c();       
       newOrders.Account__c = newAccount.id;   
       newOrders.Contact__c  = newContact.Id;  
       newOrders.GP_ERP_Order_ID__c  = 'TestOrderID';    
       insert newOrders;  
         
       
  
       newLocation = new Location__c();       
       newLocation.Customer__c = newAccount.id;
       newLocation.Name = 'TestLocation';      
       insert newLocation ;  
       
       etaStaging = new ETA_Staging__c();
       etaStaging.ETA_Staging_Status__c = 'Pending';
       etaStaging.Account__c = newAccount.Id;
       etaStaging.Order__c = newOrders.Id;
       etaStaging.Location__c = newLocation.Id; 
       insert etaStaging;
          
       newOLID = new Order_Line_Item_Details__c();                   
       newOLID.Location__c  = newLocation.id;
       newOLID.SF_Orders__c     = newOrders.id;
       newOLID.Contact_Name__c =newContact.Name;
       newOLID.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID.ETA_Staging__c = etaStaging.Id;
       newOLID.Service_Completed__c = null;
       insert newOLID;    
    }
    static testMethod void createdStatusTest() {
        Test.startTest();
        createTestData();
        etaStaging.ETA_Activity_ID__c = '123456';
        etaStaging.Accept_Reject_Job__c = 'Accept';        
        etaStaging.First_Attempt_Date__c = Date.today();
        etaStaging.Second_Attempt_Date__c = Date.today()+1;
        etaStaging.ETA_Staging_Status__c = 'Pending';
        etaStaging.Assigned_Resource_ID__c = 'verizon_nwf';
        etaStaging.Scheduled_Date__c = Date.today()+2;
        etaStaging.Assigned_Resource_ID__c = 'Reject';
        etaStaging.Accept_Reject_Job__c = 'Reject';        
        update etaStaging;
        etaStaging.Accept_Reject_Job__c = 'Accept';
        update etaStaging;
        etaStaging.ETA_Staging_Status__c = 'Cancelled';
        update etaStaging;
        etaStaging.Scheduled_Date__c = Date.today()+3;
        update etaStaging;
        Test.stopTest();
    }
    static testMethod void firstAttemptTest() {
        createTestData();

        Vehicle_Log__c objNewLog = new Vehicle_Log__c();
        objNewLog.Old_Value__c = 'Created';
        objNewLog.Old_Value_TimeStamp__c = system.now();
        objNewLog.Order_Line_Item_Detail__c = newOLID.Id;
        objNewLog.Field_Api__c = 'ComputedVehicleStatus';
        insert objNewLog;
        etaStaging.Assigned_Resource_ID__c = 'Accept';
        etaStaging.Accept_Reject_Job__c = 'Accept';
        etaStaging.First_Attempt_Date__c = Date.today();
        update etaStaging;
        etaStaging.Assigned_Resource_ID__c = 'Reject';
        etaStaging.Accept_Reject_Job__c = 'Reject';
        update etaStaging;
    }
    
    static testMethod void multiAttemptTest() {
        createTestData();
        etaStaging.First_Attempt_Date__c = Date.today();               
        etaStaging.Second_Attempt_Date__c= Date.today();
        update etaStaging;
        etaStaging.Second_Attempt_Date__c = Date.today()+1;
        update etaStaging;
    }
    
    static testMethod void AttemptTest() {
        createTestData();
        etaStaging.ETA_Activity_ID__c = '123';
        etaStaging.First_Attempt_Date__c = Date.today();
        etaStaging.Second_Attempt_Date__c= Date.today();
        etaStaging.Scheduled_Date__c= Date.today();
        etaStaging.Assigned_Resource_ID__c = 'verizon_nwf';
        etaStaging.ETA_Staging_Status__c = 'Cancelled';
        update etaStaging;
        //VehicleLogUtility.hasLogged_vehicle = false;
        newOLID.Service_Completed__c = 'Yes';
        update newOLID;
        etaStaging.Second_Attempt_Date__c= Date.today()+1;
        update etaStaging;
    }
    static testMethod void PCTest() {
        createTestData();
        etaStaging.Assigned_Resource_ID__c = 'Reject';
        etaStaging.Accept_Reject_Job__c = 'Reject';
        update etaStaging;
        etaStaging.Assigned_Resource_ID__c = 'verizon_nwf';        
        update etaStaging;
        //VehicleLogUtility.hasLogged_vehicle = false;
        newOLID.Service_Completed__c = 'Yes';
        update newOLID;
        etaStaging.Second_Attempt_Date__c= Date.today()+1;
        update etaStaging;
    }
    
    static testMethod void vehNoShowTest() {
        createTestData();
        //VehicleLogUtility.hasLogged_vehicle = false;

        newOLID.Service_Completed__c = 'No show';
        update newOLID;
    }
    
    static testMethod void vehReturnLaterTest() {
        createTestData();
        //VehicleLogUtility.hasLogged_vehicle = false;

        newOLID.Service_Completed__c = 'Return on a later date';
        update newOLID;
        
        //VehicleLogUtility.hasLogged_vehicle = false;
        
        newOLID.Service_Completed__c = 'Cancelled by customer';
        update newOLID;
        
    }
    
    static testMethod void completedTest() {
        createTestData();
        Vehicle_Log__c objNewLog = new Vehicle_Log__c();
        objNewLog.Old_Value__c = 'No show';
        objNewLog.Old_Value_TimeStamp__c = system.now();
        objNewLog.Order_Line_Item_Detail__c = newOLID.Id;
        objNewLog.Field_Api__c = 'ComputedVehicleStatus';
        insert objNewLog;
        //VehicleLogUtility.hasLogged_vehicle = false;
        
        newOLID.Service_Completed__c = 'Cancelled by customer';
        update newOLID;
        
        //VehicleLogUtility.hasLogged_vehicle = false;
        
        newOLID.Service_Completed__c = 'Yes';
        update newOLID;
        
        //VehicleLogUtility.hasLogged_vehicle = false;
        newOLID.Service_Completed__c = 'No';
        update newOLID;
        
    }
    
     
}