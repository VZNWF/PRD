/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the OrderLocationLookupController
Modifications:
******************************************************************/
@isTest()
private class OrderLocationLookupControllerTest {
    
    static testMethod void testCreateNewLocation() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        
        Test.startTest();
       //create location  record
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer', Customer__c = acc.Id);
        insert loc;
        
        System.currentPageReference().getParameters().put('ordId', ord.Id); 
        OrderLocationLookupController addLocVar = new OrderLocationLookupController();
        addLocVar.searchString = 'Sam killmer';
        System.assert(addLocVar.results.size() > 0);
        Test.stopTest();
    
        }
        
        static testMethod void testsearchLocation() {
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer');
        insert loc;
        Test.startTest();
        OrderLocationLookupController addLocVar = new OrderLocationLookupController();
        Test.stopTest();
    
        }
        
        /*static testMethod void testsaveLocation() {
         Location__c loc = new Location__c(ContactName__c = 'Sam killmer');
        insert loc;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(loc);
        OrdersLocationsController addLocVar = new OrdersLocationsController(sc);
        loc.OpportunityId__c = oppId;
        insert loc;
        Test.stopTest();
    
        }*/
         static testMethod void testCall1(){
            OrderLocationLookupController ol = new OrderLocationLookupController();
            ol.saveLocation();
            ol.getFormTag();
            ol.getTextBox();
            ol.refreshTab();
            ol.search();
        }
     }