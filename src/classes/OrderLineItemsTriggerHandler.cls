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
// File Name:       OrderLineItemsTriggerHandler 
// Summary:         Helper class for Order and Order Line Items Data
// Created On:      March-16-2015

// Modification Log:
====================

// Aravind    - 3/16/2015 - Create a base version of OrderLineItemsTriggerHandler class 

*******************************************************************************/

public with sharing class OrderLineItemsTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public LIST<Order_Line_Items__c> lstOLID;
    public LIST<Order_Line_Items__c> listQLIToUpdate;
   
    
    public Map<string, List<Order_Line_Items__c>> OrderAndOrderLineItemsMap = new Map<string, List<Order_Line_Items__c>>();    
    
    public OrderLineItemsTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Order_Line_Items__c[] newOLIs){     
         processNewQLIsOnItemNumber(newOLIs);
    }
    
    public void OnAfterInsert(Order_Line_Items__c[] newOLIs){
        
    }
    
    public void OnBeforeUpdate(Order_Line_Items__c[] oldQLIs, Order_Line_Items__c[] updatedQLIs, Map<ID, Order_Line_Items__c> oldQLIMap, Map<ID, Order_Line_Items__c> updatedQLIMap){
       processQLIsOnItemNumberUpdate(updatedQLIs,oldQLIMap); //pass UpdatedList and OldMap
    }
      
    public void processNewQLIsOnItemNumber(Order_Line_Items__c[] newOLIs){                     
         try    {
            listQLIToUpdate = new LIST<Order_Line_Items__c>();
            for(Order_Line_Items__c newOLI: newOLIs){
            if(!VZ_Util.IsNullOrEmpty(newOLI.GP_Item_Number__c))    {
            
                GP_Item_Number_Mapping__c lGPItemNumberMapping = GP_Item_Number_Mapping__c.getInstance(newOLI.GP_Item_Number__c); 
                if(lGPItemNumberMapping != null)    {     
                        newOLI.GP_Item_Description__c = lGPItemNumberMapping.Item_Description__c;
                        newOLI.Installation_Type__c = lGPItemNumberMapping.Installation_Type__c;
                        newOLI.Devices_Installed__c = lGPItemNumberMapping.Installation_Devices__c; 
                        newOLI.TypeOfDevice__c = lGPItemNumberMapping.Device_Type__c;
                        if(lGPItemNumberMapping.Device_Type__c <> 'PrimaryDevice'){
                          newOLI.Service_Type__c =  lGPItemNumberMapping.Installation_Type__c + ' ' +lGPItemNumberMapping.Device_Type__c;
                        }else{
                            newOLI.Service_Type__c =  lGPItemNumberMapping.Installation_Type__c;
                        }
                    }
                    else     {
                        newOLI.GP_Item_Description__c = '';
                        newOLI.Installation_Type__c = '';
                        newOLI.Devices_Installed__c = '';
                        newOLI.TypeOfDevice__c = '';
                        newOLI.Service_Type__c = '';
                    }
                    listQLIToUpdate.add(newOLI);
                }            
            } 
        } Catch (Exception e){
              System.debug(e.getMessage());                    
              return;
        }  
    } 
      
    private void processQLIsOnItemNumberUpdate(Order_Line_Items__c[] updatedQLIs, Map<ID, Order_Line_Items__c> oldQLIMap)    { // Method to generate Contact and Order Map data
      
      try    {
          listQLIToUpdate = new LIST<Order_Line_Items__c>();             
          Map<ID, Order_Line_Items__c> mapUpdatedQLIs = new Map<ID, Order_Line_Items__c>();
     
          for(Order_Line_Items__c qli:updatedQLIs)   {    
             
            Order_Line_Items__c oldQLI= oldQLIMap.get(qli.Id);
            
            if(oldQLI!=null && qli.GP_Item_Number__c!=oldQLI.GP_Item_Number__c && !VZ_Util.IsNullOrEmpty(qli.GP_Item_Number__c))
            {
                mapUpdatedQLIs.put(qli.Id, qli);
                GP_Item_Number_Mapping__c lGPItemNumberMapping = GP_Item_Number_Mapping__c.getInstance(qli.GP_Item_Number__c); 
                if(lGPItemNumberMapping != null)    {                
                    qli.GP_Item_Description__c = lGPItemNumberMapping.Item_Description__c;
                    qli.Installation_Type__c = lGPItemNumberMapping.Installation_Type__c;
                    qli.Devices_Installed__c = lGPItemNumberMapping.Installation_Devices__c; 
                    qli.TypeOfDevice__c = lGPItemNumberMapping.Device_Type__c;
                     if(lGPItemNumberMapping.Device_Type__c <> 'PrimaryDevice'){
                          qli.Service_Type__c =  lGPItemNumberMapping.Installation_Type__c + ' ' +lGPItemNumberMapping.Device_Type__c;
                        }else{
                            qli.Service_Type__c =  lGPItemNumberMapping.Installation_Type__c;
                        }
                    
                }
                else     {
                    qli.GP_Item_Description__c = '';
                    qli.Installation_Type__c = '';
                    qli.Devices_Installed__c = '';
                    qli.TypeOfDevice__c = '';
                    qli.Service_Type__c = '';
                }
                listQLIToUpdate.add(qli);
            } 
        
        } 
        
        } Catch (Exception e){
              System.debug(e.getMessage());                    
              return;
        }
      }
        
        
}