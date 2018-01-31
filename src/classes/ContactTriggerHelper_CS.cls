/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Steve Swiger (CodeScience)
// File Name:       ContactTriggerHelper_CS
// Summary:         Trigger Handler class for Contact Data, replacing
//					inline code from Contact Trigger
// Created On:      08-18-2015

// Modification Log:
====================

// Swiger    - 08/18/2015 - Create a base version of ContactTriggerHelper_CS class 

*******************************************************************************/
public without sharing class ContactTriggerHelper_CS {
	//private variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    //public properties
	public boolean IsTriggerContext{
		get{ return m_isExecuting;}
	}

	//constructor
    public ContactTriggerHelper_CS(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    //public methods
    public void OnBeforeInsert(Contact[] newContacts){
		//When a new Contact record is created, 
		//update the Contact Owner to match the owner of the related Account
		Set<Id> accountIds = new Set<Id>{};
		for(Contact c: newContacts){
			accountIds.add(c.accountId);
		}
		if(accountIds.size() > 0) {
			transferContactOwnership(accountIds, newContacts);
		}
    } 
    
/*	//NOT CURRENTLY USED
    public void OnAfterInsert(Contact[] newContacts){
    
    public void OnBeforeUpdate(Contact[] oldContacts, Contact[] updatedContacts, Map<ID, Contact> contactMap, Map<ID, Contact> oldContactMap) {}

    public void OnAfterUpdate(Contact[] oldContacts, Contact[] updatedContacts, Map<ID, Contact> contactMap) {}

	public void OnBeforeDelete(Contact[] recordsToDelete, Map<ID, Contact> recordMap){}
	
	public void OnAfterDelete(Contact[] deletedRecords, Map<ID, Contact> recordMap){}

	public void onAfterUndelete(Contact[] undeletedRecords) {}
*/

	private void transferContactOwnership(Set<Id> accountIds, Contact[] newContacts) {
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
			
		for(Contact c: newContacts){
			if(c.accountId != null){
				if(ActiveMap.get(accountMap.get(c.accountId).ownerId)){
					c.ownerId = accountMap.get(c.accountId).ownerId;
				}
			}
		}
	}

}