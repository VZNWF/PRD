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
// File Name:       OrderLineItemDetailsTriggerHandler 
// Summary:         Helper class for Creating Activities from Order and Order Line Items Data
// Created On:      March-16-2015

// Modification Log:
====================

// Aravind    - 3/16/2015 - Create a base version of OrderLineItemDetailsTriggerHandler class 
// Siteja     -11/11/2016 - Update the Assigned Resource ID to Cloned Bucket ID when the record is cloned 
// Sunil      -02/17/2017 - Updated the code to pupulate All Vins field on ETA Activity Object(Jira ticket number IT-210)
// Sunil      -06/15/2017 - Commented hasLogged_vehicle flag for Vehicle Log modifications - IT-1966
// Sunil      -07/12/2017 -  code to update balance quantity when an vehicle is attached to order line item. - IT-1931   
*******************************************************************************/

public with sharing class OrderLineItemDetailsTriggerHandler {
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public LIST<Order_Line_Item_Details__c> lstOLID;
    Set<string> uniqueOrderIds = new Set<string>();
    public String GPERPOrderId{get; set;}
    public Map<string, List<Order_Line_Item_Details__c>> OrderAndOrderLineItemsMap = new Map<string, List<Order_Line_Item_Details__c>>();
    private Map<Id, Map<String, Set<Id>>> orderOLIDeviceMap = new Map<Id, Map<String, Set<Id>>>();   
    
    Set<String> etaIds = new Set<String>();
    
    public OrderLineItemDetailsTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnBeforeInsert(Order_Line_Item_Details__c[] newOLIDetails){     
    /* List<Id> orderIds = new List<Id>();
      Map<Id,string> orderIdOwnerEmailMap = new Map<Id,string>();
      List<orders__c> ordersList = new List<orders__c>();
       
       for(Order_Line_Item_Details__c olid:newOLIDetails ){
          if(olid.SF_Orders__c != null){
             orderIds.add(olid.SF_Orders__c);
          }
       }
       ordersList = [select id,Opportunity__r.Owner.Email from Orders__c where Id in :orderIds];
       for(Orders__c o:ordersList ){
          if(o.Opportunity__r.Owner.Email != null){
             orderIdOwnerEmailMap.put(o.Id,o.Opportunity__r.Owner.Email);
          }
       }
       for(Order_Line_Item_Details__c olid:newOLIDetails){
           if(olid.SF_Orders__c != null && orderIdOwnerEmailMap.get(olid.SF_Orders__c) != null){
               olid.Opportunity_Owner_Email__c = orderIdOwnerEmailMap.get(olid.SF_Orders__c);
               system.debug('@@@@@@'+orderIdOwnerEmailMap.get(olid.SF_Orders__c));
           }
       }*/     
    }
    
    public void OnAfterInsert(Order_Line_Item_Details__c[] newOLIDetails){
      List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c>();
        if(!VZ_Util.IsOLIDBulkImport){
            InitOrders(newOLIDetails);
        }
        
        updatePurchaseBalance(newOLIDetails);
        
        for(Order_Line_Item_Details__c oli : newOLIDetails){
            if(oli.ETA_Staging__c != null){
            etaIds.add(oli.ETA_Staging__c);
            }
        }
        
        if(etaIds.size() > 0){
           etaStagingList = populateETAList(etaIds);
         if(etaStagingList.size() > 0){
             Database.update(etaStagingList, false);         
         }
       }
       
       //createOrderLineItemEntries(newOLIDetails, null);
    }
    
    public void OnAfterUpdate(Order_Line_Item_Details__c[] updatedOLI, Map<ID, Order_Line_Item_Details__c> OLIMap, Map<ID, Order_Line_Item_Details__c> OLIOldMap){
        system.debug('UpdateTriggerFired=>');
        List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c>();
        List<Order_Line_Item_Details__c> updatedOLIDetails = new List<Order_Line_Item_Details__c>();
        
        for(Order_Line_Item_Details__c oliRecord: updatedOLI){
            
            System.debug('OrderLineItemDetailsTriggerHandler OnAfterUpdate Step1 - ' + oliRecord.ID);
            
            
            if(oliRecord.isSubmitted__c == true && VZ_Util.IsNullOrEmpty(oliRecord.ETA_Staging__c)){
                updatedOLIDetails.add(oliRecord);
            }
            
            //Added for summary count
            if(oliRecord.ETA_Staging__c != null){
                etaIds.add(oliRecord.ETA_Staging__c);
            }
            
        }
        
        updatePurchaseBalance(updatedOLI);
         
        if(!VZ_Util.IsNullOrEmpty(updatedOLIDetails) && !VZ_Util.IsOLIDBulkImport)    {
            InitOrders(updatedOLIDetails);   
        }
        
        
        if(etaIds.size() > 0){
            etaStagingList = populateETAList(etaIds);
            if(etaStagingList.size() > 0){
                Database.update(etaStagingList, false);         
            }
        }
        //IT - 740 Vehicle Status log - Begin
        if(/*!VehicleLogUtility.hasLogged_vehicle && */Label.VehicleLog == 'ON'){
            system.debug('vehLOgFired=>');
            VehicleLogUtility.fnLogOnVehicleChanges(OLIOldMap, OLIMap);
        }
        //IT - 740 Vehicle Status log - End
        
        //createOrderLineItemEntries(updatedOLI, OLIOldMap);
        
    }
    
    public void InitOrders(Order_Line_Item_Details__c[] newOLIDetails){ //Initialize the orders with GPERPOrderId parameter 
            
        uniqueOrderIds = new Set<string>();
        //IT-1071: Unplanned-OLID assigned to new ETA Activity.
        set<id> olidSet = new Set<id>();
        //IT-1071: Changes end.
        for(Order_Line_Item_Details__c newOLIDetail : newOLIDetails){
            uniqueOrderIds.Add(newOLIDetail.SF_Orders__c);
            //IT-1071: Unplanned-OLID assigned to new ETA Activity.
            olidSet.add(newOLIDetail.Id);
            //IT-1071: Changes end.
        }   
        // GP_ERP_OrderId = 'GPERPORD001'; //hard-coded for testing
        
        lstOLID =  [SELECT id, 
                    ETA_Staging__c, 
                    GP_ERP_Order_Id__c, 
                    SF_Orders__c, 
                    Order_Account_ID__c, 
                    ETA_Assigned_Resource__c,
                    Location__r.Id,
                    //IT-1004: The cost tab does not carry over into cloned activities
                    Original_ETA__c,
                    //IT_1004: Changes end
                    //IT-767: Ref Id for Not Done Clone
                    Parent_ETA_ID__c        
                    ////IT-767: Changes end          
                                             
                    FROM Order_Line_Item_Details__c  
                    //IT-1071: Unplanned-OLID assigned to new ETA Activity.        
                    WHERE ETA_Staging__c = '' AND isSubmitted__c = true AND ID IN :olidSet AND SF_Orders__c in:uniqueOrderIds 
                    //IT-1071: Changes end.
                    //WHERE GP_ERP_Order_id__c in:uniqueOrderIds 
                    ORDER By Location__c];
                    
        for (Order_Line_Item_Details__c OLID : lstOLID) {
                                          
              if(OrderAndOrderLineItemsMap.containsKey(OLID.SF_Orders__c))    {    
                  OrderAndOrderLineItemsMap.get(OLID.SF_Orders__c).add(OLID);  
              }
              else    {           
                List<Order_Line_Item_Details__c> listOfValues = new List<Order_Line_Item_Details__c>();
                listOfValues.add(OLID);
                OrderAndOrderLineItemsMap.put(OLID.SF_Orders__c,listOfValues);  
              }
        }
        
        CreateETAStagingRecords(OrderAndOrderLineItemsMap);
        
    }
    
    public void OnAfterDelete(Order_Line_Item_Details__c[] oldOLI, Order_Line_Item_Details__c[] newOLI){
        List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c>();
        
        for(Order_Line_Item_Details__c oli : oldOLI){
            //Added for summary count
            if(oli.ETA_Staging__c != null){
                etaIds.add(oli.ETA_Staging__c);
            }        
        }
        
        updatePurchaseBalance(oldOLI);
        
         if(etaIds.size() > 0){
           etaStagingList = populateETAList(etaIds);
         if(etaStagingList.size() > 0){
             Database.update(etaStagingList, false);         
         }
      }
    
    }
    
    public void OnUndelete(Order_Line_Item_Details__c[] newOLI){
        List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c>();
        
        for(Order_Line_Item_Details__c oli : newOLI){
            //Added for summary count
            if(oli.ETA_Staging__c != null){
                etaIds.add(oli.ETA_Staging__c);
            }        
        }
        
        updatePurchaseBalance(newOLI);
        
         if(etaIds.size() > 0){
           etaStagingList = populateETAList(etaIds);
         if(etaStagingList.size() > 0){
             Database.update(etaStagingList, false);         
         }
      }
    
    }
 
 
    public void CreateETAStagingRecords(Map<string, List<Order_Line_Item_Details__c>> paramOrderAndOrderLineItemsMap)    {
        
        LIST<Order_Line_Item_Details__c> lstOLIDRecords; 
        //IT-567: Update the Assigned Resource ID with a Clone Bucket ID
        //LIST<Order_Line_Item_Details__c> lstOLIDRecords1; 
        List<String> affiliateNames = new List<String>();
        List<String> affiliateNamesIncludingAssociatedAff = new List<String>();
        LIST<Order_Line_Item_Details__c> lstOLID = new LIST<Order_Line_Item_Details__c>();   
        //IT-567: Changes end      
        LIST<ETA_Staging__c > lstETA = new LIST<ETA_Staging__c >();
        Map<string, List<Order_Line_Item_Details__c>> duplicateOrderLineIDsMap = new Map<string, List<Order_Line_Item_Details__c>>();    
        Map<string, Map<string, List<Order_Line_Item_Details__c>>> ordersAndOLIDMap = new Map<string, Map<string, List<Order_Line_Item_Details__c>>>(); 
           
        //IT-567: Update the Assigned Resource ID with a Clone Bucket ID
        for (string strGP_ERP_Order_id : paramOrderAndOrderLineItemsMap.keySet()){
            lstOLID.addall(paramOrderAndOrderLineItemsMap.get(strGP_ERP_Order_id));
        }
        
        //IT-1004: The cost tab does not carry over into cloned activities
        Set<Id> ETAStagingIds = new Set<Id>();
        //IT-1004: Changes end
        
        for(Order_Line_Item_Details__c olid:lstOLID){
            if(!String.isBlank(OLID.ETA_Assigned_Resource__c)){    
                affiliateNames.add(OLID.ETA_Assigned_Resource__c);
            }
        //IT-1004: The cost tab does not carry over into cloned activities
            if(!String.isBlank(OLID.Original_ETA__c)){    
                ETAStagingIds.add(OLID.Original_ETA__c);
                //affiliateNames.add(OLID.ETA_Assigned_Resource__c);
            }
        }
        
    Map<Id,ETA_Staging__c> ETAStagingRecordsMap = new Map<Id,ETA_Staging__c>([Select Id, OwnerId, Owner.IsActive , IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Account_Name__c, 
    Account_Sub_Type__c, Account__c, Alternate_Contact_Email_txt__c, Alternate_Contact_Name_txt__c, Alternate_Contact_Phone_txt__c, Alternate_Contact_Phone_ext_txt__c, Assigned_Resource_ID__c, Attempts__c, Cancel_Reason__c, Contact_Email_txt__c, Contact_Name_txt__c, 
    Contact_Phone_txt__c, Contact_Phone_ext_txt__c, Customer_Number__c, Device_Shipped_To__c, ETA_Activity_Type__c, ETA_Staging_Status__c, First_Attempt_Comment__c, First_Attempt_Date__c, First_Attempt_Reason__c, 
    First_Contact_Method__c, GP_Client_ID__c, GP_Create_Date__c, GP_Currency_ID__c, GP_Customer_PO_Number__c, GP_ERP_Order_ID__c, GP_ERP_Promo_Code__c, GP_Order_Type__c, GP_Salesperson__c, Garage_Address1_txt__c, 
    Garage_Address2_txt__c, Garage_City_txt__c, Garage_Country_pl__c, Garage_Name__c, Garage_State_pl__c, Garage_Zip_txt__c, Location__c, Order__c, Orders_Name__c, Parent_Account_Name__c, Preferred_Installer_Resource__c, 
    Preferred_Installer__c, Refer_To_Customer_Date__c, SLA_Window_End__c, SLA_Window_Start__c, Affiliate_Id__c, Second_Attempt_Comment__c, Second_Attempt_Date__c, Second_Attempt_Reason__c, Second_Contact_Method__c,
    X2nd_Refer_to_Customer_Date__c, No_of_Install_Type__c, No_of_Removal_Type__c, No_of_Swap_Type__c, No_of_Training_Type__c, No_of_Transfer_Type__c, No_of_Troubleshoot_Type__c, ETA_Inventory_Type_c__c, 
    Date_Referred_Back__c, Not_Done_Reason__c, Number_of_vehicles_to_add__c, Rejected_Reason__c, Assigned_Resource_Update_Stamp__c, Clone__c, Customer_facing_notes__c, Fleet_Seller_Key__c, Internal_notes__c, 
    Second_Date_Referred_Back__c, Trigger_ETA_Integration__c, Dispatcher_Comments__c, Addon_Cost__c, Install_Cost__c, Install__c, No_Show_Cost__c, Removal_Cost__c, Removal__c, Sensor_Cost__c, Swap_Cost__c, Swap__c, 
    Training_Full__c, Training_Half__c, Transfer_Cost__c, Transfer__c, Troubleshoot_Cost__c, Troubleshoot__c, Parent_Id__c, Buzzer__c, Duplicate_Activities__c, Tracking_Number__c, Shipment_Date__c, Data_Audit__c, 
    Reference_Id__c, Child_Account__c, All_Vins__c, NWF_Activity_Status__c, Accept_Reject_Job__c,Preferred_Install_Date_Time_1__c,Preferred_Install_Date_Time_2__c FROM ETA_Staging__c where Id in :ETAStagingIds]);
        
        //IT-1004: Changes end
        
        List<Affiliate__c> affList = new List<Affiliate__c>();
        List<Affiliate__c> affiliatesAssociatedList = new List<Affiliate__c>();
        Map<string,string> olidaffiliateClonedbucketAff = new Map<string,string>();
        affList = [select id, Parent_Affiliate__r.Id,Parent_Affiliate__r.Name,Name,Clone_bucket__c from Affiliate__c where Name in :affiliateNames OR Parent_Affiliate__r.Name in :affiliateNames];
        List<Contact> contacts = new List<Contact>();
        system.debug('@@@@@@@affiliate Names'+affiliateNames);
        contacts = [select id,Affiliate_ID__r.Name,Affiliate_ID__r.Parent_Affiliate__r.Name,Certified_Installer_ID__c,Certificate__c from contact where Certified_Installer_ID__c in :affiliateNames OR Certificate__c in :affiliateNames];        
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
        /*for(Affiliate__c aff:affList){
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
        //IT-567: Changes end 
        //IT-804 - Contact/Alternate Contact details on ETA Activity - Begin
        Set<Id> locIdSet = new Set<Id>();
        for(Order_Line_Item_Details__c olid:lstOLID){
            locIdSet.add(olid.Location__c);     
        }
        Map<Id,Location__c> locationMap = new Map<Id,Location__c>([SELECT Id,ContactName__c,Phone__c,Phone_ext__c,Email__c,Alternate_Name__c,Alternate_Phone__c,Alternate_Phone_ext__c,Alternate_Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Preferred_Install_Date_Time_1__c,Preferred_Install_Date_Time_2__c FROM Location__c WHERE Id IN :locIdSet]);
        //IT-804 - Contact/Alternate Contact details on ETA Activity - End
        lstETA = new LIST<ETA_Staging__c >();
        
            for (string strGP_ERP_Order_id : paramOrderAndOrderLineItemsMap.keySet())   {
                    
                    lstOLIDRecords = paramOrderAndOrderLineItemsMap.get(strGP_ERP_Order_id);
                 
                if(!VZ_Util.IsNullOrEmpty(lstOLIDRecords)) {
                                        
                    for (Order_Line_Item_Details__c OLID : lstOLIDRecords) {
                                                          
                          if(duplicateOrderLineIDsMap.containsKey(OLID.Location__r.Id))    {    
                              duplicateOrderLineIDsMap.get(OLID.Location__r.Id).add(OLID);  
                          }
                          else    {
                          
                            List<Order_Line_Item_Details__c> listOfValues = new List<Order_Line_Item_Details__c>();
                            listOfValues.add(OLID);
                            duplicateOrderLineIDsMap.put(OLID.Location__r.Id,listOfValues);  
                            //IT-1004: The cost tab does not carry over into cloned activities
                              ETA_Staging__c ETA = new ETA_Staging__c(); 
                                                                                      
                              if(String.isNotBlank(OLID.Original_ETA__c)){                                 
                                     ETA_Staging__c ETAClone = ETAStagingRecordsMap.get(OLID.Original_ETA__c);
                                  
                                  ETA = ETAClone.clone(false, false, false, false);
                                  system.debug('ETA=>'+ETA);
                                  ETA.ETA_staging_Status__c = 'Pending';
                                  ETA.OwnerId = ETA.Owner.IsActive == true ? ETA.OwnerId : UserInfo.getUserId() ; // code fix for inactive ownerid(User) records
                              } else {                               
                                  ETA = new ETA_Staging__c(
                                      //IT-1004: Changes end
                                      Location__c = OLID.Location__c,
                                      Account__c = OLID.Order_Account_ID__c,
                                      Order__c = OLID.SF_Orders__c,
                                      ETA_Activity_Type__c = '6'
                                  );
                                  //IT-804 - Contact/Alternate Contact details on ETA Activity - Begin
                                                                                                                                                                                                            
                                  if(locationMap.get(OLID.Location__c) != null){
                                      ETA.Contact_Name_txt__c = locationMap.get(OLID.Location__c).ContactName__c;       
                                      ETA.Contact_Email_txt__c = locationMap.get(OLID.Location__c).Email__c;
                                      ETA.Contact_Phone_txt__c = locationMap.get(OLID.Location__c).Phone__c;
                                      ETA.Contact_Phone_ext_txt__c = locationMap.get(OLID.Location__c).Phone_ext__c;
                                      ETA.Alternate_Contact_Name_txt__c = locationMap.get(OLID.Location__c).Alternate_Name__c;
                                      ETA.Alternate_Contact_Email_txt__c = locationMap.get(OLID.Location__c).Alternate_Email__c;
                                      ETA.Alternate_Contact_Phone_txt__c = locationMap.get(OLID.Location__c).Alternate_Phone__c;
                                      ETA.Alternate_Contact_Phone_ext_txt__c = locationMap.get(OLID.Location__c).Alternate_Phone_ext__c;
                                      ETA.Garage_Address1_txt__c = locationMap.get(OLID.Location__c).Garage_Address1__c;        
                                      ETA.Garage_Address2_txt__c = locationMap.get(OLID.Location__c).Garage_Address2__c;
                                      ETA.Garage_City_txt__c = locationMap.get(OLID.Location__c).Garage_City__c;
                                      ETA.Garage_Country_pl__c = locationMap.get(OLID.Location__c).Garage_Country__c;                                     
                                      ETA.Garage_State_pl__c = locationMap.get(OLID.Location__c).Garage_State__c;
                                      ETA.Garage_Zip_txt__c = locationMap.get(OLID.Location__c).Garage_Zip__c;
                                      ETA.Preferred_Install_Date_Time_1__c = locationMap.get(OLID.Location__c).Preferred_Install_Date_Time_1__c;
                                      ETA.Preferred_Install_Date_Time_2__c = locationMap.get(OLID.Location__c).Preferred_Install_Date_Time_2__c;
                                  }
                                  //IT-804 - Contact/Alternate Contact details on ETA Activity - End
                                  //IT-767: Ref Id for Not Done Clone
                                  if(OLID.Parent_ETA_ID__c != null){
                                      ETA.Reference_Id__c = OLID.Parent_ETA_ID__c;    
                                  }
                              }
                               //IT-767: Changes end
                               //IT-567: Update the Assigned Resource ID with a Clone Bucket ID
                               
                                if(String.isNotBlank(OLID.ETA_Assigned_Resource__c)) {
                                    //IT-1022 - Assign Resource Id missing after FSR Clone - Begin
                                    Boolean hasCloneBucket = false;
                                    //IT-1022 - Assign Resource Id missing after FSR Clone - End
                                    for(affiliate__c aff:affiliatesAssociatedList){
                                        if(aff.Parent_Affiliate__r.Id!= null && (aff.Parent_Affiliate__r.Name == OLID.ETA_Assigned_Resource__c || olidaffiliateClonedbucketAff.get(OLID.ETA_Assigned_Resource__c) == aff.Parent_Affiliate__r.Name || olidaffiliateClonedbucketAff.get(conCertiaffiliateName.get(OLID.ETA_Assigned_Resource__c)) == aff.Parent_Affiliate__r.Name || conCertiaffiliateName.get(OLID.ETA_Assigned_Resource__c) == aff.Parent_Affiliate__r.Name)  && aff.Clone_bucket__c == true){
                                            ETA.Assigned_Resource_ID__c = aff.Name;
                                            //IT-1022 - Assign Resource Id missing after FSR Clone - Begin
                                            hasCloneBucket = true;
                                            //IT-1022 - Assign Resource Id missing after FSR Clone - End
                                       } 
                                    }                  
                                    // ETA.Assigned_Resource_ID__c = OLID.ETA_Assigned_Resource__c;
                                    //IT-567: Changes end 
                                    //IT-1022 - Assign Resource Id missing after FSR Clone - Begin
                                    if(ETA.Assigned_Resource_ID__c == null && hasCloneBucket == false && conCertiaffiliateName.get(OLID.ETA_Assigned_Resource__c) != null){
                                        ETA.Assigned_Resource_ID__c = OLID.ETA_Assigned_Resource__c;    
                                    }
                                    //IT-1022 - Assign Resource Id missing after FSR Clone - End
                         
                                    
                                } else{
                                    ETA.Assigned_Resource_ID__c = 'verizon_nwf';    
                                }
                             lstETA.add(ETA);
                             system.debug('ETA-after=>'+ETA);                
                          }

                    }

                    if(ordersAndOLIDMap.containsKey(strGP_ERP_Order_id))    {    
                             // ordersAndOLIDMap.get(strGP_ERP_Order_id).add(duplicateOrderLineIDsMap);  
                    }
                    else    {
                        ordersAndOLIDMap.Put(strGP_ERP_Order_id,duplicateOrderLineIDsMap); 
                    }
                
                }
            }
            
            
            if(!VZ_Util.IsNullOrEmpty(lstETA))  {
                try{  
                    
                    insert lstETA;
                } Catch (Exception e){
                    System.debug(e.getMessage());
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Error while creating Activities'));                          
                    return;
                }

                LIST<Order_Line_Item_Details__c> toUpdatelstOLID = new LIST<Order_Line_Item_Details__c>();
                
                for (ETA_Staging__c currentETA : lstETA){
                
                    Map<string, List<Order_Line_Item_Details__c>> getOrderLineIDsMap = new Map<string, List<Order_Line_Item_Details__c>>();    
                    if(ordersAndOLIDMap.containsKey(currentETA.Order__c))    {    
                            getOrderLineIDsMap = ordersAndOLIDMap.get(currentETA.Order__c);  
                    }
                    else{
                        break;
                    }
                    if(getOrderLineIDsMap.containsKey(currentETA.Location__c))    {
                          
                          List<Order_Line_Item_Details__c> toUpdateOLIDs = getOrderLineIDsMap.Get(currentETA.Location__c);
                          for (Order_Line_Item_Details__c tempOLID : toUpdateOLIDs){
                               tempOLID.ETA_Staging__c = currentETA.Id;
                               toUpdatelstOLID.add(tempOLID);
                          }     
                    }                                     
                }
                
                    try{ 
                       update toUpdatelstOLID;
                      // Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Sucessfully updated OLIDs - ETA Inserted -' + lstETA.Size() + ' OLIDs Updated - ' + toUpdatelstOLID.Size()));  
                    } catch (Exception e){
                        System.debug(e.getMessage());
                      //  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'Error while updating OLIDs'));    
                    }
                
            }
            
            else    {       
               // Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No Lines found for Order ID entered ' + GPERPOrderId + ' or not valid - GP_ERP_Order_Id'));                         
                return;
            }
        }
        
        
        public List<ETA_Staging__c> populateETAList(Set<String> eIds){
           List<ETA_Staging__c> etaList = new List<ETA_Staging__c>();  
           Map<String, Map<String, Integer>> etaOrderMap = CalculateOrderLineUnits(eIds); 
           Map<id, String> etaAllVinsMap = SetAllVins(eIds); // code for All Vins population
           System.debug('etaOrderMap::'+etaOrderMap);
           System.debug('etaAllVinsMap::'+etaAllVinsMap);
           String etaSummVal; 
           ETA_Staging__c eta;
           Map<String, Integer> ordMap = new Map<String, Integer>();
           Map<String, InstallType__c> installCSMap = InstallType__c.getAll();
           
           if(etaOrderMap.size() > 0){
           for(String etaId : etaOrderMap.keySet()){ 
           System.debug('***inside all vins update code::'+etaId);
               ordMap = etaOrderMap.get(etaId);
               etaSummVal = '';
               if( ordMap != null && ordMap.size() > 0 ){
                   eta = new ETA_Staging__c(Id = etaId);
                   for(String s : ordMap.keyset()){
                       if(installCSMap.containskey(s) && installCSMap.get(s) != null){
                        etaSummVal +=  installCSMap.get(s).Code__c +':' + ordMap.get(s)+' ';
                       }                       
                   }
                   eta.Summary_Count__c = etaSummVal;
                   eta.All_VINS__c = etaAllVinsMap.get(etaid) <> null ?  etaAllVinsMap.get(etaid) : eta.All_VINS__c; // code for All Vins population
                   etaList.add(eta);
               }
            }     
         }
            return etaList;
        }
        
        public Map<String, Map<String, Integer>> CalculateOrderLineUnits(Set<String> etaIds){
            Map<String, Map<String, Integer>> etaOrderCountMap = new Map<String, Map<String, Integer>>();
            String etaId;
            String InsType;
            Integer etaCount;
            Map<String, Integer> tempMap = new Map<String, Integer>();
            
            if(etaIds.size() > 0){
            for (AggregateResult ar : [Select Count(Id), Installation_Type__c inst, ETA_Staging__c etaId from Order_Line_Item_Details__c 
                                        where ETA_Staging__c IN: etaIds Group By ETA_Staging__c, Installation_Type__c  ])  {
                System.debug('count' + ar.get('expr0'));
                System.debug('InsType' + ar.get('inst'));
                System.debug('ETA Id' + ar.get('etaId'));
                etaCount = Integer.valueOf(ar.get('expr0'));
                InsType = String.valueOf(ar.get('inst'));
                etaId = String.valueOf(ar.get('etaId'));
                
                
                
                if(etaOrderCountMap != null && etaOrderCountMap.containsKey(etaId)){
                    tempMap = etaOrderCountMap.get(etaId);
                    if(InsType != null){                        
                        tempMap.put(InsType, etaCount);     
                        etaOrderCountMap.put(etaId, tempMap);
                    }                   
                }else{
                    tempMap = new Map<String, Integer>();
                    if(InsType != null){
                        tempMap.put(InsType, etaCount);
                        etaOrderCountMap.put(etaId, tempMap);
                    }
                }
            }
            }
            return etaOrderCountMap;
        }
        // code to update All Vins field on ETA Activity Object
        public Map<Id, String> SetAllVins(Set<String> etaIds){
            Map<id,String> etaAllVinsMap = new Map<id,String>();
            for (ETA_Staging__c currentETA : [Select id,All_Vins__c,(Select id,VIN__c from Order_Line_Item_Details__r where VIN__c != '' AND VIN__c != 'unknown') From ETA_Staging__c WHERE id IN :etaIds]){
                String allVins = '';
                for(Order_Line_Item_Details__c oli : currentETA.Order_Line_Item_Details__r){                            
                    if(String.isBlank(allVins) || !allVins.contains(oli.VIN__c)){
                            allVins = allVins + oli.VIN__c+';'; 
                    }
                }
                system.debug('***allVins:'+allVins);
                if(allVins != ''){                          
                    etaAllVinsMap.put(currentETA.id,allVins);
                }
            }
            return etaAllVinsMap;
        }
        
        // code to update balance quantity when an vehicle is attached to order line item.
        
        public void updatePurchaseBalance(List<Order_Line_Item_Details__c> orderLineItemsList){
              List<Order_Line_Items__c> oliList = new List<Order_Line_Items__c>();
              Set<id> uniqueSet = new Set<id>();
              for(Order_Line_Item_Details__c olid : orderLineItemsList){
                  if(olid.Order_Line_Items__c != null){
                      uniqueSet.add(olid.Order_Line_Items__c);
                  }
              }
              
              system.debug('***uniqueSet'+uniqueSet);
              
              if(!uniqueSet.isEmpty()){
                  for(Order_Line_Items__c oli : [Select Id,Name,GP_Quantity__c,Installation_Type__c,Service_Type__c,BalanceQuantity__c,(Select Id,Installation_Type__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c from Order_Line_Item_Details__r) from Order_Line_Items__c where id IN : uniqueSet]){
                     if(oli.Order_Line_Item_Details__r.size() > 0){
                         Order_Line_Items__c olItem = new Order_Line_Items__c(Id=oli.Id);
                         olItem.BalanceQuantity__c = oli.GP_Quantity__c - oli.Order_Line_Item_Details__r.size();
                         oliList.add(olItem);
                     }
                 } 
              }
              system.debug('***oliList'+oliList);
              
              if(oliList.size() > 0){
                  update oliList;
              }
        }
        
        /*private void createOrderLineItemEntries(List<Order_Line_Item_Details__c> newOLIDList, Map<Id, Order_Line_Item_Details__c> oldOLIDMap){
            List<Order_Line_Item_Details__c> eligibleOLIDList = new List<Order_Line_Item_Details__c>();
            Set<Id> deleteOLID = new Set<Id>();
            Set<Id> orderIds = new Set<Id>();
            
            if(oldOLIDMap == null){
                for(Order_Line_Item_Details__c newOLID: newOLIDList){
                    orderIds.add(newOLID.SF_Orders__c);
                    if(newOLID.Device_Type__c != null){
                        deleteOLID.add(newOLID.Id);
                        eligibleOLIDList.add(newOLID);
                    }
                }
            }else{
                for(Order_Line_Item_Details__c newOLID: newOLIDList){
                    orderIds.add(newOLID.SF_Orders__c);
                    if(newOLID.Device_Type__c != oldOLIDMap.get(newOLID.Id).Device_Type__c){
                        deleteOLID.add(newOLID.Id);
                        eligibleOLIDList.add(newOLID);
                    }
                }
            }
            
            //Generate the Order Line Item, devices Map
            if(orderIds.size()>0){
                genOLIDeviceMap(orderIds);
            }
            //Delete the OLIE for the service types which have changed
            if(deleteOLID.size()>0){
                deleteOLIEntries(deleteOLID);
            }
            //Create the primary device OLIE
            if(eligibleOLIDList.size()>0){
                createOLIEntries(eligibleOLIDList);
            }
        }
        
        private void genOLIDeviceMap(Set<Id> OrderIdSet){
            orderOLIDeviceMap = new Map<Id, Map<String, Set<Id>>>();
            List<Order_Line_Items__c> oliItemsList = [Select Installation_Type__c, Service_Type__c, Devices_Installed__c, TypeOfDevice__c, GP_Quantity__c, Balance_Quantity__c, Orders__c from Order_Line_Items__c where Orders__c IN:OrderIdSet and TypeOfDevice__c = 'PrimaryDevice' and Balance_Quantity__c > 0];
                        
            for(Order_Line_Items__c oliItem: oliItemsList){
                String key = oliItem.Service_Type__c+'_'+oliItem.Devices_Installed__c;
                if(orderOLIDeviceMap.containsKey(oliItem.Orders__c)){
                    Map<String, Set<Id>> oliDeviceMap = orderOLIDeviceMap.get(oliItem.Orders__c);
                    if(oliDeviceMap.containsKey(key)){
                        Set<Id> tempIdSet = oliDeviceMap.get(key);
                        tempIdSet.add(oliItem.Id);
                        oliDeviceMap.put(key, tempIdSet);
                        orderOLIDeviceMap.put(oliItem.Orders__c, oliDeviceMap);
                    }else{
                        oliDeviceMap.put(key, new Set<Id>{oliItem.Id});
                        orderOLIDeviceMap.put(oliItem.Orders__c, oliDeviceMap);
                    }
                }else{
                    Map<String, Set<Id>> oliDeviceMap = new Map<String, Set<Id>>();
                    oliDeviceMap.put(key, new Set<Id>{oliItem.Id});
                    orderOLIDeviceMap.put(oliItem.Orders__c, oliDeviceMap);
                }
                
            }
        }
        
        private void createOLIEntries(List<Order_Line_Item_Details__c> newOLIDList){
            List<Order_Line_Item_Entry__c> insertOLIEList = new List<Order_Line_Item_Entry__c>();
            
            Set<String> assetGuardSet = new Set<String>{'Asset Guard PW (Hardwired)','Asset Guard BX (Battery Powered)'};
            Map<String, String> nullDeviceNameReference = new Map<String, String>{'5200'=>'5200', '5500'=>'5500', '6100'=>'6100 (ExpressFleet)'};
            system.debug(orderOLIDeviceMap);
            for(order_Line_Item_Details__c olidTemp: newOLIDList){
                if(orderOLIDeviceMap.containsKey(olidTemp.SF_Orders__c)){
                    String deviceName = (olidTemp.Device_Type__c != null && assetGuardSet.contains(olidTemp.Device_Type__c))? 'Asset Guard' : nullDeviceNameReference.containsKey(olidTemp.Device_Type__c) ? nullDeviceNameReference.get(olidTemp.Device_Type__c) : olidTemp.Device_Type__c;
                    string olidKey = olidTemp.Installation_Type__c+'_'+deviceName;
                    system.debug(olidKey);
                    Map<String, Set<Id>> oliDeviceMap = orderOLIDeviceMap.get(olidTemp.SF_Orders__c);
                    if(oliDeviceMap.containsKey(olidKey)){
                        for(Id orderIdTemp: oliDeviceMap.get(olidKey)){
                            //Create Order Line Item Entry
                            Order_Line_Item_Entry__c oliE = new Order_Line_Item_Entry__c();
                            oliE.Order_Line_Item__c = orderIdTemp;
                            oliE.Order_Line_Item_Detail__c = olidTemp.Id;
                            insertOLIEList.add(oliE);
                            break;
                        }
                    }else{
                        olidkey = olidTemp.Installation_Type__c+'_null';
                        for(Id orderIdTemp: oliDeviceMap.get(olidKey)){
                            //Create Order Line Item Entry
                            Order_Line_Item_Entry__c oliE = new Order_Line_Item_Entry__c();
                            oliE.Order_Line_Item__c = orderIdTemp;
                            oliE.Order_Line_Item_Detail__c = olidTemp.Id;
                            insertOLIEList.add(oliE);
                            break;
                        }
                    }
                }
            }
            
            if(insertOLIEList.size() > 0){
                insert insertOLIEList;
            }
        }
        
        private void deleteOLIEntries(Set<Id> OLID){
            
            List<Order_Line_Item_Entry__c> oliEntries = [Select Id from Order_Line_Item_Entry__c where Order_Line_Item_Detail__c IN:OLID];
            
            delete oliEntries;
        }*/

    }