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
// File Name:       AttachmentTriggerHandler
// Summary:         Trigger Handler class for Affiliate Data
// Created On:      April-3-2015

// Modification Log:
====================

// Vasanth    - 4/3/2015 - Create a base version of AttachmentTriggerHandler class 

*******************************************************************************/

public with sharing class AttachmentTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
       
      
    public AttachmentTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Attachment[] newAttachment)    {     
      // EXECUTE BEFORE INSERT LOGIC
      Map<String, CPQ_Contract_Version__c> mapOppContracts = new Map<String, CPQ_Contract_Version__c>();
      Set<String> oppIdSet = new Set<String>();
      List<CPQ_Contract_Version__c> contractsToInsert = new List<CPQ_Contract_Version__c>();
      List<Attachment> attToInsert = new List<Attachment>();
      List<Attachment> attToDelete = new List<Attachment>();
      
      for(Attachment att : newAttachment){
        String parentId = att.ParentId;
        if(parentId != null && parentId.startswith('006')) {
            oppIdSet.add(parentId);
        }
      }
      if(oppIdSet.size() > 0){
        for(Opportunity opp : [Select Id, Name, (Select Id from CPQ_Contract_Versions__r), (Select Id, ParentId From Attachments) from Opportunity where Id IN: oppIdSet]){
            if(opp.Attachments.size() > 0){
            if(opp.CPQ_Contract_Versions__r != null && opp.CPQ_Contract_Versions__r.size() > 0){
                mapOppContracts.put(opp.Id, opp.CPQ_Contract_Versions__r[0]);
            }else{
                contractsToInsert.add(new CPQ_Contract_Version__c(Opportunity__c = opp.Id, Name__c = opp.Name));
            }
            }
        }
        
        if(contractsToInsert.size() > 0){
            Database.insert(contractsToInsert, false);
            for(CPQ_Contract_Version__c con : contractsToInsert){
                mapOppContracts.put(con.Opportunity__c, con);
            }
        }
        
        
        Attachment newAtt;
        for(Attachment att : [Select Id, SystemModstamp, ParentId, OwnerId, Name, 
                                    LastModifiedDate, LastModifiedById, IsPrivate, IsDeleted, 
                                    Description, CreatedDate, CreatedById, 
                                    ContentType, BodyLength, Body 
                              from Attachment where ParentId IN : mapOppContracts.keySet() limit 5000]){
            if(mapOppContracts.containsKey(att.ParentId) && mapOppContracts.get(att.ParentId) != null){
                newAtt = att.clone(false, false);
                newAtt.ParentId = mapOppContracts.get(att.ParentId).Id;              
                attToInsert.add(newAtt);
                
                attToDelete.add(att);
            }
        }
        if(attToInsert.size() > 0){
            Database.insert(attToInsert, false);
        }
        
        try{        
        if(attToDelete.size() > 0){            
        delete attToDelete;            
           }        
        }        
        catch(dmlexception e){        
        throw new dmlexception('Make sure you are the owner of the Opportunity');        
        }    
      }
    }
    
    public void OnAfterInsert(Attachment[] newAttachment)    { // After Insert Method Handler - bulkified
        Set<String> oppIdSet = new Set<String>();
        
        System.debug('@@@@@@@@@@@');
        
        for(Attachment att : newAttachment){
        String parentId = att.ParentId;
        if(parentId != null && parentId.startswith('006')) {
            oppIdSet.add(parentId);
        }
      }
      List<Opportunity> ListOpportunity  = new List<Opportunity>();
      List<Opportunity> UpdatedOpportunity = new List<Opportunity>();
        
        if(oppIdSet.size()>0){      
           ListOpportunity = [Select Id,HasContract__c, GSA_Approved__c From Opportunity WHERE Id IN: oppIdSet];
        }
        if(ListOpportunity.size()>0){
            for(Opportunity opp: ListOpportunity){
                    opp.HasContract__c = True;
                    //opp.GSA_Approved__c = False;                
                UpdatedOpportunity.add(opp);
            }       
        }
        
        Try{        
            if(UpdatedOpportunity.size()>0){
        Update UpdatedOpportunity;
        }      
          }        
        catch(dmlexception e){        
                
        }     
       // EXECUTE AFTER INSERT LOGIC
      
    } 

    public void OnBeforeUpdate (Attachment[] newAttachment) {
    //(Map<Id, Attachment> oldAttachments, Attachment[] updatedAttachments, Map<ID, Attachment> attachmentMap){
        
        
    }
    
    public void OnAfterUpdate (Attachment[] newAttachment) {
    //(Affiliate__c[] oldAffiliates, Affiliate__c[] updatedAffiliates, Map<ID, Affiliate__c> oldAffiliateMap, Map<ID, Affiliate__c> affiliateMap){
      
    }
/*
    public void OnBeforeDelete(Attachment[] AffiliatesToDelete, Map<ID, Affiliate__c> affiliateMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Attachment[] deletedAffiliates, Map<ID, Affiliate__c> affiliateMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Attachment[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
*/

}