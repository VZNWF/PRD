@istest(seealldata=true)
public class Workforce2_OLID_ETAStaging_Test {
    private static Account newAccount;
    private static Contact newContact;
    private static Orders__c newOrders;
    private static Location__c newLocation;
    private static ETA_Staging__c etaStaging;
    private static Order_Line_Item_Details__c newOLID;
    
    public static void createTestData(){
        
        Toggle_Switch__c trgSw = Toggle_Switch__c.getInstance('Workforce2_OLID');
      	trgSw.isTriggerDisabled__c = false;
        update trgSw;
        
        
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
        insert newOLID;    
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
    
    
    
}