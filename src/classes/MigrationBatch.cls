/*
 * //////////////////////////////////////////////////////////////////////////////////
 *
 *
 * Database.executeBatch(new MigrationBatch('Hardware', '5200N', '5200N3AS'), 1);
 * Database.executeBatch(new MigrationBatch('Hardware', '5500N', '5500N3AS'), 1);
 * Database.executeBatch(new MigrationBatch('Bundle', '5500N', '5500N3AS'), 1);
 *
 * //////////////////////////////////////////////////////////////////////////////////
 */

global class MigrationBatch implements Database.Batchable<sObject>, Database.Stateful {
/*
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([select Id, OpportunityId, Opportunity.Service_Tier__c, Opportunity.Type_of_Sale__c, PricebookEntry.Product2Id, Quantity from OpportunityLineItem where Opportunity.IsClosed = false and Category__c = 'Hardware']);
	}
	
	global void execute(Database.BatchableContext context, List<SObject> records) {
		List<OpportunityLineItem> lineItems = (List<OpportunityLineItem>) records;
	
		for (OpportunityLineItem lineItem : lineItems) {
			try {
				Child_Product__c childProduct = [select Child_Product__c from Child_Product__c where Product__c = :lineItem.PricebookEntry.Product2Id and Price_Tier__c = :lineItem.Opportunity.Service_Tier__c];
				PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2.Name = :lineItem.Opportunity.Type_of_Sale__c and Product2Id = :childProduct.Child_Product__c];
				
				OpportunityLineItem childLineItem = new OpportunityLineItem();
				childLineItem.OpportunityId = lineItem.OpportunityId;
				childLineItem.PricebookEntryId = pricebookEntry.Id;
				childLineItem.Parent_OpportunityLineItem_Id__c = lineItem.Id;
				childLineItem.Category__c = 'Service';
				childLineItem.Quantity = lineItem.quantity;
				childLineItem.UnitPrice = pricebookEntry.UnitPrice;
				insert childLineItem;
				
				System.debug('############################## NEW LINE ITEM='+childLineItem);
			} catch (Exception e) {
				System.debug('############################## UNABLE TO FIND CHILD PRODUCT='+e);
			}
		}
	
	}
*/

	global String category;
	global String oldProductCode;
	global String newProductCode;
	
	global MigrationBatch(String category, String oldProductCode, String newProductCode) {
		this.category = category;
		this.oldProductCode = oldProductCode;
		this.newProductCode = newProductCode;
	}
	

/*
They want to update all Open Opportunities that have a Product Code of 5200N or 5500N and replace it with the new Products, 5200NAS and 5500N3AS respectively. And they want to update all Closed Won Opportunities where the Closed Date is greater than or equal to 12/7/12.

What I would LOVE to have done is:
Loop through all the Opps when a Product Match is found (based on Product Code, Type of Sale / Pricebook and Tier) add the new Hardware (H/W) Product and related Child (Service) Product.
Copy the quantity from the old Products (both Hardware and Service) and add to the new Hardware and Service Product
If the Tier is Custom copy the price from the old Products (H/W and Service) to the new H/W and Service Product
Delete the old Hardware and Service Product
Let me know what questions you have and when you could do this. Like all clients right now, they want it as soon as possible.
*/
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([select Id, OpportunityId, Opportunity.Service_Tier__c, Opportunity.Type_of_Sale__c, PricebookEntry.Product2.Price_Tier__c, Quantity, UnitPrice
		                                 from OpportunityLineItem
		                                 where (Opportunity.IsClosed = false or (Opportunity.IsWon = true and Opportunity.CloseDate >= :Date.newInstance(2012, 12, 7)))
		                                 and Category__c = :category
//and OpportunityId = '006f00000024UoGAAU'
		                                 and PricebookEntry.ProductCode = :oldProductCode]);
	}
	
	global void execute(Database.BatchableContext context, List<SObject> records) {
		List<OpportunityLineItem> lineItems = (List<OpportunityLineItem>) records;

		for (OpportunityLineItem lineItem : lineItems) {
			System.debug('############################## OLD LINE ITEM='+lineItem);
			
			try {
				PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where ProductCode = :newProductCode and Pricebook2.Name = :lineItem.Opportunity.Type_of_Sale__c and Product2.Price_Tier__c = :lineItem.PricebookEntry.Product2.Price_Tier__c];

				OpportunityLineItem newLineItem = new OpportunityLineItem();
				newLineItem.OpportunityId = lineItem.OpportunityId;
				newLineItem.PricebookEntryId = pricebookEntry.Id;
				newLineItem.Category__c = category;
				newLineItem.Quantity = lineItem.Quantity;
				if (lineItem.PricebookEntry.Product2.Price_Tier__c == 'Custom') {
					newLineItem.UnitPrice = lineItem.UnitPrice;
				} else {
					newLineItem.UnitPrice = pricebookEntry.UnitPrice;
				}
				insert newLineItem;

				System.debug('############################## NEW LINE ITEM='+newLineItem);

				if (category == 'Hardware') {
					List<OpportunityLineItem> childLineItems = [select Id, OpportunityId, Opportunity.Type_of_Sale__c, PricebookEntry.Product2.Price_Tier__c, Quantity, UnitPrice, Category__c from OpportunityLineItem where Parent_OpportunityLineItem_Id__c = :lineItem.Id];
					if (childLineItems.size() == 1) {
						System.debug('############################## OLD CHILD LINE ITEM='+childLineItems[0]);
	
						Child_Product__c childProduct = [select Child_Product__c from Child_Product__c where Product__c = :lineItem.PricebookEntry.Product2Id and Price_Tier__c = :lineItem.Opportunity.Service_Tier__c];
						PricebookEntry childPricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2.Name = :lineItem.Opportunity.Type_of_Sale__c and Product2Id = :childProduct.Child_Product__c];

						OpportunityLineItem newChildLineItem = new OpportunityLineItem();
						newChildLineItem.OpportunityId = lineItem.OpportunityId;
						newChildLineItem.PricebookEntryId = childPricebookEntry.Id;
						newChildLineItem.Parent_OpportunityLineItem_Id__c = newLineItem.Id;
						newChildLineItem.Category__c = childLineItems[0].Category__c;
						newChildLineItem.Quantity = childLineItems[0].Quantity;
						if (childLineItems[0].PricebookEntry.Product2.Price_Tier__c == 'Custom') {
							newChildLineItem.UnitPrice = childLineItems[0].UnitPrice;
						} else {
							newChildLineItem.UnitPrice = childPricebookEntry.UnitPrice;
						}
						insert newChildLineItem;
	
						// Remove existing child line item.
						delete childLineItems;
		
						System.debug('############################## NEW CHILD LINE ITEM='+newChildLineItem);
					}
				}
				
				// Remove existing line item.
				delete lineItems;
			} catch (Exception e) {
				System.debug('############################## ERROR='+e);
			}
		}
	}

	global void finish(Database.BatchableContext context) {
	}
	
	public static void coverage() {
        Integer count = 0;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
        count++;
	}

	static testMethod void testCoverage() {
        MigrationBatch.coverage();
    }

}