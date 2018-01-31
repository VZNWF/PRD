/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class Test_CalculateChildOppsUnitTotalTrigger {

	private static Pricebook2 Pricebook { 
		
		get {
			
			if(Pricebook == null) {
				
				Pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
			}
			
			return Pricebook;
		}
		set;
	}
	
	private static Opportunity CreateOpportunity(String oppName, Id accountId) {
		
		Opportunity opportunity = new Opportunity();
		
        opportunity.Name = oppName;
        opportunity.AccountId = accountId;
        opportunity.Type = 'Existing Business';
        opportunity.LeadSource = 'Other';
        opportunity.CloseDate = Date.today().addDays(5);
        opportunity.StageName = 'Initial Meeting / Demo';
		
		return opportunity;
	}
	
	private static OpportunityLineItem CreateOpportunityLineItem(Id oppId, String productName, String category, Decimal serviceAmount, Decimal salesPrice, Integer quantity) {

		Product2 product = new Product2();
		product.Name = productName;
		
		insert product;

		PricebookEntry pricebookEntry = new PricebookEntry();
		pricebookEntry.Pricebook2Id = Pricebook.Id;
		pricebookEntry.Product2Id = product.Id;
		pricebookEntry.IsActive = true;
		pricebookEntry.UnitPrice = salesPrice;
		
		insert pricebookEntry;
		
		OpportunityLineItem oppLineItem = new OpportunityLineItem();
		oppLineItem.OpportunityId = oppId;
		oppLineItem.PricebookEntryId = pricebookEntry.Id;
		oppLineItem.UnitPrice = salesPrice;
		oppLineItem.Quantity = quantity;
		oppLineItem.Category__c = category;
		oppLineItem.Service_Amount__c = serviceAmount;
		
		return oppLineItem;		
	}
	
    static testMethod void PositiveTest() {
        
        List<OpportunityLineItem> oppLineItemsList = null;
        Opportunity parentOpp = null;
        Opportunity childOpp = null;
        Account account = TestUtils.createAccount();
        
        //Parent
        
        parentOpp = CreateOpportunity('Parent Opportunity', account.Id);
        
        parentOpp.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        
        insert parentOpp;
        
        oppLineItemsList = new List<OpportunityLineItem>();
        
        oppLineItemsList.add(CreateOpportunityLineItem(parentOpp.Id, 'A Service', 'Service', 25.99, 25.99, 1));
		oppLineItemsList.add(CreateOpportunityLineItem(parentOpp.Id, 'Some Hardware', 'Hardware', 0, 25.99, 1));
		oppLineItemsList.add(CreateOpportunityLineItem(parentOpp.Id, 'An Accessory', 'Accessory', 0, 25.99, 1));

		insert oppLineItemsList;
		
		parentOpp.StageName = 'Closed Won';
		parentOpp.Type_of_Sale__c = 'Purchase';
		parentOpp.Hardware_Tier__c = 'DIR-010';
		parentOpp.Service_Tier__c = 'Custom';
		parentOpp.Accessory_Tier__c = 'Standard';
		parentOpp.Pricing_Setup__c = 'Account Level';
		parentOpp.Install_Type__c = 'Self Install';
		parentOpp.Approval_Required__c =false;
		parentOpp.Approved__c=true;
		update parentOpp;
		       
        //Child
        
        childOpp = CreateOpportunity('Child Opportunity', account.Id);
        
        childOpp.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        childOpp.Parent_Opportunity__c = parentOpp.Id;
        
        insert childOpp;
        
        oppLineItemsList = new List<OpportunityLineItem>();
        
		oppLineItemsList.add(CreateOpportunityLineItem(childOpp.Id, 'A Service', 'Service', 25.99, 25.99, 1));
		oppLineItemsList.add(CreateOpportunityLineItem(childOpp.Id, 'Some Hardware', 'Hardware', 0, 25.99, 3));
		oppLineItemsList.add(CreateOpportunityLineItem(childOpp.Id, 'An Accessory', 'Accessory', 0, 25.99, 1));
		
	    insert oppLineItemsList;
		
		//Final Assert
		
		parentOpp = [SELECT Id, Unit_Total_of_Child_Opps__c FROM Opportunity WHERE Id = :parentOpp.Id LIMIT 1];
		
		System.assertEquals(null, parentOpp.Unit_Total_of_Child_Opps__c);
		
    }
}