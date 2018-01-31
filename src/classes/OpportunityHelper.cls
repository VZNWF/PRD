/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Satish Prasad
// File Name:       OpportunityHelper 
// Summary:         Trigger Handler class for Opportunity Data
// Created On:      Jan-31-2017

// Modification Log:
====================

// Satish    - 01/31/2017 - Create a base version of OpportunityHelper class 
//Satish     - 07/18/2017 - Creating Order for Incorrect Part Order
*******************************************************************************/


global class OpportunityHelper{


    webservice static String createOrder(String oppId){
      
      try{  
      OpportunityOrderMap__mdt[] oppFieldMdt = [Select OpportunityField__c, OrderField__c, MasterLabel, Label, Id From OpportunityOrderMap__mdt];
      String orderRecType = Schema.SObjectType.Orders__c.getRecordTypeInfosByName().get('EO').getRecordTypeId();
      List<OrderLocation__c> ordActLst = new List<OrderLocation__c>();
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
      
      for(OpportunityOrderMap__mdt oMdt : oppFieldMdt){
        fields += ','+ oMdt.OpportunityField__c;
      }
      
      
      String sql = 'Select Id, Customer_Number__c, Case_Number__c, AccountId, Type, Multiple_PO__c, CreateOrder__c, Type_of_Sale__c, Multiple_Address__c, Location_Name__c, Shipping_Street2__c, Shipping_Street3__c, Shipping_City2__c, Shipping_City3__c, Shipping_State2__c, Shipping_State3__c, Shipping_ZipCode2__c, Shipping_ZipCode3__c, Shipping_email2__c, Shipping_email3__c, Shipping_phone3__c, Shipping_phone2__c, Opportunity_ID__c '+fields+', '+
                +'(Select Id, Name, Garage_Address1__c From Locations__r), (Select Id, Product2Id, Product2.Name, ProductCode, Name, Quantity, UnitPrice, TotalPrice, Category__c From OpportunityLineItems), (Select Id, Sale_Type__c, BUN_Qty__c, Product_Category__c, Bundle_Kit_ID__c, Primary__c, Mismatch_Install__c, Product_Record_Id__r.CPQ_PRODUCT_NAME__c, Product_Record_Id__r.ProductCode, PUR_Qty__c, Product_Record_Id__c, Product_Record_Id__r.Name, PUR_MRC_List__c From CPQ_Quote_Products__r) from Opportunity where Id =:oppId';
      
      Opportunity opp = Database.query(sql); 
      //Relating Case and Opportunity 
      Case cas;    
      if(opp.Case_Number__c != null){
        
        List<Case> casList = [Select id, CaseNumber from Case where CaseNumber =: opp.Case_number__c];
        if(casList.size() > 0){
            cas = casList[0];
        }else{
            return 'The Error : Case Number not found';
        }
      }
      
      Orders__c ord = new Orders__c(Opportunity__c = opp.Id, Account__c = opp.AccountId, RecordTypeId = orderRecType, Order_Status__c = 'New',Shipping_Methods__c = 'GROUND', Ship_To_Installer__c='N', isEoOrder__c = true,
                                Ship_Phone__c = opp.Shipping_phone__c, Shipping_Contact__c = opp.Shipping_Contact__c, Promo_Code__c =opp.Discount_Code__c, Opportunity_ID__c = opp.Opportunity_ID__c);
            if(opp.Customer_Number__c != null && opp.Customer_Number__c.endswith('s')){
                ord.Order_Types__c = 'BUNDLE';
              }
            if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA'){
                ord.Order_Types__c = 'RA-EXCHANG';
            } else{
                ord.Order_Types__c = 'STDORD';
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
            if(opp.CPQ_Quote_Products__r.size() > 0){
                if(opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'BUNDLE'){
                ord.Order_Types__c = 'BUNDLE';
                }if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA' && opp.Type_of_Sale__c == 'Bundled'){
                ord.Order_Types__c = 'BU-EXCHANG';
                ord.Case_Id__c = opp.Case_Number__c;
                ord.Case__c = cas != null ? cas.Id : null;
                }
                if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA' && opp.Type_of_Sale__c == 'Purchase'){
                ord.Order_Types__c = 'RA-EXCHANG';
                ord.Case_Id__c = opp.Case_Number__c;
                ord.Case__c = cas != null ? cas.Id : null;
                }else if(opp.CPQ_Quote_Products__r[0].Sale_Type__c == 'PURCHASE'){
                    ord.Order_Types__c = 'STDORD';
                }
            }
            if(opp.OpportunityLineItems.size() > 0){
                if(opp.Case_Number__c != null && opp.Type == 'Exchange/RA'){
                ord.Order_Types__c = 'RA-EXCHANG';
                ord.Case_Id__c = opp.Case_Number__c;
                ord.Case__c = cas != null ? cas.Id : null;
                }
            }
        
        if(opp.Locations__r.size() > 0){    
        for(Location__c loct : opp.Locations__r){
            uniqGarAddress.add(loct.Garage_Address1__c);
        }
        }
            
        if(!opp.Multiple_PO__c || !opp.Multiple_Address__c){
            if(opp.Locations__r != null && opp.Locations__r.size() > 0 ){
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
                loc = new Location__c(Name = opp.Shipping_Street2__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Shipping_Street2__c, Garage_Zip__c= opp.Shipping_ZipCode2__c != null ? opp.Shipping_ZipCode2__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City2__c, Garage_State__c= opp.Shipping_State2__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone2__c, Email__c = opp.Shipping_email2__c);
                locsToCreate.add(loc);
                }
                if(opp.Shipping_Street3__c != null && opp.Shipping_Street3__c != ''  && !uniqGarAddress.contains(opp.Shipping_Street3__c)){
                loc = new Location__c(Name = opp.Shipping_Street3__c, OpportunityId__c = opp.Id, Garage_Address1__c= opp.Shipping_Street3__c, Garage_Zip__c= opp.Shipping_ZipCode3__c != null ? opp.Shipping_ZipCode3__c.substringbefore('-'): null, Garage_City__c= opp.Shipping_City3__c, Garage_State__c= opp.Shipping_State3__c, Customer__c= opp.AccountId, ContactName__c= opp.Shipping_Contact__c, ShipToInstaller__c= 'N', ShipMethod__c = ord.Shipping_Methods__c, Phone__c = opp.Shipping_phone3__c, Email__c = opp.Shipping_email3__c);
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
        
     
      
      if(ord != null){
        Database.insert(ord, true);
        oppOrdMap.put(opp.Id, ord);               
        
      }
      
      System.debug('locsToCreate::'+locsToCreate);
      if(locsToCreate.size() > 0){
        Database.SaveResult[] srLst = Database.insert(locsToCreate, false);
        
        if(srLst.size() > 0){                
          oppLocMap.put(loc.OpportunityId__c, locsToCreate);               
        }
      }
          
      if(oppOrdMap.size() > 0 && oppOrdMap.get(opp.Id) != null && oppLocMap.size() > 0 && oppLocMap.get(opp.Id) != null){
            for(Location__c lo : oppLocMap.get(opp.Id)){
               ordActLst.add(new OrderLocation__c(PO_Number__c = (opp.Case_Number__c != null && opp.Type == 'Exchange/RA') ? 'RA'+opp.Case_Number__c : opp.PO_Number__c, Orders__c = oppOrdMap.get(opp.Id).Id, Location__c = lo.Id, Ship_To_Installer__c = 'N'));
               
            }
            if(mapOpptyLineItems.get(opp.Id) != null){
                mapOrderLineItems.put(oppOrdMap.get(opp.Id).Id, mapOpptyLineItems.get(opp.Id));
            } 
            if(mapOpptyCPQProds.get(opp.Id) != null){
                mapOrderCPQProds.put(oppOrdMap.get(opp.Id).Id, mapOpptyCPQProds.get(opp.Id));
            }               
        }
   
     
      if(ordActLst.size() > 0){
       Database.saveResult[] savRes = Database.insert(ordActLst, true);
       
        if(savRes.size() > 0){
            for(OrderLocation__c ordL : ordActLst){
                
                if(mapOrderLineItems.get(ordL.Orders__c) != null){
                    List<OpportunityLineItem> olitems = mapOrderLineItems.get(ordL.Orders__c);
                    for(OpportunityLineItem oli :olitems){
                        if(oli.Category__c != 'Service'){
                        ordProdsToCreate.add(new Order_Product__c(Location__c = ordL.Location__c, Order_Details__c = ordL.Orders__c, OrderLocationMappings__c = ordL.Id, Order_Products__c = oli.Product2Id, Product_Code__c = oli.ProductCode, Product_Name__c = oli.Product2.Name, Quantity__c = oli.Quantity, Sales_Price__c = oli.UnitPrice));
                        }
                    }
                }
                if(mapOrderCPQProds.get(ordL.Orders__c) != null){
                    List<CPQ_Opportunity_Products__c> cpqlitems = mapOrderCPQProds.get(ordL.Orders__c);
                    for(CPQ_Opportunity_Products__c cpqli :cpqlitems){                      
                        if(cpqLi.Sale_Type__c == 'PURCHASE' && cpqLi.Product_Category__c != 'SERVICE' && cpqLi.Product_Category__c != 'SOLUTION' && cpqLi.Primary__c == true){
                        ordProdsToCreate.add(new Order_Product__c(Location__c = ordL.Location__c, Order_Details__c = ordL.Orders__c, OrderLocationMappings__c = ordL.Id, Order_Products__c = cpqli.Product_Record_Id__c, Product_Code__c = cpqli.Product_Record_Id__r.ProductCode ,Product_Name__c = (cpqli.Product_Record_Id__r.Name != null && cpqli.Product_Record_Id__r.Name.contains('*CPQ ONLY* DO NOT USE -')) ? cpqli.Product_Record_Id__r.Name.substring(24): cpqli.Product_Record_Id__r.Name, Quantity__c = cpqli.Pur_Qty__c, Sales_Price__c = cpqli.PUR_MRC_List__c));
                        }
                        else if( cpqLi.Sale_Type__c == 'BUNDLE' && cpqLi.Bundle_Kit_ID__c != null && cpqLi.Primary__c == true  && cpqli.Mismatch_Install__c == false){
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
      return (ord.Id);
     }catch(Exception ex){
        
        String err;
        if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
            err = ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
        }else{
            err = ex.getMessage();
        }
        
        
       return 'The Error : '+err;  
     }
         
    }

}