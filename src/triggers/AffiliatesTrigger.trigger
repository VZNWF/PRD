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
// File Name:       AffiliatesTrigger 
// Summary:         Trigger for Affiliate__c 
// Created On:      April-3-2015

// Modification Log:
====================

// Aravind    - 4/3/2015 - Created a trigger

*******************************************************************************/

trigger AffiliatesTrigger on Affiliate__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    AffiliatesTriggerHandler handler = new AffiliatesTriggerHandler(Trigger.isExecuting, Trigger.size);
    AppSettings__c APP= AppSettings__c.getOrgDefaults();
    boolean App1= App.Disable_Triggers__c;
    
    AppSettings__c USERSETTING= AppSettings__c.getInstance(userinfo.getUserId());
    boolean USERSETTING1= USERSETTING.Disable_Triggers__c;
    
    if(App1== true || USERSETTING1 == true)
    return;
        
    if(Trigger.isInsert && Trigger.isBefore){
     //   handler.OnBeforeInsert(Trigger.new);
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
      
    }
    
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        //VZ_ETAStaging_Helper.OnAfterUpdateAsync(Trigger.newMap.keySet());
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