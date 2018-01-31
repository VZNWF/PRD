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
// File Name:       OrdersTriggerHandler 
// Summary:         Helper class for Orders Data
// Created On:      March-20-2015

// Modification Log:
====================

// Aravind    - 3/16/2015 - Create a base version of OrdersTriggerHandler class
//Siteja    - 04/14/2016  -  Modified the handler to Populate the Contact Name and Contact Email for Installs Main POC, Fleet Manager Main User, Signatory from Opportunity Contact roles
//Siteja    - 10/28/2016  -  Modified the handler to Populate the Opportunity Owner Email from opportunity associated with the order when the order is created or updated, Update the opportunity owner email from opportunity when opportunity owner is changed only when the vehicle info added from IODS submit. 
//Siteja    - 11/03/2016  -  Update ETA_Staging.Trigger_ETA_Integration__c from 0 to 1 when the orders.Child_Account__c is updated or deleted. 
//Sunil     -02/21/2017  -  code fix to populate correct installer email(Jira Ticket Number -IT-446)
//Satish    - 02/21/2017 -   Added code for Order Automation
//Vanditha  - 07/18/2017 -   Added code for RA UI status
//Vanditha  -09/28/2017  -   Added code for RA UI 
*******************************************************************************/

public with sharing class OrdersTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
   
      
    public OrdersTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Orders__c[] newOrders)    {     
       populateContactFromOpportunityContactRoles(newOrders); 
       updateContactEmailandInstallationCoordinator(newOrders);  
    }
    
     public void OnAfterInsert(Orders__c[] newOrders)    { // After Insert Method Handler - bulkified
       
       Map<Id, Orders__c> oppOrderMap = new Map<Id, Orders__c>();
       List<Opportunity> oppsToUpdate = new List<Opportunity>();
       Map<String, Orders__c> caseRALog = new Map<String,Orders__c>();
       
       for(Orders__c ord : newOrders){
        oppOrderMap.put(ord.Opportunity__c, ord);
        if(ord.Case__c != null){
            caseRALog.put(ord.Case__c, ord);
        }
       } 
       
       for(Opportunity opp : [Select Id, Order_Status__c, Order_Owner__c, (Select Id, isEoOrder__c from Orders__r where Order_Status__c != 'Cancelled' and isEoOrder__c = true) from Opportunity where Id IN : oppOrderMap.keyset()]){
        if(opp.Orders__r.size() > 1){
            newOrders[0].addError('An Opportunity can have ONE active EO order');
        }
        opp.Order_Status__c = oppOrderMap.get(opp.Id).Order_Status__c;
        opp.Order_Owner__c = Userinfo.getName();
        oppsToUpdate.add(opp);
       }
       
       if(oppsToUpdate.size() > 0){
                Database.update(oppsToUpdate, false);
       }
       
       populateRALog(caseRALog);
       
    }
    
    public void OnAfterUpdate(Orders__c[] OldOrders, Orders__c[] newOrders, Map<Id,Orders__c> oldMap, Map<Id,Orders__c> newMap)    { // After Update Method Handler - bulkified
        List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c>();    
        List<ETA_Staging__c> etaStagingUpdateList = new List<ETA_Staging__c>();
        set<Id> orderIds = new set<Id>();
        for(Orders__c ord:newOrders){
            if(oldMap.get(ord.id).Child_Account__c != ord.Child_Account__c ){
                orderIds.add(ord.Id);
            }
            
        }   
        etaStagingList = [select id,Order__c, Trigger_ETA_Integration__c from ETA_Staging__c where Order__c in :orderIds];
        for(ETA_Staging__c eta:etaStagingList){
            eta.Trigger_ETA_Integration__c = 1;
            etaStagingUpdateList.add(eta);
            }
        update etaStagingUpdateList;
    }
    
    
    public void OnBeforeUpdate(Orders__c[] OldOrders, Orders__c[] newOrders, Map<Id,Orders__c> oldMap, Map<Id,Orders__c> newMap)    {
        Set<Id> OppIdSet = new Set<id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<Id, Orders__c> oppOrderMap = new Map<Id, Orders__c>();
         Map<String, Order_Promo_Codes__c> promoCodeMap =  Order_Promo_Codes__c.getAll(); 
        Map<Id, Orders__c> ordStatusMap = new Map<Id, Orders__c>(); 
        List<OrderLocation__c> ordLocLst = new List<OrderLocation__c>();
         
        for(Orders__c newOrder:newOrders){
            if(newOrder.Opportunity__c != null){
                oppOrderMap.put(newOrder.Opportunity__c, newOrder);
            }
             if(newOrder.Opportunity__c != null && newOrder.Submitted_by_IODS__c == true && newOrder.Submitted_by_IODS__c != oldMap.get(newOrder.Id).Submitted_by_IODS__c){
                OppIdSet.add(newOrder.Opportunity__c);    
            } 
            if(newOrder.opportunity__c == null){
                newOrder.Opportunity_Owner_Email__c = null;
            } 
            if(newOrder.Order_Types__c != null && promoCodeMap.get(newOrder.Order_Types__c) != null){
             newOrder.Promo_Code__c = promoCodeMap.get(newOrder.Order_Types__c).Promo_Code__c; 
             newOrder.Shipping_Methods__c = promoCodeMap.get(newOrder.Order_Types__c).Shipping_Method__c; 
            }
            
             if(newOrder.Order_Status__c != oldMap.get(newOrder.Id).Order_Status__c
                && (newOrder.Order_Status__c == 'Submitted' || newOrder.Order_Status__c == 'Account HOLD' || newOrder.Order_Status__c == 'Inventory HOLD' || newOrder.Order_Status__c == 'Cancelled' || newOrder.Order_Status__c == 'CR Hold' || newOrder.Order_Status__c == 'Pending' ||newOrder.Order_Status__c == 'Committed' ||newOrder.Order_Status__c == 'Hold')){
                ordStatusMap.put(newOrder.Id, newOrder);
            }
            
            /*if(newOrder.Order_Types__c != null && newOrder.Order_Types__c.equalsignoreCase('RAORD')){
            newOrder.Promo_Code__c = 'AHYAAN005';
            newOrder.Shipping_Methods__c = 'FREE SHIPPING';
          }
          if(newOrder.Order_Types__c != null && newOrder.Order_Types__c.equalsignoreCase('MIGRATE')){
            newOrder.Promo_Code__c = 'KHYEAN001';
             newOrder.Shipping_Methods__c = 'GROUND';
          }
          if(newOrder.Order_Types__c != null && (newOrder.Order_Types__c.equalsignoreCase('BUNDLE') || newOrder.Order_Types__c.equalsignoreCase('BU-EXCHANG')|| newOrder.Order_Types__c.equalsignoreCase('BU-UPGRADE'))){
            newOrder.Promo_Code__c = 'KHYEAN001';
            newOrder.Shipping_Methods__c = 'GROUND';
          }
          if(newOrder.Order_Types__c != null && newOrder.Order_Types__c.equalsignoreCase('PILOT')){
            newOrder.Promo_Code__c = '';
            newOrder.Shipping_Methods__c = 'FREE SHIPPING';
          }
          if(newOrder.Order_Types__c != null && newOrder.Order_Types__c.equalsignoreCase('RA-WTY-ACC')){
            newOrder.Promo_Code__c = 'AHYAAN002';
           newOrder.Shipping_Methods__c = 'FREE SHIPPING';
          }*/
          
        }
        Map<Id,Opportunity> oppIdEmail = new Map<Id,Opportunity>();
        if(!OppIdSet.isEmpty()){
            for(Opportunity opp:[select id,Owner.Email, Discount_Code__c from Opportunity where Id in :OppIdSet]){
                if(opp.Owner.Email != null){
                    oppIdEmail.put(opp.Id,opp);
                }    
            }
            for(Orders__c newOrder : newOrders)    {
                if(newOrder.opportunity__c != null && oppIdEmail.get(newOrder.opportunity__c) != null 
                && newOrder.Submitted_by_IODS__c == true && newOrder.Submitted_by_IODS__c != oldMap.get(newOrder.Id).Submitted_by_IODS__c){
                    newOrder.Opportunity_Owner_Email__c  = oppIdEmail.get(newOrder.opportunity__c).Owner.Email ; 
                }
                if(newOrder.Order_Types__c != null && newOrder.Order_Types__c.equalsignoreCase('STDORD')){
                  if(oppIdEmail.get(newOrder.opportunity__c).Discount_Code__c != null){  
                     newOrder.Promo_Code__c = oppIdEmail.get(newOrder.opportunity__c).Discount_Code__c; 
                  }
                   
                  }
                
            }
        }
        
        if(oppOrderMap.size() > 0){
            for(Opportunity opp : [Select Id, Order_Status__c, Order_Owner__c, StageName from Opportunity where Id IN : oppOrderMap.keyset()]){
                opp.Order_Status__c = oppOrderMap.get(opp.Id).Order_Status__c;
                opp.Order_Owner__c = Userinfo.getName();
                /*if(opp.Order_Status__c == 'Submitted'){
                    opp.StageName = 'Closed Won';
                }*/
                oppsToUpdate.add(opp);
            }
            
            if(oppsToUpdate.size() > 0){
                Database.update(oppsToUpdate, false);
            }
        }
        
         if(ordStatusMap.size() > 0){
        for(OrderLocation__c ordLoc : [Select Id, Order_Activity_Status__c, Orders__c, EO_OrderID__c  from OrderLocation__c where Orders__c IN : ordStatusMap.keyset()]){
            if((ordLoc.EO_OrderID__c == null && ordLoc.Order_Activity_Status__c == 'Failed') || ordLoc.Order_Activity_Status__c ==null){
            ordLoc.Order_Activity_Status__c = ordStatusMap.get(ordLoc.Orders__c).Order_Status__c;
            ordLocLst.add(ordLoc);
        }
        }
        if(ordLocLst.size() > 0){
            Database.update(ordLocLst, false);
        }
        }
    }
    
     private void populateContactFromOpportunityContactRoles(Orders__c[] newOrders)    { // Method to generate Contact and Order Map data
    
       System.Debug(Logginglevel.DEBUG,'OrdersHelper.populateContactFromOpportunityContactRoles- START');
        System.Debug(Logginglevel.DEBUG,'OrdersHelper.populateContactFromOpportunityContactRoles- Orders__c[] size' + newOrders.Size());
        
        List<Contact> listContacts = new List<Contact>();
        List<Orders__c> listOrdersWithOpportunity = new List<Orders__c>();
        List<Orders__c> listOrdersWithoutOpportunity = new List<Orders__c>();        
        List<Orders__c> listOrdersToUpdate = new List<Orders__c>();
        
        
        Map<string, string> mapOptyAndContactIDS = new Map<string, string>();
        
        Set<ID> setOptys = new Set<ID>();
        Set<ID> setOpptys = new Set<ID>();
        
        for(Orders__c order : newOrders){
            //    if(order.Contact_Email__c == null)
        System.Debug(Logginglevel.DEBUG,'OrdersHelper.populateContactFromOpportunityContactRoles- Orders.Contact__c - ' + order.Opportunity__c);
           if(!VZ_Util.IsNullOrEmpty(order.Opportunity__c))    {            
                listOrdersWithOpportunity.add(order);
                setOptys.add(order.Opportunity__c);
            }
           if(order.Opportunity__c == null){   
            listOrdersWithoutOpportunity.add(order);
            }
            if(order.Opportunity__c != null){
                setOpptys.add(order.Opportunity__c);
            }
        }
        
        list<IODSEmailList__c> ListIODSEmailList = IODSEmailList__c.getall().values();
        map<string,string> IODSNameEmail = new map<string,string>();
        for(IODSEmailList__c IODS:ListIODSEmailList){
        IODSNameEmail.put(IODS.name,IODS.email__c);
        }
        
        for(Orders__c tmporderswithNoOpp:listOrdersWithoutOpportunity){
        if(IODSNameEmail.get(tmporderswithNoOpp.Customer_Number__c) != null){   
        tmporderswithNoOpp.Contact_Email__c = IODSNameEmail.get(tmporderswithNoOpp.Customer_Number__c);
        }
        listOrdersToUpdate.add(tmporderswithNoOpp);        
        }
        
        
        list<opportunity> opportunityList = new list<opportunity>();
        opportunityList = [select id,Owner.Email from Opportunity where Id in :setOpptys];
        Map<Id,string> oppIdEmail = new Map<Id,string>();
        for(opportunity opp:opportunityList){
           if(opp.Owner.Email != null){
                 oppIdEmail.put(opp.Id,opp.Owner.Email);
              }
        }
       
        for(Orders__c order : newOrders)    {
              if(order.opportunity__c != null && oppIdEmail.get(order.opportunity__c) != null){
                  order.Opportunity_Owner_Email__c  = oppIdEmail.get(order.opportunity__c) ; 
              }
        }
            
        List<OpportunityContactRole> opportunityContactRoles = [SELECT ContactId,Id,IsDeleted,IsPrimary,OpportunityId,Role,contact.email FROM OpportunityContactRole WHERE Role in ('Signatory','Install Main POC','Fleet Manager Main User') AND OpportunityId IN :setOptys];
        
        Map<Id,string> ContactIDEmail = new Map<Id,string>();
        
               
         for(OpportunityContactRole tmpOptyContactRole: opportunityContactRoles )    {
                        
            if(tmpOptyContactRole.role == 'Install Main POC' ){            
            if(!mapOptyAndContactIDS.ContainsKey(tmpOptyContactRole.OpportunityId))    {
            
               mapOptyAndContactIDS.put(tmpOptyContactRole.OpportunityId,tmpOptyContactRole.ContactId);
               ContactIDEmail.put(tmpOptyContactRole.ContactId,tmpOptyContactRole.Contact.email);
            }
            }
           
        }
        
        for(OpportunityContactRole tmpOptyContactRole: opportunityContactRoles )    {
                        
            if(tmpOptyContactRole.role == 'Fleet Manager Main User' ){            
            if(!mapOptyAndContactIDS.ContainsKey(tmpOptyContactRole.OpportunityId))    {
            
               mapOptyAndContactIDS.put(tmpOptyContactRole.OpportunityId,tmpOptyContactRole.ContactId);
               ContactIDEmail.put(tmpOptyContactRole.ContactId,tmpOptyContactRole.Contact.email);              
            }
            }
           
        }
        
        for(OpportunityContactRole tmpOptyContactRole: opportunityContactRoles )    {
                        
            if(tmpOptyContactRole.role == 'Signatory' ){            
            if(!mapOptyAndContactIDS.ContainsKey(tmpOptyContactRole.OpportunityId))    {
            
               mapOptyAndContactIDS.put(tmpOptyContactRole.OpportunityId,tmpOptyContactRole.ContactId);
               ContactIDEmail.put(tmpOptyContactRole.ContactId,tmpOptyContactRole.Contact.email);              
            }
        //    }
           
        }
        
         for(Orders__c tmporders: listOrdersWithOpportunity)    {
                        
            if(mapOptyAndContactIDS.ContainsKey(tmporders.Opportunity__c)){               
                tmporders.Contact__c = mapOptyAndContactIDS.get(tmporders.Opportunity__c);   
                tmporders.Contact_Email__c = ContactIDEmail.get(mapOptyAndContactIDS.get(tmporders.Opportunity__c));       
                listOrdersToUpdate.add(tmporders);
            }
            else    {
            
                tmporders.Opportunity__c = null;   
                tmporders.Contact__c = null;                
                listOrdersToUpdate.add(tmporders);
            }
           
        }
        
                
        if(VZ_Util.IsNullOrEmpty(listOrdersToUpdate))    {     
            System.Debug(Logginglevel.DEBUG,'OrdersHelper.populateContactFromOpportunityContactRoles- No Valid Orders with opty info');
            return;   //No Valid Orders with opty info
        }
      }
    }
    
    private void updateContactEmailandInstallationCoordinator(Orders__c[] newOrders)    { // Method to populate Contact Email and Installation Coordinator
      
        List<Contact> listContacts = new List<Contact>();
        List<Account> listAccounts = new List<Account>();
        
        Set<Id> setContacts = new Set<Id>();
        Set<Id> setAccounts = new Set<Id>();
        
        List<Orders__c> listOrdersWithContacts = new List<Orders__c>();  
        List<Orders__c> listOrdersWithAccounts = new List<Orders__c>();      
        List<Orders__c> listOrderstoUpdateContact = new List<Orders__c>();
        List<Orders__c> listOrderstoUpdateInstallation_Coordinator = new List<Orders__c>();
        User icUser = new User();
        
        if(OrderICuser__c.getAll() != null && OrderICuser__c.getAll().values() != null){              
        OrderICuser__c cs = OrderICuser__c.getvalues('Sophia Arroyo');     
             if(cs!=null){
                 IcUser  = [Select Id, Name from User where Name =: cs.name];
             }
         }
        
                 
        for(Orders__c order : newOrders)    { //loop through and populate lists for updating contacts and installation coordinators
                        if(!VZ_Util.IsNullOrEmpty(order.Contact__c))    {                           
                setContacts.add(order.Contact__c);
                listOrdersWithContacts.add(order);
            
            }
                        if(!VZ_Util.IsNullOrEmpty(order.Account__c))    {                           
                setAccounts.add(order.Account__c);
                listOrdersWithAccounts.add(order);
            
            }
        }
        
        listContacts = [SELECT Id,Email FROM Contact WHERE Id IN :setContacts];
        Map<Id, Contact> mapContacts = new Map<Id, Contact>(listContacts);
        
        listAccounts = [SELECT Id,Installation_Coordinator__c, (Select Id, Name, Email from Contacts) FROM Account WHERE Id IN :setAccounts];
        Map<Id, Account > mapAccounts = new Map<Id, Account >(listAccounts );
        
        
        for(Orders__c order : listOrdersWithAccounts )    {
            if(String.isBlank(order.Contact_Email__c)){  // this line of code is added to fix installer email logic
             if(!VZ_Util.IsNullOrEmpty(order.Contact__c))    {                           
                order.Contact_Email__c = mapContacts.Get(order.Contact__c).Email;
                listOrderstoUpdateContact.add(order);
            }
            
            if(VZ_Util.IsNullOrEmpty(order.Contact__c) && !VZ_Util.IsNullOrEmpty(order.Contact_Person__c)){
             System.debug('mapAccounts.get(order.Account__c)::'+mapAccounts.get(order.Account__c));
                if(mapAccounts.get(order.Account__c) != null){
                    for(Contact con : mapAccounts.get(order.Account__c).Contacts){
                        System.debug('con::'+con);
                        if(con.Name == order.Contact_Person__c){
                            order.Contact__c = con.Id;  
                            order.Contact_Email__c = con.Email; 
                            }
                        }
                    }
                }
                                    
            }
        }
        
        for(Orders__c order : newOrders)    {

            if(VZ_Util.IsNullOrEmpty(order.Installation_Coordinator__c)){
                if(!VZ_Util.IsNullOrEmpty(mapAccounts.Get(order.Account__c).Installation_Coordinator__c))  {                           
                    order.Installation_Coordinator__c = mapAccounts.Get(order.Account__c).Installation_Coordinator__c;
                    listOrderstoUpdateInstallation_Coordinator.add(order);
                
                }else{
                     order.Installation_Coordinator__c = icUser != null ? icUser.Id : null;
                }
                
                }                
          
        }                       
               
    }
    
    public void OnBeforeDelete(Orders__c[] oldOrders, Map<Id,Orders__c> oldMap){
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Orders__c ord : oldOrders){
            if(ord.Opportunity__c != null && ord.Order_Status__c != 'Cancelled'){
                oppIds.add(ord.Opportunity__c);
            }
            
        }
        
         if(oppIds.size() > 0){
            for(Opportunity opp : [Select Id, Order_Status__c, Order_Owner__c from Opportunity where Id IN : oppIds]){
                opp.Order_Status__c = '';
                opp.Order_Owner__c = '';
                oppsToUpdate.add(opp);
            }
            
            if(oppsToUpdate.size() > 0){
                Database.update(oppsToUpdate, false);
            }
        }
    }
     public void RAStatusShipped(Orders__c[] Orders){
        Set<Id> ordIds = new Set<Id>();
        List<RA_Log__c> RAStatusToUpdate = new List<RA_Log__c>();
        for(Orders__c ord : Orders){
            if(ord.Id != null &&  ord.Order_Status__c == 'Shipped'){
                ordIds.add(ord.Id);
                system.debug('=====>Orders with Shipped' + ordIds);
            }
        }
        
        if(ordIds.size() > 0){
            for(RA_Log__c RA : [Select Id, RA_Status__c, Order__c from RA_Log__c where Order__c   =: ordIds]){
                RA.RA_Status__c = 'Shipped';
                RAStatusToUpdate.add(RA);
                system.debug('=====>Orders with RAStatus' + RAStatusToUpdate);
            }
            
            if(RAStatusToUpdate.size() > 0){
                Database.update(RAStatusToUpdate, false);
            }
        }
    }
    
    public void RAStatusCancelled(Orders__c[] Orders){
        Set<Id> ordIds = new Set<Id>();
        List<RA_Log__c> RAStatusToUpdate = new List<RA_Log__c>();
        for(Orders__c ord : Orders){
            if(ord.Id != null &&  ord.Order_Status__c == 'Cancelled'){
                ordIds.add(ord.Id);
                system.debug('=====>Orders with Shipped' + ordIds);
            }
        }
        
        if(ordIds.size() > 0){
            for(RA_Log__c RA : [Select Id, RA_Status__c, Order__c from RA_Log__c where Order__c   =: ordIds]){
                RA.RA_Status__c = 'Cancelled';
                RAStatusToUpdate.add(RA);
                system.debug('=====>Orders with RAStatus' + RAStatusToUpdate);
            }
            
            if(RAStatusToUpdate.size() > 0){
                Database.update(RAStatusToUpdate, false);
            }
        }
    }
    
    public void RAStatusSubmitted(Orders__c[] Orders){
        Set<Id> ordIds = new Set<Id>();
        List<RA_Log__c> RAStatusToUpdate = new List<RA_Log__c>();
        for(Orders__c ord : Orders){
            if(ord.Id != null &&  (ord.Order_Status__c == 'Submitted' ||ord.Order_Status__c == 'Processing' ||ord.Order_Status__c == 'Completed')){
                ordIds.add(ord.Id);
                system.debug('=====>Orders with Shipped' + ordIds);
            }
        }
        
        if(ordIds.size() > 0){
            for(RA_Log__c RA : [Select Id, RA_Status__c, Order__c from RA_Log__c where Order__c   =: ordIds]){
                RA.RA_Status__c = 'Submitted';
                RAStatusToUpdate.add(RA);
                system.debug('=====>Orders with RAStatus' + RAStatusToUpdate);
            }
            
            if(RAStatusToUpdate.size() > 0){
                Database.update(RAStatusToUpdate, false);
            }
        }
    }
  
      public void populateRALog(Map<String, Orders__c> caseRALog){
        
        List<RA_Log__c> raLogUpdate = new List<RA_Log__c>();
       
        
        if(caseRALog.size() > 0){
            for(Case cas : [Select Id, (Select Id, Case__c,RA_Status__c, Order__c from RA_Logs__r  where Order__c = null and RA_Status__c != 'Cancelled' ) from Case where Id IN : caseRALog.keyset()]){
                if(cas.RA_Logs__r.size() > 0 && caseRALog.get(cas.Id) != null){
                    cas.RA_logs__r[0].Order__c = caseRALog.get(cas.Id).Id;
                    raLogUpdate.add(cas.RA_Logs__r[0]);
                }
            }
        }
        
        if(raLogUpdate.size() > 0){
            Database.update(raLogUpdate, false);
        }
    }
  
}