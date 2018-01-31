@isTest 
public class AttachmentTriggerHandler_Test{

    public static testmethod void unitTestAtt(){
        Account Acc = UtilsTest.CreateAccount(); 
        Opportunity opp = UtilsTest.CreateOpportunity(Acc);
        Attachment att = UtilsTest.CreateAttachmentForOpportunity(opp);
        Test.startTest();
        Attachment att2 = UtilsTest.CreateAttachmentForOpportunity(opp);        
        Test.stopTest();  
    }

}