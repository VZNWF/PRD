@isTest
public class OrdersTriggerHandler_Test {
    
    public static testmethod void OrdersTriggerHandlerContactRole() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);
      OpportunityContactRole oppContactRole = UtilsTest.CreateOpportunityContactRoles(opp,con);      
      Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id,Opportunity__c = opp.Id );
      test.startTest();
      insert Orders;
      test.stopTest();  
      orders__c ord = [select id,contact__c from orders__c where Id = :Orders.Id];
      system.assertEquals(Con.Id,Ord.Contact__C);
    }
    
    public static testmethod void OrdersTriggerHandlerContactRolePOC() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);      
      OpportunityContactRole oppContactRolePOC = UtilsTest.CreateOpportunityContactRolesPOC(opp,con);
      OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);
      Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id,Opportunity__c = opp.Id );
      test.startTest();
      insert Orders;
      test.stopTest();  
      orders__c ord = [select id,contact__c from orders__c where Id = :Orders.Id];
      system.assertEquals(Con.Id,Ord.Contact__C);
    }
    
    public static testmethod void OrdersTriggerHandlerContactRoleFleet() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);
      OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);
      Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id,Opportunity__c = opp.Id );
      test.startTest();
      insert Orders;
      test.stopTest();  
      orders__c ord = [select id,contact__c from orders__c where Id = :Orders.Id];
      system.assertEquals(Con.Id,Ord.Contact__C);
    }
    
    public static testmethod void OrdersTriggerHandlerNoOppty() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      acc.AccountNumber = 'ABC';
      update acc;  
      IODSEmailList__c iods = new IODSEmailList__c();
      iods.name = 'ABC';
      iods.Email__c = 'test@test.com';  
      insert iods;  
      Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id);
      test.startTest();
      insert Orders;
      test.stopTest();
      orders__c ord = [select id,contact_email__c from orders__c where Id = :Orders.Id];
      system.assertEquals(iods.Email__c,Ord.contact_email__c);  
    }
    public static testmethod void OrdersTriggerHandlerContactRoleDelete() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);
      OpportunityContactRole oppContactRole = UtilsTest.CreateOpportunityContactRoles(opp,con);  
      OpportunityContactRole oppContactRolePOC = UtilsTest.CreateOpportunityContactRolesPOC(opp,con);
       OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);  
      Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id,Opportunity__c = opp.Id );
      test.startTest();
      insert Orders;
      orders__c ord = [select id,contact__c from orders__c where Id = :Orders.Id];
      system.assertEquals(Con.Id,Ord.Contact__C);
      Delete Orders;
      unDelete Orders;
      test.stopTest();  
    }
    
    public static testmethod void OrdersTriggerHandlerRAStatusShipped() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);      
      OpportunityContactRole oppContactRolePOC = UtilsTest.CreateOpportunityContactRolesPOC(opp,con);
      OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);
      Orders__c Orders = new orders__c(Account__c = Acc.Id,Opportunity__c = opp.Id ); 
      insert Orders;  
      RA_Log__c RA = new RA_Log__c (RA_Status__c = 'Open',RA_Type__c = 'Test',Order__c= Orders.Id);
      insert RA;  
      test.startTest();    
      Orders.Order_Status__c = 'Shipped';
      update Orders;
      orders__c ord = [select id,Order_Status__c  from orders__c where Id = :Orders.Id];
      test.stopTest();  
      RA_Log__c RA1 = [select id,RA_Status__c from RA_Log__c where Id = :RA.Id];
      system.debug('RA Status is' + RA1.RA_Status__c );
      system.assertEquals(Ord.Order_Status__c ,RA1.RA_Status__c );
    }
    
    public static testmethod void OrdersTriggerHandlerRAStatusCancelled() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);      
      OpportunityContactRole oppContactRolePOC = UtilsTest.CreateOpportunityContactRolesPOC(opp,con);
      OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);
      Orders__c Orders = new orders__c(Account__c = Acc.Id,Opportunity__c = opp.Id ); 
      insert Orders;  
      RA_Log__c RA = new RA_Log__c (RA_Status__c = 'Open',RA_Type__c = 'Test',Order__c= Orders.Id);
      insert RA;  
      test.startTest();    
      Orders.Order_Status__c = 'Cancelled';
      update Orders;
      orders__c ord = [select id,Order_Status__c  from orders__c where Id = :Orders.Id];
      test.stopTest();  
      RA_Log__c RA1 = [select id,RA_Status__c from RA_Log__c where Id = :RA.Id];
      system.debug('RA Status is' + RA1.RA_Status__c );
      system.assertEquals(Ord.Order_Status__c ,RA1.RA_Status__c );
    }
    
    public static testmethod void OrdersTriggerHandlerRAStatusSubmitted() {
    
      OrderICuser__c ICuser = UtilsTest.createOrderICuser();
      Affiliate__c aff = UtilsTest.CreateAffiliate();
      contact con = UtilsTest.createContact(aff);      
      Account acc = UtilsTest.createAccountforOrder();
      Opportunity opp = UtilsTest.createOpportunity(acc);      
      OpportunityContactRole oppContactRolePOC = UtilsTest.CreateOpportunityContactRolesPOC(opp,con);
      OpportunityContactRole oppContactRoleFleet = UtilsTest.CreateOpportunityContactRolesFleet(opp,con);
      Orders__c Orders = new orders__c(Account__c = Acc.Id,Opportunity__c = opp.Id ); 
      insert Orders;  
      RA_Log__c RA = new RA_Log__c (RA_Status__c = 'Open',RA_Type__c = 'Test',Order__c= Orders.Id);
      insert RA;  
      test.startTest();    
      Orders.Order_Status__c = 'Completed';
      update Orders;
      orders__c ord = [select id,Order_Status__c  from orders__c where Id = :Orders.Id];
      test.stopTest();  
      RA_Log__c RA1 = [select id,RA_Status__c from RA_Log__c where Id = :RA.Id];
      system.debug('RA Status is' + RA1.RA_Status__c );
    }

    
}