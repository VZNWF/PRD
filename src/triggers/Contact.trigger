trigger Contact on Contact (before insert) {
	
	//Contact Trigger : When a new Contact record is created, 
	//update the Contact Owner to match the owner of the related Account
	
	Set<Id> AccountIds = new Set<Id>{};
	for(Contact c: Trigger.new){
		AccountIds.add(c.accountId);
	}
	Map<Id, Account> accountMap = new Map<Id, Account>{};
	Map<Id, Boolean> activeMap = new Map<Id, Boolean>{};
	
	Set<Id> owners = new Set<Id>{};
	for (Account a : [select id,OwnerId from Account where id in :accountIds]){
		accountMap.put(a.id, a);
		owners.add(a.OwnerId);
	}
	
	for(user u : [select Id, IsActive from User where id in: owners]){
		activeMap.put(u.id, u.IsActive);
	}
					
		
	for(Contact c: Trigger.new){
		if(c.accountId != null){
			if(ActiveMap.get(accountMap.get(c.accountId).ownerId)){
				c.ownerId = accountMap.get(c.accountId).ownerId;
			}
		}
	}
}