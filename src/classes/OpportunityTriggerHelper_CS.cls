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
// File Name:       OpportunityTriggerHelper_CS
// Summary:         Trigger Handler class for Opportunity Data, replacing
//                  inline code from Opportunity Trigger
// Created On:      08-26-2015

// Modification Log:
====================

// Swiger    - 08/26/2015 - Create a base version of OpportunityTriggerHelper_CS class
//                          Add functionality from Task #111: updating Has_Pilot_Opp__c
// Sunil - 03/24/2017 - Commented the welcome mails code(Jira Ticket Number - 1577) 
//Sunil  - 04/21/2017 - Added code to fix CPQ Process Builder Production issue.
*******************************************************************************/
public without sharing class OpportunityTriggerHelper_CS {
    //private variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private Id csoRecordTypeId;
    private Id pilotRecordTypeId;
    private Id salesOpportunityRecordTypeId;

    //public properties
    public static boolean firstRun = true;
    public boolean IsTriggerContext{
        get{ return m_isExecuting;}
    }

    //constructor
    public OpportunityTriggerHelper_CS(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
        csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        pilotRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Pilot Opportunity');
        salesOpportunityRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
    }

    //public methods

/*  //NOT CURRENTLY USED
    public void OnBeforeInsert(Opportunity[] newOpportunities){} 
*/
    public void OnAfterInsert(Opportunity[] newOpportunities){
        List<Opportunity> childOpps = new List<Opportunity>();
        List<Id> opportunitiesToUpdate = new List<Id>();
        Set<Id> updateParents = new Set<Id>();
        List<Opportunity> approvalOpps = new List<Opportunity>();
        for(Opportunity opp : newOpportunities) {
            if(opp.RecordTypeId == pilotRecordTypeId && opp.Parent_Opportunity__c != null) {
                updateParents.add(opp.Parent_Opportunity__c);
            }
            if(!CSUtils.isEmpty(opp.Affiliate_Lead_ID__c) && opp.Parent_Opportunity__c == NULL) {
                opportunitiesToUpdate.add(opp.Id);
            }
            // Added code to fix CPQ Process Builder Production issue - Sunil Kumar
            if(opp.Account_Setup_Trigger__c == true && opp.Account_Setup_Done__c == false){
                approvalOpps.add(opp);
            }
            // End of code to fix CPQ Process Builder Production issue
        }

        processChildCalculations(newOpportunities);
        CopyParentOppsContactRoles.Execute(newOpportunities);
        processUpdatePRM(opportunitiesToUpdate);
        updateParentOppPilotFlag(updateParents, true);
        // Added code to fix CPQ Process Builder Production issue - Sunil Kumar
        if(approvalOpps.size()>0){
            submitRecordToApproval(approvalOpps);
        }
        // End of code to fix CPQ Process Builder Production issue    
    }
    
    public void OnBeforeUpdate(Opportunity[] oldOpportunities, Opportunity[] updatedOpportunities, Map<ID, Opportunity> opportunityMap, Map<ID, Opportunity> oldOpportunityMap) {
        List<Opportunity> oppsToCheck = new List<Opportunity>();
        List<Id> parentsToCheck = new List<Id>();

        for (Integer i = 0;i < updatedOpportunities.size();i++) {
            if ((updatedOpportunities[i].RecordTypeId != pilotRecordTypeId) && (updatedOpportunities[i].IsClosed != oldOpportunities[i].IsClosed) && 
                (updatedOpportunities[i].IsClosed == true)) {
                oppsToCheck.add(updatedOpportunities[i]);
            }
            if ((updatedOpportunities[i].RecordTypeId == csoRecordTypeId) && (updatedOpportunities[i].IsClosed != oldOpportunities[i].IsClosed) && 
                (updatedOpportunities[i].IsClosed == true) && (updatedOpportunities[i].IsWon == true)) {
                parentsToCheck.add(updatedOpportunities[i].Parent_Opportunity__c);
            }
        }

        validatePilotOppsForClose(oppsToCheck, updatedOpportunities);
        validateClosedStatusFromParents(parentsToCheck, updatedOpportunities);

    }

    public void OnAfterUpdate(Opportunity[] oldOpportunities, Opportunity[] updatedOpportunities, Map<ID, Opportunity> opportunityMap,Map<ID, Opportunity> oldOpportunityMap) {
        List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> childOpps = new List<Opportunity>();
        List<Id> closedPilotParents = new List<Id>();
        List<Id> opportunitiesToUpdate = new List<Id>();
        Set<Id> updateParents = new Set<Id>();
        List<Opportunity> approvalOpps = new List<Opportunity>();

        for (Opportunity opportunity : updatedOpportunities) {
            if (opportunity.RecordTypeId == salesOpportunityRecordTypeId && opportunity.IsWon == true && opportunity.Type == 'New Business') {
                opportunitiesToProcess.add(opportunity);
                accountIds.add(opportunity.AccountId);
             }
        }

        integer j=0; 
        while(j < updatedOpportunities.size()) {            
             if((updatedOpportunities[j].IsWon != oldOpportunities[j].IsWon) && (oldOpportunities[j].IsWon || updatedOpportunities[j].IsWon)) {                 
                childOpps.add(updatedOpportunities[j]);
            }
            if ((updatedOpportunities[j].RecordTypeId == pilotRecordTypeId) &&
                (updatedOpportunities[j].IsClosed != oldOpportunities[j].IsClosed) && (updatedOpportunities[j].IsClosed == true) &&
                (updatedOpportunities[j].IsWon == false) && (updatedOpportunities[j].Parent_Opportunity__c != null)) {
                closedPilotParents.add(updatedOpportunities[j].Parent_Opportunity__c);
            }
            if(!CSUtils.isEmpty(updatedOpportunities[j].Affiliate_Lead_ID__c) && 
                (updatedOpportunities[j].StageName != oldOpportunities[j].StageName || updatedOpportunities[j].OwnerId != oldOpportunities[j].OwnerId || 
                oldOpportunities[j].Unit_Total_of_Child_Opps__c != updatedOpportunities[j].Unit_Total_of_Child_Opps__c) && 
                updatedOpportunities[j].Parent_Opportunity__c == NULL){
                opportunitiesToUpdate.add(updatedOpportunities[j].Id);
            }
            j++;
        }

        for(Opportunity opp : updatedOpportunities) {
            if(opp.RecordTypeId == pilotRecordTypeId && opp.Parent_Opportunity__c != null) {
                updateParents.add(opp.Parent_Opportunity__c);
            }
            if((opp.Account_Setup_Trigger__c == true && opp.Account_Setup_Done__c == false) && (opp.Account_Setup_Trigger__c != oldOpportunityMap.get(opp.id).Account_Setup_Trigger__c || opp.Account_Setup_Done__c != oldOpportunityMap.get(opp.id).Account_Setup_Done__c)){
                approvalOpps.add(opp);
            }
        }

        //processWelcomeCalls(opportunitiesToProcess, accountIds);
        processChildCalculations(childOpps);
        processUpdatePRM(opportunitiesToUpdate);
        updateParentOppPilotFlag(updateParents, true);
        if(approvalOpps.size()>0){
            submitRecordToApproval(approvalOpps);
        }

    }

    public void OnBeforeDelete(Opportunity[] recordsToDelete, Map<ID, Opportunity> recordMap){
        processChildCalculations(recordsToDelete);

    }

    public void OnAfterDelete(Opportunity[] deletedRecords, Map<ID, Opportunity> recordMap){
        Set<Id> updateParents = new Set<Id>();
        for(Opportunity opp : deletedRecords) {
            if(opp.RecordTypeId == pilotRecordTypeId && opp.Parent_Opportunity__c != null) {
                updateParents.add(opp.Parent_Opportunity__c);
            }
        }
        updateParentOppPilotFlag(updateParents, false);
    }
/*
    public void onAfterUndelete(Opportunity[] undeletedRecords) {}
*/

    private void updateParentOppPilotFlag(Set<Id> updateParents, boolean flagValue) {
        if(updateParents.size() > 0) {
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Id oid : updateParents) {
                updateOpps.add(
                    new Opportunity(
                        Id = oid,
                        Has_Pilot_Opp__c = flagValue
                    )
                );
            }
            if(updateOpps.size() > 0) { update updateOpps; }
        }
    }

    /*private void processWelcomeCalls(List<Opportunity> opportunitiesToProcess, Set<Id> accountIds) {
        if (opportunitiesToProcess.size() > 0) {
            Map<Id, Account> accounts =
                new Map<Id, Account>([select Id, ParentId
                                      from Account
                                      where Id in :accountIds
                                      and Acct_Type__c = 'End Customer'
                                      and (Sub_Type__c = 'SMB' or Sub_Channel__c = 'PUBLIC SECTOR SMB')
                                      and Exclude_from_Welcome_Call__c = false
                                      and Completed_Account_Set_up__c >= :Date.today().addDays(-7)]);

            system.debug('accounts.size(): ' + accounts.size());
            if (accounts.size() > 0) {
                Map<Id, Opportunity> opportunities =
                    new Map<Id, Opportunity>([select Id, (select ContactId from OpportunityContactRoles where Role = 'Signatory')
                                              from Opportunity
                                              where Id in :opportunitiesToProcess]);
                system.debug('opportunities.size: ' + opportunities.size());
                Set<Id> parentAccountIds = new Set<Id>();
                for (Account account : accounts.values()) {
                    if (account.ParentId != null) {
                        parentAccountIds.add(account.ParentId);
                    }
                }
                system.debug('parentAccountIds.size ' + parentAccountIds.size());
                Set<Id> siblingAccountIds = new Set<Id>();
                Map<Id, Set<Id>> parentToChildAccountIds = new Map<Id, Set<Id>>();
                if (parentAccountIds.size() > 0) {
                    for (Account account : [select Id, ParentId from Account where ParentId in :parentAccountIds]) {
                        siblingAccountIds.add(account.Id);
    
                        Set<Id> childAccountIds = parentToChildAccountIds.get(account.ParentId);
                        if (childAccountIds == null) {
                            childAccountIds = new Set<Id>();
                            parentToChildAccountIds.put(account.ParentId, childAccountIds);
                        }
                        
                        childAccountIds.add(account.Id);
                    }
                    system.debug('siblingAccountIds.size ' + siblingAccountIds.size());
                    system.debug('parentToChildAccountIds.size ' + parentToChildAccountIds.size());
                }

                Set<Id> welcomeCallAccountIds = new Set<Id>();
                Set<Id> welcomeCallOpportunityIds = new Set<Id>();
                List<Welcome_Call__c> existingWelcomeCalls =
                    [select Account_Name__c, Opportunity_Name__c
                     from Welcome_Call__c
                     where Account_Name__c in :accountIds or
                     Account_Name__c in :parentAccountIds or
                     Account_Name__c in :siblingAccountIds or
                     Opportunity_Name__c in :opportunitiesToProcess];
                
                for (Welcome_Call__c welcomeCall : existingWelcomeCalls) {
                    welcomeCallAccountIds.add(welcomeCall.Account_Name__c);
                    welcomeCallOpportunityIds.add(welcomeCall.Opportunity_Name__c);
                }
                system.debug('existingWelcomeCalls.size ' + existingWelcomeCalls.size());               
                system.debug('welcomeCallAccountIds.size ' + welcomeCallAccountIds.size());             
                system.debug('welcomeCallOpportunityIds.size ' + welcomeCallOpportunityIds.size());             

                Id welcomeCallQueueId = [select Id from Group where Type = 'Queue' and DeveloperName = 'Welcome_Call_Queue'].Id;

                system.debug('welcomeCallQueueId ' + welcomeCallQueueId);               
                
                List<Welcome_Call__c> welcomeCalls = new List<Welcome_Call__c>();
                for (Opportunity opportunity : opportunitiesToProcess) {
                    System.debug('1');
                    // If a Welcome Call record doesn't exist yet, create one.
                    Account account = accounts.get(opportunity.AccountId);
                    if (account != null) {
                        System.debug('2');
                        // Check that the Opportunity and it's Account don't have a welcome call.
                        if (welcomeCallOpportunityIds.contains(opportunity.Id) || welcomeCallAccountIds.contains(opportunity.AccountId)) {
                            System.debug('3');
                            continue;
                        }
                        
                        // Check that the Opportunity's Account's parent or sibling Accounts don't have a welcome call.
                        if (account.ParentId != null) {
                            System.debug('4');
                            if (welcomeCallAccountIds.contains(account.ParentId)) {
                                System.debug('5');
                                continue;
                            }

                            if (parentToChildAccountIds.containsKey(account.ParentId)) {
                                System.debug('6');
                                Boolean welcomeCallFound = false;

                                for (Id accountId : parentToChildAccountIds.get(account.ParentId)) {
                                    if (welcomeCallAccountIds.contains(accountId)) {
                                        System.debug('7');
                                        welcomeCallFound = true;
                                        break;
                                    }
                                }
                                
                                if (welcomeCallFound) {
                                    System.debug('8');
                                    continue;
                                }
                            }
                        }
                        System.debug('9');
                        
                        Welcome_Call__c welcomeCall = new Welcome_Call__c();
                        welcomeCall.Account_Name__c = opportunity.AccountId;
                        welcomeCall.Opportunity_Name__c = opportunity.Id;
                        
                        if (opportunities.get(opportunity.Id).OpportunityContactRoles.size() > 0) {
                            System.debug('10');
                            welcomeCall.Contact_Name__c = opportunities.get(opportunity.Id).OpportunityContactRoles[0].ContactId;
                        }
                        
                        welcomeCall.OwnerId = welcomeCallQueueId;
                        welcomeCalls.add(welcomeCall);
                        System.debug('11');

                    }
                }
                system.debug('WelcomeCalls.size: ' + welcomeCalls.size());
                insert welcomeCalls;
            }
        }
    }*/

    private void validatePilotOppsForClose(List<Opportunity> oppsToCheck, List<Opportunity> allOpps) {
        if (oppsToCheck.size() > 0) {
            List<Opportunity> pilotOpps = new List<Opportunity>();
            try {
                pilotOpps = [SELECT Id, Name, StageName, Parent_Opportunity__c, IsClosed, IsWon FROM Opportunity WHERE IsClosed = FALSE AND RecordTypeId =: pilotRecordTypeId AND Parent_Opportunity__c IN :oppsToCheck];
            } 
            catch (Exception e) { 
                // Do nothing.
            }

            if (pilotOpps.size() > 0) {
                for (Opportunity pilotOpp : pilotOpps) {
                    for (Opportunity badOpp : allOpps) {
                        if (badOpp.Id == pilotOpp.Parent_Opportunity__c) {
                            badOpp.StageName.addError('Cannot close this Opportunity while Pilot Opportunity ' + pilotOpp.Name + ' is still open.');
                        }
                    }
                }
            }
        }       
    }

    private void validateClosedStatusFromParents(List<Id> parentsToCheck, List<Opportunity> allOpps) {
        // Don't allow Child Opportunity to be Closed Won if Parent Opportunity is Closed Lost
        if (parentsToCheck.size() > 0) {
            List<Opportunity> parentOpps = new List<Opportunity>();
            try {
                parentOpps = [SELECT Id, Name, StageName, IsClosed, IsWon FROM Opportunity WHERE IsClosed = TRUE AND IsWon = FALSE AND Id IN :parentsToCheck];
            } catch (Exception e) {
                // Do nothing.
            }

            if (parentOpps.size() > 0) {
                for (Opportunity parentOpp : parentOpps) {
                    for (Opportunity badOpp : allOpps) {
                        if (badOpp.Parent_Opportunity__c == parentOpp.Id) {
                            badOpp.StageName.addError('Cannot mark this Opportunity as Won when Parent Opportunity ' + parentOpp.Name + ' is Lost.');
                        }
                    }

                }
            }
        }
    }

    private void processChildCalculations(List<Opportunity> childOpps) {
        if(childOpps.size() > 0) {
            Set<Id> childOppIdsSet = new Set<Id>();
            for(opportunity opp : childOpps) {          
                if(opp.Parent_Opportunity__c != null && opp.RecordTypeId == csoRecordTypeId ) {             
                    childOppIdsSet.add(opp.Id);
                }
            }
            if(childOppIdsSet.size() > 0 ) {            
                CalculateChildOppsUnitTotal.ProcessParentOpps(childOppIdsSet);
            }   
        }
    }

    private void processPilotParentClosedLost(List<Id> closedPilotParents) {
        if (closedPilotParents.size() > 0) {
            List<Opportunity> opportunitiesToClose = new List<Opportunity>();
            try {
                opportunitiesToClose = [SELECT Id, Name, StageName, IsClosed FROM Opportunity WHERE Id IN :closedPilotParents];
            } catch (Exception e) {
                // Do nothing
            }

            if (opportunitiesToClose.size() > 0) {
                for (Opportunity opp : opportunitiesToClose) {
                    opp.StageName = 'Closed Lost';
                    opp.Main_Lost_Reason__c = 'Pilot Unsuccessful';
                }
                update opportunitiesToClose;
            }
        }       
    }
    
    private void processUpdatePRM(List<Id> opportunitiesToUpdate) {
        //update PRM
        if(opportunitiesToUpdate.size() > 0 && firstRun){
            PRMLeadUpdate.updateLeads(null, new Set<Id>(opportunitiesToUpdate), test.isRunningTest());
            firstRun = false;
            /*system.debug('calling out to batch');
            PRMLeadUpdateBatch b = new PRMLeadUpdateBatch(null, opportunitiesToUpdate, test.isRunningTest());
            if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 99){
               system.debug('executing batch');
               Database.executeBatch(b,20);
            } 
            else {
               system.debug('scheduling to be executed again in 5 minutes');
               //schedule this same schedulable class again in 30 mins
               PRMLeadUpdateBatchSchedule sc = new PRMLeadUpdateBatchSchedule(null,opportunitiesToUpdate,test.isRunningTest());
               Datetime dt = Datetime.now().addMinutes(5);
               String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
               Id schedId = System.Schedule('Update PRM Retry'+timeForScheduler + String.ValueOf(Math.random()),timeForScheduler,sc);
            }*/
        }
    }
    // Added code to fix CPQ Process Builder Production issue - Sunil Kumar
    private void submitRecordToApproval(List<Opportunity> opps){
        for(Opportunity opp : opps){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Automatically submitted for Account Setup Approval for Existing Customer.');
            req1.setObjectId(opp.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(userinfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Account_Setup_for_Existing_Customer');
            req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
        }
    }
    // End of code to fix CPQ Process Builder Production issue
}