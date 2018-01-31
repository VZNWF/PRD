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
// File Name:       ContactTriggerHandler
// Summary:         Trigger Handler class for Contact/Installer Data
// Created On:      April-14-2015

// Modification Log:
====================

// Vasanth    - 4/14/2015 - Create a base version of ContactTriggerHandler class 
// Siteja    - 4/26/2016 - Modified the handler to Create and update Contact as Contact role in Opportunity based on the Opportunity ID and Contact Role
// Siteja    - 6/13/2016 - Added functionality not to execute Insert resource and insert user callouts if the Affiliate ID= label.Affiliate_Name

*******************************************************************************/

public with sharing class ContactTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public string NTSSId = system.label.Affiliate_Name;   
      
    public ContactTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Contact[] newContact)    {     
      // EXECUTE BEFORE INSERT LOGIC
    }
    
    public void OnAfterInsert(Contact[] newContact)    { // After Insert Method Handler - bulkified
       // EXECUTE AFTER INSERT LOGIC
       //Added by Siteja
       set<Id> AffiliateIds = new set<Id>();
       for(Contact con : newContact){
       AffiliateIds.add(con.Affiliate_ID__c);
       }
       map<id,Affiliate__c> mapAffiliateIdRecord = new map<id,Affiliate__c>([select id,name from affiliate__c where Id in :AffiliateIds]);

       list<OpportunityContactRole> oppContactRoles = new list<OpportunityContactRole>();
       for(Contact con : newContact){
          if(con.Callout__c != true  && con.Certificate__c != null && con.Contact_Type__c == 'Installer' && mapAffiliateIdRecord.get(con.Affiliate_ID__c).name != NTSSId){
           ETA_Resource.InsertResourceFromContact(con.Id);
           ETA_Resource.InsertUserFromContact(con.Id);
           //ETA_Resource.InsertWorkZoneFromContact(con.Id);
          } 
          //Added by Siteja
          if(con.Opportunity_ID__c != null && con.Contact_Role__c != null){
            OpportunityContactRole oppConRole = new OpportunityContactRole();
            oppConRole.OpportunityId = con.Opportunity_ID__c;
            oppConRole.role = con.Contact_Role__c;
            oppConRole.ContactId = con.Id;
            oppContactRoles.add(oppConRole);
          } 
       }
       insert oppContactRoles;
    } 

    public void OnBeforeUpdate(Map<Id, Contact> oldContact, Contact[] updatedContact, Map<ID, Contact> ContactMap){
      // EXECUTE BEFORE UPDATE LOGIC  
        for(Contact con : updatedContact){
            if(con.Name != oldContact.get(con.Id).Name || con.Installer_Status__c != oldContact.get(con.Id).Installer_Status__c || con.Affiliate_ID__c != oldContact.get(con.Id).Affiliate_ID__c){
                con.Callout__c = false;
            }
        }        
    }
    
    public void OnAfterUpdate(Contact[] oldContact, Contact[] updatedContact, Map<ID, Contact> oldContactMap, Map<ID, Contact> ContactMap){
       // EXECUTE AFTER UPDATE LOGIC
       set<Id> AffiliateIds = new set<Id>();
       for(Contact con : updatedContact){
       AffiliateIds.add(con.Affiliate_ID__c);
       }
       map<id,Affiliate__c> mapAffiliateIdRecord = new map<id,Affiliate__c>([select id,name from affiliate__c where Id in :AffiliateIds]);
       
       list<OpportunityContactRole> oppContactRoles = new list<OpportunityContactRole>();
       set<Id> opportunityIds = new set<Id>();
       for(Contact con : updatedContact){       
           opportunityIds.add(con.Opportunity_ID__c);
       }
       
       
       list<opportunity> opportunityList = new  list<opportunity>();
       Map<Id,Opportunity> mapOppIdOpportunity = new Map<Id,Opportunity>();
       opportunityList = [select id, (select id,OpportunityId,role from OpportunityContactRoles) from opportunity where Id in :opportunityIds];
       Boolean oppContactRoleAlreadyCreated;
       
       for(opportunity opp: opportunityList){
       mapOppIdOpportunity.put(opp.Id,opp);
       }
       
       for(Contact con : updatedContact){
           oppContactRoleAlreadyCreated = false;
                if(con.Callout__c != true && con.Contact_Type__c == 'Installer' && con.Certificate__c != null){
               
                    if(((oldContactMap.get(con.Id).Certificate__c == null || oldContactMap.get(con.Id).Certificate__c == '') || con.ETA_Insert__c) && mapAffiliateIdRecord.get(con.Affiliate_ID__c).name != NTSSId){
                         ETA_Resource.InsertResourceFromContact(con.Id);
                         ETA_Resource.InsertUserFromContact(con.Id);
                         
                    }else{ 
                        ETA_Resource.UpdateResourceFromContact(con.Id);    
                        ETA_Resource.UpdateUserFromContact(con.Id);
                    }           
            }
            else{
            System.Debug('@@@@@@@@if loop'+updatedContact);
                if(con.ETA_Insert_User__c){
                ETA_Resource.InsertUserFromContact(con.Id);
                }
            }    
            if(con.Opportunity_ID__c != null && con.Contact_Role__c != null && mapOppIdOpportunity.get(con.Opportunity_ID__c) != null){
            
            for(OpportunityContactRole oppCR:mapOppIdOpportunity.get(con.Opportunity_ID__c).OpportunityContactRoles){
                if(oppCR.OpportunityId == con.Opportunity_ID__c && oppCR.role == con.Contact_Role__c){
                oppContactRoleAlreadyCreated = true;
                }
            
            }
            
            if(!oppContactRoleAlreadyCreated){
                OpportunityContactRole oppConRole = new OpportunityContactRole();
                oppConRole.OpportunityId = con.Opportunity_ID__c;
                oppConRole.role = con.Contact_Role__c;
                oppConRole.ContactId = con.Id;
                oppContactRoles.add(oppConRole);
            }
           
        }
        }
        if(oppContactRoles.size() > 0){
        insert oppContactRoles; 
         }
         
         
 
    }

    public void OnBeforeDelete(Affiliate__c[] AffiliatesToDelete, Map<ID, Affiliate__c> affiliateMap){
        // BEFORE DELETE LOGIC
    }

    public void OnAfterDelete(Affiliate__c[] deletedAffiliates, Map<ID, Affiliate__c> affiliateMap){
        // AFTER DELETE LOGIC
    }

    public void OnUndelete(Affiliate__c[] restoredObjects){
        // AFTER UNDELETE LOGIC
    }
  

}