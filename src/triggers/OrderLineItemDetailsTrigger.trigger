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
// File Name:       OrderLineItemDetailsTrigger 
// Summary:         Trigger for Order_Line_Item_Details__c 
// Created On:      March-18-2015

// Modification Log:
====================

// Aravind    - 3/18/2015 - Created a trigger

*******************************************************************************/

trigger OrderLineItemDetailsTrigger on Order_Line_Item_Details__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    OrderLineItemDetailsTriggerHandler handler = new OrderLineItemDetailsTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
        //VZ_ETAStaging_Helper.OnAfterInsertAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
       // handler.OnBeforeUpdate(Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        //VZ_ETAStaging_Helper.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    
    else if(Trigger.isDelete && Trigger.isBefore){
       // handler.OnBeforeDelete(Trigger.old, Trigger.new);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.new);
        //VZ_ETAStaging_Helper.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);  
    }
}