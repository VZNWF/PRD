/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Aravind Rajamanickam
// File Name:       ETAStagingTrigger 
// Summary:         Trigger for ETA_STAGING__c 
// Created On:      March-18-2015

// Modification Log:
====================
// Vasanth    - 02-15-2016 - Enabled After Insert Logic to Pull AP and AR values and populate in ETA Staging Record

// Aravind    - 7/15/2015 - Created a trigger

*******************************************************************************/

trigger ETAStagingTrigger on ETA_Staging__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    /*Toggle_Switch__c trgSw = Toggle_Switch__c.getInstance('ETA_Staging__c');
    //Skip trigger if it is disabled using custom setting 
    system.debug(trgSw);
    if(trgSw.isTriggerDisabled__c) {
    return;
    }*/
    ETAStagingTriggerHandler handler = new ETAStagingTriggerHandler(Trigger.isExecuting, Trigger.size);
    /*
    if(Trigger.isInsert && Trigger.isBefore){
       // handler.OnBeforeInsert(Trigger.new);
    }
    else*/
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.newMap);
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
         handler.OnBeforeUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    /*
    else if(Trigger.isDelete && Trigger.isBefore){
        //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //VZ_ETAStaging_Helper.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    
    else if(Trigger.isUnDelete){
        //handler.OnUndelete(Trigger.new);  
    }*/
}