@istest
public class OrderLineItemDetailsTriggerHandler_Test{
    
    private static Account newAccount;
    private static Contact newContact;
    private static Orders__c newOrders;
    private static Location__c newLocation;
    private static ETA_Staging__c etaStaging;
    private static Order_Line_Item_Details__c newOLID;
     private static list<Order_Line_Item_Details__c> newOLIDlst;
    private static set<id> vlstnewOLID;
    private static set<id> orderid;
    @testsetup
    public static void insertSetting(){
       Toggle_Switch__c trgSw = new Toggle_Switch__c();
       trgsW.Name = 'ETA_Staging__c';
       trgSw.isTriggerDisabled__c = false;
       upsert trgSw;
    }
    
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
         
        orderid = new set<id>();
       orderid.add(newOrders.id);
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
        vlstnewOLID = new set<id>();
        vlstnewOLID.add(newOLID.id);
       insert newOLID;  
        //insert vlstnewOLID;
    }
    
    
    static testMethod void initiateNewOrderLineItemDetail() {
       
       createTestData();
       
       //update newOLID;
       delete newOLID;
         Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();
                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
        
       insert newOLID2;
       newOLID2.isSubmitted__c = true;
        
       update newOLID2;
       delete newOLID2;
       undelete newOLID2;
       
    }
    
     static testMethod void installationTestonCreate() {
       
       createTestData();       
       
       Test.startTest();      
       Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID2.Installation_Type__c = 'Install';
       newOLID2.ETA_Staging__c = etaStaging.Id;
       insert newOLID2;
       
       Order_Line_Item_Details__c newOLID3 = new Order_Line_Item_Details__c();                   
       newOLID3.Location__c  = newLocation.id;
       newOLID3.isSubmitted__c = false;
       newOLID3.SF_Orders__c     = newOrders.id;
       newOLID3.Contact_Name__c =newContact.Name;
       newOLID3.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID3.Installation_Type__c = 'Swap';
       newOLID3.ETA_Staging__c = etaStaging.Id;
       insert newOLID3;
                         
       Test.stopTest();
       
       ETA_Staging__c eta = [Select Id, Summary_Count__c from ETA_Staging__c where Id =: etaStaging.Id];
       
       System.assert(eta.Summary_Count__c == 'Sw:1 In:1');
       
       
    }
    
    static testMethod void installationTestonUpdate() {
       
       createTestData();       
       
           
       Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;       
       newOLID2.ETA_Staging__c = etaStaging.Id;
       insert newOLID2;
       
       Order_Line_Item_Details__c newOLID3 = new Order_Line_Item_Details__c();                   
       newOLID3.Location__c  = newLocation.id;
       newOLID3.isSubmitted__c = false;
       newOLID3.SF_Orders__c     = newOrders.id;
       newOLID3.Contact_Name__c =newContact.Name;
       newOLID3.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;       
       newOLID3.ETA_Staging__c = etaStaging.Id;
       insert newOLID3;
       
       Test.startTest();  
       newOLID2.Installation_Type__c = 'Install';
       update newOLID2;
       newOLID3.Installation_Type__c = 'Swap';
       update newOLID3;
       Test.stopTest();
       
       ETA_Staging__c eta = [Select Id, Summary_Count__c from ETA_Staging__c where Id =: etaStaging.Id];
       
       System.assert(eta.Summary_Count__c == 'Sw:1 In:1');
       
       
    }
    
     static testMethod void installationTestonDelete() {
       
       createTestData();       
       
           
       Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.Installation_Type__c = 'Install';
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;  
       newOLID2.ETA_Staging__c = etaStaging.Id;
       insert newOLID2;
       
       Order_Line_Item_Details__c newOLID3 = new Order_Line_Item_Details__c();                   
       newOLID3.Location__c  = newLocation.id;
       newOLID3.isSubmitted__c = false;
       newOLID3.SF_Orders__c     = newOrders.id;
       newOLID3.Contact_Name__c =newContact.Name;
       newOLID3.Installation_Type__c = 'Swap';
       newOLID3.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;       
       newOLID3.ETA_Staging__c = etaStaging.Id;
       insert newOLID3;
       
       Test.startTest();  
       
       delete newOLID2;
       
       delete newOLID3;
       Test.stopTest();
       
       ETA_Staging__c eta = [Select Id, Summary_Count__c from ETA_Staging__c where Id =: etaStaging.Id];
       
       System.assert(eta.Summary_Count__c != 'Sw:1 In:1');
       
       
    }
    
     static testMethod void installationTestonUndelete() {
       
       createTestData();       
       
           
       Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID2.Installation_Type__c = 'Install';       
       newOLID2.ETA_Staging__c = etaStaging.Id;
       insert newOLID2;
       
       Order_Line_Item_Details__c newOLID3 = new Order_Line_Item_Details__c();                   
       newOLID3.Location__c  = newLocation.id;
       newOLID3.isSubmitted__c = false;
       newOLID3.SF_Orders__c     = newOrders.id;
       newOLID3.Contact_Name__c =newContact.Name;
       newOLID3.Installation_Type__c = 'Swap';
       newOLID3.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;       
       newOLID3.ETA_Staging__c = etaStaging.Id;
       insert newOLID3;
       
       delete newOLID2;
       delete newOLID3;
       
       Test.startTest();  
       undelete newOLID2;
       undelete newOLID3;
       
       Test.stopTest();
       
       ETA_Staging__c eta = [Select Id, Summary_Count__c from ETA_Staging__c where Id =: etaStaging.Id];
       
       System.assert(eta.Summary_Count__c == 'Sw:1 In:1');
       
       
    }
     static TestMethod void TestMethodNew()
     {
        createTestData(); 
            Order_Line_Item_Details__c newOLID22 = new Order_Line_Item_Details__c();                   
       newOLID22.Location__c  = newLocation.id;
       newOLID22.isSubmitted__c = false;
       newOLID22.SF_Orders__c     = newOrders.id;
       newOLID22.Contact_Name__c =newContact.Name;
       newOLID22.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID22.Installation_Type__c = 'Install';       
       newOLID22.ETA_Staging__c = etaStaging.Id;
       //insert newOLID22;
          newOLIDlst = new list<Order_Line_Item_Details__c>();
       Order_Line_Item_Details__c newOLID2 = new Order_Line_Item_Details__c();
                   
       newOLID2.Location__c  = newLocation.id;
       newOLID2.isSubmitted__c = false;
       newOLID2.SF_Orders__c     = newOrders.id;
       newOLID2.Contact_Name__c =newContact.Name;
       newOLID2.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
        newOLIDlst.add(newOLID2);
         //insert newOLIDlst;
         newOLIDlst.add(newOLID22);
         insert newOLIDlst;
         Map<Id, Order_Line_Item_Details__c> mapolid = new map<Id, Order_Line_Item_Details__c>();
         mapolid.put(newOLIDlst[0].id, newOLIDlst[0]);
         OrderLineItemDetailsTriggerHandler olid = new OrderLineItemDetailsTriggerHandler(true,5);
        // olid.genOLIDeviceMap(orderid);
        
         // olid.createOLIEntries(newOLIDlst); 
          //   olid.deleteOLIEntries(vlstnewOLID);     
     }
        
}