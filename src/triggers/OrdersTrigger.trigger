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
// File Name:       OrdersTrigger 
// Summary:         Trigger for Orders__c 
// Created On:      March-18-2015

// Modification Log:
====================

// Aravind    - 3/20/2015 - Created a trigger
//Vanditha    - 8/16/2017 - Updated Trigger to Modify RA Status based on Order Status(Line52 to Line60)
*******************************************************************************/

trigger OrdersTrigger on Orders__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    OrdersTriggerHandler handler = new OrdersTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
        //VZ_ETAStaging_Helper.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        //VZ_ETAStaging_Helper.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
        handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //VZ_ETAStaging_Helper.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }    
    else if(Trigger.isUnDelete){
        //handler.OnUndelete(Trigger.new);  
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.RAStatusSubmitted(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.RAStatusShipped(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore){
        handler.RAStatusCancelled(Trigger.new);
    }
}