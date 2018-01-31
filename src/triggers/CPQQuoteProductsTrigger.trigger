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
// File Name:       CPQLineItemTrigger 
// Summary:         Trigger for CPQ Line Item
// Created On:      FEB-9-2017

// Modification Log:
====================
//Satish    - 02/09/2017 - Created a base version of CPQLineItemTrigger class 
*******************************************************************************/



trigger CPQQuoteProductsTrigger on CPQ_Opportunity_Products__c (before insert, before update) {

    if(Trigger.isbefore && Trigger.isInsert){
        CPQQuoteProductsTriggerHandler.populateBundleKit(Trigger.newMap, Trigger.new, Trigger.isInsert);
    }
    
    if(Trigger.isbefore && Trigger.isUpdate){
        CPQQuoteProductsTriggerHandler.populateBundleKit(Trigger.newMap, Trigger.new, Trigger.isInsert);
    }
}