public with sharing class WelcomeCallOpportunityLineItemsCntrl {
	
	private Id welcomeCallId;
	
	public List<OpportunityLineItem> opportunityLineItems {get; private set;}

	
	public WelcomeCallOpportunityLineItemsCntrl(ApexPages.StandardController standardController) {
		welcomeCallId = standardController.getId();
	}
	
	public void initPage() {
		Welcome_Call__c welcomeCall = [select Opportunity_Name__c from Welcome_Call__c where Id = :welcomeCallId];
		if (welcomeCall.Opportunity_Name__c != null) {
			opportunityLineItems = [select Product2.Name, Quantity, Category__c
			                        from OpportunityLineItem
			                        where OpportunityId = :welcomeCall.Opportunity_Name__c];
		}
	}

}