@isTest
public class OpportunitySearchControllerTesting{

public static testmethod void testing(){

//create order tracking record
Order_Tracking__c orIns = new Order_Tracking__c(Customer_Number__c = 'ABC123');
insert orIns;

//create Account

Opportunity oppIns = new Opportunity(name = 'selling Mobiles', stageName = 'Closed');
oppIns.closeDate = date.today();
insert oppIns;

//creating instance of class

 ApexPages.StandardController sc = new ApexPages.StandardController(orIns);
 OpportunitySearchController  classIns = new OpportunitySearchController(sc);

 classIns.searchResults = [select id from Opportunity limit 1];
 classIns.search();
 }
 
 }