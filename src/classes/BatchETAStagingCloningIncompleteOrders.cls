/*******************************************************************************
// Copyright (c) 2014 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author: Siteja Kakumanu       
// File Name: BatchETAStagingCloningIncompleteOrders   
// Summary: Batch class for ETA staging Clone        
// Created On:  06/03/2016    

// Modification Log:
====================
// Siteja- created a batch class for ETA Staging clone functionality
// Tech M offshore : IT-133: Added Reference Id for SOQL and Field mapping of cloned records
// Siteja- Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed. 
// Sunil-  Updated the code to fix invalid query locator
*******************************************************************************/
global class BatchETAStagingCloningIncompleteOrders implements Database.Batchable<SObject>,schedulable{
    public string query; 
    List<Id> ETAStagingIds;
    list<ETA_Staging__c> ETAStagingStartedRecords;
    //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
    list<ETA_Staging__c> ETAStagingPendingRecords;
    list<ETA_Staging__c> ETAStagingCompletedRecords;
    list<ETA_Staging__c> ETAStagingUpdateCompleteRecords;
    list<ETA_Staging__c> ETAStagingUpdateRecords;
    //IT-567: Changes end 
    
    list<ETA_Staging__c> ETAStagingRecords;
    list<Order_Line_Item_Details__c> ClonedOrderLineItemDetails;
    list<ETA_Staging__c> UpdatedETAStagingRecords;
    
    //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
    list<ETA_Staging__c> ETAStagingClonedRecords;
    Map<string,Id> MapETAStagingIDParentId;
    global Database.queryLocator start(Database.BatchableContext BC){
        //Fetch the ETASTaging records to update
        //Removing the limit 100, As this Batch would consider only the top 100 and ignore the remaining records.
        query = 'Select Id FROM ETA_Staging__c where (ETA_Staging_Status__c = \'Started\' OR ETA_Staging_Status__c = \'Pending\')';
        //IT-567: Changes end 
        
        return Database.getQueryLocator(query); 
          
    }
    
    //Scheduler for the batch apex
    global void execute(SchedulableContext sc) {
        BatchETAStagingCloningIncompleteOrders b = new BatchETAStagingCloningIncompleteOrders();
        database.executebatch(b,100);
    }

    //Update the ETASTaging records
    global void execute(Database.BatchableContext BC, List<ETA_Staging__c> scope){
        ETAStagingIds = new list<Id>();
        ETAStagingStartedRecords = new list<ETA_Staging__c>();
        //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
        ETAStagingPendingRecords = new list<ETA_Staging__c>();
        ETAStagingCompletedRecords = new list<ETA_Staging__c>();
        ETAStagingUpdateCompleteRecords = new list<ETA_Staging__c>(); 
        ETAStagingUpdateRecords = new list<ETA_Staging__c>();
        //IT-567:changes end
        UpdatedETAStagingRecords = new list<ETA_Staging__c>();
        //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
        ETAStagingClonedRecords = new list<ETA_Staging__c>();
        ETAStagingRecords =  new list<ETA_Staging__c>();
        ClonedOrderLineItemDetails = new list<Order_Line_Item_Details__c>();
        MapETAStagingIDParentId = new Map<string,Id>();
        for(ETA_Staging__c etaS:scope){
            ETAStagingIds.add(etaS.Id);
        }
        //IT-567 Changes end 
        ETAStagingRecords = [Select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Account_Name__c, 
        Account_Sub_Type__c, Account__c, Alternate_Contact_Email_txt__c, Alternate_Contact_Name_txt__c, Alternate_Contact_Phone_txt__c, Assigned_Resource_ID__c, Attempts__c, Cancel_Reason__c, Contact_Email_txt__c, Contact_Name_txt__c, 
        Contact_Phone_txt__c, Customer_Number__c, Device_Shipped_To__c, ETA_Activity_Type__c, ETA_Staging_Status__c, First_Attempt_Comment__c, First_Attempt_Date__c, First_Attempt_Reason__c, 
        First_Contact_Method__c, GP_Client_ID__c, GP_Create_Date__c, GP_Currency_ID__c, GP_Customer_PO_Number__c, GP_ERP_Order_ID__c, GP_ERP_Promo_Code__c, GP_Order_Type__c, GP_Salesperson__c, Garage_Address1_txt__c, 
        Garage_Address2_txt__c, Garage_City_txt__c, Garage_Country_pl__c, Garage_Name__c, Garage_State_pl__c, Garage_Zip_txt__c, Location__c, Order__c, Orders_Name__c, Parent_Account_Name__c, Preferred_Installer_Resource__c, 
        Preferred_Installer__c, Refer_To_Customer_Date__c, SLA_Window_End__c, SLA_Window_Start__c, Affiliate_Id__c, Second_Attempt_Comment__c, Second_Attempt_Date__c, Second_Attempt_Reason__c, Second_Contact_Method__c,
        X2nd_Refer_to_Customer_Date__c, No_of_Install_Type__c, No_of_Removal_Type__c, No_of_Swap_Type__c, No_of_Training_Type__c, No_of_Transfer_Type__c, No_of_Troubleshoot_Type__c, ETA_Inventory_Type_c__c, 
        Date_Referred_Back__c, Not_Done_Reason__c, Number_of_vehicles_to_add__c, Rejected_Reason__c, Assigned_Resource_Update_Stamp__c, Clone__c, Customer_facing_notes__c, Fleet_Seller_Key__c, Internal_notes__c, 
        Second_Date_Referred_Back__c, Trigger_ETA_Integration__c, Dispatcher_Comments__c, Addon_Cost__c, Install_Cost__c, Install__c, No_Show_Cost__c, Removal_Cost__c, Removal__c, Sensor_Cost__c, Swap_Cost__c, Swap__c, 
        Training_Full__c, Training_Half__c, Transfer_Cost__c, Transfer__c, Troubleshoot_Cost__c, Troubleshoot__c, Parent_Id__c, Buzzer__c, Duplicate_Activities__c, Tracking_Number__c, Shipment_Date__c, Data_Audit__c, 
        Reference_Id__c, Scheduled_Date__c, Child_Account__c, All_Vins__c, NWF_Activity_Status__c, Accept_Reject_Job__c,(Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
        LastViewedDate, LastReferencedDate, Location__c, Active_Status__c, Activity_Notes__c, Addon_Alternate_Power_Adapter__c, Addon_Bluetooth_module__c, Addon_Driver_ID__c, Addon_Garmin_CONNECT__c, Addon_Harness__c, 
        Addon_Magnet_Mounts__c, Addon_NMEA_Cable__c, Addon_PEM__c, Addon_Pelican_Box__c, Addon_Pigtail__c, Addon_Quake_Satellite_Modem__c, Addon_Window_Mount_GPS_Antenna__c, Alternate_Contact_Email__c, Alternate_Contact_Name__c, 
        Alternate_Contact_Phone__c, Alternate_Contact_Secondary_Phone__c, Alternate_Contact__c, Asset_Tracker_Location__c, Cancel_Reason__c, Color__c, Contact_Name__c, Country__c, Device_Returned__c, Device_Serial_Number_Old__c, 
        Device_Serial_Number__c, Device_Type__c, Driver_ID_Key__c, Driver_ID_Reader_Adapter__c, Driver_ID_Reader__c, ETAStagingID__c, ETA_Activity_ID__c, ETA_Staging__c, Email__c, Engine_Hours__c, Fuel_Type__c, GP_ERP_Order_ID__c, 
        IMEI__c, IV_Case_Number__c, Installation_Type__c, Installer_VIN__c, License_Plate__c, License_State__c, Make__c, Model__c, Add_on_Only_Install__c, Odometer__c, Old_VID__c, Old_Vehicle_Label__c, Old_Vin__c, Order_Account_ID__c, 
        Order_Line_Items__c, Parts_Used1__c, Parts_Used2__c, Phone__c, Parts_Reason_Other1__c, Reason1__c, Reason2__c, SF_Orders__c, Secondary_Phone__c, Sensor1__c, Sensor2__c, Sensor3__c, Sensor4__c, Sensor5__c, Sensor6__c, 
        Tampered_Reason__c, Tampered__c, VID__c, VIN__c, Vehicle_Harness_Category__c, Vehicle_Label__c, Vendor_ID__c, Warranty__c, Warrnty_Start_Date__c, Year__c, isSubmitted__c, Addon_Port_Expansion_Module__c, Addon_NMEA__c, 
        Addon_Serial_Sensor_Expansion_Module__c, Addon_FMI_Cable__c, ETA_INV_ID__c, ETA_INV_POOL__c, ETA_Assigned_Resource__c, ETA_Inventory_Type__c, Garmin_Model__c, Garmin_Serial__c, Not_Done_Action__c, Not_Done_Clone__c, 
        Not_Done_Reason__c, PEM_Serial__c, Quake_Serial__c, Tampered_Other__c, Vehicle_Availability__c, Vehicle_Install_Status__c, Addon_Bluetooth_Extension__c, Is_Original_Addon_Values_updated__c, License_Plate_Country__c, 
        License_Plate_Match__c, License_plate_updated__c, Notes__c, Oracle_CRDR_ID__c, RA__c, Sensors_1_2__c, Sensors_3_4__c, Sensors_5_6__c, Serial_1__c, Serial_2__c, Serial_3__c, Serial_4__c, Serial_5__c, Service_Completed__c, 
        Unit_1__c, Unit_2__c, Unit_3__c, Unit_4__c, Unit_5__c, VIN_Match__c, Vehicle_Install_Date__c, Parts_Reason_Other2__c, Is_Warranty__c, Addon_Buzzer__c, ETA_ACT_ID__c, Duplicate_Count__c, Dups_without_ETA_Staging__c, 
        Dups_without_servicecompleted__c, VIN_vs_Installer_VIN__c, Lic_Plate_vs_License_plate_updated__c, Customer_Name__c, Old_ETA_Staging__c, Parent_ETA_ID__c, Source_Vehicle_ID__c FROM Order_Line_Item_Details__r)  
        FROM ETA_Staging__c where Id in :ETAStagingIds];
        
        Map<id,List<Order_Line_Item_Details__c>> etaOrderLineItemDetailsMap = new Map<id,List<Order_Line_Item_Details__c>>();
        
        for(Order_Line_Item_Details__c oli : [Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
        LastViewedDate, LastReferencedDate, Location__c, Active_Status__c, Activity_Notes__c, Addon_Alternate_Power_Adapter__c, Addon_Bluetooth_module__c, Addon_Driver_ID__c, Addon_Garmin_CONNECT__c, Addon_Harness__c, 
        Addon_Magnet_Mounts__c, Addon_NMEA_Cable__c, Addon_PEM__c, Addon_Pelican_Box__c, Addon_Pigtail__c, Addon_Quake_Satellite_Modem__c, Addon_Window_Mount_GPS_Antenna__c, Alternate_Contact_Email__c, Alternate_Contact_Name__c, 
        Alternate_Contact_Phone__c, Alternate_Contact_Secondary_Phone__c, Alternate_Contact__c, Asset_Tracker_Location__c, Cancel_Reason__c, Color__c, Contact_Name__c, Country__c, Device_Returned__c, Device_Serial_Number_Old__c, 
        Device_Serial_Number__c, Device_Type__c, Driver_ID_Key__c, Driver_ID_Reader_Adapter__c, Driver_ID_Reader__c, ETAStagingID__c, ETA_Activity_ID__c, ETA_Staging__c, Email__c, Engine_Hours__c, Fuel_Type__c, GP_ERP_Order_ID__c, 
        IMEI__c, IV_Case_Number__c, Installation_Type__c, Installer_VIN__c, License_Plate__c, License_State__c, Make__c, Model__c, Add_on_Only_Install__c, Odometer__c, Old_VID__c, Old_Vehicle_Label__c, Old_Vin__c, Order_Account_ID__c, 
        Order_Line_Items__c, Parts_Used1__c, Parts_Used2__c, Phone__c, Parts_Reason_Other1__c, Reason1__c, Reason2__c, SF_Orders__c, Secondary_Phone__c, Sensor1__c, Sensor2__c, Sensor3__c, Sensor4__c, Sensor5__c, Sensor6__c, 
        Tampered_Reason__c, Tampered__c, VID__c, VIN__c, Vehicle_Harness_Category__c, Vehicle_Label__c, Vendor_ID__c, Warranty__c, Warrnty_Start_Date__c, Year__c, isSubmitted__c, Addon_Port_Expansion_Module__c, Addon_NMEA__c, 
        Addon_Serial_Sensor_Expansion_Module__c, Addon_FMI_Cable__c, ETA_INV_ID__c, ETA_INV_POOL__c, ETA_Assigned_Resource__c, ETA_Inventory_Type__c, Garmin_Model__c, Garmin_Serial__c, Not_Done_Action__c, Not_Done_Clone__c, 
        Not_Done_Reason__c, PEM_Serial__c, Quake_Serial__c, Tampered_Other__c, Vehicle_Availability__c, Vehicle_Install_Status__c, Addon_Bluetooth_Extension__c, Is_Original_Addon_Values_updated__c, License_Plate_Country__c, 
        License_Plate_Match__c, License_plate_updated__c, Notes__c, Oracle_CRDR_ID__c, RA__c, Sensors_1_2__c, Sensors_3_4__c, Sensors_5_6__c, Serial_1__c, Serial_2__c, Serial_3__c, Serial_4__c, Serial_5__c, Service_Completed__c, 
        Unit_1__c, Unit_2__c, Unit_3__c, Unit_4__c, Unit_5__c, VIN_Match__c, Vehicle_Install_Date__c, Parts_Reason_Other2__c, Is_Warranty__c, Addon_Buzzer__c, ETA_ACT_ID__c, Duplicate_Count__c, Dups_without_ETA_Staging__c, 
        Dups_without_servicecompleted__c, VIN_vs_Installer_VIN__c, Lic_Plate_vs_License_plate_updated__c, Customer_Name__c, Old_ETA_Staging__c, Parent_ETA_ID__c, Source_Vehicle_ID__c FROM Order_Line_Item_Details__c Where ETA_Staging__c in : ETAStagingIds]){
                if(etaOrderLineItemDetailsMap.containsKey(oli.ETA_Staging__c)){                 
                    List<Order_Line_Item_Details__c> orderLineItemDetails = etaOrderLineItemDetailsMap.get(oli.ETA_Staging__c);
                    orderLineItemDetails.add(oli);
                    etaOrderLineItemDetailsMap.put(oli.ETA_Staging__c, orderLineItemDetails);
                }
                else{
                    etaOrderLineItemDetailsMap.put(oli.ETA_Staging__c, new List<Order_Line_Item_Details__c> { oli});
                }
        }
       //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
        set<Id> etaStagingIdsNotServiceCompleted = new set<Id>();
        
        set<String> affiliateNames = new set<String>();
        List<String> affiliateNamesIncludingAssociatedAff = new List<String>();
        Map<string,string> olidaffiliateClonedbucketAff = new Map<string,string>();
        for(ETA_Staging__c etaS:ETAStagingRecords){
            if(!String.isBlank(etaS.Assigned_Resource_ID__c)){
                affiliateNames.add(etaS.Assigned_Resource_ID__c);
            }
            if(etaOrderLineItemDetailsMap.get(etaS.id) != null){
                for(Order_Line_Item_Details__c olid : etaOrderLineItemDetailsMap.get(etaS.id)){
                    if(olid.Service_Completed__c != 'Yes' && olid.isSubmitted__c == true){
                    etaStagingIdsNotServiceCompleted.add(olid.ETA_Staging__c);
                    
                    }
                }
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
        /* for(Affiliate__c aff:affList){
            affiliateNamesIncludingAssociatedAff.add(aff.Name);
            if(aff.Parent_Affiliate__r.Name != null){
                affiliateNamesIncludingAssociatedAff.add(aff.Parent_Affiliate__r.Name);
            }
        }*/
        affiliatesAssociatedList = [select id, Parent_Affiliate__r.Id,Parent_Affiliate__r.Name,Name,Clone_bucket__c from Affiliate__c where Name in :affiliateNamesIncludingAssociatedAff OR Parent_Affiliate__r.Name in :affiliateNamesIncludingAssociatedAff];
        
        for(affiliate__c aff:affiliatesAssociatedList){
            if(aff.Parent_Affiliate__r.Name != null){
                olidaffiliateClonedbucketAff.put(aff.Name,aff.Parent_Affiliate__r.Name);
            }
        }
        
        Date todayDate = Date.today();
        for(ETA_Staging__c etaS:ETAStagingRecords){
            if(etaS.ETA_Staging_Status__c == 'Started' && etaS.Scheduled_Date__c == todayDate.addDays(-1) && etaStagingIdsNotServiceCompleted.contains(etaS.Id) ){
                ETAStagingStartedRecords.add(etaS);
            } else if(etaS.ETA_Staging_Status__c == 'Pending' && etaS.Scheduled_Date__c == todayDate.addDays(-1) /*&& etaStagingIdsNotServiceCompleted.contains(etaS.Id)*/) {
                ETAStagingPendingRecords.add(etaS);
            } else if(!etaStagingIdsNotServiceCompleted.contains(etaS.Id)) {
                ETAStagingCompletedRecords.add(etaS);
            }
        }
       
        /*for(ETA_Staging__c  a :ETAStagingCompletedRecords){
           // a.ETA_Staging_Status__c = 'Completed';
            ETAStagingUpdateCompleteRecords.add(a);
        }
        
        update ETAStagingUpdateCompleteRecords;*/
        
        ETA_Staging__c ETAStagingRecordClone;
        //IT-567: changes end
        
        for(ETA_Staging__c  a : ETAStagingStartedRecords){
            a.ETA_Staging_Status__c = 'Suspended';
            //a.Scheduled_Date__c = null; 
            a.Cloned_by_Batch__c = true;
            ETAStagingRecordClone = new ETA_Staging__c();
            ETAStagingRecordClone = a.clone(false, true, true,true);
            ETAStagingRecordClone.Parent_Id__c = a.Id;
            ETAStagingRecordClone.ETA_Staging_Status__c = 'Pending';
            ETAStagingRecordClone.Cloned_by_Batch__c = false;
            ETAStagingRecordClone.Scheduled_Date__c = null;
            //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
            /*for(Affiliate__c aff:affList){
                if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == a.Assigned_Resource_ID__c || aff.Name == a.Assigned_Resource_ID__c)){
                        ETAStagingRecordClone.Assigned_Resource_ID__c = aff.Name;
                    
                } 
            }*/
            if(!String.isBlank(a.Assigned_Resource_ID__c)){
                for(affiliate__c aff:affiliatesAssociatedList){
                    if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == a.Assigned_Resource_ID__c || olidaffiliateClonedbucketAff.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name || olidaffiliateClonedbucketAff.get(conCertiaffiliateName.get(a.Assigned_Resource_ID__c)) == aff.Parent_Affiliate__r.Name || conCertiaffiliateName.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name)  && aff.Clone_bucket__c == true){
                        ETAStagingRecordClone.Assigned_Resource_ID__c = aff.Name;
                        
                    }
              }
                
            }
            //IT-567: Changes end
            
            //Tech M offshore : 22/08/2016
            ETAStagingRecordClone.Reference_Id__c=a.Reference_Id__c;
            //Tech M Offshore :22/08/2016
            ETAStagingClonedRecords.add(ETAStagingRecordClone);            
            ETAStagingUpdateRecords.add(a);
        }  
        
        //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
        try{
        insert ETAStagingClonedRecords;
        for(ETA_Staging__c  a : ETAStagingPendingRecords){
            /*for(Affiliate__c aff:affList){
                if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == a.Assigned_Resource_ID__c || aff.Name == a.Assigned_Resource_ID__c)){
                        a.Assigned_Resource_ID__c = aff.Name;
                    
                } 
            }*/
            if(!String.isBlank(a.Assigned_Resource_ID__c)){
                for(affiliate__c aff:affiliatesAssociatedList){
                    if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == a.Assigned_Resource_ID__c || olidaffiliateClonedbucketAff.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name || olidaffiliateClonedbucketAff.get(conCertiaffiliateName.get(a.Assigned_Resource_ID__c)) == aff.Parent_Affiliate__r.Name || conCertiaffiliateName.get(a.Assigned_Resource_ID__c) == aff.Parent_Affiliate__r.Name)  && aff.Clone_bucket__c == true){
                        a.Assigned_Resource_ID__c = aff.Name;
                    }
                }
            }    
            a.Scheduled_Date__c = null; //date.newinstance(3000,01,01);
            ETAStagingUpdateRecords.add(a);
        }         
       
       if(ETAStagingUpdateRecords.size()>0) {
        update ETAStagingUpdateRecords;
        //IT-567: Changes end 
        
       }
       for(ETA_Staging__c ETAStaging:ETAStagingClonedRecords){
         if(ETAStaging.Parent_Id__c != null){
             MapETAStagingIDParentId.put(ETAStaging.Parent_Id__c,ETAStaging.Id);
         }   
        }
        for(ETA_Staging__c  ETA_Staging : ETAStagingStartedRecords){
            if(etaOrderLineItemDetailsMap.get(ETA_Staging.id) != null){
            for(Order_Line_Item_Details__c olid:etaOrderLineItemDetailsMap.get(ETA_Staging.id)){
                system.debug('@@@@@@'+olid.Id);
                if((olid.Service_Completed__c == null || olid.Service_Completed__c == ' ' || olid.Service_Completed__c == 'Return on a later date' || olid.Service_Completed__c == 'No show') && olid.isSubmitted__c == true){
                    Order_Line_Item_Details__c NewOlid = new Order_Line_Item_Details__c();
                    NewOlid = olid.clone(false, true, true,true);
                     //IT-771: Create source vehicle id (OLID name) during cloning in OFSC                    
                     if(String.isNotBlank(olid.Source_Vehicle_ID__c)){                    
                     NewOlid.Source_Vehicle_ID__c = olid.Source_Vehicle_ID__c;                    
                     } else {                    
                     NewOlid.Source_Vehicle_ID__c = olid.Name;                    
                     }                    
                     //IT-771: Changes end
                    if(MapETAStagingIDParentId.get(olid.ETA_Staging__c) != null)
                    NewOlid.ETA_Staging__c = MapETAStagingIDParentId.get(olid.ETA_Staging__c);
                    NewOlid.Service_Completed__c = null;
                    ClonedOrderLineItemDetails.add(NewOlid);
                }
            }
          }
        }
      //IT-567: Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned and if all the vehicles are completed change the ETA Staging Status to Completed.
        if(ClonedOrderLineItemDetails.size()>0)
        insert ClonedOrderLineItemDetails;
        } catch(exception e){
         System.debug(logginglevel.Error, '@@@@@@@Failed here'+e.getMessage()+'stack trace'+ e.getStackTraceString());
        }
    }
        
    //IT-567: Changes end 
    

    global void finish(Database.BatchableContext BC){
    }   

}