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
// File Name:       RALogDetailController
// Summary:         Controller class for RALogDetails Visualforce Component
// Created On:      Aug-14-2017

// Modification Log:
====================

// Satish    - 08/14/2017 - Create a base version of RALogDetailController class 
*******************************************************************************/

global class RALogDetailController {

global String raLogId{get; set;}

global List<RA_Log_Detail__c> getRALogDetails(){
    if(raLogId != null){
    
     System.debug('raLogId::'+raLogId);
     List<RA_Log_Detail__c> ralogDet = [Select Id, Unit_Type_Needed__c, Quantity__c,Serial_Number__c,RA_Location__r.Garage_Address1__c,RA_Location__r.Garage_City__c,RA_Location__r.ContactName__c, RA_Location__r.Ship_Company__c,RA_Location__r.Garage_State__c,RA_Location__r.Garage_Zip__c,RA_Log_Id__r.Case__r.Contact.Name,RA_Log_Id__r.Case__r.CaseNumber from RA_Log_Detail__c where RA_Log_Id__c =:raLogId];
     return raLogDet;    
    }
    
    return null;
}


}