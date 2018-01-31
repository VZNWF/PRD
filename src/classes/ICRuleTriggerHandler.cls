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
// File Name:       ICRuleTriggerHandler
// Summary:         Trigger Handler class for Installation_Coordinator_Assignment_Rule__c Data
// Created On:      July-27-2015

// Modification Log:
====================

// Aravind    - 7/27/2015 - Create a base version of ICRuleTriggerHandler class 

*******************************************************************************/

public with sharing class ICRuleTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
       
      
    public ICRuleTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
       
    public void OnAfterUpdate(Map<Id, Installation_Coordinator_Assignment_Rule__c> oldICRules, Installation_Coordinator_Assignment_Rule__c[] updatedICRules, Map<ID, Installation_Coordinator_Assignment_Rule__c> ICRulesMap){
        
        Set<ID> AccICIds = new Set<ID>();
        Set<ID> OptyICIds = new Set<ID>();
        string optyType = '';
        
        string subType = '';
        string customerNumber = '';        
        string ownerManagerID = '';
        
        
        RecordType OpportunityRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Opportunity_Specific' limit 1];
        RecordType AccountRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Account_Specific' limit 1];
         
        for(Installation_Coordinator_Assignment_Rule__c icRule : updatedICRules){
            if(icRule.RecordTypeId ==  AccountRecType.Id && icRule.Install_Coordinator__c != oldICRules.get(icRule.Id).Install_Coordinator__c && icRule.Install_Coordinator__c != null){
                AccICIds.add(oldICRules.get(icRule.Id).Install_Coordinator__c);
                subType = oldICRules.get(icRule.Id).Account_Sub_Type__c;
                customerNumber = oldICRules.get(icRule.Id).Customer_Number__c;
                ownerManagerID =  oldICRules.get(icRule.Id).Account_Owner_Manager__c;
            }
            
             if(icRule.RecordTypeId ==  OpportunityRecType.Id && icRule.Install_Coordinator__c != oldICRules.get(icRule.Id).Install_Coordinator__c && icRule.Install_Coordinator__c != null){
                 OptyICIds.add(oldICRules.get(icRule.Id).Install_Coordinator__c);
                                  OptyICIds.add(oldICRules.get(icRule.Id).Install_Coordinator__c);
                              optyType = oldICRules.get(icRule.Id).Opportunity_Type__c;
                                  
            }
            system.debug('ICRuleTriggerHandler AccICIds Size ' + AccICIds.Size());
              processAccountsOnUpdate(AccICIds, subType, customerNumber,ownerManagerID);
              processOpportunitiesOnUpdate(OptyICIds, optyType);
        } 
        
    }
    
   
    private void processAccountsOnUpdate(Set<ID> ICIds, string subType, string customerNumber, string ownerManagerID)    { // Method to generate Account List and Update trigger flag
        
      List<Account> accountsToUpdate = new List<Account>();
       
        if(ICIds.Size() > 0)    {
            
            //get Accounts Map 
           // List<Account> listAccountsToUpdate = [select Id, Installation_Coordinator__c,Force_Trigger_Update__c from Account where Installation_Coordinator__c IN :ICIds LIMIT 50000];
            Map<Id, Account> mapAccounts = new Map<Id, Account>();
            if(String.isNotBlank(ownerManagerID) && !String.isNotBlank(customerNumber)) {
                mapAccounts = new Map<Id, Account>([SELECT Id,Owner.Manager.Id,  Installation_Coordinator__c,Force_Trigger_Update__c FROM Account where Sub_Type__c = :subType AND Owner.Manager.Id = :ownerManagerID and Installation_Coordinator__c IN :ICIds LIMIT 50000]); 

            }
            else if (!String.isNotBlank(ownerManagerID) && String.isNotBlank(customerNumber)) {
                mapAccounts = new Map<Id, Account>([SELECT Id,Owner.Manager.Id,  Installation_Coordinator__c,Force_Trigger_Update__c FROM Account where Sub_Type__c = :subType AND AccountNumber = :customerNumber  and Installation_Coordinator__c IN :ICIds LIMIT 50000]); 

            }
            else if (String.isNotBlank(ownerManagerID) && String.isNotBlank(customerNumber)) {
                mapAccounts = new Map<Id, Account>([SELECT Id,Owner.Manager.Id,  Installation_Coordinator__c,Force_Trigger_Update__c FROM Account where Sub_Type__c = :subType AND Owner.Manager.Id = :ownerManagerID AND AccountNumber = :customerNumber  and Installation_Coordinator__c IN :ICIds LIMIT 50000]); 

            }
            else
            {
            
             mapAccounts = new Map<Id, Account>([SELECT Id,Owner.Manager.Id,  Installation_Coordinator__c,Force_Trigger_Update__c FROM Account where Sub_Type__c = :subType AND Installation_Coordinator__c IN :ICIds LIMIT 50000]); 
            
            }
            
            
            
            for(Account tmpAccount: mapAccounts.values()) { 
                System.debug(tmpAccount.Id); 
                tmpAccount.Force_Trigger_Update__c = true;  
                 accountsToUpdate.add(tmpAccount);            
            }
            
            system.debug('ICRuleTriggerHandler accountsToUpdate Size ' + accountsToUpdate.Size());

         //  if(!VZ_UTIL.IsNullOrEmpty(listAccountsToUpdate))    {
             /*    for(Account tmpAccount:listAccountsToUpdate)     { 
                                      
                     tmpAccount.Force_Trigger_Update__c = true;            
                    
                     accountsToUpdate.add(tmpAccount);                   
                } */
                
               if(!VZ_UTIL.IsNullOrEmpty(accountsToUpdate))    {
                     
                     try    { 
                              
                        update accountsToUpdate;
                    } Catch (Exception e)   {           
                        System.Debug(Logginglevel.DEBUG,'ICRuleTriggerHandler.processAccountsOnUpdate - Error while updating Accounts ' + e.getMessage());                         
                        return;
                    }
                }
           // }
        
        }  
    }  
    
     private void processOpportunitiesOnUpdate(Set<ID> ICIds,string optyType )    { // Method to generate Opportunity List and Update trigger flag
        
      List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
       
         if(ICIds.Size() > 0)    {
            
            //get Opportunities Map 
            List<Opportunity> listOpportunitysToUpdate = [select Id, Installation_Coordinator__c,Type, Force_Trigger_Update__c from Opportunity where Type = :optyType AND Installation_Coordinator__c IN :ICIds LIMIT 50000];
            
            if(!VZ_UTIL.IsNullOrEmpty(listOpportunitysToUpdate))    {
                for(Opportunity tmpOpportunity:listOpportunitysToUpdate)     { 
                                      
                     tmpOpportunity.Force_Trigger_Update__c = true;            
                    
                     opportunitiesToUpdate.add(tmpOpportunity);                   
                } 
                
                if(!VZ_UTIL.IsNullOrEmpty(opportunitiesToUpdate))    {
                     
                     try    { 
                              
                        update opportunitiesToUpdate;
                    } Catch (Exception e)   {           
                        System.Debug(Logginglevel.DEBUG,'ICRuleTriggerHandler.processOpportunitysOnUpdate - Error while updating Opportunities ' + e.getMessage());                         
                        return;
                    }
                }
            }
        
        }  
    }  
    
}