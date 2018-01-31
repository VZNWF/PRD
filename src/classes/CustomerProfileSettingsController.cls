/*
    Name: CustomerProfileSettingsController
    Test Class : CustomerProfileSettingsControllerTest
    Description:  This is the controller class of the Customer Profile Settings page.
    Visualforce page: CustomerProfileSettings.vfp
    Modification History:
    Author      Jira                Date        Description

        
*/

public with sharing class CustomerProfileSettingsController {
    //Member Variables
    public Map<String,List<String>> caseReasonSubReasonMap{get;set;}
    public String reason{get;set;}
    public List<SelectOption> caseReasonList {get; set;}
    public List<SelectOption> availableSubReasonList {get; set;}
    public List<SelectOption> selectedSubReasonList {get; set;}
    public ReasonWrapperClass reasonWrapperObj {get; set;}
    public String editMapKey {get; set;}
    public boolean displayPopUp {get; set;}
    private String userAction;
    public boolean hasKeyFlag {get; set;}
    public String errorTitle {get; set;}
    public String errorSummary {get; set;}
    //Wrapper class object
    public CustomerProfileConfig custProfConfig {get; set;}

    //getter method 1
    private Set<String> getSelectOptionsInStringSet(){
        Set<String> selectedSubReasonSet = new Set<String>();
        if(selectedSubReasonList!=null && selectedSubReasonList.size()>0){
            for(SelectOption s :selectedSubReasonList){
                selectedSubReasonSet.add(s.getvalue());
          }
        }
        return selectedSubReasonSet;
    }
    //getter method 2
    public List<SelectOption> getCategoryValues(){
        List<SelectOption> buckValList = new List<SelectOption>();
        buckValList.add(new SelectOption('None', 'None'));
        buckValList.add(new SelectOption('Product', 'Product'));
        buckValList.add(new SelectOption('Billing & Finance', 'Billing & Finance'));
        buckValList.add(new SelectOption('Service & Support', 'Service & Support'));
        return buckValList;
    }
    //getter method 3
    public List<SelectOption> getTimeFrameValues(){
        List<SelectOption> timeFrameList = new List<SelectOption>();
        timeFrameList.add(new SelectOption('0', 'None'));
        timeFrameList.add(new SelectOption('365', 'Last 365 days'));
        timeFrameList.add(new SelectOption('183', 'Last 183 days'));
        return timeFrameList;
    }

    //Wrapper Class 1
    public class ReasonWrapperClass
    {
        public String caseReason {get; set;}
        public Set<String> selectedSubReasonSet{get; set;}
        public String categoryBucket {get; set;}
        public Integer timeFrame {get; set;}
        //Wrapper constructor
        public ReasonWrapperClass(){
            selectedSubReasonSet = new Set<String>();
            caseReason = 'None';
            categoryBucket = 'None';
            timeFrame = 0;
        }
    }
    
    //Wrapper Class 2: Custom Profile Settings Wrapper Class
    public class CustomerProfileConfig{
        //public Customer_Profile_Config__mdt cPC {get; set;}
        public Customer_Profile_Settings__c cPSettings {get; set;}
        //public Customer_Profile_Configuration__c cpcSettings {get; set;}
        public Map<String, ReasonWrapperClass> caseReasonMap;
        public List<ReasonWrapperClass> rWCList {get; set;}
        
        //Constructor
        public CustomerProfileConfig(){
            cPSettings = new Customer_Profile_Settings__c();
            //Get the fields API names from Customer_Profile_Settings__c object
            Map <String, Schema.SObjectField> fieldMap = Customer_Profile_Settings__c.sObjectType.getDescribe().fields.getMap();
            rWCList = new List<ReasonWrapperClass>();
            String fieldNameString = '';
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                fieldNameString += (dfield.getname() + ',');
            }
            
            fieldNameString = fieldNameString.removeEnd(',');
			//Query the Customer Profile Setting active record
            String queryString = 'Select '+fieldNameString+' from Customer_Profile_Settings__c where Is_Active__c = true LIMIT 1';
            List<Customer_Profile_Settings__c> cPSettingsTemp = database.query(queryString);
            
            cPSettings = cPSettingsTemp.size()>0?cPSettingsTemp[0]:cPSettings;
            
            if(cPSettings != null){
                caseReasonMap = new Map<String, ReasonWrapperClass>();
                caseReasonMap = getCustomSettingDetails();
            }
            
        }
        
        //Method to deserialise the settings in the string format into a Map collection
        public Map<String, ReasonWrapperClass> getCustomSettingDetails(){

            String savedJSONString = '';
            
            savedJSONString += (cPSettings.zCase_Reason_SubReason_String1__c != null?cPSettings.zCase_Reason_SubReason_String1__c:'');
            savedJSONString += (cPSettings.zCase_Reason_SubReason_String2__c != null?cPSettings.zCase_Reason_SubReason_String2__c:'');
            savedJSONString += (cPSettings.zCase_Reason_SubReason_String3__c != null?cPSettings.zCase_Reason_SubReason_String3__c:'');
            system.debug('rWCList=======----------'+rWCList);
            if(savedJSONString!=''){
                rWCList = (List<ReasonWrapperClass>)JSON.deserialize(savedJSONString, List<ReasonWrapperClass>.class);
            }
            system.debug('rWCList=======----------'+rWCList);
            Map<String, ReasonWrapperClass> tempCaseReasonMap = new Map<String, ReasonWrapperClass>();
            for(ReasonWrapperClass rWC: rWCList){
                tempCaseReasonMap.put(rWC.caseReason+'_'+rWC.timeFrame+'_'+rWC.categoryBucket, rWC);
            }
            
            return tempCaseReasonMap;
        } 
        
    }
    
    //Constructor
    public CustomerProfileSettingsController(ApexPages.StandardController controller){
        displayPopUp = false;
        userAction = '';
        hasKeyFlag = false;

        reasonWrapperObj = new ReasonWrapperClass();
        init();
        System.debug(availableSubReasonList);   
    }
    
    //Init method
    private void init(){
        caseReasonList = new List<SelectOption>();
        caseReasonSubReasonMap=new Map<String,List<String>>();
        reason = 'None';
        custProfConfig = new CustomerProfileConfig();
        caseReasonSubReasonMap=DependentOptions.GetDependentOptions('Case', 'Reason','Case_Sub_Reason__c');
        caseReasonList.add(new SelectOption('None', 'None'));
        for(String cReason: caseReasonSubReasonMap.keySet()){
            caseReasonList.add(new SelectOption(cReason, cReason));
        }
        fetchSubReasons();
    }
    
    //Method to fetch the Case Sub-Reasons based on the Case reason
    public void fetchSubReasons(){
        availableSubReasonList = new List<SelectOption>();
        selectedSubReasonList = new List<SelectOption>();
        if(reason!='None' ){
            List<String> s1 = caseReasonSubReasonMap.get(reason);
            for(String s2: s1){
                availableSubReasonList.add(new SelectOption(s2,s2));
            }
        }              
    }
	
	//Method to save the Case Reason Criteria
    public void saveRow(){
        system.debug(userAction);
        system.debug(editMapKey);
        system.debug(custProfConfig.caseReasonMap.containsKey(editMapKey));
        //Check if the case reason is a duplicate
        if(userAction == 'New' && custProfConfig.caseReasonMap.containsKey(reason+'_'+reasonWrapperObj.TimeFrame+'_'+reasonWrapperObj.categoryBucket)){
            hasKeyFlag = true;
            errorTitle = 'Duplicate Case Reason.';
            errorSummary = 'The following Case Reason with same Time Frame and Category exists. Please edit the existing Case Reason instead.';
        }else if(reason == 'None' || selectedSubReasonList.isEmpty() || reasonWrapperObj.timeFrame == 0 || reasonWrapperObj.categoryBucket == 'None'){
            //Check if any of the fields - Case Reason, Sub-Reason, Timeframe or Category are blank in the form
            hasKeyFlag = true;
            errorTitle = 'Missing Information.';
            errorSummary = '';
            errorSummary += reason == 'None'?' \'Case Reason\',':'';
            errorSummary += selectedSubReasonList.isEmpty()?' \'Case Sub-Reasons\',':'';
            errorSummary += reasonWrapperObj.timeFrame == 0?' \'Timeframe\',':'';
            errorSummary += reasonWrapperObj.categoryBucket == 'None'?' \'categoryBucket\',':'';
            errorSummary = errorSummary.removeEnd(',');
            errorSummary += (errorSummary.countMatches(',') > 0?' are':' is')+' required.';
        }else{
        	//Edit scenario
            ReasonWrapperClass h = new ReasonWrapperClass();
            h.caseReason = reason;
            h.categoryBucket = reasonWrapperObj.categoryBucket;
            h.timeFrame = reasonWrapperObj.TimeFrame;
            system.debug(reasonWrapperObj.selectedSubReasonSet);
            h.selectedSubReasonSet.addAll(getSelectOptionsInStringSet());
            
            custProfConfig.caseReasonMap.put(h.caseReason+'_'+h.timeFrame+'_'+h.categoryBucket, h);
            //update table in the VF page
            updateWrapperList();
			//Reset
            displayPopUp = false;
            hasKeyFlag = false;
            userAction = '';
        }
        
    }
    
    public void editRow(){
        //reset values
        displayPopUp = true;
        userAction = 'Update';
        availableSubReasonList.clear();
        selectedSubReasonList.clear();
        system.debug('EditMapKey: '+editMapKey);
        ReasonWrapperClass rwcList = new ReasonWrapperClass();
        rwcList = custProfConfig.caseReasonMap.get(editMapKey);
        system.debug(rwcList);
        reasonWrapperObj = rwcList;
        reason = rwcList.caseReason;

        List<String> s1 = caseReasonSubReasonMap.get(reason);
        //Populate the available sub-reason list
        for(String s2: s1){
            if(!rwcList.selectedSubReasonSet.contains(s2)){
                availableSubReasonList.add(new SelectOption(s2,s2));
            }
        }
        //To retain the case sub-reasons if they are not available at the moment but needed for calculation.
        //Populate the selected Sub Reason List
        for(String s2: rwcList.selectedSubReasonSet){
            selectedSubReasonList.add(new SelectOption(s2,s2));
        }
        
        system.debug(rwcList.selectedSubReasonSet.size());
        system.debug(selectedSubReasonList.size());
        system.debug(availableSubReasonList.size());
    }
    
    //Method to add new Case Reason, Sub-reason, Timeframe and Category values
    public void newRow(){
        //reset values
        displayPopUp = true;
        userAction = 'New';
        reason = 'None';
        reasonWrapperObj = new ReasonWrapperClass();
        fetchSubReasons();
        System.debug(availableSubReasonList); 
    }
    
    //Delete the Case Reason Criteria
    public void deleteRow(){
        system.debug('EditMapKey: '+editMapKey);
        custProfConfig.caseReasonMap.remove(editMapKey);
        //update table in the VF page
        updateWrapperList();
        
    }
    
    //Update the Case-Reason Criteria table
    private void updateWrapperList(){
        system.debug(custProfConfig.rWCList.size());
        custProfConfig.rWCList.clear();
        custProfConfig.rWCList.addAll(custProfConfig.caseReasonMap.values());
        system.debug(custProfConfig.rWCList.size());
    }
    
    //Cancel the changes
    public void cancel(){
        displayPopUp = false;
        hasKeyFlag = false;
    }
    
    //Method to update the Customer Profile Configuration record
    public PageReference updateConfig(){
        
        // Get the JSON string.
        String JSONString = JSON.serialize(custProfConfig.rWCList);
        System.debug(JSONString.length());
        System.debug(JSONString);
        
        //Break the JSON string into the fields in the Custom Profile Settings object 
        Integer JSONLength = JSONString.length();
        Integer tempCount = JSONLength / 131072;
        List<String> JSONStringList = new List<String>(3);
        for(Integer i=0;i<=tempCount;i++){
            Integer startIndex = i*131072;
            Integer endIndex = (JSONLength>(i+1)*131072)?((i+1)*131072):JSONLength;
            
            String tempJSONString = JSONString.subString(startIndex, endIndex);
            JSONStringList[i] = tempJSONString;
            system.debug(tempJSONString);
            system.debug(tempJSONString.length());
        }
        system.debug(JSONStringList[0]);
        system.debug(custProfConfig.cPSettings);
        
        //Assign the split serialised string to the corresponding fields
        custProfConfig.cPSettings.zCase_Reason_SubReason_String1__c = JSONStringList[0];
        custProfConfig.cPSettings.zCase_Reason_SubReason_String2__c = JSONStringList[1];
        custProfConfig.cPSettings.zCase_Reason_SubReason_String3__c = JSONStringList[2];
        
        custProfConfig.cPSettings.Settings_Last_Updated_By__c = userinfo.getName();
        custProfConfig.cPSettings.Settings_Last_Updated_Date__c = system.now();
        
        system.debug(custProfConfig.cPSettings);
        try{
        	//Update configuration
            upsert custProfConfig.cPSettings;
        }catch(Exception e){
            
        }
        return null;
    }
}