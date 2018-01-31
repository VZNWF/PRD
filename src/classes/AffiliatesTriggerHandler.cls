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
// File Name:       AffiliatesTriggerHandler
// Summary:         Trigger Handler class for Affiliate Data
// Created On:      April-3-2015

// Modification Log:
====================

// Aravind    - 4/3/2015 - Create a base version of AffiliatesTriggerHandler class 

*******************************************************************************/

public with sharing class AffiliatesTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
       
      
    public AffiliatesTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Affiliate__c[] newAffiliates)    {     
      // EXECUTE BEFORE INSERT LOGIC
    }
    
    public void OnAfterInsert(Affiliate__c[] newAffiliates)    { // After Insert Method Handler - bulkified
       // EXECUTE AFTER INSERT LOGIC
       for(Affiliate__c aff : newAffiliates){
           if(aff.Callout__c != true){
            ETA_Resource.InsertResourceFromAffiliate(aff.Id);
            ETA_Resource.InsertRejectedBucketForAffiliate(aff.Id);
          }  
       }
    } 

    public void OnBeforeUpdate(Map<Id, Affiliate__c> oldAffiliates, Affiliate__c[] updatedAffiliates, Map<ID, Affiliate__c> affiliateMap){
        
        for(Affiliate__c aff : updatedAffiliates){
            if(aff.Name != oldAffiliates.get(aff.Id).Name || aff.Affiliate_Status__c != oldAffiliates.get(aff.Id).Affiliate_Status__c || aff.Parent_Affiliate__c != oldAffiliates.get(aff.Id).Parent_Affiliate__c){
                aff.Callout__c = false;
            }
        } 
        
    }
    
    public void OnAfterUpdate(Affiliate__c[] oldAffiliates, Affiliate__c[] updatedAffiliates, Map<ID, Affiliate__c> oldAffiliateMap, Map<ID, Affiliate__c> affiliateMap){
       processAffiliatesOnStatusUpdate(updatedAffiliates,oldAffiliateMap); //pass UpdatedList and OldMap
       
            for(Affiliate__c aff : updatedAffiliates){
                if(aff.Callout__c != true){
                    if(aff.ETA_Insert__c){
                         ETA_Resource.InsertResourceFromAffiliate(aff.Id);
                        
                    }else{
                    System.debug('Callout::'+aff.Id);   
                    ETA_Resource.UpdateResourceFromAffiliate(aff.Id);
                    
                }
               }
            else{
                if(aff.CreateRejectedBucket__c){
                   ETA_Resource.InsertRejectedBucketForAffiliate(aff.Id);
                }
            
            }
        }
    }
/*
    public void OnBeforeDelete(Affiliate__c[] AffiliatesToDelete, Map<ID, Affiliate__c> affiliateMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Affiliate__c[] deletedAffiliates, Map<ID, Affiliate__c> affiliateMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Affiliate__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
*/  
    private void processAffiliatesOnStatusUpdate(Affiliate__c[] updatedAffiliates, Map<ID, Affiliate__c> oldAffiliateMap)    { // Method to generate Contact and Order Map data
           
      Map<ID, Affiliate__c> mapUpdatedAffiliates = new Map<ID, Affiliate__c>();
      List<Contact> contactsToUpdate = new List<Contact>();
        for(Affiliate__c a:updatedAffiliates)   {    
             
            Affiliate__c oldAffiliate = oldAffiliateMap.get(a.Id);
            
            if(oldAffiliate!=null && a.Affiliate_Status__c!=oldAffiliate.Affiliate_Status__c && (a.Affiliate_Status__c == 'Suspended' || a.Affiliate_Status__c == 'Terminated' || a.Affiliate_Status__c == 'Inactive'  ) )
            {
                mapUpdatedAffiliates.put(a.Id, a);
            } 
        
        } 
       
        if(!VZ_UTIL.IsNullOrEmpty(mapUpdatedAffiliates))    {
            
            //get Contacts Map 
            List<Contact> listContactsToUpdate = [select Id, FirstName, LastName, Email,Affiliate_ID__c from Contact where Affiliate_ID__c IN :mapUpdatedAffiliates.KeySet()];
            
            if(!VZ_UTIL.IsNullOrEmpty(listContactsToUpdate))    {
                for(Contact tmpContact:listContactsToUpdate)     { 
                   
                    Affiliate__c affiliateRecord =  mapUpdatedAffiliates.get(tmpContact.Affiliate_ID__c);
                     tmpContact.Installer_Status__c = affiliateRecord.Affiliate_Status__c;            
                     tmpContact.Installer_Status_Reason__c = affiliateRecord.Affiliate_Status_Reason__c;    
                     contactsToUpdate.add(tmpContact);                   
                } 
                
                if(!VZ_UTIL.IsNullOrEmpty(contactsToUpdate))    {
                     
                     try    { 
                       // WerbserviceCallout.isAffiliateCalloutMade = true;            
                        update contactsToUpdate;
                    } Catch (Exception e)   {           
                        System.Debug(Logginglevel.DEBUG,'AffiliatesHelper.processAffiliatesOnStatusUpdate - Error while updating Contacts ' + e.getMessage());                         
                        return;
                    }
                }
            }
        
        }  
    }  
}