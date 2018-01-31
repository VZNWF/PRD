@isTest
public class Test_AccountandOptySearchController{

 static testMethod void AccountandOptySearchController() {
 testAccountandOptySearchController();
 }

static void testAccountandOptySearchController(){
    // create an account record 
    Order_Tracking__c ot = new Order_Tracking__c(Customer_Number__c='12345'); 
    insert ot;
    // create a new Account standard controller by passing it the account record
    ApexPages.StandardController controller = new ApexPages.StandardController(ot);

    // now pass it to the extension
    AccountSearchController stdController = new AccountSearchController(controller);

    system.assert(stdController != null); // controller has successfully been created
    
    OpportunitySearchController  stdController2 = new OpportunitySearchController(controller);
    
    system.assert(stdController2 != null); // controller has successfully been created
    // .. now test your extension methods, checking validity of results and code coverage. 

}

}