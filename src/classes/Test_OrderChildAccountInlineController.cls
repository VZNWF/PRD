@IsTest
Public Class Test_OrderChildAccountInlineController{
    Public static testmethod void OrderChildAccountInlineController(){
    
    
    Account acc = new Account();
    acc.Name ='Test Account';
    acc.Acct_Type__c = 'Sales Partner';
    acc.AccountNumber ='1235698';
    acc.XXCustomer_Number__c ='123456';
    acc.Type  = 'Prospect - End Customer';
    acc.Sub_Type__c ='VAR';
    Insert acc;
    System.AssertEquals(acc.Id!=null,True);
    
    Account childacc = new Account();
    childacc.Name ='Test Account';
    childacc.Acct_Type__c = 'Sales Partner';
    childacc.AccountNumber ='1235698';
    childacc.XXCustomer_Number__c ='123456';
    childacc.Type  = 'Prospect - End Customer';
    Insert childacc;
    System.AssertEquals(childacc.Id!=null,True);
    
    
    Orders__c order1 = new Orders__c();
    order1.Account__c = acc.Id;
    Insert order1;
    System.AssertEquals(order1.Id!=null,True);
    
    order1.Child_Account__c =childacc.Id;
    Update order1;
    System.AssertEquals(order1.Id!=null,True);
    
    Apexpages.StandardController Ctrl =  new Apexpages.StandardController(order1);
    apexpages.currentpage().getparameters().put('id',order1.Id);
    OrderChildAccountInlineController child = new OrderChildAccountInlineController(ctrl);
    
    child.getchildAccounts();
    child.UpdateChildaccount();
    }

}