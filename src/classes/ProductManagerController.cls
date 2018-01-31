public class ProductManagerController extends BaseController {

	private static final Integer MINIMUM_LINE_ITEMS = 5;

	public Boolean pricebookOrTiersChanged {get; set;}

	public Opportunity opportunity {get; set;}
	public List<LineItem> lineItems {get; set;}
	public String lineItemIndex {get; set;}


	public void initPage() {
		String id = getParameter('id');

		// Validate that an Id was specified.
        if (CSUtils.isEmpty(id)) {
            addErrorMessage('No Opportunity Id specified.');
            return;
        }

		// Load Opportunity.
		try {
			opportunity = [select Id, Name, Pricebook2Id, Pricebook2.IsActive, Type_of_Sale__c, Bundle_Tier__c, Hardware_Tier__c, Accessory_Tier__c, Service_Tier__c, Install_Type__c, Installation_Tier__c from Opportunity where Id = :id];
		} catch (Exception e) {
			// Handle invalid Opportunity Id.
			addErrorMessage('Invalid Opportunity Id specified.');
			return;
		}

		// Detect if Pricebook is no longer active.
		if (opportunity.Pricebook2Id != null && opportunity.Pricebook2.IsActive != true) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You are editing an opportunity that has a new price book. Selecting "Ok" will erase previously selected products and require that products be re-entered on the new price book. To review products first, please select "Cancel" then return to edit products when ready.'));
			return;
		}

		lineItems = new List<LineItem>();
		List<LineItem> childLineItems = new List<LineItem>();

		// Load existing product line items.
		for (OpportunityLineItem opportunityLineItem : [select Id, PricebookEntry.Product2Id, PricebookEntryId, Parent_OpportunityLineItem_Id__c, PricebookEntry.Name, Category__c, Quantity, UnitPrice from OpportunityLineItem where OpportunityId = :opportunity.Id]) {
			LineItem lineItem = new LineItem();
			lineItem.opportunityLineItemId = opportunityLineItem.Id;
			lineItem.productId = opportunityLineItem.PricebookEntry.Product2Id;
			lineItem.pricebookEntryId = opportunityLineItem.PricebookEntryId;
			lineItem.parentOpportunityLineItemId = opportunityLineItem.Parent_OpportunityLineItem_Id__c;
			lineItem.productName = opportunityLineItem.PricebookEntry.Name;
			lineItem.category = opportunityLineItem.Category__c;
			lineItem.quantity = (opportunityLineItem.Quantity == null ? null : opportunityLineItem.Quantity + '');
			lineItem.salePrice = opportunityLineItem.UnitPrice;

			if (opportunityLineItem.Parent_OpportunityLineItem_Id__c == null) {
				lineItems.add(lineItem);
			} else {
				childLineItems.add(lineItem);
			}
System.debug('########################################## LINE ITEM='+lineItem);
		}

		if (childLineItems.size() > 0) {
			for (LineItem childLineItem : childLineItems) {
				Boolean foundParent = false;
				for (Integer i = 0; !foundParent && i < lineItems.size(); i++) {
					if (childLineItem.parentOpportunityLineItemId == lineItems[i].opportunityLineItemId) {
						childLineItem.parentPricebookEntryId = lineItems[i].pricebookEntryId;
						
						// Add child just below parent.
						if (lineItems.size() - 1 == i) {
							lineItems.add(childLineItem);
						} else {
							lineItems.add(i + 1, childLineItem);
						}
						
						foundParent = true;
					}
				}
			}
		}

		// Display at least 5 product line items.
		if (lineItems.size() < MINIMUM_LINE_ITEMS) {
			for (Integer i = lineItems.size(); i < MINIMUM_LINE_ITEMS; i++) {
				lineItems.add(new LineItem());
			}
		}
		
		calculateTotalPrices();
	}
	
	public PageReference changePricebook() {
		// Remove existing products.
		delete [select Id from OpportunityLineItem where OpportunityId = :opportunity.Id and Parent_OpportunityLineItem_Id__c = null];
		
		// Update the Opportunity to use the new price book.
		opportunity.Pricebook2Id = [select Id from Pricebook2 where Name = :getPricebookName(opportunity.Type_of_Sale__c)].Id;
		update opportunity;
		
		PageReference productManagerPage = Page.ProductManager;
		productManagerPage.setRedirect(true);
		productManagerPage.getParameters().put('id', opportunity.Id);
		return productManagerPage;
	}

	public void updateTypeOfSale() {
		pricebookOrTiersChanged = true;
		opportunity.Hardware_Tier__c = null;
		opportunity.Accessory_Tier__c = null;
		opportunity.Service_Tier__c = null;
		opportunity.Install_Type__c = null;
		opportunity.Installation_Tier__c = null;
		opportunity.Bundle_Tier__c = null;
		
		// Clear out any current line items if the pricebook changes. Existing Opportunity
		// Line Item records will be deleted when and if the user ultimately chooses to save.
		lineItems = new List<LineItem>();
		for (Integer i = lineItems.size(); i < MINIMUM_LINE_ITEMS; i++) {
			lineItems.add(new LineItem());
		}
	}

	public Boolean getHasCreatedLineItems() {
		for (LineItem lineItem : lineItems) {
			if (lineItem.productId != null) {
				return true;
			}
		}
		
		return false;
	}

	public void updateTier() {
		List<SelectOption> bundleOptions = getProductOptions('Bundle', opportunity.Bundle_Tier__c, true);
		List<SelectOption> hardwareOptions = getProductOptions('Hardware', opportunity.Hardware_Tier__c, true);
		List<SelectOption> accessoryOptions = getProductOptions('Accessory', opportunity.Accessory_Tier__c, true);
		List<SelectOption> installationOptions = getProductOptions('Installation', opportunity.Installation_Tier__c, true);
		List<SelectOption> serviceOptions = getProductOptions('Service', opportunity.Service_Tier__c, true);

		// Lookup names for the products.
		Set<String> productIds = new Set<String>();
		for (LineItem lineItem : lineItems) {
			if (lineItem.productId != null) {
				productIds.add(lineItem.productId);
			}
		}
		
		Map<String, Product2> products = new Map<String, Product2>([select Id, Name from Product2 where Id in :productIds]);
System.debug('################# PRODUCTS='+products);
		// Swap out product ids with those of the new tier.
		productIds.clear();
		
		for (LineItem lineItem : lineItems) {
			// Skip line items that don't have a product selected.
			if (lineItem.productId == null) continue;
			
			List<SelectOption> options;
				
			     if (lineItem.category == 'Bundle') options = bundleOptions;
			else if (lineItem.category == 'Hardware') options = hardwareOptions;
			else if (lineItem.category == 'Accessory') options = accessoryOptions;
			else if (lineItem.category == 'Installation') options = installationOptions;
			else if (lineItem.category == 'Service') options = serviceOptions;
			else options = serviceOptions; // Child product.
System.debug('############################# lineItem.category='+lineItem.category);
for (SelectOption option : options) {
	System.debug('############################# OPTION='+option);
}
			String productName = products.get(lineItem.productId).Name;
System.debug('############################# PRODUCT NAME='+productName);
			Boolean matchFound = false;
			for (Integer i = 0; i < options.size() && !matchFound; i++) {
				if (productName == options[i].getLabel()) {
					lineItem.productId = options[i].getValue();
					productIds.add(lineItem.productId);
					matchFound = true;
				}
			}
		}

		// Get new prices for the line items' new products.
System.debug('################################## getPricebookName2='+getPricebookName(opportunity.Type_of_Sale__c));
System.debug('################################## productids='+productIds);
		Map<String, PricebookEntry> pricebookEntries = new Map<String, PricebookEntry>();
		for (PricebookEntry pricebookEntry : [select Id, Product2Id, UnitPrice from PricebookEntry where Pricebook2.Name = :getPricebookName(opportunity.Type_of_Sale__c) and Product2Id in :productIds and PriceBook2.IsActive = true]) {
			pricebookEntries.put(pricebookEntry.Product2Id, pricebookEntry);
System.debug('################# PB ENTRY='+pricebookEntry);
		}
		
		for (LineItem lineItem : lineItems) {
			PricebookEntry pricebookEntry = pricebookEntries.get(lineItem.productId);
			if (pricebookEntry != null) {		
				lineItem.pricebookEntryId = pricebookEntry.Id;
				lineItem.salePrice = pricebookEntry.UnitPrice;
			} else {
				// Reset data if Pricebook Entry not found.		
				lineItem.pricebookEntryId = null;
				lineItem.salePrice = null;
			}
System.debug('########################################## UPDATE TIER LINE ITEM='+lineItem);
		}

		calculateTotalPrices();
	}

	public void updateInstallationType() {
		pricebookOrTiersChanged = true;
		opportunity.Installation_Tier__c = null;
		
		List<LineItem> newLineItems = new List<LineItem>();
		
		for (LineItem lineItem : LineItems) {
			if (lineItem.category != 'Installation') {
				newLineItems.add(lineItem);
			}
		}
		
		lineItems = newLineItems;
		
		
		for (Integer i = lineItems.size(); i < MINIMUM_LINE_ITEMS; i++) {
			lineItems.add(new LineItem());
		}
	}

	public void updateDisplay() {
		calculateTotalPrices();
	}

	public void updateProduct() {
		// Convert index from String (e.g., '1.0') to Integer. 
		Integer index = CSUtils.convertDecimalToInteger(Decimal.valueOf(lineItemIndex));

		LineItem lineItem = lineItems[index];

		if (lineItem.productId != null) {
			try {
				String pbName = getPricebookName(opportunity.Type_of_Sale__c);
				//PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2.Name = :getPricebookName(opportunity.Type_of_Sale__c) and Product2Id = :lineItem.productId];
				PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2Id = :getPricebookId(opportunity.Type_of_Sale__c) and Product2Id = :lineItem.productId];

				lineItem.pricebookEntryId = pricebookEntry.Id;
				lineItem.salePrice = pricebookEntry.UnitPrice;
			} catch (Exception e) {
				// Reset data if Pricebook Entry not found.		
				lineItem.pricebookEntryId = null;
				lineItem.salePrice = null;
			}
			
			// Look for a Child Product if currently working with the Purchase Pricebook.
			if (lineItem.pricebookEntryId != null && opportunity.Type_of_Sale__c == 'Purchase' || opportunity.Type_of_Sale__c == 'Indirect') {
				try {
//					Product2 product = [select Price_Tier__c from Product2 where Id = :lineItem.productId];
					Child_Product__c childProduct = [select Id, Child_Product__c, Child_Product__r.Name from Child_Product__c where Product__c = :lineItem.productId and Price_Tier__c = :opportunity.Service_Tier__c];
					//PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2.Name = :getPricebookName(opportunity.Type_of_Sale__c) and Product2Id = :childProduct.Child_Product__c];
					PricebookEntry pricebookEntry = [select Id, UnitPrice from PricebookEntry where Pricebook2Id = :getPricebookId(opportunity.Type_of_Sale__c) and Product2Id = :childProduct.Child_Product__c];

					LineItem childLineItem = new LineItem();
					childLineItem.parentPricebookEntryId = lineItem.pricebookEntryId;
					childLineItem.productId = childProduct.Child_Product__c;
					childLineItem.pricebookEntryId = pricebookEntry.Id;
					childLineItem.category = 'Service';
					childLineItem.productName = childProduct.Child_Product__r.Name;
					childLineItem.salePrice = pricebookEntry.UnitPrice;
					
					// Add child just below parent.
					if (lineItems.size() - 1 == index) { // Last line item.
						lineItems.add(childLineItem);
					} else {
						// If line item already has a child line item, overwrite the child line item.
						if (lineItems.get(index + 1).parentPricebookEntryId != null) {
							lineItems.set(index + 1, childLineItem);

						// Else add new line item.
						} else {
							lineItems.add(index + 1, childLineItem);
						}
					}
				} catch (Exception e) {
				}
			}
		} else {
			// Reset data if Product deselected.		
			lineItem.pricebookEntryId = null;
			lineItem.salePrice = null;
		}

		calculateTotalPrices();
	}
	
	private void calculateTotalPrices() {
		for (LineItem lineItem : LineItems) {
			if (!CSUtils.isEmpty(lineItem.quantity) && lineItem.salePrice != null) {
				lineItem.totalPrice = Decimal.valueOf(lineItem.quantity) * lineItem.salePrice;
			} else {
				lineItem.totalPrice = null;
			}
		}
	}
	
	public Boolean getShowProducts() {
		if (opportunity.Type_of_Sale__c == null) {
			return false;
		} else if (opportunity.Type_of_Sale__c == 'Bundled' && opportunity.Bundle_Tier__c != null) {
			return true;
		} else if (opportunity.Hardware_Tier__c != null && opportunity.Accessory_Tier__c != null && opportunity.Service_Tier__c != null && opportunity.Install_Type__c != null && (opportunity.Install_Type__c == 'Self Install' || opportunity.Installation_Tier__c != null)) {
			return true;
		}
		
		return false;
	}
	
	public void addProduct() {
		lineItems.add(new LineItem());
	}

	public PageReference save() {
		// Remove any existing line items in case anything has changed. Many fields on
		// the OpportunityLineItem can't be updated (specifically PriceBookEntryId) so
		// new records must be created to update that information.
		delete [select Id from OpportunityLineItem where OpportunityId = :opportunity.Id and Parent_OpportunityLineItem_Id__c = null];

		// Update the Opportunity.
		opportunity.Pricebook2Id = [select Id from Pricebook2 where Name = :getPricebookName(opportunity.Type_of_Sale__c)].Id;
		update opportunity;

		// Process parent Products.
		List<OpportunityLineItem> parentOpportunityLineItems = new List<OpportunityLineItem>();
		
		for (LineItem lineItem : LineItems) {
			if (lineItem.parentPricebookEntryId == null && !CSUtils.isEmpty(lineItem.quantity)) {
				OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId=opportunity.Id, PricebookEntryId=lineItem.pricebookEntryId);
				opportunityLineItem.Category__c = lineItem.category;
				opportunityLineItem.Quantity = (lineItem.quantity == null || !CSUtils.isNumeric(lineItem.quantity) ? null : Decimal.valueOf(lineItem.quantity));
				opportunityLineItem.UnitPrice = lineItem.salePrice;
				parentOpportunityLineItems.add(opportunityLineItem);
			}
		}

		insert parentOpportunityLineItems;
		
		// Process child Products.
		List<OpportunityLineItem> childOpportunityLineItems = new List<OpportunityLineItem>();

		Integer parentIndex = -1;
		for (LineItem lineItem : LineItems) {
			if (lineItem.parentPricebookEntryId != null && !CSUtils.isEmpty(lineItem.quantity)) {
System.debug('########################################## SAVE CHILD LINE ITEM='+lineItem);
				OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId=opportunity.Id, PricebookEntryId=lineItem.pricebookEntryId);
				opportunityLineItem.Parent_OpportunityLineItem_Id__c = parentOpportunityLineItems[parentIndex].Id;
				opportunityLineItem.Category__c = lineItem.category;
				opportunityLineItem.Quantity = (lineItem.quantity == null || !CSUtils.isNumeric(lineItem.quantity) ? null : Decimal.valueOf(lineItem.quantity));
				opportunityLineItem.UnitPrice = lineItem.salePrice;
				childOpportunityLineItems.add(opportunityLineItem);
			}
			
			if (lineItem.parentPricebookEntryId == null) {
				parentIndex++;
			}
		}
System.debug('################################ CHILD OLIS='+childOpportunityLineItems);
		insert childOpportunityLineItems;
		
		return new PageReference('/' + opportunity.Id);
	}

	public List<SelectOption> getCategoryOptions() {
		List<SelectOption> options = new List<SelectOption>();
		
		for (String value : CSUtils.getPicklistValues('Product2', 'Category__c', true)) {
			// Skip Installation category for Self Install.
			if (opportunity.Install_Type__c == 'Self Install' && value == 'Installation') {
				continue;
			}
			
			// Skip Bundle category for Purchase.
			if (opportunity.Type_of_Sale__c == 'Purchase' && value == 'Bundle') {
				continue;
			}
			
			// Only Accessory, Bundle and Installation apply to Bundled Type of Sale.
			if (opportunity.Type_of_Sale__c == 'Bundled' && value != 'Accessory' && value != 'Bundle' && value != 'Installation') {
				continue;
			}
			
			// Skip Bundle category for Indirect.
			if (opportunity.Type_of_Sale__c == 'Indirect' && value == 'Bundle') {
				continue;
			}
			
			options.add(new SelectOption(value, value));
		}
		
		return options;
	}
	
	public List<SelectOption> getProductOptions(String category, String priceTier, Boolean includeChildren) {
		List<SelectOption> options = new List<SelectOption>();
		
		Id pricebookId = [select Id from Pricebook2 where Name = :getPricebookName(opportunity.Type_of_Sale__c) and IsActive = true].Id;
		
		System.debug('######################################## PRICEBOOK=' + pricebookId);
		System.debug('######################################## PRODUCT CATEGORY=' + category);
		System.debug('######################################## PRODUCT PRICE TIER=' + priceTier);
		
		Set<String> recordTypes = new Set<String>{CSUtils.getRecordTypeId('Product2', 'Product Record Type')};
		if (includeChildren) {
			recordTypes.add(CSUtils.getRecordTypeId('Product2', 'Child Product Record Type'));
		}
		
		List<PricebookEntry> pricebookEntries;
		if (priceTier == null) {
			pricebookEntries = [select Product2Id, Product2.Name
			                    from PricebookEntry
			                    where Pricebook2Id = :pricebookId
			                    and Product2.IsActive = true
			                    and Product2.Category__c = :category
			                    and Product2.RecordTypeId in :recordTypes
			                    order by Product2.Name asc];
		} else if (category == 'Installation' && (priceTier == 'Pilot-No Charge' || priceTier == 'GSA-010')) {
			pricebookEntries = [select Product2Id, Product2.Name
			                    from PricebookEntry
			                    where Pricebook2Id = :pricebookId
			                    and Product2.IsActive = true
			                    and Product2.Category__c = :category
			                    and Product2.Price_Tier__c = :priceTier
			                    and Product2.RecordTypeId in :recordTypes
			                    order by Product2.Name asc];
		} else {
			pricebookEntries = [select Product2Id, Product2.Name
			                    from PricebookEntry
			                    where Pricebook2Id = :pricebookId
			                    and Product2.IsActive = true
			                    and Product2.Category__c = :category
			                    and (Product2.Price_Tier__c = :priceTier or Product2.Price_Tier__c = null)
			                    and Product2.RecordTypeId in :recordTypes
			                    order by Product2.Name asc];
		}
		
		for (PricebookEntry pricebookEntry : pricebookEntries) {
			options.add(new SelectOption(pricebookEntry.Product2Id, pricebookEntry.Product2.Name));
		}

		return options;
	}
	
	public List<SelectOption> getAccessoryProductOptions() {
		return getProductOptions('Accessory', opportunity.Accessory_Tier__c, false);
	}
	
	public List<SelectOption> getBundleProductOptions() {
		return getProductOptions('Bundle', opportunity.Bundle_Tier__c, false);
	}
	
	public List<SelectOption> getHardwareProductOptions() {
		return getProductOptions('Hardware', opportunity.Hardware_Tier__c, false);
	}
	
	public List<SelectOption> getInstallationProductOptions() {
		return getProductOptions('Installation', (opportunity.Type_of_Sale__c == 'Bundled' ? 'Tier 1' : opportunity.Installation_Tier__c), false);
	}
	
	public List<SelectOption> getServiceProductOptions() {
		return getProductOptions('Service', opportunity.Service_Tier__c, false);
	}

	public String getPricebookName(String typeOfSale) {
		if (typeOfSale == 'Bundled') {
			return Pricebook_Settings__c.getInstance().Bundled_Price_Book__c;
		} else if (typeOfSale == 'Indirect') {
			return Pricebook_Settings__c.getInstance().Indirect_Price_Book__c;
		} else { // typeOfSale == 'Purchase'
			return Pricebook_Settings__c.getInstance().Purchase_Price_Book__c;
		}
	}
	
	public String getPricebookId(String typeOfSale) {
		return [select Id from Pricebook2 where Name = :getPricebookName(typeOfSale)].Id;
	}
	

	public class LineItem {
		public String parentOpportunityLineItemId {get; set;}
		public String parentPricebookEntryId {get; set;}
		public String opportunityLineItemId {get; set;}
		public String category {get; set;}
		public String productId {get; set;}
		public String pricebookEntryId {get; set;}
		public String productName {get; set;}
		public String quantity {get; set;}
		public Decimal salePrice {get; set;}
		public Decimal totalPrice {get; set;}
	}

}