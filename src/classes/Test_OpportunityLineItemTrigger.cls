// Note that seeAllData is necessary to get access to the Standard price book.
@isTest(seeAllData=true)
private class Test_OpportunityLineItemTrigger {

    static testMethod void testCascadingDelete() {
    
         User user = [Select Id from User Limit 1];
         Account account = new Account(Name = 'Test Account 234234', SOS_Owner__c = user.Id, Acct_Type__c = 'Other', Sub_Type__c = 'Other', Sales_Partner_Vertical__c = 'Other', Total_Number_of_Vehicles__c = 10);
        insert account;
    
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.AccountId = account.Id;
        insert opportunity;

        Pricebook2 pricebook = [select Id from Pricebook2 where IsStandard = true];

        Product2 parentProduct = new Product2();
        parentProduct.Name = 'Test Parent';
        insert parentProduct;

        PricebookEntry parentPricebookEntry = new PricebookEntry();
        parentPricebookEntry.Pricebook2Id = pricebook.Id;
        parentPricebookEntry.Product2Id = parentProduct.Id;
        parentPricebookEntry.IsActive = true;
        parentPricebookEntry.UnitPrice = 100;
        insert parentPricebookEntry;
        
        OpportunityLineItem parentOpportunityLineItem = new OpportunityLineItem();
        parentOpportunityLineItem.OpportunityId = opportunity.Id;
        parentOpportunityLineItem.PricebookEntryId = parentPricebookEntry.Id;
        parentOpportunityLineItem.Quantity = 5;
        parentOpportunityLineItem.UnitPrice = 100;
        insert parentOpportunityLineItem;
        
        Product2 childProduct = new Product2();
        childProduct.Name = 'Test Child';
        insert childProduct;

        PricebookEntry childPricebookEntry = new PricebookEntry();
        childPricebookEntry.Pricebook2Id = pricebook.Id;
        childPricebookEntry.Product2Id = childProduct.Id;
        childPricebookEntry.IsActive = true;
        childPricebookEntry.UnitPrice = 30;
        insert childPricebookEntry;
        
        OpportunityLineItem childOpportunityLineItem = new OpportunityLineItem();
        childOpportunityLineItem.OpportunityId = opportunity.Id;
        childOpportunityLineItem.PricebookEntryId = childPricebookEntry.Id;
        childOpportunityLineItem.Parent_OpportunityLineItem_Id__c = parentOpportunityLineItem.Id;
        childOpportunityLineItem.Quantity = 1;
        childOpportunityLineItem.UnitPrice = 7;
        insert childOpportunityLineItem;
        
        System.assertEquals(2, [select count() from OpportunityLineItem where OpportunityId = :opportunity.Id]);
        
        delete childOpportunityLineItem;
        
        delete parentOpportunityLineItem;
        
        // Verify that child was deleted when parent was.
        System.assertEquals(0, [select count() from OpportunityLineItem where OpportunityId = :opportunity.Id]);
    }

}