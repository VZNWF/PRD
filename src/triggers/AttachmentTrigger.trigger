/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Vasanth Parvatagiri
// File Name:       AttachmentTrigger 
// Summary:         Trigger for Contact
// Created On:      April-14-2015

// Modification Log:
====================

// Vasanth    - 4/14/2015 - Created a trigger
//Vasanth     - 4/16/2015 - Added Insert and Update handlers

*******************************************************************************/

trigger AttachmentTrigger on Attachment (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AppSettings__c APP= AppSettings__c.getOrgDefaults();
    boolean App1= App.Disable_Triggers__c;
    
    AppSettings__c USERSETTING= AppSettings__c.getInstance(userinfo.getUserId());
    boolean USERSETTING1= USERSETTING.Disable_Triggers__c;
        
    if(App1== true || USERSETTING1 == true)
    return;
   
    AttachmentTriggerHandler handler = new AttachmentTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
          handler.OnBeforeInsert(Trigger.new);

    }
    else if(Trigger.isInsert && Trigger.isAfter){
          handler.OnAfterInsert(Trigger.new);
      
    } 
    
    else if(Trigger.isUpdate && Trigger.isBefore){
         // handler.OnBeforeUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){ 
        // handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    /*
    else if(Trigger.isDelete && Trigger.isBefore){
        //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        //handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    
    else if(Trigger.isUnDelete){
        //handler.OnUndelete(Trigger.new);  
    }*/
    }