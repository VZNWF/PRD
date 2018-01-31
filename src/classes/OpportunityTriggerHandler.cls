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
// File Name:       OpportunityTriggerHandler 
// Summary:         Trigger Handler class for Opportunity Data
// Created On:      May-7-2015

// Modification Log:
====================

// Aravind    - 5/7/2015 - Create a base version of OpportunityTriggerHandler class 
//Siteja    - 4/6/2016 - Modified the handler to update CPQ terms, Quote terms, Contract terms, Addendum terms on opportunity records based on Contract type, GSA Eligible, Acct Subtype from custom settings
//Siteja    - 4/29/2016 -Added code for populating the SOS email and Account Operational Account Manager on Opportunity from Accounts SOS Owner and Operational Account Manager.
//Siteja    - 4/30/2016 - Added code to get the Contact Pricebook in Opportunity from Account.Pricebook__c when Docusign Status is completed for the first time. 
//Siva A    - 1/17/2017 - calcLeadLifecycleAge, init, calHoursToDecimal methods and TaskAgeMetadataWrapper wrapper class were added for Age Calculation purposes.
//Satish     -2/21/2017 - Added code for Order Automation
//Sunil      -4/21/2017 - Added code to fix CPQ Process Builder Production issue.
//Vanditha   -07/07/2017- Added Code(updateParentOpportunity) for checking Pilot Coversion on Parent Opportunity 
//Satish     -07/19/2017 - Added Code for Incorrect part Order
*******************************************************************************/

public with sharing class OpportunityTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapOptyZone1Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    private Map<string, Installation_Coordinator_Assignment_Rule__c> mapOptyZone2Rule = new Map<string, Installation_Coordinator_Assignment_Rule__c>();
    private Map<Id,Account> mapOptyIdAndAccounts = new Map<Id,Account>();
        
    private RecordType OpportunityRecType = new RecordType();
    private List<Installation_Coordinator_Assignment_Rule__c> installationCoordinatorRules = new  List<Installation_Coordinator_Assignment_Rule__c>();
        
        
    //Member variables - Added by Siva - Begin
    private static List<Task_Age_Config__mdt> taskAgeMtdLst;
    private static Map<String, TaskAgeMetadataWrapper> leadSrcConfigMtdMap;
    //Member variables - Added by Siva - End    
    
    public OpportunityTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
        
    public void OnBeforeInsert(Opportunity[] newOpportunitys){
       //Added by Siteja
       updateCPQTerms(newOpportunitys);
       //Added by Siva Adapa - Begin
       resetS2LAgeBeforeInsert(newOpportunitys);
       //Added by Siva Adapa - End
       //OpportunityUpdate(newOpportunitys);
        
         populateMapOptyIdAndAccounts(newOpportunitys);
         if(VZ_UTIL.IsNullOrEmpty(OpportunityRecType.ID))
        {
            populateMapICRules();
        }
         updateInstallationCoordinator(newOpportunitys);           
         populateCPQTier(newOpportunitys); // Added code to fix CPQ Process Builder Production issue - Sunil Kumar
    }
    
    public void OnAfterInsert(Opportunity[] newOpportunitys){
        OpportunityTriggerHandler.updateParentOpportunity(newOpportunitys);
    }
    
   
    
    public void OnBeforeUpdate(Opportunity[] oldOpportunitys, Opportunity[] updatedOpportunitys, Map<ID, Opportunity> OpportunityMap, Map<ID, Opportunity> oldOpportunityMap){
        
        //Added by Siva A for Lead Life Cycle age calculations
        calcLeadLifecycleAge(updatedOpportunitys, OpportunityMap, oldOpportunityMap);
        
        //Added by Siteja
        //OpportunityUpdate(updatedOpportunitys);
        updateCPQTerms(updatedOpportunitys);
        UpdateCPQPricebook(OpportunityMap,oldOpportunityMap); 
        CheckAnCreateOrders(OpportunityMap, oldOpportunityMap);
        
         /* disabling until troubleshoot complete
         try {
        List<Opportunity> OpportunitysToUpdate = new List<Opportunity>();
        
        for (Opportunity opp: updatedOpportunitys) {
                if(opp.Force_Trigger_Update__c == true) { 
                
                System.debug('DEBUG ON OnBeforeUpdate Force_Trigger_Update__c ');
                              
                    OpportunitysToUpdate.add(opp);      
                }
                else {
                    Opportunity oldOpportunity = oldOpportunityMap.get(opp.Id);                    
                     if(String.isNotBlank(opp.Type) && String.isNotBlank(oldOpportunity.Type) && String.isNotBlank(opp.Opportunity_Owner_Manager_Name__c)) {
                     
                         System.debug('DEBUG ON OnBeforeUpdate after checking for null or blank');
                        if (opp.Type != oldOpportunity.Type || opp.Opportunity_Owner_Manager_Name__c != oldOpportunity.Opportunity_Owner_Manager_Name__c) {
                        
                         System.debug('DEBUG ON OnBeforeUpdate after checking for != condition');
                         
                         OpportunitysToUpdate.add(opp);
                        }
                    
                    }
                }
           
        }
        
        populateMapOptyIdAndAccounts(OpportunitysToUpdate);
        
        
        if(VZ_UTIL.IsNullOrEmpty(OpportunityRecType.ID))
        {
            populateMapICRules();
        }
           
        updateInstallationCoordinator(OpportunitysToUpdate);
        
         } catch(Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                      
        }*/
    }
    
    public void OnAfterUpdate(Opportunity[] oldOpportunitys, Opportunity[] updatedOpportunitys, Map<ID, Opportunity> OpportunityMap){
        
    }
    
    private void populateMapOptyIdAndAccounts(Opportunity[] newOpportunitys){
       
       
        try {
        
            // Now let's get the accountIds
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity op : newOpportunitys){
                accountIds.add(op.AccountId);
            }
    
            // Get the account you want
            Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,Name,Installation_Coordinator__c, PO_Required__c  FROM Account WHERE Id IN :accountIds LIMIT 100]);
    
            // Put them together
            for(Opportunity op : newOpportunitys){
                Id acctId = op.AccountId;
                mapOptyIdAndAccounts.put(op.Id,mapAccounts.get(acctId));
                if(mapAccounts.get(acctId).PO_Required__c){
                    op.PO_Required__c = true;
                }
            }
        }
         catch(Exception e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                        
       }
                    
    }
    
      private void populateMapICRules()    {
      
      
            
                //OpportunityRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Opportunity_Specific' limit 1];
                Id OpportunityRecType = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Opportunity Specific').getRecordTypeId();
                List<Installation_Coordinator_Assignment_Rule__c> installationCoordinatorRules = [SELECT Opportunity_Owner_Manager_Name__c,Opportunity_Zone__c, Opportunity_Type__c,Id,Install_Coordinator__c,RecordTypeId FROM Installation_Coordinator_Assignment_Rule__c WHERE RecordTypeId =: OpportunityRecType];
            
        
              for(Installation_Coordinator_Assignment_Rule__c tmpICRule: installationCoordinatorRules )    {
                
                string Zone1String =  '';
               
                string Zone2String =  '';  
              
    
                Zone1String =  tmpICRule.Opportunity_Type__c.toUpperCase();
                if(!mapOptyZone1Rule.ContainsKey(Zone1String) && tmpICRule.Opportunity_Zone__c == '1')    {
                           
                   mapOptyZone1Rule.put(Zone1String ,tmpICRule);
                  
                }
                
                if(!VZ_UTIL.IsNullOrEmpty(tmpICRule.Opportunity_Owner_Manager_Name__c) && tmpICRule.Opportunity_Zone__c == '2')    {         
                    Zone2String =  tmpICRule.Opportunity_Type__c.toUpperCase() + tmpICRule.Opportunity_Owner_Manager_Name__c.toUpperCase(); 
                    if(!mapOptyZone2Rule.ContainsKey(Zone2String))    {                       
                       mapOptyZone2Rule.put(Zone2String ,tmpICRule);              
                    }                
                } 
                               
            }
      }
      private void updateInstallationCoordinator(Opportunity[] newOpportunitys)    { // Method to populate Installation Coordinator

         for(Opportunity Opportunity : newOpportunitys)    {
              
                string oppZone1String =  '';         
                string oppZone2String =  ''; 
              
                
                if(!VZ_UTIL.IsNullOrEmpty(Opportunity.Type))    {  
                    oppZone1String =  Opportunity.Type.toUpperCase();  
                }
               
                if(!VZ_UTIL.IsNullOrEmpty(Opportunity.Type) && !VZ_UTIL.IsNullOrEmpty(Opportunity.Opportunity_Owner_Manager_Name__c))    {      
                    oppZone2String =  Opportunity.Type.toUpperCase() + Opportunity.Opportunity_Owner_Manager_Name__c.toUpperCase();         
                }
               
    
                    boolean matchFound = false;
                    
                    if(mapOptyZone1Rule.ContainsKey(oppZone1String) && !VZ_UTIL.IsNullOrEmpty(oppZone1String))    {     // SubType only    - Zone1               
                       Opportunity.Installation_Coordinator__c =  mapOptyZone1Rule.get(oppZone1String).Install_Coordinator__c; 
                       matchFound = true;             
                    }
             
                    if(mapOptyZone2Rule.ContainsKey(oppZone2String) && !VZ_UTIL.IsNullOrEmpty(oppZone2String))    {   // SubType + Opportunity Owner Manager - Zone3
                       Opportunity.Installation_Coordinator__c =  mapOptyZone2Rule.get(oppZone2String).Install_Coordinator__c;   
                       matchFound = true;           
                    }
              
                    try {
   

                    if(!matchFound)    {
                        if(mapOptyIdAndAccounts.ContainsKey(Opportunity.Id) && !VZ_UTIL.IsNullOrEmpty(mapOptyIdAndAccounts) )    {                       
                            
                               Opportunity.Installation_Coordinator__c = mapOptyIdAndAccounts.get(Opportunity.Id).Installation_Coordinator__c; // get it from Account and set 
                          
                            
                        }                       
                    }
                    } catch(Exception e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        Opportunity.Installation_Coordinator__c = null;
                    }
                    
                    Opportunity.Force_Trigger_Update__c  = false;
                                                        
            }                    
    }
    
     private void updateOppTermsHelper( Opportunity oppt, Opportunity_CPQ_Mapping__c setting ){
        oppt.CPQ_Account_Type__c   = setting.CPQ_Account_Type__c;
        oppt.CPQ_Template_Title__c = setting.CPQ_Template_Title__c;        
        oppt.Quote_Terms__c        = setting.Quote_Terms__c;
        oppt.Contract_Terms__c     = setting.Contract_Terms__c;
        oppt.Addendum_terms__c     = setting.Addendum_terms__c;  
    }
    
    public void updateCPQTerms(Opportunity[] OpportunitiesList){
        
        Set<Id> accountCPQIds = new Set<Id>();
        Map<Id,Opportunity> MapAccountIdOpportunity = new Map<Id,Opportunity>();
        for (opportunity opp:OpportunitiesList) {     
            accountCPQIds.add(opp.AccountId); 
            //MapAccountIdOpportunity.put(opp.AccountId,opp); 
            if((opp.Shipping_Street2__c != null || opp.Shipping_Street3__c != null) && !opp.Multiple_Address__c){
                opp.Multiple_Address__c = true;
            }
        }
        
        list<Opportunity> opportunitiesToUpdateCPQ = new list<Opportunity>();
        Map<id,Account> accountsMap = new  Map<id,Account>([select id,Operational_Acct_Manager__c, Operational_Acct_Manager__r.email,SOS_Owner__c,SOS_Owner__r.email,name,Contract_Type__c,GSA_Eligible__c,Sub_Type__c,Acct_type__c from account where Id in :accountCPQIds]);
        for(opportunity opp:OpportunitiesList) {
            if(opp.Account_Operational_Account_Manager__c != null){
                opp.SOS_Email__c  = accountsMap.get(opp.AccountId).SOS_Owner__r.email;
                opp.Account_Operational_Account_Manager__c = accountsMap.get(opp.AccountId).Operational_Acct_Manager__r.email;
            }
        }
        Opportunity_CPQ_Mapping__c transferCustomSetting      = Opportunity_CPQ_Mapping__c.getValues('Transfer');
        Opportunity_CPQ_Mapping__c standardCustomSetting      = Opportunity_CPQ_Mapping__c.getValues('STANDARD');
        Opportunity_CPQ_Mapping__c pilotDirectCustomSetting   = Opportunity_CPQ_Mapping__c.getValues('PILOT_DIRECT');
        Opportunity_CPQ_Mapping__c pilotIndirectCustomSetting = Opportunity_CPQ_Mapping__c.getValues('PILOT_INDIRECT');     
        Opportunity_CPQ_Mapping__c NJPACustomSetting    = Opportunity_CPQ_Mapping__c.getValues('NJPA');
        Opportunity_CPQ_Mapping__c NJPA1CustomSetting   = Opportunity_CPQ_Mapping__c.getValues('NJPA1');
        Opportunity_CPQ_Mapping__c NJPA2CustomSetting   = Opportunity_CPQ_Mapping__c.getValues('NJPA2');
        Opportunity_CPQ_Mapping__c NJPA3CustomSetting   = Opportunity_CPQ_Mapping__c.getValues('NJPA3');
        Opportunity_CPQ_Mapping__c STDECustomSetting    = Opportunity_CPQ_Mapping__c.getValues('STDE');         
        Opportunity_CPQ_Mapping__c NYOGSCustomSetting   = Opportunity_CPQ_Mapping__c.getValues('NY-OGS');    
        Opportunity_CPQ_Mapping__c ADDONCustomSetting   = Opportunity_CPQ_Mapping__c.getValues('ADD_ON');   
        Opportunity_CPQ_Mapping__c defaultCustomSetting = Opportunity_CPQ_Mapping__c.getValues('Default'); 
        Opportunity_CPQ_Mapping__c GSACustomSetting     = Opportunity_CPQ_Mapping__c.getValues('GSA'); 
        
        string contractType;
        string gsaEligible;
        string subType;
        string AcctType;
        
        for(opportunity opp:OpportunitiesList){
            if(opp.accountid != null){
                if(accountsMap.get(opp.accountid).Contract_Type__c != null){
                    contractType = accountsMap.get(opp.accountid).Contract_Type__c;
                }
                if(accountsMap.get(opp.accountid).GSA_Eligible__c != null){
                    gsaEligible = accountsMap.get(opp.accountid).GSA_Eligible__c;
                }
                if(accountsMap.get(opp.accountid).Sub_Type__c != null){
                    subType = accountsMap.get(opp.accountid).Sub_Type__c;
                }
                if(accountsMap.get(opp.accountid).Acct_type__c != null){
                    AcctType = accountsMap.get(opp.accountid).Acct_type__c;
                }
                if(opp.Type == transferCustomSetting.Opportunity_Type__c && contractType == transferCustomSetting.Contract_Type__c ){                
                    updateOppTermsHelper(opp,transferCustomSetting);
                } else if (contractType == NYOGSCustomSetting.Contract_Type__c && gsaEligible == NYOGSCustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,NYOGSCustomSetting);
                } else if (contractType == GSACustomSetting.Contract_Type__c   && gsaEligible == GSACustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,GSACustomSetting);               
                } else if (contractType == NJPACustomSetting.Contract_Type__c  && gsaEligible == NJPACustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,NJPACustomSetting);
                } else if (contractType == NJPA1CustomSetting.Contract_Type__c && gsaEligible == NJPA1CustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,NJPA1CustomSetting);
                } else if (contractType == NJPA2CustomSetting.Contract_Type__c && gsaEligible == NJPA2CustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,NJPA2CustomSetting);
                } else if (contractType == NJPA3CustomSetting.Contract_Type__c && gsaEligible == NJPA3CustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,NJPA3CustomSetting);
                } else if (contractType == STDECustomSetting.Contract_Type__c  && gsaEligible == STDECustomSetting.GSA_Eligible__c ){                
                    updateOppTermsHelper(opp,STDECustomSetting);                 
                } else if (opp.Type == pilotDirectCustomSetting.Opportunity_Type__c && 
                           (subType == pilotDirectCustomSetting.Account_Sub_Type__c || 
                            subType == pilotDirectCustomSetting.Account_Sub_Type2__c || 
                            subType == pilotDirectCustomSetting.Account_Sub_Type3__c || 
                            subType == pilotDirectCustomSetting.Account_Sub_Type4__c )){                
                    updateOppTermsHelper(opp,pilotDirectCustomSetting);          
                } else if ( AcctType == ADDONCustomSetting.Acct_Type__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type2__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type3__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type4__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type5__c && 
                            opp.Type != ADDONCustomSetting.Opportunity_Type6__c ){                
                    updateOppTermsHelper(opp,ADDONCustomSetting);          
                } else if (opp.Type == pilotIndirectCustomSetting.Opportunity_Type__c && 
                           (subType == pilotIndirectCustomSetting.Account_Sub_Type__c || 
                            subType == pilotIndirectCustomSetting.Account_Sub_Type2__c || 
                            subType == pilotIndirectCustomSetting.Account_Sub_Type3__c )){                
                    updateOppTermsHelper(opp,pilotIndirectCustomSetting);          
                } else if (opp.Type != standardCustomSetting.Opportunity_Type__c && contractType == standardCustomSetting.Contract_Type__c ){                
                    updateOppTermsHelper(opp,standardCustomSetting);         
                } else {
                    updateOppTermsHelper(opp,defaultCustomSetting);           
                }
            }     
        }
    }
    
        public void UpdateCPQPricebook(Map<ID, Opportunity> newOpportunityMap,Map<ID, Opportunity> oldOpportunitiesMap){
        
        set<Id> oppIdSet = newOpportunityMap.KeySet();
        list<opportunity> opportunityList = [select id,AccountId,Account.Price_Book__c from opportunity where Id in :oppIdSet];
        Map<Id,Id> MapAccountIdPricebookId = new Map<Id,Id>();
        for(opportunity opp:opportunityList){
        MapAccountIdPricebookId.put(opp.AccountId,opp.Account.Price_Book__c);
        }
        
        for(Id oppId:oppIdSet){
            if(newOpportunityMap.get(oppId).DocuSign_Status__c == 'Completed' && oldOpportunitiesMap.get(oppId).DocuSign_Status__c != 'Completed' && oldOpportunitiesMap.get(oppId).Contract_Pricebook_Updated__c == false){
            newOpportunityMap.get(oppId).Contract_Pricebook__c = MapAccountIdPricebookId.get(newOpportunityMap.get(oppId).AccountId);
            newOpportunityMap.get(oppId).Contract_Pricebook_Updated__c = true;
            }
        }
        
        }
        /*Public void OpportunityUpdate(List<opportunity> objoportunity)
        {
        
        if(objoportunity.size()>0)
    {
        
       // Updating oportunity Rerate Required field
       Set<Id> accountId = new set<Id>();
       for(Opportunity obj : objoportunity)
       {
         accountId.add(obj.AccountId);
       }
       if(accountId.size()>0)
       {
           List<account> accountlist = [select id,Account_Bundled_Tier__c,Account_Hardware_Accessory_Tier__c,Account_Service_Tier__c from account where id in:accountId];
            //check account data size
            if(accountlist.size()>0)
            {  
              for(Opportunity obj : objoportunity)
              {  
                 for(account objacc : accountlist)
                 {
                    //opportunity account and account id same
                    if(obj.AccountId == objacc.Id)
                      {                     
                          
                          boolean Issupdate=false;
                          
                          if(string.isnotBlank(objacc.Account_Bundled_Tier__c))
                          {
                               if(objacc.Account_Bundled_Tier__c.startswith('DIR-0') || objacc.Account_Bundled_Tier__c.startswith('B-DIR-0'))
                                {
                                  Issupdate = true;
                                } 
                          }
                          
                          if(string.isnotBlank(objacc.Account_Hardware_Accessory_Tier__c))
                          {
                               if(objacc.Account_Hardware_Accessory_Tier__c.startswith('DIR-0') || objacc.Account_Hardware_Accessory_Tier__c.startswith('B-DIR-0'))
                                {
                                  Issupdate = true;
                                }
                          }
                          
                          if(string.isnotBlank(objacc.Account_Service_Tier__c))
                          {
                                if(objacc.Account_Service_Tier__c.startswith('DIR-0') || objacc.Account_Service_Tier__c.startswith('B-DIR-0'))
                                {
                                  Issupdate = true;
                                } 
                          }
                          
                          if(Issupdate == true)
                          {                          
                            obj.Re_Rate_Required__c = true;                         
                          }
                          else
                          {
                            obj.Re_Rate_Required__c = false;
                          }
                    } 
                 }
              } 
            }   
         }
       
       
      //Update opportunity  Promocode Required field 
       for(Opportunity obj : objoportunity)
       {          
          if(obj.Discount_Code__c == null && obj.Deferred_Billing_Date__c!=null)
          {
            obj.Promo_Code_Needed__c = 'Yes';
          }
          else
          {
            obj.Promo_Code_Needed__c = 'No';
          }
       }
    }
        }*/
          //Code changes by Siva Adapa - Begin
    
        //A method checks if the Opportunity is cloned from existing opportunity records and resets the Age fields, timestamps on the cloned record.
        public static void resetS2LAgeBeforeInsert(List<Opportunity> newOpptyList){
            for(Opportunity o: newOpptyList){
                system.debug('o.isClone():'+o.isClone());
                /*if(o.isClone()){
                    system.debug('In Clone');
                    o.Is_Created_From_Lead__c = false;
                    o.Actual_Sales_Closed_Timestamp__c = null;
                    o.Lead_Created_Date__c = null;
                    o.Market_Qualified_Timestamp__c = null;
                    o.Sales_Accepted_Timestamp__c = null;
                    o.Sales_Qualified_Timestamp__c = null;
                    o.MQL__c = null;
                    o.MQL_in_minutes__c = null;
                    o.SAL__c = null;
                    o.SAL_in_minutes__c = null;
                    o.SQL__c = null;
                    o.SQL_in_minutes__c = null;
                    o.SOL__c = null;
                    o.SOL_in_minutes__c = null;
                    o.SRL__c = null;
                    o.SRL_in_minutes__c = null;
                }*/
                //As the isClone function is displaying false for the standard clone button (why?), changed the logic
                if(o.Is_Created_From_Lead__c = true){
                    o.Is_Created_From_Lead__c = false;
                    o.Actual_Sales_Closed_Timestamp__c = null;
                    o.Lead_Created_Date__c = null;
                    o.Market_Qualified_Timestamp__c = null;
                    o.Sales_Accepted_Timestamp__c = null;
                    o.Sales_Qualified_Timestamp__c = null;
                    o.MQL__c = null;
                    o.MQL_in_minutes__c = null;
                    o.SAL__c = null;
                    o.SAL_in_minutes__c = null;
                    o.SQL__c = null;
                    o.SQL_in_minutes__c = null;
                    o.SOL__c = null;
                    o.SOL_in_minutes__c = null;
                    o.SRL__c = null;
                    o.SRL_in_minutes__c = null;
                }
                
            }
        }
        //Calculates the Lead Life Cycle Ages
        private void calcLeadLifecycleAge(List<Opportunity> newOpportunities, Map<Id, Opportunity> newOpptyMap, Map<Id, Opportunity> oldOpptyMap){
            //Call initialisation method
            init();
            
            for(Opportunity o: newOpportunities){
                TaskAgeMetadataWrapper tmpMtd = new TaskAgeMetadataWrapper();
                if((o.LeadSource!=null && leadSrcConfigMtdMap.containsKey(o.LeadSource))){
                    tmpMtd = leadSrcConfigMtdMap.get(o.LeadSource);
                    Integer workHoursPerDay = tmpMtd.workHoursPerDay;
                    Integer workDaysPerWeek = tmpMtd.workDaysPerWeek;
                    Decimal startTime = tmpMtd.startTime;
                    Decimal endTime = tmpMtd.endTime;
                    if(o.isClosed && !oldOpptyMap.get(o.Id).isClosed){
                        if(o.Sales_Qualified_Timestamp__c !=null && o.Lead_Created_Date__c!=null){
                            o.SRL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(o.Sales_Qualified_Timestamp__c, o.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                            o.SRL__c = VZ_Util.calculateAge(o.Sales_Qualified_Timestamp__c, o.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                            
                            o.SOL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(o.Lead_Created_Date__c, o.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                            o.SOL__c = VZ_Util.calculateAge(o.Lead_Created_Date__c, o.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                            o.Actual_Sales_Closed_Timestamp__c = o.lastModifiedDate;
                        }
                    }else if(!o.isClosed && oldOpptyMap.get(o.Id).isClosed){
                        o.SRL_in_minutes__c = null;
                        o.SRL__c = null;
                        
                        o.SOL_in_minutes__c = null;
                        o.SOL__c = null;
                        o.Actual_Sales_Closed_Timestamp__c = null;
                    }
                }
            }
        }
        
        //////
        //Initialisation Method
        //////
        private static void init(){
            //Query the Task Age Config parameters
            taskAgeMtdLst = new List<Task_Age_Config__mdt>();
            //Map1
            leadSrcConfigMtdMap = new Map<String, TaskAgeMetadataWrapper>();

            //Query the methods
            taskAgeMtdLst=[Select DeveloperName, MasterLabel, IsActive__c, Preliminary_Milestones__c, Final_Milestones__c, Start_Time__c, End_Time__c, Work_Days_per_Week__c, Work_Hours_per_Day__c from Task_Age_Config__mdt where isActive__c=True];

            for(Task_Age_Config__mdt tac: taskAgeMtdLst){
                
                //Populate the Wrapper class
                TaskAgeMetadataWrapper wrapperObj = new TaskAgeMetadataWrapper();
                wrapperObj.LeadSource = tac.MasterLabel;
                wrapperObj.workDaysPerWeek = tac.Work_Days_per_Week__c!=null?Integer.valueOf(tac.Work_Days_per_Week__c):0;
                wrapperObj.workHoursPerDay = tac.Work_Hours_per_Day__c!=null?Integer.valueOf(tac.Work_Hours_per_Day__c):0;
                
                wrapperObj.startTime = tac.Start_Time__c!=null?calHoursToDecimal(tac.Start_Time__c):0;
                wrapperObj.endTime = tac.End_Time__c!=null?calHoursToDecimal(tac.End_Time__c):0;

                //Populate the Map1 - LeadSource and the decoded wrapper class config paratmers as Key, Value
                leadSrcConfigMtdMap.put(tac.MasterLabel, wrapperObj);
                
            }
        }
        
        //////
        ////Method to Convert the custom text hours into the Decimal hours
        //////
        private static Decimal calHoursToDecimal(String input){
            List<String> inputArray = input.split(':');
                
            Integer inHr = inputArray[0].isNumeric()?Integer.valueOf(inputArray[0]):0;
            Decimal inMin = inputArray.size()>1?Decimal.valueOf(inputArray[1]):0;
                
            inHr = (inHr>=0 && inHr<24) ? inHr : 0;
            inMin = (inMin >=0 && inMin<60) ?(inMin/60):(inMin >=60)? 0 : 0;
            Decimal inTime = inHr + inMin.setScale(2, System.RoundingMode.HALF_UP);
            
            return inTime;
        }
        
        //////
        //Wrapper Class of Task_Age_Config__mdt
        //////
        private class TaskAgeMetadataWrapper{
            private String LeadSource;
            private Decimal startTime;
            private Decimal endTime;
            private Integer workDaysPerWeek;
            private Integer workHoursPerDay;
        }
    //Code changes by Siva Adapa - End
    
    //Code Change by Satish - Start
        
        private void CheckAnCreateOrders(Map<Id,Opportunity> newOpptysMap, Map<Id, Opportunity> oldOpptyMap){
          
          List<Orders__c> ordToCreate = new List<Orders__c>();
          Opportunity oldOpp;
          Opportunity newOpp;
          OpportunityOrderMap__mdt[] oppFieldMdt = [Select OpportunityField__c, OrderField__c, MasterLabel, Label, Id From OpportunityOrderMap__mdt];
          String orderRecType = Schema.SObjectType.Orders__c.getRecordTypeInfosByName().get('EO').getRecordTypeId();
          List<OrderLocation__c> ordActLst = new List<OrderLocation__c>();
          boolean createAct = false;
          boolean createOrdProd = false;          
          List<Location__c> locsToCreate = new List<Location__c>();          
          Map<String, List<Location__c>> oppLocMap = new Map<String, List<Location__c>>();
          Map<String, Orders__c> oppOrdMap = new Map<String, Orders__c>();          
          Map<String, List<OpportunityLineItem>> mapOpptyLineItems = new Map<String, List<OpportunityLineItem>>();
          Map<String, List<OpportunityLineItem>> mapOrderLineItems = new Map<String, List<OpportunityLineItem>>();
          List<Order_Product__c> ordProdsToCreate = new List<Order_Product__c>();
          Location__c loc = new Location__c();
          
          Set<String> uniqGarAddress = new Set<String>();
          Map<String, List<CPQ_Opportunity_Products__c>> mapOpptyCPQProds = new Map<String, List<CPQ_Opportunity_Products__c>>();
          Map<String, List<CPQ_Opportunity_Products__c>> mapOrderCPQProds = new Map<String, List<CPQ_Opportunity_Products__c>>();
          String fields = '';
          Set<String> casenumbersSet = new Set<String>();
          Map<String, Case> casNumMap = new Map<String,Case>();
          List<CPQ_Opportunity_Products__c> cpqQuotestoUpdate = new List<CPQ_Opportunity_Products__c>();
          
          for(OpportunityOrderMap__mdt oMdt : oppFieldMdt){
            fields += ','+ oMdt.OpportunityField__c;
          }
          
          Set<Id> oppIds = newOpptysMap.keyset();
          
          for(Opportunity opp : newOpptysMap.values()){
            if(opp.Case_Number__c != null){
                casenumbersSet.add(opp.Case_Number__c);
            }
          }
                    
          if(casenumbersSet.size() > 0){
            for(Case cas : [Select Id, CaseNumber from Case where CaseNumber IN : casenumbersSet]){
                casNumMap.put(cas.CaseNumber, cas);
            }
          }
          
          String sql = 'Select Id, Customer_Number__c, Case_Number__c, AccountId, Type, Multiple_PO__c, CreateOrder__c, Type_of_Sale__c, Multiple_Address__c, Location_Name__c, Shipping_Street2__c, Shipping_Street3__c, Shipping_City2__c, Shipping_City3__c, Shipping_State2__c, Shipping_State3__c, Shipping_ZipCode2__c, Shipping_ZipCode3__c, Shipping_email2__c, Shipping_email3__c, Shipping_phone3__c, Shipping_phone2__c, Opportunity_ID__c'+fields+', (Select Id, Name, Garage_Address1__c From Locations__r), (Select Id, Product2Id, Product2.Name, ProductCode, Name, Quantity, UnitPrice, TotalPrice From OpportunityLineItems), (Select Id, Sale_Type__c, Mismatch_Install__c, BUN_Qty__c, Bundle_Kit_ID__c, Product_Category__c,  Primary__c, Product_Record_Id__r.ProductCode, Product_Record_Id__r.CPQ_PRODUCT_NAME__c, PUR_Qty__c, Product_Record_Id__c, Product_Record_Id__r.Name, PUR_MRC_List__c, CPQ_Product_Inserted__c From CPQ_Quote_Products__r) from Opportunity where Id IN :oppIds';
          
          Case cas;    
          /*if(opp.Case_Number__c != null){
        
            List<Case> casList = [Select id, CaseNumber from Case where CaseNumber =: opp.Case_number__c];
            if(casList.size() > 0){
                cas = casList[0];
            }else{
                return 'The Error : Case Number not found';
            }
          }*/
          
          for(Opportunity opp : Database.query(sql)){
            newOpp = newOpptysMap.get(opp.Id);
            oldOpp = oldOpptyMap.get(opp.Id);
            if(opp.Case_Number__c != null){
                casenumbersSet.add(opp.Case_Number__c);
            }
            if(newopp.CPQ_Products_Loaded__c && newopp.CPQ_Products_Loaded__c != oldOpp.CPQ_Products_Loaded__c ){
             for(CPQ_Opportunity_Products__c cpqL : opp.CPQ_Quote_Products__r){
             cpqL.CPQ_Product_Inserted__c = true;
             cpqQuotestoUpdate.add(cpqL);
             }
             newopp.CPQ_Products_Loaded__c = false;
            }
            
            if(newOpp.CreateOrder__c != oldOpp.CreateOrder__c && newOpp.CreateOrder__c){
          
            Orders__c ord = new Orders__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, RecordTypeId = orderRecType, Order_Types__c = 'STDORD',Order_Status__c = 'New',Shipping_Methods__c = 'GROUND', Ship_To_Installer__c='N',  isEoOrder__c = true,
                                     Ship_Phone__c = opp.Shipping_phone__c, Shipping_Contact__c = opp.Shipping_Contact__c, Promo_Code__c =opp.Discount_Code__c , Opportunity_ID__c = opp.Opportunity_ID__c);
              
              if(opp.Customer_Number__c != null && opp.Customer_Number__c.endswith('s')){
                ord.Order_Types__c = 'BUNDLE';
              }
              if(opp.Case_Number__c != null && casNumMap.get(opp.Case_Number__c) != null){
                ord.Case__c = casNumMap.get(opp.Case_Number__c).Id;
              }
              
                if(oppFieldMdt.size() > 0){
                    for(OpportunityOrderMap__mdt oMdt : oppFieldMdt){
                        ord.put(oMdt.OrderField__c, opp.get(oMdt.OpportunityField__c));
                    }
                }
                if(opp.Additional_Shipping_Address_Line1__c == null){
                    if(opp.Shipping_Street2__c != null){
                        ord.Address_Line_1__c = opp.Shipping_Street2__c;
                    }else if(opp.Shipping_Street3__c != null){
                        ord.Address_Line_1__c = opp.Shipping_Street3__c;
                    }
                }
              ordToCreate.add(ord);
              
              if(opp.CPQ_Quote_Products__r.size() > 0){
                if(opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'BUNDLE'){
                ord.Order_Types__c = 'BUNDLE';
                }if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA' && opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'BUNDLE'){
                ord.Order_Types__c = 'BU-EXCHANG';
                //ord.Case_Id__c = opp.Case_Number__c;
                }
                if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA' && opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'PURCHASE'){
                ord.Order_Types__c = 'RA-EXCHANG';
                ord.Case_Id__c = opp.Case_Number__c;
                //ord.Case__c = cas != null ? cas.Id : null;
                }else if(opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'PURCHASE'){
                    ord.Order_Types__c = 'STDORD';
                }
            }
              
              if(opp.Locations__r.size() > 0){    
        for(Location__c loct : opp.Locations__r){
            uniqGarAddress.add(loct.Garage_Address1__c);
        }
        }
            if(!opp.Multiple_PO__c || !opp.Multiple_Address__c){
                if(opp.Locations__r != null && opp.Locations__r.size() > 0){
                    oppLocMap.put(opp.Id, opp.Locations__r);
                }
                if(opp.Location_Name__c != '' && opp.Location_Name__c != null && !uniqGarAddress.contains(opp.Additional_Shipping_Address_Line1__c)){
                loc = new Location__c(Name = opp.Location_Name__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Additional_Shipping_Address_Line1__c, Garage_Zip__c= opp.Shipping_Zip_Code__c != null ? opp.Shipping_Zip_Code__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City__c, Garage_State__c= opp.Shipping_State__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone__c, Email__c = opp.Shipping_email__c);
                locsToCreate.add(loc);
                }else{
                    if(opp.Additional_Shipping_Address_Line1__c != null && opp.Additional_Shipping_Address_Line1__c != ''  && !uniqGarAddress.contains(opp.Additional_Shipping_Address_Line1__c)){
                    loc = new Location__c(Name = opp.Additional_Shipping_Address_Line1__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Additional_Shipping_Address_Line1__c, Garage_Zip__c= opp.Shipping_Zip_Code__c != null ? opp.Shipping_Zip_Code__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City__c, Garage_State__c= opp.Shipping_State__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone__c, Email__c = opp.Shipping_email__c);
                    locsToCreate.add(loc);
                    }
                    if(opp.Shipping_Street2__c != null && opp.Shipping_Street2__c != ''  && !uniqGarAddress.contains(opp.Shipping_Street2__c)){
                    loc = new Location__c(Name = opp.Shipping_Street2__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Shipping_Street2__c, Garage_Zip__c= opp.Shipping_ZipCode2__c != null ? opp.Shipping_ZipCode2__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City2__c, Garage_State__c= opp.Shipping_State2__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone2__c, Email__c =opp.Shipping_email2__c);
                    locsToCreate.add(loc);
                    }
                    if(opp.Shipping_Street3__c != null && opp.Shipping_Street3__c != ''  && !uniqGarAddress.contains(opp.Shipping_Street3__c)){
                    loc = new Location__c(Name = opp.Shipping_Street3__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Shipping_Street3__c, Garage_Zip__c= opp.Shipping_ZipCode3__c != null ? opp.Shipping_ZipCode3__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City3__c, Garage_State__c= opp.Shipping_State3__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone3__c, Email__c =opp.Shipping_email3__c);
                    locsToCreate.add(loc);  
                    }
                }
                
                if(opp.OpportunityLineItems.size() > 0 && !opp.Multiple_Address__c && opp.Locations__r.size() <= 1){
                    mapOpptyLineItems.put(opp.Id, opp.OpportunityLineItems);
                }
                if(opp.CPQ_Quote_Products__r.size() > 0 && !opp.Multiple_Address__c && opp.Locations__r.size() <= 1){
                mapOpptyCPQProds.put(opp.Id, opp.CPQ_Quote_Products__r);
            }
            
                
            }
            
            }
          }
          
          System.debug('ord::'+ordToCreate);
          
          if(ordToCreate.size() > 0){
            try{
                insert ordToCreate;
                }catch(Exception ex){        
            
            
                String err;
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                    err = ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').substringbefore('[]');
                }else{
                    err = ex.getMessage();
                }
                Trigger.new[0].addError(err);
             }
            
            
            for(Orders__c ord : ordToCreate){
                oppOrdMap.put(ord.Opportunity__c, ord);               
               
            }
          }
          
          System.debug('locsToCreate::'+locsToCreate);
          if(locsToCreate.size() > 0){
            Database.SaveResult[] srLst = Database.insert(locsToCreate, true);
            
            if(srLst.size() > 0){                
              oppLocMap.put(loc.OpportunityId__c, locsToCreate);               
            }
          }
          
          
          for(Opportunity opp : newOpptysMap.values()){
            oldOpp = oldOpptyMap.get(opp.Id);
            if(opp.CreateOrder__c != oldOpp.CreateOrder__c && opp.CreateOrder__c){
                opp.Order_Status__c = 'New';
                opp.Order_Owner__c = Userinfo.getName();
                
                if(!opp.Multiple_Address__c){
                createAct = true;
                createOrdProd = true;
                }
                if(!opp.Multiple_PO__c){
                createAct = true;
                }
                
                if(createAct && oppOrdMap.size() > 0 && oppOrdMap.get(opp.Id) != null && oppLocMap.size() > 0 && oppLocMap.get(opp.Id) != null){
                    for(Location__c lo : oppLocMap.get(opp.Id)){
                          ordActLst.add(new OrderLocation__c(PO_Number__c = (opp.Case_Number__c != null && opp.Type == 'Exchange/RA') ? 'RA'+opp.Case_Number__c : opp.PO_Number__c, Orders__c = oppOrdMap.get(opp.Id).Id, Location__c = lo.Id, Ship_To_Installer__c = 'N'));
                    }
                    if(createOrdProd && mapOpptyLineItems.get(opp.Id) != null){
                        mapOrderLineItems.put(oppOrdMap.get(opp.Id).Id, mapOpptyLineItems.get(opp.Id));
                    } 
                    if(createOrdProd && mapOpptyCPQProds.get(opp.Id) != null){
                mapOrderCPQProds.put(oppOrdMap.get(opp.Id).Id, mapOpptyCPQProds.get(opp.Id));
            }                  
                }
            }            
            
          }
          
          if(cpqQuotestoUpdate.size() > 0){
              Database.update(cpqQuotestoUpdate, false);
          }          
          if(ordActLst.size() > 0){
           Database.saveResult[] savRes = Database.insert(ordActLst, false);
           
            if(savRes.size() > 0){
                for(OrderLocation__c ordL : ordActLst){
                    if(mapOrderLineItems.get(ordL.Orders__c) != null){
                        List<OpportunityLineItem> olitems = mapOrderLineItems.get(ordL.Orders__c);
                        for(OpportunityLineItem oli :olitems){
                            ordProdsToCreate.add(new Order_Product__c(Location__c = ordL.Location__c, Order_Details__c = ordL.Orders__c, OrderLocationMappings__c = ordL.Id, Order_Products__c = oli.Product2Id, Product_Code__c = oli.ProductCode, Product_Name__c = oli.Product2.Name, Quantity__c = oli.Quantity, Sales_Price__c = oli.UnitPrice));
                        }
                    }
                    if(mapOrderCPQProds.get(ordL.Orders__c) != null){
                    List<CPQ_Opportunity_Products__c> cpqlitems = mapOrderCPQProds.get(ordL.Orders__c);
                    for(CPQ_Opportunity_Products__c cpqli :cpqlitems){
                        if(cpqLi.Sale_Type__c == 'PURCHASE' && cpqLi.Product_Category__c != 'SERVICE' && cpqLi.Product_Category__c != 'SOLUTION' && cpqLi.Primary__c == true){
                        ordProdsToCreate.add(new Order_Product__c(Location__c = ordL.Location__c, Order_Details__c = ordL.Orders__c, OrderLocationMappings__c = ordL.Id, Order_Products__c = cpqli.Product_Record_Id__c, Product_Code__c = cpqli.Product_Record_Id__r.ProductCode ,Product_Name__c = (cpqli.Product_Record_Id__r.Name != null && cpqli.Product_Record_Id__r.Name.contains('*CPQ ONLY* DO NOT USE -')) ? cpqli.Product_Record_Id__r.Name.substring(24): cpqli.Product_Record_Id__r.Name, Quantity__c = cpqli.Pur_Qty__c, Sales_Price__c = cpqli.PUR_MRC_List__c));
                        }
                        else if( cpqLi.Sale_Type__c == 'BUNDLE' && cpqLi.Bundle_Kit_ID__c != null && cpqLi.Primary__c == true && cpqli.Mismatch_Install__c == false){
                            ordProdsToCreate.add(new Order_Product__c(Location__c = ordL.Location__c, Order_Details__c = ordL.Orders__c, OrderLocationMappings__c = ordL.Id, Order_Products__c = cpqli.Product_Record_Id__c, Product_Name__c = cpqli.Bundle_Kit_ID__c, Product_Code__c = cpqli.Bundle_Kit_ID__c, Quantity__c = cpqli.BUN_Qty__c, Sales_Price__c = cpqli.PUR_MRC_List__c));
                        }
                    }
                }
                }
            }
            if(ordProdsToCreate.size() > 0){
                Database.insert(ordProdsToCreate, true);
            }
            
          }
         
        }
    //Code Change by Satish - End 
    // Added code to fix CPQ Process Builder Production issue - Sunil Kumar  
    private void populateCPQTier(Opportunity[] newOpportunitys){ 
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity op : newOpportunitys){
            accountIds.add(op.AccountId);
        }
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,CPQ_PRICE_TIER__c FROM Account WHERE Id IN :accountIds ]);
        for(Opportunity opp : newOpportunitys){
            if(opp.type == 'Re-Rate No Products'){
                opp.Re_Rate_Tier__c = mapAccounts.get(opp.AccountId).CPQ_PRICE_TIER__c;
            }
        }
    }
    // End of code to fix CPQ Process Builder Production issue
    
    //Pilot conversion method
    public static void updateParentOpportunity(List<Opportunity> lstOpportunity){
        Set<Id> setOpptIds = new Set<Id>();
             
        List<Opportunity> lstUpdateOpportunity = new List<Opportunity>();
        Id rtOpportunity =Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Pilot Opportunity').getRecordTypeId();
        for(Opportunity objOpp: lstOpportunity){
            if(objOpp.recordtypeid==rtOpportunity && objOpp.Parent_Opportunity__c != null){
                setOpptIds.add(objOpp.Parent_Opportunity__c);
            }           
        }
        if(setOpptIds.size() >0){
            List<Opportunity> lstOppty =[Select Id, Parent_Opportunity__c from Opportunity where Parent_Opportunity__c in:setOpptIds and recordtypeid =:rtOpportunity ];
            Set<Id> setParentOpps= new Set<Id>();
            if(lstOppty.size() >0){
                for(Opportunity objOpp: lstOppty){
                    if(!setParentOpps.contains(objOpp.Parent_Opportunity__c)){
                        setParentOpps.add(objOpp.Parent_Opportunity__c);
                        lstUpdateOpportunity.add( new Opportunity(Id = objOpp.Parent_Opportunity__c, Pilot_Conversion__c = true));
                    }
                }
                if(lstUpdateOpportunity.size()>0){
                    update lstUpdateOpportunity;
                }
            }
        }
    }
}