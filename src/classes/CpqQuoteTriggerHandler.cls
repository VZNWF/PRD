/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Vasanth Parvatagiri
// File Name:       CpqQuoteTriggerHandler 
// Summary:         Trigger Handler class for marking CPQ Quote as Primary
// Created On:      July-6-2016

// Modification Log:
====================

// Vasanth   - 7/6/2016 - Create a base version of CpqQuoteTriggerHandler class 

*******************************************************************************/

public with sharing class CpqQuoteTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public CpqQuoteTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeDelete(list<CPQ_SOMAST__c> oldRecords){
        Set<ID> cpqOppIDS = new Set<ID>();
        list<CPQ_SOMAST__c> cpqSomastList = new list<CPQ_SOMAST__c>();
        for(CPQ_SOMAST__c cpq : oldRecords)
        {
            if(cpq.Primary__c == true)
            {
                cpqOppIDS.add(cpq.Opportunity__c);
            }
        }
        if(cpqOppIDS != null && !cpqOppIDS.isEmpty())
        {
            try
            {
                list<CPQ_SOMAST__c> cpqToPrimary = [SELECT id,NAme,Additional_Shipping_Address_Line1__c,
                                              Shipping_Country__c,Shipping_State__c,Shipping_Zip_Code__c,Shipping_City__c,Primary__c FROM CPQ_SOMAST__c WHERE 
                                              Opportunity__c IN: cpqOppIDS AND Primary__c != true ORDER BY CreatedDate ASC LIMIT 1];
                for(CPQ_SOMAST__c cpqs:cpqToPrimary){
                cpqs.Primary__c = true;
                cpqSomastList.add(cpqs);           
                }
                update cpqSomastList;
            }
            catch(Exception e)
            {
                System.Debug('Exception::'+e.getMessage());
            }
        }    
    }
 
}