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
// File Name:       RALocationLookupController
// Summary:         Controller class for RALocationLookup
// Created On:      Aug-01-2017

// Modification Log:
====================

// Satish    - 08/01/2017 - Create a base version of RALocationLookupController class 
*******************************************************************************/
public with sharing class RALocationLookupController {

  String raId;   
  String locAcctId;
  String oppId;
  RA_Log__c raLogObj = new RA_Log__c();    
  public Location__c loc {get;set;} // new location to create
  public List<Location__c> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  Map<String, Location__c> garLocMap = new Map<String, Location__c>();
  
  
  public RALocationLookupController() {
    loc = new Location__c();
    results = new List<Location__c>();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    if(System.currentPageReference().getParameters().get('raId') != null){
    raId = System.currentPageReference().getParameters().get('raId');   
    raLogObj = [Select Id, RA_Type__c, RA_Location__c,Case__r.Fleet_Account__c from RA_Log__c where Id =: raId Order By CreatedDate desc];
    locAcctId = raLogObj.Case__r.Fleet_Account__c;
    //oppId = ordObj.Opportunity__c;
    runSearch(); 
    } 
  }
   
  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }
  
  // prepare the query and issue the search command
  public void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results.clear();
    garLocMap.clear();
    
    System.debug('searchString::'+searchString);
    results = performSearch(searchString);  
    
    for(Location__c loc : results){
        garLocMap.put(loc.Garage_Address1__c, loc); 
    }
      
    if(garLocMap.size() > 0){
        results = garLocMap.values();
    } 
    System.debug('results::'+results);            
  } 
  
  // run the search and return the records found. 
  public List<Location__c> performSearch(string searchString) {
    
   
    String soql = 'select id, name, Garage_Address1__c from Location__c Where Customer__c =:locAcctId';
    
    if(searchString != '' && searchString != null)
      soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';
    soql = soql + ' Order By CreatedDate Desc limit 50';
    System.debug('soql::'+soql);
    return database.query(soql); 

  }
  
  // save the new account record
  public PageReference saveLocation() {
      
    if(garLocMap.size() > 0 && garLocMap.containsKey(loc.Garage_Address1__c)){
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Location already exists. You cannot create Location'));
    return null;
    }  
    try{
    if(loc.Name == '' || loc.Name == null){
        loc.Name = loc.Garage_Address1__c;
    }
    loc.OpportunityId__c = oppId;
    insert loc;
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Location record created successfully. Please navigate to Search tab to associate'));
     // reset the account
    loc = new Location__c();
    runSearch();
    }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,ex.getMessage()));
    }
   
    return null;
  }
  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }
    
  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }
  
  public PageReference refreshTab(){      
      loc = new Location__c(Garage_Country__c = 'USA',customer__c = locAcctId);
      return null;
  }
 
}