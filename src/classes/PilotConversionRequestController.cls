public with sharing class PilotConversionRequestController {
	public Opportunity parentOpp ;
	public Id parentOppId {get;set;}
	public Id childOppId {get;set;}
	public Opportunity childOpp {get;set;}
	public String relatedResellerName;
	public String sosOwnerName;

	public PilotConversionRequestController() {
			
	}

	public Opportunity getParentOpp(){
		List<Opportunity> opps = [SELECT Id, Name, Service_Tier__c, Bundle_Tier__c, Accessory_Tier__c, Installation_Tier__c, Pricing_Setup__c, Hardware_Extended_Terms__c,Hardware_Tier__c, Deferred_Billing_Date__c, Freight_per_Unit__c, PO_Number__c, Addl_Info__c
				FROM opportunity 
				WHERE id = :parentOppId];


		if(opps.size() > 0){
			return opps[0];
		}
		return null;
	}
	public Opportunity getChildOpp(){
		//what we need from this query is RelatedReseller.Name and Account.SOS_Owner__c.Name

		List<Opportunity> opps = [SELECT Id, Name, Parent_Opportunity__c, Customer_Number__c, Account.Acct_Type__c, Account.Sub_Type__c,
											AccountId, Related_Reseller__r.Name, Type_of_Sale__c, Account.Owner.Name,
											Account.SOS_Owner__c, Discount_Code__c, Affiliate_Lead_ID__c, LeadSource
				FROM opportunity 
				WHERE id = :childOppId];


		if(opps.size() > 0){
			return opps[0];
		}
		return null;
	}

	public String getRelatedResellerName(){
		if(childOpp == null){
			childOpp = getChildOpp();
		}
		//select name from account where id = Related_Reseller__c
		List<Account> accountList = [SELECT Name FROM Account WHERE id=:childOpp.Related_Reseller__c];
		if(accountList.size() > 0){
			return accountList[0].Name;
		} 
		return null;
	}
	//select SOS_Owner__c.Name from User where id = : childopp.accountid ??

}