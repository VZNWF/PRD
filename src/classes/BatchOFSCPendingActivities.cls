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
// File Name: BatchOFSCPendingActivities   
// Summary: Batch class for ETA staging Pending records to nullify scheduled date        
// Created On:  03/28/2017    
// Jira Ticket Number: IT1638
// Modification Log:
====================
*******************************************************************************/
global class BatchOFSCPendingActivities implements Database.Batchable<SObject>,schedulable{
    public string query;
    List<Id> OFSCIds;
    list<ETA_Staging__c> OFSCRecords;    
    list<ETA_Staging__c> OFSCPendingRecords; 
    list<ETA_Staging__c> OFSCUpdateRecords;
    
     
     global Database.queryLocator start(Database.BatchableContext BC){
        //Fetch the ETASTaging records to update
        query = 'Select Id FROM ETA_Staging__c where (ETA_Staging_Status__c = \'Suspended\' OR ETA_Staging_Status__c = \'Pending\')';
        return Database.getQueryLocator(query);
    }
    
    //Scheduler for the batch apex
    global void execute(SchedulableContext sc) {
        BatchOFSCPendingActivities b = new BatchOFSCPendingActivities();
        database.executebatch(b,100);
    }
    
    global void execute(Database.BatchableContext BC, List<ETA_Staging__c> scope){
          OFSCIds = new list<Id>();
          OFSCRecords = new list<ETA_Staging__c>();          
          OFSCPendingRecords = new list<ETA_Staging__c>();
          OFSCUpdateRecords = new list<ETA_Staging__c>();
          
          for(ETA_Staging__c etaS:scope){
            OFSCIds.add(etaS.Id);
          }
        
        OFSCRecords = [Select Id,Order__r.Customer_Number__c,Scheduled_Date__c,ETA_Staging_Status__c,Assigned_Resource_ID__c FROM ETA_Staging__c where Id in :OFSCIds];
        
        set<String> affiliateNames = new set<String>();
        List<String> affiliateNamesIncludingAssociatedAff = new List<String>();
        Map<string,string> olidaffiliateClonedbucketAff = new Map<string,string>();
        for(ETA_Staging__c etaS:OFSCRecords){
            if(!String.isBlank(etaS.Assigned_Resource_ID__c)){
                affiliateNames.add(etaS.Assigned_Resource_ID__c);
            }
        }
        
        List<Affiliate__c> affList = new List<Affiliate__c>();
        List<Affiliate__c> affiliatesAssociatedList = new List<Affiliate__c>();
        affList = [select id, Parent_Affiliate__r.Id,Parent_Affiliate__r.Name,Name from Affiliate__c where Name in :affiliateNames OR Parent_Affiliate__r.Name in :affiliateNames];
        List<Contact> contacts = new List<Contact>();
        system.debug('@@@@@@@affiliate Names'+affiliateNames);
        contacts = [select id,Affiliate_ID__r.Name,Affiliate_ID__r.Parent_Affiliate__r.Name,Certified_Installer_ID__c,Certificate__c from contact where (Certified_Installer_ID__c in :affiliateNames OR Certificate__c in :affiliateNames)];
        Map<string,string> conCertiaffiliateName = new Map<string,string>();
        
        if(contacts.size() > 0){        
            for(Contact con:contacts){
                    affiliateNamesIncludingAssociatedAff.add(con.Affiliate_ID__r.Name);
                    if(!String.isBlank(con.Certified_Installer_ID__c)){
                    conCertiaffiliateName.put(con.Certified_Installer_ID__c,con.Affiliate_ID__r.Name);
                    } else if(!String.isBlank(con.Certificate__c)){
                    conCertiaffiliateName.put(con.Certificate__c,con.Affiliate_ID__r.Name);
                    }
                    if(con.Affiliate_ID__r.Parent_Affiliate__r.Name  != null){
                        affiliateNamesIncludingAssociatedAff.add(con.Affiliate_ID__r.Parent_Affiliate__r.Name);
                    }
            }
        }
        system.debug('@@@@@@affiliateNamesIncludingAssociatedAff'+affiliateNamesIncludingAssociatedAff);
        if(affList.size() > 0){        
            for(Affiliate__c aff:affList){
                    affiliateNamesIncludingAssociatedAff.add(aff.Name);
                    if(aff.Parent_Affiliate__r.Name != null){
                        affiliateNamesIncludingAssociatedAff.add(aff.Parent_Affiliate__r.Name);
                    }
            }
        }
        affiliatesAssociatedList = [select id, Parent_Affiliate__r.Id,Parent_Affiliate__r.Name,Name,Clone_bucket__c from Affiliate__c where Name in :affiliateNamesIncludingAssociatedAff OR Parent_Affiliate__r.Name in :affiliateNamesIncludingAssociatedAff];
        
        for(affiliate__c aff:affiliatesAssociatedList){
            if(aff.Parent_Affiliate__r.Name != null){
                olidaffiliateClonedbucketAff.put(aff.Name,aff.Parent_Affiliate__r.Name);
            }
        }
        
        Date todayDate = Date.today();
        for(ETA_Staging__c etaS:OFSCRecords){
            if((etaS.ETA_Staging_Status__c == 'Pending' || etaS.ETA_Staging_Status__c == 'Suspended' )&& etaS.Scheduled_Date__c ==  todayDate.addDays(-1)) {
                OFSCPendingRecords.add(etaS);
            } 
        }
            
        for(ETA_Staging__c  a : OFSCPendingRecords){
            if(!String.isBlank(a.Assigned_Resource_ID__c)){
                for(affiliate__c aff:affiliatesAssociatedList){
                    if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == a.Assigned_Resource_ID__c || olidaffiliateClonedbucketAff.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name || olidaffiliateClonedbucketAff.get(conCertiaffiliateName.get(a.Assigned_Resource_ID__c)) == aff.Parent_Affiliate__r.Name || conCertiaffiliateName.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name)  && aff.Clone_bucket__c == true){
                        a.Assigned_Resource_ID__c = aff.Name;
                    }
                }
            }    
            a.Scheduled_Date__c = null; //date.newinstance(3000,01,01);
            OFSCUpdateRecords.add(a);
        }
        if(OFSCUpdateRecords.size()>0) {
            update OFSCUpdateRecords;
       } 
    }

    global void finish(Database.BatchableContext BC){
        
    }
}