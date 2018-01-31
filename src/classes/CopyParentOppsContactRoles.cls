public with sharing class CopyParentOppsContactRoles {

	public static Boolean HAS_EXECUTED = false;
	
	public static void Execute(List<Opportunity> opportunityList) {
	
		if(HAS_EXECUTED) {
			
			return;
		}
		
		HAS_EXECUTED = true;
		
		Map<Id, List<Opportunity>> parentChildOppsMap = new Map<Id, List<Opportunity>>();
		List<Opportunity> childOppsList = null;
		List<OpportunityContactRole> newOppsContactRolesList = new List<OpportunityContactRole>();
		List<OpportunityContactRole> oppsContactRolesList = null;
		Opportunity opp = null;
		OpportunityContactRole cloneOppContactRole = null;
		Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
		
		//Put sibling Opportunities into a Map stored by their Parent Ids for easier processing down the road
		for(Opportunity tmpOpp : opportunityList) {
		
			if(tmpOpp.Parent_Opportunity__c != null && tmpOpp.RecordTypeId == csoRecordTypeId) {	
			
				childOppsList = parentChildOppsMap.get(tmpOpp.Parent_Opportunity__c);
				
				if(childOppsList != null) {
					
					childOppsList.add(tmpOpp);
				}
				else {
					
					childOppsList = new List<Opportunity>();
					
					childOppsList.add(tmpOpp);
					
					parentChildOppsMap.put(tmpOpp.Parent_Opportunity__c, childOppsList);
				}
			}
		}
		
		//Get matching Opportunity Contact Roles from database
		oppsContactRolesList = [SELECT Id, OpportunityId, ContactId, Role, IsPrimary FROM OpportunityContactRole
										WHERE OpportunityId IN :parentChildOppsMap.keySet()];
		
		//Clone a matching Opportunity Contact for each Opportunity with matching Parent Opportunity Ids
		for(OpportunityContactRole tmpOppContactRole : oppsContactRolesList) {
			
			childOppsList = parentChildOppsMap.get(tmpOppContactRole.OpportunityId);
			
			if(childOppsList != null) {
				
				for(Opportunity tmpOpp : childOppsList) {
					
					cloneOppContactRole = tmpOppContactRole.clone(false, true);
					
					cloneOppContactRole.OpportunityId = tmpOpp.Id;
					
					newOppsContactRolesList.add(cloneOppContactRole);
				}
			}
		}
		
		//Save new Opportunity Contact Roles
		if(newOppsContactRolesList.size() > 0) {
			
			insert newOppsContactRolesList;
		}
		
	}
}