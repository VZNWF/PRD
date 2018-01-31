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
// File Name:       InstallCoordinatorAssignmentRuleTrigger
// Summary:         Trigger for Installation_Coordinator_Assignment_Rule__c
// Created On:      July-27-2015

// Modification Log:
====================

// Aravind    - 7/27/2015 - Created a base template trigger

*******************************************************************************/

trigger InstallCoordinatorAssignmentRuleTrigger on Installation_Coordinator_Assignment_Rule__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    ICRuleTriggerHandler handler = new ICRuleTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
       
    }
    else if(Trigger.isInsert && Trigger.isAfter){
     
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter){
       handler.OnAfterUpdate(Trigger.oldMap,Trigger.new,Trigger.newMap);
    }
  
}