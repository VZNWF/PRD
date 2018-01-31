@isTest
public class AccountSearchControllerTesting{

public static testmethod void testing(){

//create order tracking record
Order_Tracking__c orIns = new Order_Tracking__c(Customer_Number__c = 'ABC123');
insert orIns;

//create Account

Account accIns = new Account(name = 'Qlick');
insert accIns;


//creating instance of class

 ApexPages.StandardController sc = new ApexPages.StandardController(orIns);
 AccountSearchController classIns = new AccountSearchController(sc);

 classIns.searchResults = [select id from account limit 1];
 classIns.search();


}


}