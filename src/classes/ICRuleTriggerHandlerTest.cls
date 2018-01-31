@isTest 
public class ICRuleTriggerHandlerTest{
    
    private static Account newAccount = new Account();  
    private static Contact newContact;
    private static Orders__c newOrders;
    private static Opportunity newOpportunity;
    private static Installation_Coordinator_Assignment_Rule__c newICRule;
    //private static Installation_Coordinator_Assignment_Rule__c newICRule1;
    private static User newUser;
    //private static User newUser1;
    
     public static String getUserNamePrefix(){

        return UserInfo.getOrganizationId() + System.now().millisecond();

    }
    
    public static void createTestData(){
    
       newAccount = new Account();  
       newAccount.Name = 'TestAccount'; 
       newAccount.Sub_Type__c = 'VAR';       
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
  
       newOpportunity = new Opportunity();       
       //AccountId = newAccount.id;
       newOpportunity.Name = 'TestOpportunity';    
       newOpportunity.StageName = 'Initial Meeting / Demo';
       newOpportunity.CloseDate = Date.today().addDays(30);  
       insert newOpportunity ; 
       
       newUser = new User();  
       newUser.Username = getUserNamePrefix() + 'standarduser@testorg.com';     
       newUser.LastName = 'TestUser'; 
       newUser.Email = 'TestUser@test.com';
       newUser.Alias = 'TestUser';        
       newUser.CommunityNickname = 'TestUser';  
       newUser.TimeZoneSidKey = 'GMT';
       newUser.LocaleSidKey = 'en_US';  
       newUser.EmailEncodingKey = 'UTF-8';
       newUser.ProfileId = '00e33000000zI6bAAE';  
       newUser.LanguageLocaleKey = 'en_US';  
         
       insert newUser ;
       
       
       
       newICRule = new Installation_Coordinator_Assignment_Rule__c();
       newICRule.Install_Coordinator__c = newUser.id;
       insert newICRule; 
       
       
       
       update newICRule; 
       
       newAccount.Force_Trigger_Update__c = true;
       update newAccount;
       
    }
    
     static testMethod void testprocessAccountsOnUpdate() {
       
       createTestData();
       
       test.startTest();
      
       
      // ICRuleTriggerHandler.processAccountsOnUpdate(newICRule.id, 'install','GP1101');
               test.stopTest();
       
       
     }
     
     static testMethod void testprocessOpportunitiesOnUpdate() {
       
       createTestData();
       
       test.startTest();
       newOpportunity.Force_Trigger_Update__c = true;
       update newOpportunity;
       
     //  ICRuleTriggerHandler.processOpportunitiesOnUpdate(newICRule.id);
               test.stopTest();
       
       
     }
    
 }