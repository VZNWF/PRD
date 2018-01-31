@istest
public class CpqQuoteTriggerHandler_Test{
    
    public testmethod static void unitTest(){
        Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        Account Acc = new Account();
        Acc = utilsTest.createAccount();
        opportunity opp = new opportunity();
        opp = utilsTest.CreateOpportunity(Acc);
        CPQ_SOMAST__c cpqSOMAST = new CPQ_SOMAST__c();
        cpqSOMAST = utilsTest.createCPQ_SOMAST(opp);
        CPQ_SOMAST__c cpqSOMASTNonPrimary = new CPQ_SOMAST__c();    
        cpqSOMASTNonPrimary = utilsTest.createCPQ_SOMAST(opp);
        cpqSOMASTNonPrimary.primary__c = false;
        update cpqSOMASTNonPrimary;
        list<CPQ_SOMAST__c> listCPQ_SOMAST = new list<CPQ_SOMAST__c>();
        listCPQ_SOMAST.add(cpqSOMAST);
        listCPQ_SOMAST.add(cpqSOMASTNonPrimary);
        Test.starttest();
        delete listCPQ_SOMAST;
        Test.stoptest();
    }
    
}