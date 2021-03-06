/*******************************************************************************
// Copyright (c) 2014 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Aravind Rajamanickam
// File Name:       OpportunitySearchController 
// Summary:         OpportunitySearchController  class for OrderTracking page
// Created On:      April-15-2015

// Modification Log:
====================

// Aravind    - 4/15/2015 - Create a base version 

*******************************************************************************/

public class OpportunitySearchController {

    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
    // the actual account
    private Order_Tracking__c a;
    // the results from the search. do not init the results or a blank rows show up initially on page load
    public List<opportunity> searchResults {get;set;}


    public string searchText {
        get {
          
            if (searchText == null) searchText = a.SF_Opp_ID__c; // prefill the search box for ease of use
            return searchText;
        }
        set;
    }

    public OpportunitySearchController(ApexPages.StandardController controller) {

        //initialize the stanrdard controller
        this.controller = controller;
        this.a = (Order_Tracking__c)controller.getRecord();
        search();
    }

    // fired when the search button is clicked
    public PageReference search() {
        if (searchResults == null) {
            searchResults = new List<opportunity>(); // init the list if it is null
        } else {
            searchResults.clear(); // clear out the current results if they exist
        }
      
        String qry = 'Select Id, Name, StageName, CloseDate, Amount from Opportunity Where Opty_ID__c LIKE \''+searchText+'%\' Order By Name';
        searchResults = Database.query(qry);
        return null;
    }

}