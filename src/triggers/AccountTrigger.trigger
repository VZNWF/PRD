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
// File Name:       AccountTrigger
// Summary:         Trigger for Account
// Created On:      May-7-2015

// Modification Log:
====================

// Aravind    - 5/7/2015 - Created a trigger

*******************************************************************************/

trigger AccountTrigger on Account (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
    AccountTriggerHelper_CS csHandler = new AccountTriggerHelper_CS(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
      handler.OnBeforeInsert(Trigger.new);
      //csHandler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
      handler.OnAfterInsert(Trigger.new);
      // AccountTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
      csHandler.OnAfterInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
      handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
      csHandler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
      // handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
      // AccountTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
      csHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }

    /*
    else if(Trigger.isDelete && Trigger.isBefore){
      // handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
      // csHandler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
      // handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
      // AccountTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
      // csHandler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
    else if(Trigger.isUnDelete){
      // handler.OnUndelete(Trigger.new);    
      // csHandler.OnUndelete(Trigger.new);
    }*/
}