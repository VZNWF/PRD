/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the OrderLocationHandler
Modifications:
//Vanditha - 6/16/2017 - Created FedexlinkURL method for OrderLocationHandler
******************************************************************/
@isTest(SeeAllData=true)
public Class OrderLocationHandlerTest{


    static TestMethod void TestoLoc1(){
    
        integer size=10;
        OrderLocationHandler ol=new OrderLocationHandler(true,10);
        Account acc=new Account();
        acc.Name='Test Account abc';
        insert acc;
        
        Orders__c ord=new Orders__c();
        ord.Account__c=acc.Id;
        ord.Address_Line_1__c='test ieoalk';
        insert ord;
        
        Location__c loc=new Location__c();
        loc.Name='TestLoc121';
        insert loc;
        
        OrderLocation__c oloc=new OrderLocation__c();
        oloc.Orders__c=ord.Id;
        oloc.Location__c=loc.Id;
        oloc.Order_Activity_Status__c = 'Completed';
        insert oloc;
        
        List<OrderLocation__c> olocList=new List<OrderLocation__c>();
        olocList.add(oloc);
        
        ol.handleBeforeUpdate(olocList);
        ol.handleBeforeInsert(olocList);
        
        
    }
    
     static TestMethod void TestFedexURL(){
    
        integer size=10;
        OrderLocationHandler ol=new OrderLocationHandler(true,10);
        Account acc=new Account();
        acc.Name='Test Account abc';
        insert acc;
        
        Orders__c ord=new Orders__c();
        ord.Account__c=acc.Id;
        ord.Address_Line_1__c='test ieoalk';
        insert ord;
        
        Location__c loc=new Location__c();
        loc.Name='TestLoc121';
        insert loc;
        
        OrderLocation__c oloc=new OrderLocation__c();
        oloc.Orders__c=ord.Id;
        oloc.Location__c=loc.Id;
        oloc.EO_Status__c= 'Shipped';
        oloc.Tracking_Numbers__c = '12345';
        oloc.Order_Activity_Status__c = 'Shipped';
        insert oloc;
        
        oloc.Tracking_Numbers__c = '8768585';
        update oloc;
        
        List<OrderLocation__c> olocList=new List<OrderLocation__c>();
        olocList.add(oloc);
        
        ol.handleBeforeUpdate(olocList);
        ol.handleBeforeInsert(olocList);
        ol.Fedexlink(olocList);
        
        
    }

}