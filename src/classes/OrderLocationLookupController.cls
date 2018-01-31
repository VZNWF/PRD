public with sharing class OrderLocationLookupController {

  String ordId;   
  String locAcctId;
  String oppId;
  Orders__c ordObj = new Orders__c();    
  public Location__c loc {get;set;} // new location to create
  public List<Location__c> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  Map<String, Location__c> garLocMap = new Map<String, Location__c>();
  
  
  public OrderLocationLookupController() {
    loc = new Location__c();
    results = new List<Location__c>();
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    if(System.currentPageReference().getParameters().get('ordId') != null){
    ordId = System.currentPageReference().getParameters().get('ordId');   
    ordObj = [Select Id, Account__c, Opportunity__c from Orders__c where Id =: ordId];
    locAcctId = ordObj.Account__c;
    oppId = ordObj.Opportunity__c;
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
    results = performSearch(searchString);  
    
    for(Location__c loc : results){
        garLocMap.put(loc.Garage_Address1__c, loc); 
    }
      
    if(garLocMap.size() > 0){
        results = garLocMap.values();
    }             
  } 
  
  // run the search and return the records found. 
  public List<Location__c> performSearch(string searchString) {
    
   
    String soql = 'select id, name, Garage_Address1__c from Location__c Where Customer__c =:locAcctId';
    
    if(searchString != '' && searchString != null)
      soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';
    soql = soql + ' limit 25';
    System.debug(soql);
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