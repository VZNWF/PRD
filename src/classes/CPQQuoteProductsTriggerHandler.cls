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
// File Name:       CPQLineItemTriggerHelper 
// Summary:         Trigger Handler class for CPQ Line Item
// Created On:      FEB-9-2017

// Modification Log:
====================
//Satish    - 02/09/2017 - Created a base version of CPQLineItemTriggerHelper class 
*******************************************************************************/

public class CPQQuoteProductsTriggerHandler{

    public static void populateBundleKit(Map<Id, CPQ_Opportunity_Products__c> cpqLiMap, List<CPQ_Opportunity_Products__c> newCPQLI, Boolean isInsert){
        Set<String> quoteIds = new Set<String>();
        Map<String, List<CPQ_Opportunity_Products__c>> mapQuoteLineItem = new Map<String, List<CPQ_Opportunity_Products__c>>();
        String harness = '';
        String hw = '';
        String install = '000';
        string term = '';
        boolean addOpp = false;
        Map<String, String> quoteWprodType = new Map<String, String>();
        List<CPQ_Opportunity_Products__c> instProdsToUpdate = new List<CPQ_Opportunity_Products__c>();
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        
        List<CPQ_Opportunity_Products__c> cpqLIs = new List<CPQ_Opportunity_Products__c>();
                
        for(CPQ_Opportunity_Products__c cpqL : newCPQLI){
            Opportunity opp;
            addOpp = false;
            if(isInsert){   
              cpqL.Trigger_Time_05__c = Datetime.now().addMinutes(-58);
              
              }
              if(cpqL.Product_Category__c == 'INSTALL' || cpqL.Product_Category__c == 'ALL OTHER'){
              cpqL.CPQ_Product_Inserted__c = true;
              }
              if(cpqL.Product_Category__c == 'SERVICE' || cpqL.Product_Category__c == 'INSTALL'){
                  opp = new Opportunity(Id = cpqL.Opportunity_Record_ID__c, Software__c = 1);
                  addOpp = true;
              }
              if(cpqL.Product_Category__c == 'HARDWARE' || cpqL.Product_Category__c == 'HARNESS'|| cpqL.Product_Category__c == 'ALL OTHER'){
                  opp = new Opportunity(Id = cpqL.Opportunity_Record_ID__c, Hardware__c = 1);
                  addOpp = true;
              }
              
              if(addOpp){
                 oppMap.put(opp.Id, opp);
              }
             
            if(cpqL.CPQ_Product_Inserted__c){
              
              if((cpqL.Product_Category__c == 'SOLUTION' || cpqL.Product_Category__c == 'HARNESS') && cpqL.Sale_Type__c == 'BUNDLE'){
                  quoteIds.add(cpqL.CPQ_Quote_Record_ID__c );                 
                  cpqLIs.add(cpqL);
              }
              if((cpqL.Product_Category__c == 'ALL OTHER' && cpqL.Sale_Type__c == 'BUNDLE' && cpqL.SKU__c != 'PARTS054') || (cpqL.Product_Category__c == 'INSTALL' && cpqL.Sale_Type__c == 'BUNDLE' && !cpqL.SKU__c.contains('D-INSTALL-UNIT'))){
                cpqL.Bundle_Kit_ID__c = cpqL.SKU__c;
              }
              if(cpqL.Product_Category__c == 'ALL OTHER' && cpqL.Sale_Type__c == 'BUNDLE' && cpqL.SKU__c  == 'PARTS054'){
                cpqL.Bundle_Kit_ID__c = 'D-CON-054-000 ';
                }
            }
        }
        
        if(quoteIds.size() > 0){
            for(CPQ_SOMAST__c quo : [Select Id, (Select Id, Name, SKU__c, Product_Category__c, SEQ__c, CPQ_Quote_Record_ID__c, BUN_Qty__c From CPQ_Quote_Products__r where SEQ__c != null Order By SEQ__c asc) From CPQ_SOMAST__c where Id IN : quoteIds]){
                if(quo.CPQ_Quote_Products__r.size() > 0){
                    
                    for(CPQ_Opportunity_Products__c cpqL : quo.CPQ_Quote_Products__r){
                        mapQuoteLineItem.put(quo.Id + cpqL.SKU__c, quo.CPQ_Quote_Products__r);
                         if(cpqL.Product_Category__c == 'HARNESS'){
                          quoteWprodType.put(cpqL.CPQ_Quote_Record_ID__c + cpqL.SKU__c, cpqL.Product_Category__c);
                         }
                         if(cpqL.Product_Category__c == 'INSTALL' && cpqL.SKU__c.contains('D-INSTALL-UNIT')){
                            install = 'INS';
                         }
                    }
                }
            }
        }
        
        System.debug('mapQuoteLineItem:::'+mapQuoteLineItem);
        
        if(mapQuoteLineItem.size() > 0){
            Set<String> uniqueLis = new Set<String>();
            for(CPQ_Opportunity_Products__c cpqL : cpqLIs){
                 harness = '000';
                 hw = '000000';
                 Boolean harnessExist = false;
                 Boolean mismatch = false;
                 decimal solBunQty;
                 install = '000';
                 
                 //term = cpqL.BUN_MRC_Term__c != null ? cpqL.BUN_MRC_Term__c.substring(0,2) : null;
                 if(cpqL.BUN_MRC_Term__c != null && cpqL.BUN_MRC_Term__c == 'N/A'){
                    term = '36';
                 }else{
                    term = cpqL.BUN_MRC_Term__c.substring(0,2);
                 }
                 if(cpqL.SEQ__c != null && ((quoteWprodType.containsKey(cpqL.CPQ_Quote_Record_ID__c+ cpqL.SKU__c) && cpqL.Product_Category__c == 'HARNESS')
                                        || (!quoteWprodType.containsKey(cpqL.CPQ_Quote_Record_ID__c + cpqL.SKU__c) && cpqL.Product_Category__c == 'SOLUTION' ))){
                 String seq = cpqL.SEQ__c.substring(0,1) + '.';
                    if(mapQuoteLineItem.get(cpqL.CPQ_Quote_Record_ID__c+ cpqL.SKU__c) != null && mapQuoteLineItem.get(cpqL.CPQ_Quote_Record_ID__c + cpqL.SKU__c).size() > 0){
                        for(CPQ_Opportunity_Products__c li : mapQuoteLineItem.get(cpqL.CPQ_Quote_Record_ID__c+ cpqL.SKU__c)){
                            System.debug('li::'+li);
                            if(li.Product_Category__c == 'SOLUTION'){
                                    solBunQty = li.BUN_QTY__c;
                            }
                            if(li.SEQ__c.contains(seq )){
                                if(li.Product_Category__c == 'HARDWARE'){
                                    hw = li.SKU__c.substring(0,5) + li.SKU__c.substring(6,7);
                                }
                                
                                if(li.Product_Category__c == 'HARNESS'){
                                if(cpqL.Id == li.Id){
                                harness = li.SKU__c.right(3);
                                }
                                harnessExist = true;
                                }
                                
                                System.debug('Category::'+cpqL.Product_Category__c);
                                if(li.Product_Category__c == 'INSTALL' && li.SKU__c.contains('D-INSTALL-UNIT')){
                                    if(solBunQty != null && solBunQty != li.BUN_Qty__c){
                                        mismatch = true;
                                        li.Mismatch_Install__c = true;
                                        install = '000';
                                    }else{
                                     install = 'INS';
                                    }
                                }
        
                            }                           

                           // li.Bundle_Kit_ID__c = 'D-'+hw+'-'+harness+'-'+term+'-'+install;
                            if(!uniquelis.contains(li.Id)){
                            instProdsToUpdate.add(li);
                            //System.debug('BundleId::'+li.Bundle_Kit_Id__c);
                            uniqueLis.add(li.Id);
                            }
                            
                        }
                        System.debug('harness::'+harnessExist +'  cpqL.Product_Category__c:::'+cpqL.Product_Category__c);
                        if((cpqL.Product_Category__c == 'SOLUTION' && !harnessExist ) || (cpqL.Product_Category__c == 'HARNESS' && harnessExist)){
                        cpql.Bundle_Kit_ID__c = 'D-'+hw+'-'+harness+'-'+term+'-'+install;
                        System.debug('mismatch::'+mismatch);
                            if(mismatch){
                                cpqL.Mismatch_Install__c = true;
                            }
                        }
                    }
                    
                 }   
            }
            if(instProdsToUpdate.size() > 0){
                Database.update(instProdsToUpdate, false);
            }
        }
        
        if(oppMap.size() > 0){
        
        Database.update(oppMap.values(), false);
        }
    }
    
    
     /*public static void handleAfterDelete(List<CPQ_Opportunity_Products__c> quoteLis){
        Set<String> oppIds = new Set<String>(); 
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(CPQ_Opportunity_Products__c qli : quoteLis){
            if(qli.Opportunity_Record_ID__c != null){
                oppIds.add(qli.Opportunity_Record_ID__c);
            }        
        }
        
        for(Opportunity opp : [Select Id, Hardware__c, Software__c, 
                                (Select Id, Product_Category__c From CPQ_Quote_Products__r where Product_Category__c IN ('HARDWARE','HARNESS','INSTALL','SERVICE')) 
                                from Opportunity where Id IN : oppIds]){
            opp.Hardware__c = 0;
            opp.Software__c = 0;
            System.debug('opp::'+opp);
            if(opp.CPQ_Quote_Products__r.size() > 0){
                for(CPQ_Opportunity_Products__c cpqLi : opp.CPQ_Quote_Products__r){
                    if(cpqLi.Product_Category__c == 'HARDWARE' || cpqLi.Product_Category__c == 'HARNESS'){
                        opp.Hardware__c = 1;
                    }
                    if(cpqLi.Product_Category__c == 'INSTALL' || cpqLi.Product_Category__c == 'SERVICE'){
                        opp.Software__c = 1;
                    }
                }
            }
            oppList.add(opp);    
        }
        
        System.debug('oppList::'+oppList);
        if(oppList.size() > 0){
            Database.update(oppList, true);
        }
    }*/

}