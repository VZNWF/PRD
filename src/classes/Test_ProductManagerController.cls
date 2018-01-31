// Note that seeAllData is necessary to get access to the Standard price book.
@isTest(seeAllData=true)
private class Test_ProductManagerController {

    static testMethod void testControllerInvalid() {
        PageReference productManagerPage = Page.ProductManager;
        Test.setCurrentPage(productManagerPage);
        ProductManagerController controller = new ProductManagerController();
        
        // Test without "id" parameter.
        controller.initPage();
        System.assertEquals('No Opportunity Id specified.', ApexPages.getMessages().get(0).getDetail());

        // Test with invalid "id" parameter.
        productManagerPage.getParameters().put('id', 'invalid');
        controller.initPage();
        System.assertEquals('Invalid Opportunity Id specified.', ApexPages.getMessages().get(1).getDetail());
    }
/*
    static testMethod void testControllerValid() {
        ProductManagerController controller = new ProductManagerController();

        User user = [Select Id from User Limit 1];
        Account account = new Account(Name = 'Test Account 234234', SOS_Owner__c = user.Id, Acct_Type__c = 'Other', Sub_Type__c = 'Other', Sales_Partner_Vertical__c = 'Other', Total_Number_of_Vehicles__c = 10);
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.Type_of_Sale__c = 'Purchase';
        opportunity.Hardware_Tier__c = 'Custom';
        opportunity.AccountId = account.Id;
        insert opportunity;
        
        Id pricebookId = [select Id from Pricebook2 where Name = :controller.getPricebookName(opportunity.Type_of_Sale__c) and IsActive = true].Id;
        PricebookEntry pricebookEntry = [select Id, Product2Id, Pricebook2.Name from PricebookEntry where Pricebook2Id = :pricebookId and IsActive = true and Product2.IsActive = true limit 1];

        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.TotalPrice = 1;
        opportunityLineItem.Quantity = 1;
        insert opportunityLineItem;
        
        OpportunityLineItem childOpportunityLineItem = new OpportunityLineItem();
        childOpportunityLineItem.OpportunityId = opportunity.Id;
        childOpportunityLineItem.Parent_OpportunityLineItem_Id__c = opportunityLineItem.Id;
        childOpportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        childOpportunityLineItem.TotalPrice = 1;
        childOpportunityLineItem.Quantity = 1;
        insert childOpportunityLineItem;
        
        PageReference productManagerPage = Page.ProductManager;
        Test.setCurrentPage(productManagerPage);
        productManagerPage.getParameters().put('id', opportunity.Id);
        
        controller.initPage();
        controller.getAccessoryProductOptions();
        controller.getBundleProductOptions();
        controller.getHardwareProductOptions();
        controller.getInstallationProductOptions();
        controller.getServiceProductOptions();
        controller.getCategoryOptions();
        controller.getHasCreatedLineItems();
        controller.addProduct();
        controller.updateTier();
        controller.updateInstallationType();
        controller.updateDisplay();
        
        controller.lineItemIndex = '0';
        controller.updateProduct();
        
        controller.save();
        
        controller.updateTypeOfSale();
        
        controller.changePricebook();
    }
*/
}