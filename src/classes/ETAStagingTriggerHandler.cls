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
// File Name:       ETAStagingTriggerHandler 
// Summary:         Helper class for ETA Staging Data
// Created On:      07-15-2015

// Modification Log:
====================
// Vasanth    - 02-15-2016 - Added code To Pull AP and AR values and populate in ETA Staging Record
// Aravind    - 07-22-2015 - Added code to create blank order line item details
// Aravind    - 07-15-2015 - Create a base version of ETAStagingTriggerHandler class 
// Siteja     - 11/11-2016 - Update ETA Staging Status to Completed if all the vehicles are completed
// Sunil      - 02/23/2017 - Code fix to populate default value for Device Type on ETA Activity Record(Jira ticket number IT-1378)
// Sunil      - 03/24/2017 - 
// Sunil      - 03/31/2017 - Code Clean up as a part of sunset of Cloning(Jira ticket number IT-1638)
// Sunil      -06/15/2017 - Commented hasLogged_vehicle flag for Vehicle Log modifications - IT-1966
*******************************************************************************/

public class ETAStagingTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    static string INSTALLTYPE_INSTALL = 'Install';
    static string INSTALLTYPE_REMOVAL = 'Removal';
    static string INSTALLTYPE_SWAP = 'Swap';
    static string INSTALLTYPE_TRANSFER = 'Transfer';
    static string INSTALLTYPE_TROUBLESHOOT = 'Troubleshoot';
    static string INSTALLTYPE_TRAINING = 'Training';
    
    public ETAStagingTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    public void OnAfterInsert(Map<Id, ETA_Staging__c> newETAStagingMap){
        
        Map<Id, String> etaCustomerMap = new Map<Id, String>();
        Map<String, AR_SalePricing__c> mapARPricing = new Map<String, AR_SalePricing__c>();
        List<ETA_Staging__c> etaUpdates = new List<ETA_Staging__c>();
        Set<String> custNumbs = new Set<String>();
        custNumbs.add('STANDARD');
        List<Order_Line_Item_Details__c> UpdatedOLIDList = new List<Order_Line_Item_Details__c>();
        for(ETA_Staging__c eta :newETAStagingMap.values()){         
                      
            if(eta.Customer_Number__c != null)
                etaCustomerMap.put(eta.Id, eta.Customer_Number__c);         
        }
        
        if(etaCustomerMap.size() > 0){
            custNumbs.addAll(etaCustomerMap.values());
        }
        for(AR_SalePricing__c arSP : [Select Id, Name, Customer_Number__c, Install__c, Swap__c, No_Show__c, Removal__c, Transfer__c, Sensor__c, Training_Full__c, Training_Half__c, Troubleshoot__c, Asset_Guard__c, Bluetooth__c, Driver_ID__c, Garmin__c, PEM__c, PMC__c, Satellite__c from AR_SalePricing__c where Customer_Number__c IN : custNumbs]){
            mapARPricing.put(arSP.Customer_Number__c, arSP);
        }           
                
        System.debug('mapARPricing::'+mapARPricing);
        for(ETA_Staging__c eta :newETAStagingMap.values()){
            boolean isAdd = false;
            ETA_Staging__c etaToUpdate = new ETA_Staging__c(Id = eta.Id);
            if(eta.Type_of_Sale__c == 'Bundled'){
                etaToUpdate.Install__c = 0.0;
                etaToUpdate.Swap__c = 0.0;
                etaToUpdate.No_Show__c = 0.0;
                etaToUpdate.Removal__c = 0.0;
                etaToUpdate.Transfer__c = 0.0;
                etaToUpdate.Sensor__c = 0.0;
                etaToUpdate.Training_Full__c = 0.0;
                etaToUpdate.Training_Half__c = 0.0;
                etaToUpdate.Troubleshoot__c = 0.0;
                etaToUpdate.Asset_Guard__c = 0.0;
                etaToUpdate.Bluetooth__c = 0.0;
                etaToUpdate.Driver_ID__c = 0.0;
                etaToUpdate.Garmin__c = 0.0;
                etaToUpdate.PEM__c = 0.0;
                etaToUpdate.PMC__c = 0.0;
                etaToUpdate.Satellite__c = 0.0;                   
                isAdd = true;
            }else{
                System.debug('etaCustomerMap::'+etaCustomerMap+'--etaCustomerMap.containskey(eta.Id)::'+etaCustomerMap.containskey(eta.Id)+'-mapARPricing-'+mapARPricing.get('STANDARD'));
                if(etaCustomerMap.containskey(eta.Id) && (mapARPricing.get(etaCustomerMap.get(eta.Id)) != null)){
                    {
                        AR_SalePricing__c arpricing = mapARPricing.get(etaCustomerMap.get(eta.Id));
                        etaToUpdate.Install__c = arpricing.Install__c;
                        etaToUpdate.Swap__c = arpricing.Swap__c;
                        etaToUpdate.No_Show__c = arpricing.No_Show__c;
                        etaToUpdate.Removal__c = arpricing.Removal__c;            
                        etaToUpdate.Transfer__c = arpricing.Transfer__c;
                        etaToUpdate.Sensor__c = arpricing.Sensor__c;
                        etaToUpdate.Training_Full__c = arpricing.Training_Full__c;            
                        etaToUpdate.Training_Half__c = arpricing.Training_Half__c;
                        etaToUpdate.Troubleshoot__c = arpricing.Troubleshoot__c;
                        etaToUpdate.Asset_Guard__c = arpricing.Asset_Guard__c;
                        etaToUpdate.Bluetooth__c = arpricing.Bluetooth__c;
                        etaToUpdate.Driver_ID__c = arpricing.Driver_ID__c;
                        etaToUpdate.Garmin__c = arpricing.Garmin__c;
                        etaToUpdate.PEM__c = arpricing.PEM__c;
                        etaToUpdate.PMC__c = arpricing.PMC__c;
                        etaToUpdate.Satellite__c = arpricing.Satellite__c;                    
                        isAdd = true;
                    }
                }else{
                    if(mapARPricing.get('STANDARD') != null){
                        AR_SalePricing__c stdARpricing = mapARPricing.get('STANDARD');
                        etaToUpdate.Install__c = stdARpricing.Install__c;
                        etaToUpdate.Swap__c = stdARpricing.Swap__c;
                        etaToUpdate.No_Show__c = stdARpricing.No_Show__c;
                        etaToUpdate.Removal__c = stdARpricing.Removal__c;
                        etaToUpdate.Transfer__c = stdARpricing.Transfer__c;
                        etaToUpdate.Sensor__c = stdARpricing.Sensor__c;
                        etaToUpdate.Training_Full__c = stdARpricing.Training_Full__c;
                        etaToUpdate.Training_Half__c = stdARpricing.Training_Half__c;
                        etaToUpdate.Troubleshoot__c = stdARpricing.Troubleshoot__c;
                        etaToUpdate.Asset_Guard__c = stdARpricing.Asset_Guard__c;
                        etaToUpdate.Bluetooth__c = stdARpricing.Bluetooth__c;
                        etaToUpdate.Driver_ID__c = stdARpricing.Driver_ID__c;
                        etaToUpdate.Garmin__c = stdARpricing.Garmin__c;
                        etaToUpdate.PEM__c = stdARpricing.PEM__c;              
                        etaToUpdate.PMC__c = stdARpricing.PMC__c;
                        etaToUpdate.Satellite__c = stdARpricing.Satellite__c;                        
                        isAdd = true;                        
                    }
                }
            }
            
            if(isAdd){
                etaUpdates.add(etaToUpdate);
            }
            
        }
        
        if(etaUpdates.size() > 0){
            Database.update(etaUpdates, false);
        }
        
                      
    }
    
    public void OnBeforeUpdate(Map<Id, ETA_Staging__c> oldETAStaging, ETA_Staging__c[] updatedETAStaging, Map<ID, ETA_Staging__c> ETAStagingMap){
        
        Set<id> ETAToUpdate = new Set<id>();
             
        List<ETA_Staging__c> ETAToAddNewVehicles = new List<ETA_Staging__c>();
        
        Set<String> assResNames = new Set<String>();
        Map<String, String> assResAPPMap = new Map<String, String>();
        List<AP_Cost_Pricing__c> apCostSettingsValues = AP_Cost_Pricing__c.getAll().values();
        List<ETA_Staging__c> lstETA = new List<ETA_Staging__c>();
        
        
        for (ETA_Staging__c eta: updatedETAStaging) {
            
            ETA_Staging__c  oldETA = oldETAStaging.get(eta.Id);
            System.debug('Arvi - *********** ' + eta.Id);
            System.debug('Arvi - *********** ' + eta.Clone_Activity_with_Inventory__c);
            
            
            
            // Populate AP Popluation
            if(eta.Assigned_Resource_ID__c != null && eta.Assigned_Resource_ID__c.startswithIgnoreCase('AFF')
               && (eta.Assigned_Resource_ID__c != oldETA.Assigned_Resource_ID__c) 
               && (oldETA.Assigned_Resource_ID__c != null && (oldETA.Assigned_Resource_ID__c.startswithIgnoreCase('VER') || oldETA.Assigned_Resource_ID__c.startswithIgnoreCase('AFF')))){
                   assResNames.add(eta.Assigned_Resource_ID__c);
               }
            
        }
        
        if(assResNames.size() > 0){
            for(Affiliate__c aff : [Select Id, Name, Affiliate_Type__c, Parent_Affiliate__c, Parent_Affiliate__r.Name, Parent_Affiliate__r.Affiliate_Type__c from Affiliate__c where Name IN : assResNames]){
                if(aff.Parent_Affiliate__c != null){
                    assResAPPMap.put(aff.Name, aff.Parent_Affiliate__r.Affiliate_Type__c);
                }else{
                    assResAPPMap.put(aff.Name, aff.Affiliate_Type__c);
                }
            }
        }
        
        for (ETA_Staging__c eta: updatedETAStaging){
            ETA_Staging__c etaUp = new ETA_Staging__c(Id = eta.Id);
            if(eta.Assigned_Resource_ID__c != null && assResAPPMap != null && assResAPPMap.get(eta.Assigned_Resource_ID__c) != null){
                for(AP_Cost_Pricing__c apCost : apCostSettingsValues){
                    
                    if(assResAPPMap.get(eta.Assigned_Resource_ID__c) == 'Premier'){
                        System.debug('apCost.Premier__c::'+apCost.Premier__c);
                        eta.put(apCost.Field__c, apCost.Premier__c);
                    }else if(assResAPPMap.get(eta.Assigned_Resource_ID__c) == 'Certified'){
                        System.debug('apCost.Certified__c::'+apCost.Certified__c);
                        eta.put(apCost.Field__c, apCost.Certified__c);
                    } 
                    System.debug('etaUp::'+etaUp);                  
                }
                
            }
            System.debug('eta::'+etaUp.Install__c +'--'+etaUp.Swap__c);
        }
        
    }
    
    public void OnAfterUpdate(Map<Id, ETA_Staging__c> oldETAStaging, ETA_Staging__c[] updatedETAStaging, Map<ID, ETA_Staging__c> ETAStagingMap){
        Set<id> etaToClone = new Set<id>();  
        Set<id> ETAToUpdate = new Set<id>();      
        List<ETA_Staging__c> ETAToAddNewVehicles = new List<ETA_Staging__c>();
        List<Order_Line_Item_Details__c> newOLIDs = new List<Order_Line_Item_Details__c>();
        List<ETA_Staging__c> noShowETAList = new List<ETA_Staging__c>(); //to create a new vehicle for No Show at Activity level. 
        
        for (ETA_Staging__c eta: updatedETAStaging) {
            
            ETA_Staging__c  oldETA = oldETAStaging.get(eta.Id);
            System.debug('Arvi - *********** ' + eta.Id);
            System.debug('Arvi - *********** ' + eta.Clone_Activity_with_Inventory__c);
            
            if ((eta.No_of_Install_Type__c > 0 && eta.No_of_Install_Type__c != oldETA.No_of_Install_Type__c) ||
                (eta.No_of_Removal_Type__c > 0 && eta.No_of_Removal_Type__c != oldETA.No_of_Removal_Type__c) ||
                (eta.No_of_Swap_Type__c > 0 && eta.No_of_Swap_Type__c != oldETA.No_of_Swap_Type__c) ||
                (eta.No_of_Transfer_Type__c > 0 && eta.No_of_Transfer_Type__c != oldETA.No_of_Transfer_Type__c) ||
                (eta.No_of_Troubleshoot_Type__c > 0 && eta.No_of_Troubleshoot_Type__c != oldETA.No_of_Troubleshoot_Type__c) ||
                (eta.No_of_Training_Type__c > 0 && eta.No_of_Training_Type__c != oldETA.No_of_Training_Type__c)) {
                    
                    ETAToAddNewVehicles.add(eta);
                    
                } 
                        
            //to create a new vehicle for No Show at Activity level.
            if(eta.Is_No_Show__c == true && oldETA.Is_No_Show__c != true){
                noShowETAList.add(eta);
            }
            
        }
        
        if(noShowETAList.size() > 0){
            createNewVehicleNoShow(noShowETAList);
        }
        
        if(ETAToAddNewVehicles.Size() > 0){    
            System.debug('Arvi - *********** OnAfterUpdate ETAToAddNewVehicles count more than 0');
            newOLIDs.addAll(AddVehiclesforNewRequest(ETAToAddNewVehicles));
        }
        
        
        if(!newOLIDs.isEmpty()){
        
            insert newOLIDs;    
        }
                                     
        //IT - 740 Vehicle Status log - Begin
        if(/*!VehicleLogUtility.hasLogged && */Label.VehicleLog == 'ON'){
            VehicleLogUtility.fnLogOnActivityChanges(oldETAStaging, ETAStagingMap);
        }
        //IT - 740 Vehicle Status log - End
        
    }
    
    private List<Order_Line_Item_Details__c> generateBlankOLIDsToAdd( ETA_Staging__c ETARecord, decimal countToAdd,string INSTALLATIONTYPE )    { // Method to populate Installation Coordinator
        
        List<Order_Line_Item_Details__c> olidRecordsToAdd = new List<Order_Line_Item_Details__c>();
        
        for(decimal a = 0; a < countToAdd; a++){
            Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c();
            olid.GP_ERP_Order_ID__c = ETARecord.GP_ERP_Order_ID__c;
            olid.SF_Orders__c = ETARecord.Order__c;
            olid.Location__c = ETARecord.Location__c;
            if(!(ETARecord.ETA_Staging_Status__c == Label.NotDone)){
                olid.ETA_Staging__c = ETARecord.Id;    
            }
            olid.Vehicle_Label__c = INSTALLATIONTYPE  + ' New Vehicle - ' + string.valueof(a+1);
            olid.Activity_Notes__c =  INSTALLATIONTYPE  + ' New Vehicle - ' + string.valueof(a+1);
            olid.isSubmitted__c = true;
            olid.Installation_Type__c= INSTALLATIONTYPE;
            olid.ETA_INV_POOL__c = 'customer';      
            olid.Parent_ETA_ID__c = ETARecord.Reference_Id__c;
            olid.ETA_Inventory_Type__c = 'Vehicle';
            olid.ETA_Assigned_Resource__c = ETARecord.Assigned_Resource_ID__c;           
            olid.Original_ETA__c = ETARecord.Id; 
            olid.Device_Type__c = '5500'; // code fix to default the value to 5500                     
            olidRecordsToAdd.add(olid);             
        }
        return olidRecordsToAdd;
        
    }
    
    private List<Order_Line_Item_Details__c> AddVehiclesforNewRequest( List<ETA_Staging__c> ETAToAddNewVehicles)    { // Method to populate Installation Coordinator
        
        List<Order_Line_Item_Details__c> olidRecordsToAdd = new List<Order_Line_Item_Details__c>();
        
        for(ETA_Staging__c ETAStagingRecord : ETAToAddNewVehicles )    {
            
            if(ETAStagingRecord.No_of_Install_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Install_Type__c, INSTALLTYPE_INSTALL ));
            }
            if(ETAStagingRecord.No_of_Removal_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Removal_Type__c, INSTALLTYPE_REMOVAL ));
            }
            if(ETAStagingRecord.No_of_Swap_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Swap_Type__c, INSTALLTYPE_SWAP ));
            }
            if(ETAStagingRecord.No_of_Transfer_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Transfer_Type__c, INSTALLTYPE_TRANSFER ));
            }
            if(ETAStagingRecord.No_of_Troubleshoot_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Troubleshoot_Type__c, INSTALLTYPE_TROUBLESHOOT ));
            }
            if(ETAStagingRecord.No_of_Training_Type__c > 0)     {
                olidRecordsToAdd.addAll(generateBlankOLIDsToAdd(ETAStagingRecord, ETAStagingRecord.No_of_Training_Type__c, INSTALLTYPE_TRAINING ));
            }
            
        }        
        return olidRecordsToAdd;
        
    }
    
            
    
    
    public void createNewVehicleNoShow(List<ETA_Staging__c> etaActivityList){ //to create a new vehicle for No Show at Activity level.
        List<Order_Line_Item_Details__c> olidList = new List<Order_Line_Item_Details__c>();
        for(ETA_Staging__c eta : etaActivityList){
            Order_Line_Item_Details__c newOLID = new Order_Line_Item_Details__c();
            newOLID.GP_ERP_Order_ID__c = eta.GP_ERP_Order_ID__c <> '' ? eta.GP_ERP_Order_ID__c : 'No Show Vehicle';
            newOLID.Service_Completed__c = 'No Show';
            newOLID.Vehicle_Install_Date__c = system.today();
            newOLID.Installation_Type__c = 'Install';
            newOLID.VID__c = 'No show vehicle';
            newOLID.Add_on_Only_Install__c = false;
            newOLID.isSubmitted__c = true;
            newOLID.ETA_INV_POOL__c = 'deinstall';
            newOLID.Location__c = eta.Location__c;
            newOLID.ETA_Staging__c = eta.id;
            newOLID.ETA_INV_ID__c = eta.Assigned_Resource_ID__c;
            olidList.add(newOLID);
        }
        if(olidList.size()>0){
            insert olidList;
        }
        // reset the Is No Show flag to false
        
        List<ETA_Staging__c> etaNoShowResetList = new List<ETA_Staging__c>();
        for(ETA_Staging__c etaRecord : [Select Id,Is_No_Show__c FROM ETA_Staging__c WHERE Id IN :etaActivityList]){
             etaRecord.Is_No_Show__c = false;
             etaRecord.Trigger_ETA_Integration__c = 1;
             etaNoShowResetList.add(etaRecord);
        }
        if(etaNoShowResetList.size() > 0){
            update etaNoShowResetList;
        }
           
    }    
}