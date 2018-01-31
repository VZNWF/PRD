@isTest(SeeAllData=True)
private class PilotConversionRequestControllerTest {
    
    @isTest static void test_method_one() {
        // Implement test code
        Account testAccount = testUtils.createAccount();
        Account testRelatedReseller = testUtils.createAccount();
        testAccount.SOS_Owner__c = UserInfo.getUserId();
        update testAccount;
        //build parent opp
        Opportunity parentOpp = new Opportunity(name='parent opp name',
                                    AccountId = testAccount.id,
                                    StageName = 'stage name', 
                                    CloseDate = Date.newInstance(2016,  01, 01), 
                                    Hardware_Tier__c = 'parent hardware tier',
                                    Service_Tier__c = 'parent service tier',
                                    Bundle_Tier__c = 'parent bundle tier',
                                    Accessory_Tier__c = 'parent accessory tier');
        insert parentOpp;
        //build chiild?
        Opportunity childOpp = new Opportunity(name='child opp name',
                                    AccountId = testAccount.Id,
                                    Related_Reseller__c = testRelatedReseller.Id,
                                    StageName = 'stage name', 
                                    CloseDate = Date.newInstance(2016,  01, 01), 
                                    Hardware_Tier__c = 'child hardware tier',
                                    Service_Tier__c = 'child service tier',
                                    Bundle_Tier__c = 'child bundle tier',
                                    Accessory_Tier__c = 'child accessory tier',
                                    Parent_Opportunity__c = parentOpp.Id);
        insert childOpp;

        PilotConversionRequestController controller = new PilotConversionRequestController();
        controller.parentOppId = parentOpp.id;
        controller.childOppId = childOpp.id;
        Opportunity insertedOpp = [SELECT Id, Name FROM Opportunity WHERE id =:parentOpp.Id];
        System.assertEquals(insertedOpp.Id, controller.getParentOpp().Id);      
        System.assertEquals(insertedOpp.name, controller.getParentOpp().name);

        system.assertEquals(testRelatedReseller.Name,controller.getRelatedResellerName());


    }
}