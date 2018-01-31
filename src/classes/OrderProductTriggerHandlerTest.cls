/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the OrderProductTriggerHandler
Modifications:
******************************************************************/
@isTest(SeeAllData=true)
public Class OrderProductTriggerHandlerTest{


    static TestMethod void opHandler1(){
        Account a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214';
        a.Contract_Type__c='Standard';
        insert a;
        
        opportunity o = new opportunity();
        o.AccountId = a.Id;
        o.Type_of_sale__c = 'Indirect';
        O.CloseDate = system.today();
        O.name = 'Test';
        O.stagename = 'pilot'; 
        o.LeadSource='2G Migration';
        o.Existing_AVL_User__c='No';  
        o.Location_Name__c='abc'; 
        
        insert o;
        
        Orders__c Ord2 = new Orders__c();
        Ord2.Account__c = A.Id;
        Ord2.opportunity__c = O.Id;
        Ord2.Order_Types__c = 'BUNDLE';
        
        insert Ord2;
         
          
                   
        Contact c = new Contact();
        c.Mailingcity = 'San Diego';
        c.MailingStreet='999 main st';
        c.MailingPostalCode='12345-9999';
        c.MailingState='California';
        c.MailingCountry='United States';
        c.LastName='Test Lastname';   
        c.FirstName='Test Firstname';
        insert c;   
        
        Location__c loc=new Location__c();
        loc.OpportunityId__c=o.Id;
        loc.Garage_Address1__c='PO BOX';
        loc.Garage_City__c='kdkdkd';
        loc.Garage_State__c='GA';
        loc.Garage_Zip__c='9829q9q';
        loc.Phone__c='020222';
        loc.ContactName__c=c.Name;    
        insert loc;
        
        Location__c loc1=new Location__c();
        loc1.OpportunityId__c=o.Id;    
        insert loc1;
        
        OrderLocation__c  oLoc=new OrderLocation__c();
        oLoc.Location__c=loc1.Id;
        oLoc.Orders__c=Ord2.Id;
        oLoc.Ship_To_Installer__c = 'N';       
        insert oLoc;
        
        OrderProductTriggerHandler ot=new OrderProductTriggerHandler();
        Order_Product__c op=new Order_Product__c();
        op.Product_Name__c='5500N3AS GPS Diagnostics';
        op.OrderLocationMappings__c=oLoc.Id;
        insert op;
        
        Map<Id,Order_Product__c> opMap=new Map<Id,Order_Product__c>();
        opMap.put(op.Id,op);
        List<Order_Product__c> opList=new List<Order_Product__c>();
        opList.add(op);
        OrderProductTriggerHandler.handleAfterUpdate(opMap);
        OrderProductTriggerHandler.handleAfterDelete(opList);
        OrderProductTriggerHandler.handleAfterUnDelete(opList);
        
    }
}