@isTest
private class OpportunityLineItemLinkOverride_Test {
        
    @isTest static void testOpportunityLineItemLinkOverride() {
        Account testAccount = testUtils.createAccount();
        Opportunity testOpp = new Opportunity(name='parent opp name',
                                    AccountId = testAccount.id,
                                    StageName = 'stage name', 
                                    CloseDate = Date.newInstance(2016,  01, 01), 
                                    Hardware_Tier__c = 'parent hardware tier',
                                    Service_Tier__c = 'parent service tier',
                                    Bundle_Tier__c = 'parent bundle tier',
                                    Accessory_Tier__c = 'parent accessory tier');
        DataBase.insert(testOpp,false);

        list<PricebookEntry> testPBEs = [Select Id from PricebookEntry limit 1];
        OpportunityLineItem testOLI = new OpportunityLineItem(
                                    OpportunityId = testOpp.Id,
                                    PriceBookEntryId = testPBEs[0].Id,
                                    Quantity=1, TotalPrice=99);
        DataBase.insert(testOLI,false);

        ApexPages.StandardController sc = new ApexPages.StandardController(testOLI);
        OpportunityLineItemLinkOverrideControllr controller = new OpportunityLineItemLinkOverrideControllr(sc);
        PageReference pr = controller.initPage();
        

        testOpp.Is_in_Approval_Process__c = true;
        DataBase.update(testOpp,false);

        sc = new ApexPages.StandardController(testOLI);
        controller = new OpportunityLineItemLinkOverrideControllr(sc);
        pr = controller.initPage();
        System.assert(pr != null);

    }
        
    @testSetup static void setupProducts() {
        Product2 p = new Product2(Name='Test Product',isActive=true);
        insert p;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), 
                                    Product2Id=p.Id, UnitPrice=99, isActive=true);
        insert pbe;

    }
    
}