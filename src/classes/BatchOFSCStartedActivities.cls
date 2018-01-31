/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author: Sunil Kumar       
// File Name: BatchOFSCStartedActivities   
// Summary: Batch class for ETA staging records to perform SOAP API Callout        
// Created On:  03/28/2017    
// Jira Ticket Number: IT1638
// Modification Log:
====================
*******************************************************************************/
global class BatchOFSCStartedActivities implements Database.Batchable<SObject>,Database.AllowsCallouts,schedulable{
    public string query;
    List<Id> OFSCIds;
    list<ETA_Staging__c> OFSCRecords;
    list<ETA_Staging__c> OFSCStartedRecords;
    
     
     global Database.queryLocator start(Database.BatchableContext BC){
        //Fetch the ETASTaging records to update
        query = 'Select Id FROM ETA_Staging__c where ETA_Staging_Status__c = \'Started\' ';
        return Database.getQueryLocator(query);
    }
    
    //Scheduler for the batch apex
    global void execute(SchedulableContext sc) {
        BatchOFSCStartedActivities b = new BatchOFSCStartedActivities();
        database.executebatch(b,1);
    }
    
    global void execute(Database.BatchableContext BC, List<ETA_Staging__c> scope){
          OFSCIds = new list<Id>();
          OFSCRecords = new list<ETA_Staging__c>();
          OFSCStartedRecords = new list<ETA_Staging__c>();
          
          for(ETA_Staging__c etaS:scope){
            OFSCIds.add(etaS.Id);
          }
        
        OFSCRecords = [Select Id,Order__r.Customer_Number__c,Scheduled_Date__c,ETA_Staging_Status__c,Assigned_Resource_ID__c FROM ETA_Staging__c where Id in :OFSCIds];
        
        if(OFSCRecords.size() > 0){
            Date todayDate = Date.today();
            for(ETA_Staging__c etaS:OFSCRecords){
                if(etaS.ETA_Staging_Status__c == 'Started' && etaS.Scheduled_Date__c ==  todayDate.addDays(-1)){
                    OFSCStartedRecords.add(etaS);
                } 
            }
        }
            
        If(OFSCStartedRecords.size() > 0){
            try{
                OFSCDataHelper.prepareData(OFSCStartedRecords);
            }
            Catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        
    }
}