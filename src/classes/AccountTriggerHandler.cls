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
// File Name:       AccountTriggerHandler 
// Summary:         Trigger Handler class for Account Data
// Created On:      May-7-2015

// Modification Log:
====================

// Aravind    - 5/7/2015 - Create a base version of AccountTriggerHandler class 
//Satish    - 02/06/2017 - Added code to make PO required for FEDRAL GOVT Account.
//Jaya      -05/17/2017 - Update Parent Account CPQ Pricing Model value to Child Account.
*******************************************************************************/

public with sharing class AccountTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapAccountZone1Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapAccountZone2Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapAccountZone3Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapAccountZone4Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    

    public AccountTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
        
    public void OnBeforeInsert(Account[] newAccounts){
        Set<Id> acctIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
         updateInstallationCoordinator(newAccounts); 
         
         for(Account acc : newAccounts){
            if(acc.Sub_Type__c == 'FEDGOVT'){
                acc.PO_Required__c = true;
            }
         }         
             
    }
    
    //Added 18th May :Offshore
    
    public void OnAfterInsert(Account[] newAccounts){
         System.Debug('Method Called');
           List<Account> accPBList=[Select Id,ParentId,Parent.CPQ_PRICING_MODEL__c,CPQ_PRICING_MODEL__c,Parent.Price_Book__c,Price_Book__c  from Account where Id In:newAccounts];
          //Start
          List<Account> accToUpdate=new List<Account>();
          if(accPBList.size()>0){
              for(Account a:accPBList){
               if(a.ParentId!=null ){
                    System.Debug('Inside loop:'+a.Parent.CPQ_PRICING_MODEL__c +'Id :'+a.ParentId+'Before Value:'+a.CPQ_PRICING_MODEL__c);
                    a.CPQ_PRICING_MODEL__c =a.Parent.CPQ_PRICING_MODEL__c;
                    accToUpdate.add(a);
                }
             }
             update accToUpdate;
         }  
            
     }
     //End
      
    /*
    public void OnAfterInsert(Account[] newAccounts){
        
        Map<String, PricebookSetup__c> prcbookMap = PricebookSetup__c.getAll();
        PricebookSetup__c prcBook;
        
        for(Account acc : newAccounts){
         // Populate the Pricebook from Pricebook Set up Custom Setting 
            if(acc.Contract_Type__c != null && acc.CPQ_PRICING_MODEL__c != null && acc.GSA_Eligible__c == 'Eligible'){
                if(prcbookMap.get(acc.Contract_Type__c +'-'+ acc.CPQ_PRICING_MODEL__c) != null){
                    prcBook = prcbookMap.get(acc.Contract_Type__c +'-'+ acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
                }else{
                    prcBook =  prcbookMap.get('Default' +'-' + acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
                }               
            }
            else{
                    prcBook =  prcbookMap.get('Default' +'-' + acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
            } 
        }
    }
    */
   
    
    public void OnBeforeUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> accountMap, Map<ID, Account> oldAccountMap){
        
        List<Account> accountsToUpdate = new List<Account>();
        Map<String, PricebookSetup__c> prcbookMap = PricebookSetup__c.getAll();
        PricebookSetup__c prcBook;
        Set<Id> acctIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        
        for (Account acc: updatedAccounts) {
             Account oldAccount = oldAccountMap.get(acc.Id);
                if(acc.Force_Trigger_Update__c) {               
                    accountsToUpdate.add(acc);      
                }
                else {
                   
                    if (acc.Sub_Type__c != oldAccount.Sub_Type__c || acc.Account_Owner_Manager_Name__c != oldAccount.Account_Owner_Manager_Name__c || acc.AccountNumber != oldAccount.AccountNumber) {
                        accountsToUpdate.add(acc);
                    }
                }
           
           // Populate the Pricebook from Pricebook Set up Custom Setting     
           if(acc.Contract_Type__c != null && acc.CPQ_PRICING_MODEL__c != null && acc.GSA_Eligible__c == 'Eligible'){
                if(prcbookMap.get(acc.Contract_Type__c +'-'+ acc.CPQ_PRICING_MODEL__c) != null){
                    prcBook = prcbookMap.get(acc.Contract_Type__c +'-'+ acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
                }else{
                    prcBook =  prcbookMap.get('Default' +'-' + acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
                }               
            }
            else{
                    prcBook =  prcbookMap.get('Default' +'-' + acc.CPQ_PRICING_MODEL__c);
                    acc.Price_Book__c = prcBook != null ? prcBook.Pricebook_Id__c : null;
            } 
            
            if(acc.Sub_Type__c != oldAccount.Sub_Type__c && acc.Sub_Type__c == 'FEDGOVT'){
                acc.PO_Required__c = true;
                acctIds.add(acc.Id);
            }
           
        }
        updateInstallationCoordinator(accountsToUpdate);
        if(acctIds.size() > 0){
            for(Opportunity opp : [Select Id, PO_Required__c from Opportunity where AccountId IN : acctIds]){
                opp.PO_Required__c = true;
                oppsToUpdate.add(opp);
            }
            
            if(oppsToUpdate.size() > 0){
                Database.update(oppsToUpdate, false);
            }
        }
    }
    
    public void OnAfterUpdate(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> accountMap){
        
    }
    
   
      private void populateMapICRules()    {
      
           // RecordType AccountRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Account_Specific' limit 1];
            Id AccountRecType = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Specific').getRecordTypeId();
            List<Installation_Coordinator_Assignment_Rule__c> installationCoordinatorRules = [SELECT Account_Owner_Manager_Name__c,Account_Sub_Type__c,Account_Zone__c,Customer_Number__c,Id,Install_Coordinator__c,RecordTypeId FROM Installation_Coordinator_Assignment_Rule__c WHERE RecordTypeId =: AccountRecType];
        
        
              for(Installation_Coordinator_Assignment_Rule__c tmpICRule: installationCoordinatorRules )    {
                
                string Zone1String =  '';
               
                string Zone2String =  '';  
                string Zone3String =  '';         
                string Zone4String =  '';  
    
                 if(String.isNotBlank(tmpICRule.Account_Sub_Type__c)) {
                Zone1String =  tmpICRule.Account_Sub_Type__c.toUpperCase();
                }
                else
                {Zone1String =  '';}
                if(!mapAccountZone1Rule.ContainsKey(Zone1String) && tmpICRule.Account_Zone__c == '1')    {
                           
                   mapAccountZone1Rule.put(Zone1String ,tmpICRule);
                  
                }
                
                if(!VZ_UTIL.IsNullOrEmpty(tmpICRule.Customer_Number__c) && tmpICRule.Account_Zone__c == '2')    {         
                    Zone2String =  tmpICRule.Account_Sub_Type__c.toUpperCase() + tmpICRule.Customer_Number__c.toUpperCase() ; 
                     if(!mapAccountZone2Rule.ContainsKey(Zone2String))    {                       
                       mapAccountZone2Rule.put(Zone2String ,tmpICRule);              
                     } 
                }
                
                if(!VZ_UTIL.IsNullOrEmpty(tmpICRule.Account_Owner_Manager_Name__c) && tmpICRule.Account_Zone__c == '3')    {         
                    Zone3String =  tmpICRule.Account_Sub_Type__c.toUpperCase() + tmpICRule.Account_Owner_Manager_Name__c.toUpperCase(); 
                    if(!mapAccountZone3Rule.ContainsKey(Zone3String))    {                       
                       mapAccountZone3Rule.put(Zone3String ,tmpICRule);              
                    }                
                } 
                if(!VZ_UTIL.IsNullOrEmpty(tmpICRule.Account_Owner_Manager_Name__c) && !VZ_UTIL.IsNullOrEmpty(tmpICRule.Customer_Number__c) && tmpICRule.Account_Zone__c == '4')    {          
                    Zone4String =  tmpICRule.Account_Sub_Type__c.toUpperCase() + tmpICRule.Customer_Number__c.toUpperCase() + tmpICRule.Account_Owner_Manager_Name__c.toUpperCase(); 
                    if(!mapAccountZone4Rule.ContainsKey(Zone4String))    {                       
                       mapAccountZone4Rule.put(Zone4String ,tmpICRule);              
                    } 
                }
                               
            }
      }
      private void updateInstallationCoordinator(Account[] newAccounts)    { // Method to populate Installation Coordinator
      
        populateMapICRules();
        
         for(Account account : newAccounts)    {
              
                string accZone1String =  '';         
                string accZone2String =  ''; 
                string accZone3String =  ''; 
                string accZone4String =  ''; 
                
                if(!VZ_UTIL.IsNullOrEmpty(account.Sub_Type__c))    {  
                    accZone1String =  account.Sub_Type__c.toUpperCase();  
                }
                if(!VZ_UTIL.IsNullOrEmpty(account.Sub_Type__c) && !VZ_UTIL.IsNullOrEmpty(account.AccountNumber))    {          
                    accZone2String =  account.Sub_Type__c.toUpperCase() + account.AccountNumber.toUpperCase() ;  
                }
                if(!VZ_UTIL.IsNullOrEmpty(account.Sub_Type__c) && !VZ_UTIL.IsNullOrEmpty(account.Account_Owner_Manager_Name__c))    {      
                    accZone3String =  account.Sub_Type__c.toUpperCase() + account.Account_Owner_Manager_Name__c.toUpperCase();         
                }
                if(!VZ_UTIL.IsNullOrEmpty(account.Sub_Type__c) && !VZ_UTIL.IsNullOrEmpty(account.Account_Owner_Manager_Name__c) && !VZ_UTIL.IsNullOrEmpty(account.AccountNumber))    {          
                    accZone4String =  account.Sub_Type__c.toUpperCase() + account.AccountNumber.toUpperCase() + account.Account_Owner_Manager_Name__c.toUpperCase();  
                }
    
                    boolean matchFound = false;
                    
                    if(mapAccountZone1Rule.ContainsKey(accZone1String) && !VZ_UTIL.IsNullOrEmpty(accZone1String))    {     // SubType only    - Zone1               
                       account.Installation_Coordinator__c =  mapAccountZone1Rule.get(accZone1String).Install_Coordinator__c; 
                       matchFound = true;             
                    }
                    if(mapAccountZone2Rule.ContainsKey(accZone2String)  && !VZ_UTIL.IsNullOrEmpty(accZone2String))    {  // SubType + Customer Number - Zone2
                       account.Installation_Coordinator__c =  mapAccountZone2Rule.get(accZone2String).Install_Coordinator__c; 
                       matchFound = true;             
                    }
                    if(mapAccountZone3Rule.ContainsKey(accZone3String) && !VZ_UTIL.IsNullOrEmpty(accZone3String))    {   // SubType + Account Owner Manager - Zone3
                       account.Installation_Coordinator__c =  mapAccountZone3Rule.get(accZone3String).Install_Coordinator__c;   
                       matchFound = true;           
                    }
                    if(mapAccountZone4Rule.ContainsKey(accZone4String) && !VZ_UTIL.IsNullOrEmpty(accZone4String))    {    // SubType + Customer Number + Account Owner Manager  - Zone4                 
                       account.Installation_Coordinator__c =  mapAccountZone4Rule.get(accZone4String).Install_Coordinator__c;   
                       matchFound = true;                                  
                    }
                    if(!matchFound)    {
                     account.Installation_Coordinator__c = null;
                    }
                    
                    account.Force_Trigger_Update__c = false;
                                                        
            }                    
    }
}