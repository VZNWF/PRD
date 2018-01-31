/**********************************************************************************

Modifications:
9/4/13 - Krishna Tatta - Made the code modular to handle multiple trigger events. 
         Modified the code so that unit total of child opps is updated for all 
         parent opps, not just ones that are won.  
************************************************************************************/

public with sharing class CalculateChildOppsUnitTotal {

	public static Boolean HAS_EXECUTED = false;
	
	public static void Execute(List<OpportunityLineItem> oppLineItemsList) {		
		Set<Id> childOppIdsSet = new Set<Id>();
				
		for(OpportunityLineItem tmpOppLineItem : oppLineItemsList) {			
			childOppIdsSet.add(tmpOppLineItem.OpportunityId);
		}
		
		ProcessParentOpps(childOppIdsSet);
	}
	
	public static void ProcessParentOpps(Set<Id> childOppIdsSet) {
		
		if(childOppIdsSet != null && !childOppIdsSet.IsEmpty()) {
			
			List<Opportunity> childOppsList = null;
			List<Opportunity> parentOppsList = null;
			Set<Id> parentOppIdsSet = new Set<Id>();
			Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');			
			
			childOppsList = [SELECT Id, Parent_Opportunity__c FROM Opportunity
								WHERE Id IN :childOppIdsSet
								AND Parent_Opportunity__c != null
								AND RecordTypeId = :csoRecordTypeId];
			
			for(Opportunity tmpOpp : childOppsList) {
							
				parentOppIdsSet.add(tmpOpp.Parent_Opportunity__c);
			}
		
			parentOppsList = [SELECT Id, Name, RecordTypeId, Parent_Opportunity__c, IsWon, Unit_Total_of_Child_Opps__c FROM Opportunity
								WHERE Id IN :parentOppIdsSet
								AND Parent_Opportunity__c = null
								AND RecordTypeId != :csoRecordTypeId];
		
			if(parentOppsList.size() > 0) {	
						
				DoCalculation(parentOppsList);
			}
		}	
	}

	//Tried using an aggregate, but it did not work well if more than one OpportunityLineItem was 
	//submitted in a batch
	private static void DoCalculation(List<Opportunity> parentOppsList) {

		Map<Id, Opportunity> parentOppsMap = new Map<Id, Opportunity>();
		Map<Id, Opportunity> childParentOppsMap = new Map<Id, Opportunity>();
		Map<Id, Opportunity> updateParentOppsMap = new Map<Id, Opportunity>();
		List<Opportunity> childOppsList = null;
		List<OpportunityLineItem> childOppLineItemsList = null;
		Set<Id> childOppIdsSet = new Set<Id>();
		Opportunity tmpParentOpp = null;
		Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
		
		for(Opportunity tmpOpp : parentOppsList) {		
			
			if(tmpOpp.Parent_Opportunity__c == null && tmpOpp.RecordTypeId != csoRecordTypeId) {	
			
				tmpOpp.Unit_Total_of_Child_Opps__c = 0;
				
				parentOppsMap.put(tmpOpp.Id, tmpOpp);
			}
		}
		
		childOppsList = [SELECT Id, Parent_Opportunity__c FROM Opportunity
							WHERE Parent_Opportunity__c IN :parentOppsMap.keySet()
							AND RecordTypeId = :csoRecordTypeId AND IsWon=true];
		
		for(Opportunity tmpOpp : childOppsList) {
			
			tmpParentOpp = parentOppsMap.get(tmpOpp.Parent_Opportunity__c);
			
			if(tmpParentOpp != null) {
				
				childOppIdsSet.add(tmpOpp.Id);
				childParentOppsMap.put(tmpOpp.Id, tmpParentOpp);
				updateParentOppsMap.put(tmpParentOpp.Id, tmpParentOpp);
			}
		}
		
		childOppLineItemsList = [SELECT Id, Quantity, OpportunityId, Is_Bundled_Connect__c, Exclude_from_Unit_Total__c FROM OpportunityLineItem
									WHERE OpportunityId IN :childOppIdsSet
									AND Category__c IN ('Hardware', 'Bundle')];
		
	
		for(OpportunityLineItem tmpOppLineItem : childOppLineItemsList) {
			
			tmpParentOpp = childParentOppsMap.get(tmpOppLineItem.OpportunityId);
			
			if(tmpParentOpp != null&& tmpOppLineItem.Is_Bundled_Connect__c == 0 && tmpOppLineItem.Exclude_from_Unit_Total__c == false ) {
				
				tmpParentOpp.Unit_Total_of_Child_Opps__c += tmpOppLineItem.Quantity;
			}			
		}
		
		if(updateParentOppsMap.size() > 0) {
		
			update updateParentOppsMap.values();
		}
	}
}