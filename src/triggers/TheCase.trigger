//trigger TheCase on Case (before insert, before update) {
trigger TheCase on Case (before insert, after insert, before update, after update) {

    // -------------------------------------------------------------------------------
    // Copy Fleet Account owner email to the Case.
    // -------------------------------------------------------------------------------

    if (Trigger.isInsert && Trigger.isBefore) {
        
        Set<Id> accountIds = new Set<Id>();
        List<Case> casesToProcess = new List<Case>();
        
        for (Case theCase : Trigger.new) {
            if (theCase.Fleet_Account__c != null) {
                accountIds.add(theCase.Fleet_Account__c);
                casesToProcess.add(theCase);
            }
        }
        
        if (casesToProcess.size() > 0) {
            Map<Id, Account> accounts = new Map<Id, Account>([select Id, Owner.Email from Account where Id in :accountIds]);
            
            for (Case theCase : casesToProcess) {
                Account account = accounts.get(theCase.Fleet_Account__c);
                if (account != null) {
                    theCase.Fleet_Account_Owner_Email__c = account.Owner.Email;
                }
            }
        }
        
    }
    
    // -------------------------------------------------------------------------------
    // Move Account's Welcome Call Number to Case when one is not provided.
    // -------------------------------------------------------------------------------

    if ((Trigger.isBefore) && (Trigger.isInsert || Trigger.isUpdate)) {

        //Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<Case> casesToDo = new List<Case>();
		Set<Id> accIds = new Set<Id>();  //Service Console
		List<Case> casesList = new List<Case>();  //Service Console
        for (Case theCase : Trigger.new) {
            //IT-910 Service Console - Changes - Begin
            if(theCase.RecordTypeId != null){
            	string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(theCase.recordtypeid).getname();
				system.debug('In Before event: Is_Fleet_same_as_Account__c: '+theCase.Is_Fleet_same_as_Account__c+', Fleet_Account__c: '+theCase.Fleet_Account__c+ ', AccountId: '+theCase.AccountId);
	            if(recordtypename == 'Case Reason'){
	                /*if(theCase.Is_Fleet_same_as_Account__c && theCase.Fleet_Account__c != null){
	                    theCase.addError('Both "Is Fleet Same as Account" & "Fleet Account" cannot be updated');    
	                }else if(trigger.isInsert){
		                if((theCase.Is_Fleet_same_as_Account__c && theCase.Fleet_Account__c == null && theCase.AccountId!= null) || (theCase.Fleet_Account__c!=null &&!theCase.Is_Fleet_same_as_Account__c)){
		                	theCase.Fleet_Account__c = theCase.Is_Fleet_same_as_Account__c?theCase.AccountId:theCase.Fleet_Account__c;
		                	theCase.Is_Fleet_same_as_Account__c = false;
			                casesList.add(theCase);
			                if(theCase.accountId != null){
			                	accIds.add(theCase.accountId);		                	
			                }
		                }
	                }else if(trigger.isUpdate){
	                	if((theCase.Is_Fleet_same_as_Account__c != trigger.oldMap.get(theCase.Id).Is_Fleet_same_as_Account__c) || (theCase.Fleet_Account__c != trigger.oldMap.get(theCase.id).Fleet_Account__c) || (theCase.AccountId != trigger.oldMap.get(theCase.Id).AccountId)){
		                	theCase.Fleet_Account__c = theCase.Is_Fleet_same_as_Account__c?theCase.AccountId:theCase.Fleet_Account__c;
		                	theCase.Is_Fleet_same_as_Account__c = false;
			                casesList.add(theCase);
			                if(theCase.accountId != null){
			                	accIds.add(theCase.accountId);		                	
			                }
		                }
	                }*/
	            }
            }
            //IT-910 Service Console - Changes - End
            if (theCase.Welcome_Call_Number__c == null) {
                if (theCase.ContactId != null) {
                    //contactIds.add(theCase.ContactId);
                    accountIds.add(theCase.AccountId);
                    casesToDo.add(theCase);
                }
            }
        }
        //Service Console - Begin
		/*if(accIds.size()>0){
			CaseTriggerHandler.updateParAccId(casesList, accIds);
		}*/
		//Service Console - End
        if (casesToDo.size() > 0) {
            //Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, (SELECT Id FROM Welcome_Calls__r) FROM Contact WHERE Id IN :contactIds]);
            Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, (SELECT Id FROM Welcome_Calls__r) FROM Account WHERE Id IN :accountIds]);

            for (Case theCase : casesToDo) {
                //Contact contact = contacts.get(theCase.ContactId);
                Account account = accounts.get(theCase.AccountId);
                //if ((contact != null) && (contact.Welcome_Calls__r.size() > 0)) {
                if ((account != null) && (account.Welcome_Calls__r.size() > 0)) {
                    // We assume there will be only one record, but if there's multiple, just use the first one.
                    //theCase.Welcome_Call_Number__c = contact.Welcome_Calls__r[0].Id;
                    theCase.Welcome_Call_Number__c = account.Welcome_Calls__r[0].Id;
                }
            }
        }

    }


    // -------------------------------------------------------------------------------
    // Detect escalation changes.
    // -------------------------------------------------------------------------------
/*
    if (Trigger.isUpdate && Trigger.isBefore) {
        
        for (Case newCase : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(newCase.Id);
            if (oldCase.IsEscalated != true && newCase.IsEscalated == true) {
                newCase.Notify__c = true;
            }
        }
        
    }
*/
	//Interim code fix for Production issue - Begin
	if(trigger.isAfter){
		Set<Id> accIds = new Set<Id>();  //Service Console
		List<Case> casesList = new List<Case>();  //Service Console
		Set<Id> caseIdSet = new Set<Id>();
		//IT-910 Service Console - Changes - Begin
		for(Case theCase: trigger.new){
			if(theCase.RecordTypeId != null){
            	string recordtypename = Schema.SObjectType.Case.getRecordTypeInfosById().get(theCase.recordtypeid).getname();
				system.debug('In After event: Is_Fleet_same_as_Account__c: '+theCase.Is_Fleet_same_as_Account__c+', Fleet_Account__c: '+theCase.Fleet_Account__c+ ', AccountId: '+theCase.AccountId);
	            if(recordtypename == 'Case Reason'){
					if(theCase.Is_Fleet_same_as_Account__c && theCase.Fleet_Account__c != null){
			        	theCase.addError('Both "Is Fleet Same as Account" & "Fleet Account" cannot be updated');    
			        }else{
						caseIdSet.add(theCase.Id);
					}
	            }
			}
		}
		
		for(Case theCase: [Select Id, RecordTypeId, Is_Fleet_same_as_Account__c, Fleet_Account__c, AccountId from Case where Id IN: caseIdSet]){
			
            if(trigger.isInsert){
		    	if(theCase.Is_Fleet_same_as_Account__c && theCase.Fleet_Account__c == null && theCase.AccountId!= null){
		        	theCase.Fleet_Account__c = theCase.Is_Fleet_same_as_Account__c?theCase.AccountId:theCase.Fleet_Account__c;
		            theCase.Is_Fleet_same_as_Account__c = false;
			        casesList.add(theCase);
			        if(theCase.AccountId != null){
			                	accIds.add(theCase.AccountId);		                	
			        }
		        }
	        }else if(trigger.isUpdate){
	            if((theCase.Is_Fleet_same_as_Account__c != trigger.oldMap.get(theCase.Id).Is_Fleet_same_as_Account__c) || (theCase.Fleet_Account__c != trigger.oldMap.get(theCase.id).Fleet_Account__c) || (theCase.AccountId != trigger.oldMap.get(theCase.Id).AccountId)){
		        	theCase.Fleet_Account__c = theCase.Is_Fleet_same_as_Account__c?theCase.AccountId:theCase.Fleet_Account__c;
		            theCase.Is_Fleet_same_as_Account__c = false;
			        casesList.add(theCase);
			        if(theCase.accountId != null){
			        	accIds.add(theCase.accountId);		                	
			        }
		        }
	        }
	    }

		//IT-910 Service Console - Changes - End
		
		//Service Console - Begin
		if(accIds.size()>0){
			CaseTriggerHandler.updateParAccId(casesList, accIds);
			update casesList;
		}
		//Service Console - End
	//Interim code fix for Production issue - End
	}
    if (Trigger.isUpdate && Trigger.isAfter) {
        
        Set<Id> caseIds = new Set<Id>();
        
        for (Case newCase : Trigger.new) {
            Case oldCase = Trigger.oldMap.get(newCase.Id);
            if (oldCase.IsEscalated != true && newCase.IsEscalated == true) {
                caseIds.add(newCase.Id);
            }
        }
        
        if (caseIds.size() > 0) {
            CaseTriggerUtil.checkNotifyFlags(caseIds);
        }
        
    }

}