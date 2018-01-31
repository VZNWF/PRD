public with sharing class CreateChildOpportunityController {
    public Boolean IsOnGpHold {get; private set;}

    //Querystring values from the current page will be saved here because
    //querystring values are cleared from the URL when a user does a traditional postback,
    //so we need to persist these values as soon as we hit this page
    public Map<String, String> SavedParametersMap {
        
        get {
            
            if(this.SavedParametersMap == null) {
                
                this.SavedParametersMap = new Map<String, String>();
            }
            
            return this.SavedParametersMap;
        }
        set;
    }
    
    //Parent Opportunities that user can select
    public List<Opportunity> ParentOpportunitiesList { 
        
        get {
            
            if(this.ParentOpportunitiesList == null) {
                
                this.ParentOpportunitiesList = new List<Opportunity>();
            }
            
            return this.ParentOpportunitiesList;
        }
        set;
    }
    
    //Empty Opportunity object whose only purpose is to help us get the Account Filter look up
    //on the associated Visualforce page
    public Opportunity NewOpportunity {
        
        get {
            
            if(this.NewOpportunity == null) {
                
                this.NewOpportunity = new Opportunity();
            }
            
            return this.NewOpportunity;
        }
        set; 
    }
    
    //Querystring key values that should be excluded in any future URL construction
    public Set<String> ExcludeKeysSet {
        
        get {
            
            if(this.ExcludeKeysSet == null) {
                
                this.ExcludeKeysSet = new Set<String>();
                
                this.ExcludeKeysSet.add('save_new');
                this.ExcludeKeysSet.add('sfdc.override');
            }
            
            return this.ExcludeKeysSet;
        }
        set;
    }
    
    public String AccountId { get; set; }
    
    public Boolean MatchesFound { get; private set; }
    
    public String SelectedOpportunityId { get; set; }
    
    public CreateChildOpportunityController(ApexPages.StandardController controller) {
    
        this.SavedParametersMap = ApexPages.currentPage().getParameters();
        
        this.NewOpportunity.AccountId = null;
        
        this.MatchesFound = false;
    }
    
    //Checks to see if a String is null or have a length of zero
    private Boolean IsStringEmpty(String input) {
        
        return (input == null || input.length() == 0);
    }
    
    //Converts an object to a String if it is not a null; otherwise, return a blank string 
    private String MakeStringConvertSafe(Object input) {
        
        return (input != null) ? String.valueOf(input) : ''; 
    }
    
    //Appends data to an existing String separated by a specified delimiter
    private String BuildDelimitedString(String baseInput, String newInput, String delimiter) {
        
        if(baseInput.length() == 0) {
                
            baseInput = newInput;
        }
        else {
                
            baseInput += delimiter + newInput;
        }
        
        return baseInput;       
    }
    
    //Build a querystring based on existing Map, while excluding specified values
    private void GenerateQueryString(PageReference pageRef, Map<String, String> parametersMap, Set<String> excludeKeysSet) {
        
        Map<String, String> newParametersMap = pageRef.getParameters();
    
        for(String paramKey : parametersMap.keySet()) {
            
            if(!excludeKeysSet.contains(paramKey)) {
            
                newParametersMap.put(paramKey, parametersMap.get(paramKey));
                system.debug('@@@@@@@@The new parameter map:'+newParametersMap);
            }
        }
    }
    
    //Redirect to Opportunity Edit Page or stay on custom Visualforce page based on the RecordType specified in querystring
    public PageReference RedirectBasedOnRecordType() {
        
        PageReference pageRef = null;
        Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        
        if(ApexPages.currentPage().getParameters().get('RecordType') != csoRecordTypeId) {
            system.debug('@@@@@@@Inside the if block of RedirectBasedOnRecordType');
            pageRef = new PageReference('/' + Opportunity.sObjectType.getDescribe().getKeyPrefix() + '/e');
            
            pageRef.getParameters().put('nooverride', '1');
            system.debug('@@@@@@@Inside the if block of RedirectBasedOnRecordType'+pageRef);
            
            this.GenerateQueryString(pageRef, ApexPages.currentPage().getParameters(), this.ExcludeKeysSet);
        }
    
        
        return pageRef;
    }
    
    //Filters Opportunities based on AccountId and non-child Opportunity status
    public PageReference FilterOpportunitiesByAccount() {
        
        //If AccountId is empty the clear everything
        if(this.IsStringEmpty(this.AccountId)) {
        
            this.ParentOpportunitiesList = null;
            
            this.SelectedOpportunityId = '';    
        }
        else {
            List<Account> accountList = [SELECT GP_Account_Hold__c FROM Account 
            WHERE id = : this.AccountId ];
            if(accountList.size() > 0){
                this.IsOnGpHold = accountList[0].GP_Account_Hold__c ;
            }
            
            List<OpportunityStage> oppStageList = [SELECT Id, MasterLabel FROM OpportunityStage
                        WHERE IsWon = false
                        AND IsClosed = true];
            Set<String> oppStageLabelSet = new Set<String>();
            Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
            Id closedOppRecordTypeId = CSUtils.getRecordTypeId('Opportunity','Closed Opp Record Type');
            
            for(OpportunityStage oppStage : oppStageList) {
                
                oppStageLabelSet.add(oppStage.MasterLabel);
            }
            
            
            //Have AccountId so query Opportunities
            this.ParentOpportunitiesList = [SELECT Id, Name, OwnerId, Owner.FirstName, Owner.LastName, Account.AccountNumber, StageName, CloseDate, Unit_Total__c, Unit_Total_All_Opps__c FROM Opportunity 
                                                WHERE AccountId = :this.AccountId
                                                AND Parent_Opportunity__c = null
                                                AND RecordTypeId != :csoRecordTypeId
                                                AND RecordTypeId != :closedOppRecordTypeId
                                                AND StageName NOT IN :oppStageLabelSet];
            
            if(this.ParentOpportunitiesList.size() > 0) {
                
                this.SelectedOpportunityId = '';
                
                //Find first Opportunity owned by current User and mark it as selected by default
                for(Opportunity opp : this.ParentOpportunitiesList) {
                
                    if(opp.OwnerId == UserInfo.getUserId()) {
                    
                        this.SelectedOpportunityId = this.ParentOpportunitiesList[0].Id;
                        break;
                    }
                }
            }
            else {
                
                //Could not find Opportunity owned by current User so do not mark anything
                this.SelectedOpportunityId = '';
            }
        }
        //Flag need for Visualforce panel rendering
        this.MatchesFound = (this.ParentOpportunitiesList.size() > 0);
    
        return null;
    }
    
    //Take selected opportunity and use its values in construction of a url that will be used to
    //redirect to Opportunity Edit page
    public PageReference Save() {

    
        Map<String, String> parametersMap = null;
        Map<String, String> fieldNamesMap = null;
        List<SObject> parentOppsList = null;
        List<Custom_Field_Settings__c> customFieldSettingsList = null;
        SObject parentOpp = null;
        Id selectedOppId = null;
        Id csoRecordTypeId = null;  
        PageReference pageRef = null;
        String fieldId = '';
        String fieldCriteria = '';
        String fieldValue = ''; 
        Boolean isValid = true;

        //Make sure user selects AccountId to filter on and Opportunity to set as Parent
        if(this.IsStringEmpty(this.AccountId)) {
        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please click the magnifying glass icon to select an account..'));
            isValid = false;
        }   
        else if(this.IsStringEmpty(this.SelectedOpportunityId)) {
        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a Sales Opportunity.'));
            isValid = false;
        }

        
        if(!isValid) {
            
            return null;
        }
        
        //Create a map that we can use to give literal values to field Ids on the Opportunity Edit page;
        //equally important, construct a SOQL query to get fresh values of the selected Parent Opportunity

        //LAB 5/5/15 in order to get fields added here to show up, run SaveFields.page to repopulate Custom_Field_Settings__c with all new custom fields
        
        fieldNamesMap = new Map<String, String>();
        
        fieldNamesMap.put('Name','');
        fieldNamesMap.put('AccountId', 'opp4_lkid');
        fieldNamesMap.put('Related_Reseller__c', '');
        fieldNamesMap.put('LeadSource', 'opp6');
        fieldNamesMap.put('Lead_Source_Detail__c','');
        fieldNamesMap.put('Specific_Lead_Source__c', '');
        fieldNamesMap.put('Partner_ID__c','');
        fieldNamesMap.put('CCI_ID__c','');
        fieldNamesMap.put('Affiliate_Lead_ID__c', '');
        fieldNamesMap.put('Affiliate_Sales_ID__c', '');
        fieldNamesMap.put('Affiliate_Sales_Name__c', '');
        fieldNamesMap.put('Affiliate_Sales_Name_2__c','');
        fieldNamesMap.put('Affiliate_Sales_Email__c', '');
        fieldNamesMap.put('Affiliate_Sales_Email_2__c','');
        fieldNamesMap.put('Affiliate_Sales_Phone__c', '');
        fieldNamesMap.put('Affiliate_Sales_Phone_2__c','');
        fieldNamesMap.put('Affiliate_Region__c', '');
        fieldNamesMap.put('Affiliate_Area__c','');
        fieldNamesMap.put('Parent_Opportunity__c', '');
        fieldNamesMap.put('SOS_Email__c', '');
        fieldNamesMap.put('CampaignId', 'opp17_lkid');
        fieldNamesMap.put('Type', 'opp5');
        fieldNamesMap.put('StageName', 'opp11');
        fieldNamesMap.put('SCC_Lead_Program__c', '');
        fieldNamesMap.put('Channel__c','');
        fieldNamesMap.put('Lead_Direction__c','');
        fieldNamesMap.put('LinkedIn__c','');
        fieldNamesMap.put('Request_Credit_Terms__c','');
        

        
        customFieldSettingsList = [SELECT Id, Name, Id__c, Table_Enum_Or_Id__c, Field_Name__c FROM Custom_Field_Settings__c
                                        WHERE Table_Enum_Or_Id__c = 'Opportunity'
                                        AND Field_Name__c IN :fieldNamesMap.keySet()];
    

        for(Custom_Field_Settings__c cfs : customFieldSettingsList) {
            
            if(fieldNamesMap.containsKey(cfs.Field_Name__c)) {
                
                fieldNamesMap.put(cfs.Field_Name__c, cfs.Id__c);
            }
        }
        
        //Construct field criteria string to later be used in SOQL query
        for(String fieldName : fieldNamesMap.keySet()) {
            
            fieldCriteria = this.BuildDelimitedString(fieldCriteria, fieldName, ',');
        }
        
        fieldCriteria = this.BuildDelimitedString(fieldCriteria, 'Related_Reseller__r.Name', ',');
        fieldCriteria = this.BuildDelimitedString(fieldCriteria, 'Campaign.Name', ',');
        
        selectedOppId = this.SelectedOpportunityId;
        
        csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        
        //Query selected Parent Opportunity, while at the same time ensure that selected Opportunity
        //is still a Parent
        parentOppsList = Database.query('SELECT ' + fieldCriteria + ' FROM Opportunity WHERE Id = :selectedOppId AND Parent_Opportunity__c = null AND RecordTypeId != :csoRecordTypeId');
        
        if(parentOppsList.size() > 0) {
            
            parentOpp = parentOppsList[0];
        } 
        
        //Selected Parent Opportunity could not be found
        if(parentOpp == null) {
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not find the selected Parent Opportunity.'));
            isValid = false;
        }

        if(!isValid) {
            
            return null;
        }
            
        pageRef = new PageReference('/' + Opportunity.sObjectType.getDescribe().getKeyPrefix() + '/e');
        
        pageRef.getParameters().put('nooverride', '1');
        
        //Parent Opportunity Fields
        
        fieldId = fieldNamesMap.get('Parent_Opportunity__c');
        
        fieldId = 'CF' + fieldId;
        
        pageRef.getParameters().put(fieldId, this.MakeStringConvertSafe(parentOpp.get('Name'))); //Name
        pageRef.getParameters().put(fieldId + '_lkid', selectedOppId); //Id

        //Related Reseller Fields
        
        if(parentOpp.getSObject('Related_Reseller__r') != null) {
        
            fieldId = fieldNamesMap.get('Related_Reseller__c');
            
            fieldId = 'CF' + fieldId;
            
            pageRef.getParameters().put(fieldId, this.MakeStringConvertSafe(parentOpp.getSObject('Related_Reseller__r').get('Name'))); //Name
            pageRef.getParameters().put(fieldId + '_lkid', this.MakeStringConvertSafe(parentOpp.get('Related_Reseller__c'))); //Id      
        }
        
        //Campaign Fields
        
        if(parentOpp.getSObject('Campaign') != null) {
        
            pageRef.getParameters().put('opp17', this.MakeStringConvertSafe(parentOpp.getSObject('Campaign').get('Name'))); //Name
            pageRef.getParameters().put('opp17_lkid', this.MakeStringConvertSafe(parentOpp.get('CampaignId'))); //Id            
        }
        
        //Generate querystring based on existing querystring on current page
        this.GenerateQueryString(pageRef, this.SavedParametersMap, this.ExcludeKeysSet);
        
        parametersMap = pageRef.getParameters();
        
        //Append selected Parent Opportunity values to querystring
        for(String fieldName : fieldNamesMap.keySet()) {
            if(fieldName == 'Type') {
                
                fieldValue = 'Existing Business';   
            }
            else if(fieldName == 'StageName') {
                
                fieldValue = 'Initial Meeting / Demo';   
            } else if(fieldName == 'Request_Credit_Terms__c'){
                  fieldValue = this.MakestringConvertSafe(parentOpp.get('Request_Credit_Terms__c'));
                   if(fieldValue == 'true'){
                       fieldValue = '1';
                   } else {
                       fieldValue = '0';
            }
            }
            else if(fieldName != 'Related_Reseller__c' && fieldName != 'CampaignId') {
                
                fieldValue = this.MakeStringConvertSafe(parentOpp.get(fieldName));
            } else {
                
                fieldValue = '';
            }
            
            if(!this.IsStringEmpty(fieldValue)) {
                parametersMap.put(fieldNamesMap.get(fieldName), fieldValue);
            }
        }
        
        return pageRef;
    }
    
    public PageReference Cancel() {
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));       
        
        return pageRef;
    }
    
    
}