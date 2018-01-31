public class ETAStagingTriggerFutureHelper{
    
    @future
    public static void cloneETAwithOrder(Set<id> etaToClone){
        List<Order_Line_Item_Details__c> clonedOrderLineItemsList = new List<Order_Line_Item_Details__c>();
       Order_Line_Item_Details__c [] orderLineItemsList = [SELECT Active_Status__c,Activity_Notes__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_Extension__c,Addon_Bluetooth_module__c, 
       Addon_Driver_ID__c,Addon_FMI_Cable__c,Addon_Garmin_CONNECT__c,Addon_Harness__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_Pelican_Box__c, 
       Addon_PEM__c,Addon_Pigtail__c,Addon_Port_Expansion_Module__c,Addon_Quake_Satellite_Modem__c,Addon_Serial_Sensor_Expansion_Module__c,Addon_Window_Mount_GPS_Antenna__c,
       Alternate_Contact_Email__c,Alternate_Contact_Name__c,Alternate_Contact_Phone__c,Alternate_Contact_Secondary_Phone__c,Alternate_Contact__c,Asset_Tracker_Location__c, 
       Cancel_Reason__c,Color__c,Contact_Name__c,Country__c,CreatedById,CreatedDate,Device_Returned__c,Device_Serial_Number_Old__c,Device_Serial_Number__c,Device_Type__c, 
       Driver_ID_Key__c,Driver_ID_Reader_Adapter__c,Driver_ID_Reader__c,Email__c,Engine_Hours__c,ETAStagingID__c,ETA_Activity_ID__c,ETA_INV_ID__c,ETA_INV_POOL__c, 
       ETA_Staging__c,Fuel_Type__c,GP_ERP_Order_ID__c,Id,IMEI__c,Installation_Type__c,Installer_VIN__c,IsDeleted,isSubmitted__c,IV_Case_Number__c,
       License_Plate__c,License_State__c,Location__c,Make__c,Model__c,Name,Not_Done_Reason__c,Odometer__c,Not_Done_Clone__c, RA__c,
       Old_Vehicle_Label__c,Old_Vin__c,Order_Account_ID__c,Order_Line_Items__c,Parts_Used1__c,Parts_Used2__c,Phone__c,Reason1__c,Reason2__c, 
       Secondary_Phone__c,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,SF_Orders__c,SystemModstamp,Tampered_Reason__c,Tampered__c, 
       Vehicle_Availability__c,Vehicle_Harness_Category__c,Vehicle_Label__c,Vendor_ID__c,VIN__c,Warranty__c,Warrnty_Start_Date__c, ETA_Assigned_Resource__c,Year__c, ETA_Staging__r.Assigned_Resource_ID__c 
       FROM Order_Line_Item_Details__c WHERE ETA_Staging__c in: etaToClone AND ETA_INV_ID__c != 'VehicleComplete' AND (Service_Completed__c = Null OR Service_Completed__c = '' OR Service_Completed__c = 'No show' OR Service_Completed__c = 'Return on a later date' )];
       
       if(orderLineItemsList.size() > 0){
          
       
           for(Order_Line_Item_Details__c olid : orderLineItemsList )    {
               Order_Line_Item_Details__c newOLID = new Order_Line_Item_Details__c();
               
              
               newOLID = olid.clone(false, false, false, false);
               if(olid.ETA_Staging__r.Assigned_Resource_ID__c != null) {
               
               olid.ETA_Assigned_Resource__c = olid.ETA_Staging__r.Assigned_Resource_ID__c;
               } 
               newOLID.ETA_Staging__c = null;
               newOLID.Not_Done_Reason__c = null;
               newOLID.Not_Done_Clone__c = FALSE;
               newOLID.ETA_Assigned_Resource__c = olid.ETA_Assigned_Resource__c != null ? olid.ETA_Assigned_Resource__c : 'verizon_nwf';
               clonedOrderLineItemsList.add(newOLID);
               
           }
           if(clonedOrderLineItemsList != null && clonedOrderLineItemsList.Size() > 0)    {
               
           insert clonedOrderLineItemsList;
           
           }
         //  Database.delete(orderLineItemsList, false);
       }
    }  


}