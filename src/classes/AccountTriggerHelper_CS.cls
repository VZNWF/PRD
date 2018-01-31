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
// File Name:       AccountTriggerHelper_CS
// Summary:         Trigger Handler class for Account Data, replacing
//                  inline code from Account Trigger
// Created On:      08-18-2015

// Modification Log:
====================

// Swiger    - 08/18/2015 - Create a base version of AccountTriggerHelper_CS class 
// Swiger    - 08/19/2015 - Refactored OnBeforeUpdate and OnAfterUpdate to call private methods
// Swiger    - 08/27/2015 - Modified to insure rates are the same between bundle and purchase accts
// Swiger    - 10/07/2015 - Modified processChildAccountUpdatesToParent to fix issue with bulk update
// Swiger    - 10/13/2015 - Commenting out the calls to processChildAccountUpdatesToParent per
//                              Sprint.ly Issue #119; If added back in, AccountTriggerHelper_CS_Test
//                              will need have the the testChildToParentUpdates function added back as well.
*******************************************************************************/
public without sharing class AccountTriggerHelper_CS {
    //private variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private boolean runDecisionOnDemand = false;
    private Id salesRecordTypeId;

    //public properties
    public static boolean firstRun = true;
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    //constructor
    public AccountTriggerHelper_CS(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
        // DecisionOnDemand: Check if we are OK to run this trigger -- it should not run from unit tests or batches
        // From Merging ExecuteAccountPolicies Trigger
        runDecisionOnDemand = (!System.isFuture() && !System.isBatch() && !Test.isRunningTest());
        salesRecordTypeId = CSUTils.getRecordTypeId('Account','Sales Account');
    }
        
    //public methods
/*    public void OnBeforeInsert(Account[] newAccounts){

    } */
    
    public void OnAfterInsert(Account[] newAccounts){
        if(runDecisionOnDemand) { executeDecisionOnDemandAccountTriggerProcess(newAccounts); }

        // If account type is end customer, is a Sales account, is bundled, has a parent, Update parent fields with child values
        // SCS - Removing per Sprint.ly #119
/*        List<Account> childAccountsForUpdate = new List<Account>();
        for(Account acc : newAccounts) {
            if(acc.Acct_Type__c == 'End Customer' && acc.ParentId != null && 
                acc.RecordTypeId == salesRecordTypeId && acc.Bundled__c == true) {
                    childAccountsForUpdate.add(acc);
            }
        }
        processChildAccountUpdatesToParent(childAccountsForUpdate);
*/
    }
    
    public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> accountMap, Map<ID, Account> oldAccountMap){
        //If ownership changed, map old owner id to new owner ids
        Set<Id> accIds = new Set<Id>();
        Map <Id, Id> oldOwnerToNewOwner = new Map<Id,Id>();
        for (Account a : updatedAccounts) {
            if(a.OwnerId != oldAccountMap.get(a.Id).OwnerId){
                system.debug('owner changed old' + oldAccountMap.get(a.Id).OwnerId);
                system.debug('owner changed new' + a.OwnerId );
                //oldOwnerToNewOwner.put(trigger.oldMap.get(a.Id).OwnerId, a.OwnerId );
                oldOwnerToNewOwner.put(a.id, a.OwnerId);
                accIds.add(a.id);
            }
            //else {
            //  system.debug('no change');
            //}
        } 
        system.debug('accIds'+ accIds);
        if(accIds.size() > 0) {
            transferContactOwnership(oldOwnerToNewOwner, accIds);
        }

    }
    
    public void OnAfterUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> accountMap){
        List<Account> accountsToInclude = new List<Account>();
        if(runDecisionOnDemand) { 
            for (Account acct  : updatedAccounts) {
                if (!String.isBlank(acct.RuleTriggerEvents__c)) { accountsToInclude.add(acct); }
            }
        }
        if (accountsToInclude.size()>0) { executeDecisionOnDemandAccountTriggerProcess(accountsToInclude); }

        // If account type is end customer, then submit record to approval process
        Set<Id> accountsToSubmitForApproval = new Set<Id>();
        // SCS - Removing per Sprint.ly #119
        List<Account> childAccountsForUpdate = new List<Account>();
        for(Account acc : updatedAccounts) {
            if(acc.Acct_Type__c == 'End Customer') { 
                accountsToSubmitForApproval.add(acc.Id); 
                // SCS - Removing per Sprint.ly #119
/*                if(acc.ParentId != null && acc.RecordTypeId == salesRecordTypeId && 
                    acc.Bundled__c == true) {
                    childAccountsForUpdate.add(acc);
                }
*/
            }
        }
        // If account type is end customer, then submit record to approval process
        processAccountApprovals(accountsToSubmitForApproval);

        // If account type is end customer, is a Sales account, is bundled, has a parent, Update parent fields with child values
        // SCS - Removing per Sprint.ly #119
        //processChildAccountUpdatesToParent(childAccountsForUpdate);
    }

/*  //NOT CURRENTLY USED
    public void OnBeforeDelete(Account[] recordsToDelete, Map<ID, Account> recordMap){
        //DecsOnD.TriggerExecutionHandler.executePolicySObjectDelete(trigger.old);
    }
    public void OnAfterDelete(Account[] deletedRecords, Map<ID, Account> recordMap){}
    public void onAfterUndelete(Account[] undeletedRecords) {}
*/

    //internal methods
    private void executeDecisionOnDemandAccountTriggerProcess(Account[] accountsToProcess) {
        Map<String, String> errorMessages = null;
        errorMessages = DecsOnD.TriggerExecutionHandler.executePolicySObjectInsert(accountsToProcess);
        if (errorMessages!=null) {
            System.debug('Errors while invoking business policies for Account');
            for (String policyName : errorMessages.keySet()) {
                System.debug('-- Policy: ' + policyName + ': ' + errorMessages.get(policyName));
            }
        }
    }

    private void transferContactOwnership(Map <Id, Id> oldOwnerToNewOwner, Set<Id> accIds) {
        //find related contacts and update their ownership
        List<Contact> consToUpdate = new List<Contact>();
        for (Contact c : [select Id, AccountId, OwnerId from  Contact where AccountId in: accIds]){
            system.debug('contact' + c);
            system.debug('ownerId' + c.ownerId);
            system.debug('new ownerId' + oldOwnerToNewOwner.get(c.accountId));
            c.ownerId = oldOwnerToNewOwner.get(c.accountId);
            consToUpdate.add(c);
        }

        if(consToUpdate.size() > 0) { update consToUpdate; }

    }

    private void processAccountApprovals(Set<Id> accountsToSubmitForApproval) {
        system.debug('size of approval submission accounts: ' + accountstoSubmitForApproval.size());
        if(accountsTosubmitForApproval.size() > 0) {
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            for (Id AccId: accountsToSubmitForApproval) {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting account for approval as account type is End Customer');
                req1.setObjectId(accId);
                requests.add(req1);
            }

            Approval.ProcessResult[] processResults = null;
            try {
                processResults = Approval.process(requests, true);
                for(Approval.Processresult result : processResults) {
                    System.debug('Submitted for approval successfully?: ' + result.isSuccess());
                }
            }
            catch (System.DmlException e) {
                System.debug('Exception Is ' + e.getMessage());
            }
        }
    }

    // SCS - Removing per Sprint.ly #119
/*    private void processChildAccountUpdatesToParent(List<Account> childAccountsForUpdate) {
        if(childAccountsForUpdate.size() > 0) {
            Map<Id,Account> parentsToUpdate = new Map<Id,Account>();
            for(Account acc : childAccountsForUpdate) {
                if(!parentsToUpdate.containsKey(acc.ParentId)) {
                    parentsToUpdate.put(acc.ParentId,
                        new Account(
                            Id = acc.ParentId,
                            Account_Hardware_Accessory_Tier__c  = acc.Account_Hardware_Accessory_Tier__c,
                            Account_Service_Tier__c = acc.Account_Service_Tier__c,
                            Account_Bundled_Tier__c = acc.Account_Bundled_Tier__c
                        )
                    );
                }
            }
            update parentsToUpdate.values();
        }
    }
*/

}