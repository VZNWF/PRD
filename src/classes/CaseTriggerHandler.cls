public class CaseTriggerHandler {
    public static void updateParAccId(List<Case> casesToUpdate, Set<Id> accIds){
    	
    	Map<Id, Account> accParIdMap = new Map<Id, Account>([Select Id, ParentId from Account where Id IN:accIds]);
    	if(accParIdMap.size()>0){
    		for(Case c: casesToUpdate){
	    		System.debug(c.AccountId);
	    		c.AccountId = accParIdMap.containsKey(c.Fleet_Account__c)?accParIdMap.get(c.Fleet_Account__c).ParentId:c.AccountId;
	    		c.Is_Fleet_same_as_Account__c = false;
	    		System.debug(c.AccountId);
	    	}
    	}
    }
}