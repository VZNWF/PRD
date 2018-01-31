@isTest(SeeAllData=True)
private class OpportunityLinkOverride_Test {
    
    @isTest static void testOpportunityLinkOverride() {
        Account testAccount = testUtils.createAccount();
        Opportunity testOpp = new Opportunity(name='parent opp name',
                                    AccountId = testAccount.id,
                                    StageName = 'stage name', 
                                    CloseDate = Date.newInstance(2016,  01, 01), 
                                    Hardware_Tier__c = 'parent hardware tier',
                                    Service_Tier__c = 'parent service tier',
                                    Bundle_Tier__c = 'parent bundle tier',
                                    Accessory_Tier__c = 'parent accessory tier');
        insert testOpp;

        ApexPages.StandardController sc = new ApexPages.StandardController(testOpp);
        OpportunityLinkOverrideController controller = new OpportunityLinkOverrideController(sc);
        PageReference pr = controller.initPage();
        System.assert(pr != null);

        testOpp.Is_in_Approval_Process__c = true;
        update testOpp;

        sc = new ApexPages.StandardController(testOpp);
        controller = new OpportunityLinkOverrideController(sc);
        pr = controller.initPage();
        System.assert(pr != null);

    }
        
}