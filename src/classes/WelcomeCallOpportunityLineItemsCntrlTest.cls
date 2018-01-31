@isTest(SeeAllData=True)
private class WelcomeCallOpportunityLineItemsCntrlTest {

   
    static testMethod void testController() {
  
    User u=[Select Id ,Name from User where Profile.Name='System Administrator'  and isActive=true Limit 1];
    
    System.RunAs(u){
 
        Account account = new Account();
        account.Name = 'Test';
        account.SOS_Owner__c=UserInfo.getUserId();
        account.Acct_Type__c='TRANSFER';
        account.Total_Number_of_Vehicles__c=10;
        account.Contract_Type__c=null;
        insert account;
        
       Opportunity_CPQ_Mapping__c o=Opportunity_CPQ_Mapping__c.getValues('Transfer');
       
      Opportunity_CPQ_Mapping__c o1=Opportunity_CPQ_Mapping__c.getValues('Default');   
        Opportunity opportunity = new Opportunity();
        
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Telogis';
        opportunity.CloseDate = Date.today().addDays(10);
        //Test Class Error Fix :Start
        opportunity.Type='Transfer (Reseller to Direct)';
        opportunity.LeadSource='E-Mail';
        opportunity.Specific_Lead_Source__c='Sales Info';
        opportunity.Existing_AVL_User__c='No';
        opportunity.HasContract__c=false;
        opportunity.Addendum_terms__c=o1.Addendum_terms__c;
        
        
        //Test Class Error Fix :End
       insert opportunity;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        DataBase.Insert(opportunityLineItem,false);
        
        Welcome_Call__c welcomeCall = new Welcome_Call__c();
        welcomeCall.Account_Name__c = account.Id;
        welcomeCall.Opportunity_Name__c = opportunity.Id;
        insert welcomeCall;
        
        WelcomeCallOpportunityLineItemsCntrl controller = new WelcomeCallOpportunityLineItemsCntrl(new ApexPages.StandardController(welcomeCall));
        controller.initPage();
        }
        
   
        
        
     }    
    }