/****************************************************************
Created: 19 Feb 2013
Author: Aaron Pettitt (CodeScience)
Purpose : Lead Trigger to update CCI on lead updates
Modifications: Added before update to change the Lead Sub Type
               based on a change of Owner.  If the new owner is
               a Queue, we blank out the Lead Sub Type.
******************************************************************/
trigger Lead on Lead (before update, after update, before insert,after insert) {

    //Merging ExecuteLeadPolicies Trigger with current Trigger

    // Check if we are OK to run this trigger -- it should not run from unit tests or batches
   boolean b=(System.isFuture() || System.isBatch() || Test.isRunningTest());

    if(!b){
        if (trigger.isAfter) {
            if (trigger.isInsert) {
                DecsOnD.TriggerExecutionHandler.executePolicySObjectInsert(trigger.new);
            } else if (trigger.isUpdate) {
                DecsOnD.TriggerExecutionHandler.executePolicySObjectUpdate(trigger.new);
            }
        }else if (trigger.isBefore && trigger.isDelete) {
            //      DecsOnD.TriggerExecutionHandler.executePolicySObjectDelete(trigger.old);
        }
    }

    if (Trigger.isAfter) {

        if(Trigger.isUpdate){
            LeadTriggerHelper.updateOpportunityOnConversion(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, 'AfterUpdate'); // Added by Siva Adapa
            
            List<Id> leadsToUpdate = new List<Id>();
            List<Opportunity> opportunities = new List<Opportunity>();
            Integer i = 0;
            while(i < trigger.new.size()){
                if(!CSUtils.isEmpty(trigger.new[i].Partner_ID__c) && !CSUtils.isEmpty(trigger.new[i].Status) &&  !trigger.new[i].isConverted  ){
                    if(trigger.new[i].OwnerId != trigger.old[i].OwnerId && trigger.new[i].Update_PRM__c == true){
                        leadsToUpdate.add(trigger.new[i].Id);
                    }
                    else if(trigger.new[i].Status != trigger.old[i].Status) {
                       leadsToUpdate.add(trigger.new[i].Id);
                    }
                }
                ++i;
            }
        
            system.debug('size of leads to update: ' + leadsToUpdate.size());
            //update PRM
            PRMLeadUpdate.updateOppDescription(trigger.newmap,trigger.oldmap);
            if(leadsToUpdate.size() > 0){
                PRMLeadUpdate.updateLeads(new Set<Id>(leadsToUpdate), null, test.isRunningTest());
                /*PRMLeadUpdateBatch b = new PRMLeadUpdateBatch(leadsToUpdate,null, test.isRunningTest());
                if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 99){
                    system.debug('executing batch');
                    Database.executeBatch(b,20);
                } 
                else {
                    system.debug('scheduling to be executed again in 5 minutes');
                    //schedule this same schedulable class again in 30 mins
                    PRMLeadUpdateBatchSchedule sc = new PRMLeadUpdateBatchSchedule(leadsToUpdate,null,test.isRunningTest());
                    Datetime dt = Datetime.now().addMinutes(5);
                    String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
                    Id schedId = System.Schedule('Update PRM Retry'+timeForScheduler + String.ValueOf(Math.random()),timeForScheduler,sc);
                } */      
            }
        }
    }
    else if (Trigger.isBefore) {

        if(Trigger.isInsert){
            LeadTriggerHelper.updateSCCSubChannel(Trigger.new);
            LeadTriggerHelper.resetS2LBeforeInsert(Trigger.new);  //Added by Siva Adapa
        }

        else if(Trigger.isUpdate){
            LeadTriggerHelper.updateSCCSubChannel(Trigger.new);
            LeadTriggerHelper.updateOpportunityOnConversion(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, 'BeforeUpdate'); //Added by Siva Adapa

            List<Lead> leadsToUpdate = new List<Lead>();
            List<Id> usersToCheck = new List<Id>();

            for (Integer i = 0;i < Trigger.new.size();i++) {
                if ((trigger.new[i].OwnerId != trigger.old[i].OwnerId) && (String.valueOf(trigger.new[i].OwnerId).startsWith('005'))) { 
                    leadsToUpdate.add(trigger.new[i]);
                    usersToCheck.add(trigger.new[i].OwnerId);
                }
            }

            if (leadsToUpdate.size() > 0) {

                Map<Id, User> leadOwners = new Map<Id, User>([SELECT Id, Channel__c FROM User WHERE Id IN : usersToCheck]);

                for (Lead lead : leadsToUpdate) {
                    lead.Lead_Sub_Type__c = leadOwners.get(lead.OwnerId).Channel__c;
                }

            }
        } 
    }
}