/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          
// File Name:       VehicleLogUtility 
// Summary:         To log vehicle and activity changes
// Created On:      12/15/2016

// Modification Log:
====================
// Vasanth    - 02-15-2016 - Added code To Pull AP and AR values and populate in ETA Staging Record
// Aravind    - 07-22-2015 - Added code to create blank order line item details
// Aravind    - 07-15-2015 - Create a base version of ETAStagingTriggerHandler class 
// Siteja     - 11/11-2016 - Update ETA Staging Status to Completed if all the vehicles are completed
// Sunil      - 02/23/2017 - Code fix to populate default value for Device Type on ETA Activity Record(Jira ticket number IT-1378)
// Sunil      - 03/31/2017 - Code Clean up as a part of sunset of Cloning(Jira ticket number IT-1638)
// Sunil      - 04/06/2017 - updated code to End vehicle logging on OLID after a Completed log -IT-1691
// Sunil      - 04/20/2017 - updated code to perform Multiple logs - IT-1734. 
// Sunil      - 05/30/2017 - Hot Fix for FSR company logging issue
// Sunil      - 06/15/2017 - Commented flags - IT-1966
*******************************************************************************/
public class VehicleLogUtility {
    
    //public static boolean hasLogged = false;
    
    //public static boolean hasLogged_vehicle = false;
    
    //Function for logging Vehicles status based on Activity level updates
    public static void fnLogOnActivityChanges(Map<Id,ETA_Staging__c> oldActivitymap, Map<Id,ETA_Staging__c> newActivitymap){
        //hasLogged = true;
        Map<Id,List<String>> activityVehStatusMap = new Map<Id,List<String>>();
        Map<Id,List<Order_Line_Item_Details__c>> activityVehiclesMap = new Map<Id,List<Order_Line_Item_Details__c>>();
        List<Id> vehicleIdsList = new List<Id>();        
        List<Vehicle_Log__c> vehicleLog = new List<Vehicle_Log__c>();
        Set<string> furtherActionAffiliates = new Set<string>();
        Set<string> parentAffiliates = new Set<string>();
        Set<String> uniqueContactAffilates = new Set<String>();
        //Pull all the further action required affiliates
        for(Affiliate__c aff:[SELECT Id, Name, Affiliate_Name__c,Parent_Affiliate__r.Name FROM Affiliate__c LIMIT 500]){
            if(string.valueof(aff.Affiliate_Name__c).toLowerCase().contains('further action')){
                furtherActionAffiliates.add(aff.Name);    
            } else if(aff.Parent_Affiliate__r.Name == null){
                parentAffiliates.add(aff.Name);    
            }  
        }
        // updated code for JIRA ticket Number IT-1734 - Sunil Kumar
        // hot fix for FSR Company vehicle logging - updated query where condition - Sunil kumar
        for(Contact contact : [Select Id, Name, Certificate__c, Affiliate_ID__r.Name from contact where Affiliate_ID__c != null AND Affiliate_Name__c = '1-NWF FSR']){
            uniqueContactAffilates.add(contact.Certificate__c);
        }
        for(ETA_Staging__c newActivity:newActivitymap.values()){
            if(oldActivitymap.get(newActivity.Id).ETA_Activity_ID__c == null && newActivity.ETA_Activity_ID__c != null){
                //Created
        if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Created');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Created'});
        }
                    
            } 
      if(oldActivitymap.get(newActivity.Id).Accept_Reject_Job__c != newActivity.Accept_Reject_Job__c && newActivity.Accept_Reject_Job__c == 'Accept'){
                //Accepted
        if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Accepted');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Accepted'});
        }
                system.debug('***acceptedactivityVehStatusMap:'+activityVehStatusMap);
            } 
      if(oldActivitymap.get(newActivity.Id).Assigned_Resource_ID__c != newActivity.Assigned_Resource_ID__c && newActivity.Assigned_Resource_ID__c != null && ((string.valueOf(newActivity.Assigned_Resource_ID__c)).toLowerCase().contains('aff') || (string.valueOf(newActivity.Assigned_Resource_ID__c)).toLowerCase().contains('nwc') || uniqueContactAffilates.contains(string.valueOf(newActivity.Assigned_Resource_ID__c))) && !furtherActionAffiliates.contains(newActivity.Assigned_Resource_ID__c)  && (parentAffiliates.contains(newActivity.Assigned_Resource_ID__c) || uniqueContactAffilates.contains(newActivity.Assigned_Resource_ID__c)) && newActivity.Assigned_Resource_ID__c != 'verizon_nwf'){
                //Pending Confirmation
                if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Pending Confirmation');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Pending Confirmation'});
        }
            } 
      if(oldActivitymap.get(newActivity.Id).Assigned_Resource_ID__c != newActivity.Assigned_Resource_ID__c && newActivity.Assigned_Resource_ID__c == 'verizon_nwf'){
                //Moved to Verizon_NWF Bucket
        if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Moved to Verizon_NWF Bucket');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Moved to Verizon_NWF Bucket'});
        }
            }
      if((oldActivitymap.get(newActivity.Id).Assigned_Resource_ID__c != newActivity.Assigned_Resource_ID__c && newActivity.Assigned_Resource_ID__c != null && (string.valueOf(newActivity.Assigned_Resource_ID__c)).toLowerCase().contains('reject')) || (oldActivitymap.get(newActivity.Id).Accept_Reject_Job__c != newActivity.Accept_Reject_Job__c && newActivity.Accept_Reject_Job__c == 'Reject')) {
                //Rejected
                if(activityVehStatusMap.get(newActivity.Id) != null){
                  List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                            activityTypeList.add('Rejected');
                            activityVehStatusMap.put(newActivity.Id,activityTypeList);
                }
                else
                {
                            activityVehStatusMap.put(newActivity.Id,new List<String>{'Rejected'});
                }
       }
      system.debug('***old first attempt date:' + oldActivitymap.get(newActivity.Id).First_Attempt_Date__c+'*** new First attempt Date:'+newActivity.First_Attempt_Date__c);
      if(oldActivitymap.get(newActivity.Id).First_Attempt_Date__c != newActivity.First_Attempt_Date__c && newActivity.First_Attempt_Date__c != null){
                //1st Attempt
            if(activityVehStatusMap.get(newActivity.Id) != null){
              List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                        activityTypeList.add('1st Attempt');
                        activityVehStatusMap.put(newActivity.Id,activityTypeList);
            }
            else
            {
                        activityVehStatusMap.put(newActivity.Id,new List<String>{'1st Attempt'});
            }
      }
      if(oldActivitymap.get(newActivity.Id).Second_Attempt_Date__c != newActivity.Second_Attempt_Date__c && newActivity.Second_Attempt_Date__c != null){
                //2nd Attempt
                if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('2nd Attempt');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'2nd Attempt'});
        }
            } 
      if(oldActivitymap.get(newActivity.Id).Assigned_Resource_ID__c != newActivity.Assigned_Resource_ID__c && newActivity.Assigned_Resource_ID__c != null && furtherActionAffiliates.contains(newActivity.Assigned_Resource_ID__c)){
                //Further Action Required
        if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Further Action Required');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Further Action Required'});
        }
            }
      if(oldActivitymap.get(newActivity.Id).Scheduled_Date__c != newActivity.Scheduled_Date__c && newActivity.Scheduled_Date__c != null && newActivity.Scheduled_Date__c != Date.valueOf('3000-01-01')){
                //Scheduled
                if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Scheduled');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Scheduled'});
        }
            }
      if(oldActivitymap.get(newActivity.Id).ETA_Staging_Status__c != newActivity.ETA_Staging_Status__c && newActivity.ETA_Staging_Status__c!= null && newActivity.ETA_Staging_Status__c == 'Cancelled'){
                //Cancelled by Installation Coordinator
                if(activityVehStatusMap.get(newActivity.Id) != null){
          List<String> activityTypeList = activityVehStatusMap.get(newActivity.Id);
                    activityTypeList.add('Cancelled by Installation Coordinator');
                    activityVehStatusMap.put(newActivity.Id,activityTypeList);
        }
        else
        {
                    activityVehStatusMap.put(newActivity.Id,new List<String>{'Cancelled by Installation Coordinator'});
        }
            } 
        }
       // end of code update for JIRA ticket Number IT-1734 - Sunil Kumar
        List<Order_Line_Item_Details__c> vehicleList = new List<Order_Line_Item_Details__c>();
        vehicleList = [SELECT Id,ETA_Staging__c FROM Order_Line_Item_Details__c WHERE ETA_Staging__c IN :activityVehStatusMap.keySet()];
        
        // updated code to End vehicle logging on OLID after a Completed log -IT-1691
        Set<id> excludedVehiclesSet = new Set<id>();
        for(Vehicle_Log__c vLog : [SELECT Id,New_Value__c,Old_Value__c,Value__c,Order_Line_Item_Detail__c FROM Vehicle_Log__c WHERE Order_Line_Item_Detail__c IN : vehicleList AND (Value__c = 'Completed' OR Old_Value__c = 'Completed' OR New_Value__c = 'Completed' )]){
             excludedVehiclesSet.add(vLog.Order_Line_Item_Detail__c);
        }
        
        
        for(Order_Line_Item_Details__c vehicle : vehicleList){
            List<Order_Line_Item_Details__c> lstTemp = new List<Order_Line_Item_Details__c>();
            if(!excludedVehiclesSet.contains(vehicle.Id)){
                if(activityVehiclesMap.get(vehicle.ETA_Staging__c) != null){
                    lstTemp = activityVehiclesMap.get(vehicle.ETA_Staging__c);    
                }    
                lstTemp.add(vehicle);
                vehicleIdsList.add(vehicle.Id);
                activityVehiclesMap.put(vehicle.ETA_Staging__c, lstTemp);
           }
        }
        
        
        //Create log entries
        for(Id activityId:activityVehStatusMap.keySet()){
            if(activityVehiclesMap.get(activityId) != null){
                for(Order_Line_Item_Details__c vehicle:activityVehiclesMap.get(activityId)){
          for(String str : activityVehStatusMap.get(vehicle.ETA_Staging__c)){ /*updated the for loop to exclude old value & new value population code IT-1734 Sunil*/
            Vehicle_Log__c objNewLog = new Vehicle_Log__c();
            objNewLog.Value__c = str;
            objNewLog.Time_Stamp__c = system.now();
            objNewLog.Order_Line_Item_Detail__c = vehicle.Id;
            objNewLog.Field_Api__c = 'ComputedVehicleStatus';
            vehicleLog.add(objNewLog);
          } 
                }
            }
        }
        // insert vehicle Status Log
        if(!vehicleLog.isEmpty()){
            insert vehicleLog;    
        }
          
    }
    
    //Function for logging Vehicles status based on vehicle level updates
    public static void fnLogOnVehicleChanges(Map<Id,Order_Line_Item_Details__c> oldVehiclemap, Map<Id,Order_Line_Item_Details__c> newVehiclemap){
        //hasLogged_vehicle = true;
        Map<Id,String> vehicleStatusMap = new map<Id,String>();
        List<Vehicle_Log__c> vehicleLog = new List<Vehicle_Log__c>();
        // updated code to End vehicle logging on OLID after a Completed log -IT-1691
        Set<id> excludedVehiclesSet = new Set<id>();
        for(Vehicle_Log__c vLog : [SELECT Id,Value__c,Order_Line_Item_Detail__c FROM Vehicle_Log__c WHERE Order_Line_Item_Detail__c IN : newVehiclemap.keySet() AND (Value__c = 'Completed' OR Old_Value__c = 'Completed' OR New_Value__c = 'Completed' )]){
             excludedVehiclesSet.add(vLog.Order_Line_Item_Detail__c);
        }
        // end of update
        for(Order_Line_Item_Details__c newVehicle:newVehiclemap.values()){
          if(!excludedVehiclesSet.contains(newVehicle.id)){
                  system.debug('***inside vehicle level log');
                  system.debug('***oldVehiclemap.get(newVehicle.Id).Service_Completed__c '+oldVehiclemap.get(newVehicle.Id).Service_Completed__c);
                  system.debug('***newVehicle.Service_Completed__c '+newVehicle.Service_Completed__c);
                if(oldVehiclemap.get(newVehicle.Id).Service_Completed__c != newVehicle.Service_Completed__c && newVehicle.Service_Completed__c == 'No show'){
                    //No Show
                    vehicleStatusMap.put(newVehicle.Id,'No Show');    
                } else if(oldVehiclemap.get(newVehicle.Id).Service_Completed__c != newVehicle.Service_Completed__c && newVehicle.Service_Completed__c == 'Return on a later date'){
                    //Return Later
                    vehicleStatusMap.put(newVehicle.Id,'Return Later');    
                } else if(oldVehiclemap.get(newVehicle.Id).Service_Completed__c != newVehicle.Service_Completed__c && newVehicle.Service_Completed__c == 'Cancelled by customer'){
                    //Cancelled on site
                    vehicleStatusMap.put(newVehicle.Id,'Cancelled on site');    
                } else if(oldVehiclemap.get(newVehicle.Id).Service_Completed__c != newVehicle.Service_Completed__c && newVehicle.Service_Completed__c == 'Yes'){
                    //Completed
                    system.debug('***inside vehicle level log completed');
                    vehicleStatusMap.put(newVehicle.Id,'Completed');    
                } 
           }     
        }
        
         //Create log entries
        for(Id vehicleId:vehicleStatusMap.keyset()){ /*updated the for loop to exclude old value & new value population code IT-1734 Sunil*/
            Vehicle_Log__c objNewLog = new Vehicle_Log__c();
            objNewLog.Value__c = vehicleStatusMap.get(vehicleId);
            objNewLog.Time_Stamp__c = system.now();
            objNewLog.Order_Line_Item_Detail__c = vehicleId;
            objNewLog.Field_Api__c = 'ComputedVehicleStatus';
            vehicleLog.add(objNewLog);
            
        }
        // insert vehicle Status Log
        if(!vehicleLog.isEmpty()){
            insert vehicleLog;    
        }
    }

}