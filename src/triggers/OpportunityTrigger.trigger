/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:           Aravind Rajamanickam
// File Name:       OpportunityTrigger
// Summary:         Trigger for Opportunity
// Created On:      May-7-2015

// Modification Log:
====================

// Aravind    - 5/8/2015 - Created a trigger
//Sunil      -  4/21/2017 - updated code to include oldmap variable in After Update handler.
//Vanditha   -  07/07/2017 - Added Code(updateParentOpportunity) for checking Pilot Coversion on Parent Opportunity 
*******************************************************************************/

trigger OpportunityTrigger on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    OpportunityTriggerHelper_CS csHandler = new OpportunityTriggerHelper_CS(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
       // OpportunityTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
        csHandler.OnAfterInsert(Trigger.New);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        csHandler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }

    else if(Trigger.isUpdate && Trigger.isAfter){
       // handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
       // OpportunityTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
       csHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
       // handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
       csHandler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
       // handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
      //  OpportunityTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
       csHandler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    /*
    else if(Trigger.isUnDelete){
      //  handler.OnUndelete(Trigger.new);    
    }*/
}