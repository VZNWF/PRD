/*
Name: ManageDevicesController
Test Class : ManageDevicesControllerTest
Description:  This is the controller class for the 'Manage' button on the Cases Device related list on a case
Visualforce page: ManageDevices.vfp
History:
Author    Jira                     Date        Description
Siva    IT-1299                    01/12/2017  Creation and further update on the controller logic to pull the appropriate devices
Siva    IT-1854, IT-1718           06/13/2017  Code optimization, Search and Query optimization
Vanditha IT-1451                   07/08/2017  Creating RA Console
Satish IT-1364                     07/14/2017  Creating Order, Performing Order Validation and Sending Email  
Satish IT-2256,2329                09/12/2017  Extended Coverage Pop-up Message & Serial Number Error Message   
Vanditha IT - 2452,2446,2447,2468  09/27/2017 RA Enhancements for Sprint 7
Satish IT - 2448, 2456,2451,2462   09/25/2017 RA Enhancements for Sprint 7 
Vanditha                           10/27/2017 RA Enhancements for Hot Fix 
Vasanth IT - 2539,2563             11/2/2017  RA Enhancements for Sprint 8 
Vanditha IT-2692,IT-2583           12/15/2017 Defualt Unit Type Needed automatically for Non-Serialized Devices & Display Total RA Count
Satish IT-2524,2699,2691           12/15/2017 RA Enhancements for Sprint 9
Satish IT-2543,2752,2622,2773,2803 01/15/2017 RA Enhancements for Sprint 10
*/

public  with sharing class ManageDevicesController {
    //Member Variables  
    public List<CaseDevices> selectedDeviceList {get;set;}
    public List<AllDevices> availableDeviceList {get;set;}
    public boolean isAvailDevListLarge {get; set;}
    public boolean isSelDevListLarge {get; set;}
    public Map<Id,AllDevices> availableDeviceMap;
    public Map<Id,CaseDevices> selectedDeviceMap; 
    public string delDeviceId {get;set;}
    //static Map<Id, AllDevices> initAvailList {get; set;}
    //static Map<Id, CaseDevices> initSelectList {get; set;}
    private Set<string> searchValueSet;
    public string searchTxtArea {get; set;}
    public Case currCase {get; set;}
    public boolean isSearchFormError {get; set;}
    List<OrderLocation__c> ordLocLst = new List<OrderLocation__c>();
    List<Order_Product__c> ordProdLst = new List<Order_Product__c>();
    OrderLocation__c ordLoc;
    Map<String, OrderLocation__c> locOrdMap = new Map<String, OrderLocation__c>();
    Id OrdRecType = Schema.SObjectType.Orders__c.getRecordTypeInfosByName().get('EO').getRecordTypeId();
    Map<String, Product2> mapProdNames = new Map<String,Product2>();
    List<Order_Product__c> tempOrdProdLst = new List<Order_Product__c>();
    Orders__c ord;
    Set<String> prodNames = new Set<String>();
    String raLogId; 
    public String searchFilter {
        get{
            if(searchFilter == null){
                searchFilter = 'DeviceSerial';
            }
            return searchFilter;        
        } 
        set;
    }
    ApexPages.StandardController stdController;
    public RA_Log_Detail__c objRADetails {get; set;}
    public List<RA_Log_Detail__c> lstNonRALogDetails{get;set;}
    public List<CaseDevicesWithLog> lstcaseDeviceWithLog;
    public RA_Log__c objRAlog {get; set;}
    public List<RA_Log_Detail__c> lstCaseDevice {get; set;}
    //List<RA_Log_Detail__c> UpdateRAlog = new List<RA_Log_Detail__c>();
    
    //Wrapper class for All Vehicle devices
    public class AllDevices{
        public Id VehDevId {get;set;}
        public Boolean isSelected {get;set;}
        public string strVIN {get;set;}
        public string strSrNo {get;set;}
        public string strVehLabel {get;set;}
        public string strActivationStatus {get;set;}
        public string strFleetId {get;set;}
        public string strFleetName {get;set;}
        public Id vehId {get; set;}
        public Id devId {get; set;}
        public string modelType {get; set;}
        public string unitUnderWrty {get; set;}
        public string custNumber {get; set;}
    }
    
    //Wrapper class for selected devices
    public class CaseDevices{
        public boolean isNew {get; set;}
        public Id VehDevId {get;set;}
        public Id caseDevId {get;set;}
        public Id caseId {get;set;}
        public string strComments {get;set;}
        public string strVIN {get;set;}
        public string strSrNo {get;set;}
        public string strVehLabel {get;set;}
        public string strActivationStatus {get;set;}
        public string strFleetId {get;set;}
        public string strFleetName {get;set;}
        public Id devId {get; set;}
        public Id vehId {get; set;}
        public string modelType {get; set;}
        public string unitUnderWrty {get; set;}
        public string dispositionType {get; set;}
        public string custNumber {get; set;}
    }
    
    public class CaseDevicesWithLog{
        public CaseDevices objCaseDevice {get; set;}
        public RA_Log_Detail__c objRALogDetails {get; set;}
        //public string strSrNo {get;set;}
        //public string modelType {get;set;}
    }
    
    //Constructor
    public ManageDevicesController(ApexPages.StandardController controller){
        //Initialization
        stdController = controller;
        availableDeviceList = new List<AllDevices>();
        selectedDeviceList = new List<CaseDevices>();
        availableDeviceMap = new Map<Id,AllDevices> ();
        selectedDeviceMap = new Map<Id,CaseDevices> ();     
        lstcaseDeviceWithLog = new List<CaseDevicesWithLog>();
        lstCaseDevice = new List<RA_Log_Detail__c>();
        objRADetails = new RA_Log_Detail__c();
        objRAlog = new RA_Log__c();  
        isAvailDevListLarge = false;
        isSelDevListLarge = false;
        Id caseId;
        /*caseId = ((Case)controller.getRecord()).Id;
        List<Case> lstempcase = [SELECT Id, AccountId, Account.Name,Status, Account.SOS_Owner__c,Reason, Fleet_Account__c, Fleet_Account__r.Name, Account.Acct_Type__c,RA_Type__c, Case_Sub_Reason__c,Customer_Number__c,CaseNumber, Account.Sub_Type__c, Fleet_Account__r.Acct_Type__c, Fleet_Account__r.Sub_Type__c, Account.Seller_Key__c, Account.AccountNumber, Fleet_Account__r.Seller_Key__c, Fleet_Account__r.AccountNumber, Fleet_Account__r.ParentId, Fleet_Account__r.Parent.ParentId, Fleet_Account__r.Parent.Acct_Type__c, Fleet_Account__r.Parent.Sub_Type__c FROM Case WHERE Id =:caseId and isDeleted=false];
        if (lstempcase != null && lstempcase.size() >0){
        Currcase = lstempcase.get(0);
        }*/
        
        caseId = ((Case)controller.getRecord()).Id;
        currCase = [SELECT Id, AccountId, Account.Name, Account.GP_Account_Hold__c, Account_Type__c, Fleet_Account__c, Account.SOS_Owner__c, Fleet_Account__r.Name, Fleet_Account__r.SOS_Owner__c, Fleet_Account__r.GP_Account_Hold__c,Fleet_Account__r.Email_Account_Owner__c, Account.Acct_Type__c, RA_Type__c, Case_Sub_Reason__c, Reason, Customer_Number__c, CaseNumber, Account.Sub_Type__c, Fleet_Account__r.Acct_Type__c, Fleet_Account__r.Sub_Type__c, Account.Seller_Key__c, Account.AccountNumber, Fleet_Account__r.Seller_Key__c, Fleet_Account__r.AccountNumber, Fleet_Account__r.ParentId, Fleet_Account__r.Parent.ParentId, Fleet_Account__r.Parent.Acct_Type__c, Fleet_Account__r.Parent.Sub_Type__c, Fleet_Account__r.Parent.Parent.Acct_Type__c, Fleet_Account__r.Parent.Parent.Sub_Type__c, (Select Id, Name, Order_Types__c From Orders__r) FROM Case WHERE Id =:caseId and isDeleted=false];
        
        
         if(ApexPages.currentPage().getParameters().get('raLogId') != null){
            raLogId = ApexPages.currentPage().getParameters().get('raLogId') ;
            objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c, SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c,RA_Serial_Cust_ID_Verified__c,
                                 Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c 
                                FROM RA_Log__c where Id =: raLogId];
        }
        lstNonRALogDetails = new List<RA_Log_Detail__c>();
        //Initialize lists through method calls
        fnInitcaseVehDevList();
        initQuery();
        fnInitNonserialisedDeviceList();
        fnInitSerialisedDeviceList();
        objRAlog.Units_In_RA__c = lstNonRALogDetails.size() + lstCaseDevice.size();
        objRAlog.Units_in_RA_Serialized__c = lstCaseDevice.size();
        checkType();
        getRAList();
        
    }
    
    //Getter method for FilterOptions
    public List<SelectOption> getFilterOptions(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('DeviceSerial','Device Serial Number')); 
        options.add(new SelectOption('VehicleVIN','Vehicle VIN Number')); 
        //options.add(new SelectOption('VehicleLabel','Vehicle Label')); 
        return options; 
    }
    
    //Initialization method
    public void initQuery(){
        //Logic to determine what Veh-Dev fleet records to be displayed.
        string accId= currCase.AccountId;
        string fAccId = currCase.Fleet_Account__c;
        string fAccParId = currCase.Fleet_Account__r.ParentId;
        string fAccGrndParId = currCase.Fleet_Account__r.Parent.ParentId;
        string accFilter;
        
        set<String> resellerTypes = new Set<String>{'RESELLER', 'RESELLER-PP', 'VAR'};
        
        //A Set to include the Parent and Grand Parent accountIds
        Set<Id> subFilterSet = new Set<Id>();
        
        //if the Fleet Account type is 'Sales Partner', just consider the Fleet Account
        if(currCase.Fleet_Account__r.Acct_Type__c == 'Sales Partner'){
            subFilterSet.add(fAccId);
        }else if(currCase.Fleet_Account__r.Acct_Type__c == 'End Customer'){
            //If the Fleet Account type is 'End Customer'
            subFilterSet.add(fAccId);
            //Consider its parent or even grand parent as long as they are 'End Customer' and Sub type is not IN {'RESELLER', 'RESELLER-PP', 'VAR'}
            if((!resellerTypes.contains(currCase.Fleet_Account__r.Sub_Type__c)) && currCase.Fleet_Account__r.Parent.Acct_Type__c == 'End Customer' && (!resellerTypes.contains(currCase.Fleet_Account__r.Parent.Sub_Type__c))){
                subFilterSet.add(fAccParId);
                if((!resellerTypes.contains(currCase.Fleet_Account__r.Parent.Parent.Sub_Type__c)) && currCase.Fleet_Account__r.Parent.Parent.Acct_Type__c == 'End Customer'){
                    subFilterSet.add(fAccGrndParId);
                }
            }
        }else{
            //Defaulter
            subFilterSet.add(fAccId);
        }
        
        //Remove null Ids, if any
        subFilterSet.remove(null);
        
        system.debug('subFilterSet: '+subFilterSet);

        //Account Filter in the pre-populate query
        accFilter = 'Account__c IN :subFilterSet OR Account__r.ParentId IN :subFilterSet OR Account__r.Parent.ParentId IN :subFilterSet';
        
        //Query to Prepopulate devices upon service console launch
        string strQuery = 'SELECT Id,Name,Account__c,Account__r.Name,Account__r.AccountNumber, Vehicle__r.VIN__c,Device__r.Customer_Number__c, Device__r.Model_Type__c, Device__r.Unit_Under_Warranty__c, Device__r.Serial_Number__c, toLabel(Device__r.Activation_Status__c), Vehicle__r.Vehicle_Label__c FROM Vehicle_Device_Map__c WHERE OracleToSQL_Status__c!=\'D\''+(accFilter!=''?+' AND ('+accFilter+')':'');
        strQuery+= ' LIMIT 1001';
        system.debug(strQuery);
        //Reset
        availableDeviceList.clear();
        availableDeviceMap.clear();
        Integer counter = 0;
        //Loop through the query result
        for(Vehicle_Device_Map__c mvd: Database.query(strQuery)){
            if(!selectedDeviceMap.containsKey(mvd.Device__c)){
                if(counter<1000){
                    AllDevices objAll = new AllDevices();
                    objAll.VehDevId = mvd.Id;
                    objAll.isSelected = false;
                    objAll.strVIN = mvd.Vehicle__r.VIN__c;
                    objAll.strSrNo = mvd.Device__r.Serial_Number__c;
                    objAll.strVehLabel = mvd.Vehicle__r.Vehicle_Label__c;
                    objAll.strActivationStatus = mvd.Device__r.Activation_Status__c;
                    objAll.strFleetId = mvd.Account__c;
                    objAll.strFleetName = mvd.Account__r.Name;
                    objAll.custNumber = mvd.Device__r.Customer_Number__c; 
                    objAll.devId = mvd.Device__c;
                    objAll.vehId = mvd.Vehicle__c;
                    objAll.modelType = mvd.Device__r.Model_Type__c;
                    objAll.unitUnderWrty = mvd.Device__r.Unit_Under_Warranty__c;
                        
                    availableDeviceMap.put(mvd.Device__c,objAll);
                    availableDeviceList.add(objAll);
                    counter++;
                }else{
                    isAvailDevListLarge = true;
                    break;
                }
            }
        }
    }
    
    //Intial list of Case vehicle Devices
    public void fnInitcaseVehDevList(){
        Integer counter = 0;
        for(Case_Device__c cvd:[SELECT Id,Case__c,Comments__c, Serial_No__c,Vehicle_Label__c,VIN__c,toLabel(Device__r.Activation_Status__c),Device__r.Customer_Number__c, Vehicle__c, Device__c, Device__r.Unit_Under_Warranty__c, Disposition_Type__c, Device__r.Model_Type__c, Fleet_Account__c, 
                                    Fleet_Account__r.Name,Fleet_Account__r.AccountNumber FROM Case_Device__c WHERE Case__c =:currCase.Id]){
            if(counter<1000){
                CaseDevices objSel = new CaseDevices();
                objSel.caseDevId = cvd.Id;
                objSel.caseId = cvd.Case__c;
                objSel.strComments = cvd.Comments__c;
                objSel.strVIN = cvd.VIN__c;
                objSel.strSrNo = cvd.Serial_No__c;
                objSel.strVehLabel = cvd.Vehicle_Label__c;
                objSel.strActivationStatus = cvd.Device__r.Activation_Status__c;
                objSel.strFleetId = cvd.Fleet_Account__c;
                objSel.strFleetName = cvd.Fleet_Account__r.Name;
                objSel.isNew = false;
                objSel.devId = cvd.Device__c;
                objSel.vehId = cvd.Vehicle__c;
                objSel.modelType = cvd.Device__r.Model_Type__c;
                objSel.unitunderwrty = cvd.Device__r.Unit_Under_Warranty__c;
                objSel.dispositionType = cvd.Disposition_Type__c;
                objSel.custNumber = cvd.Device__r.Customer_Number__c;
                
                selectedDeviceMap.put(cvd.Device__c,objSel);
                selectedDeviceList.add(objSel);
                counter++;
            }else{
                isSelDevListLarge = true;
                break;
            }
        }      
    }
    
    //Search based on VIN & Serial Number
    public void fnSearch(){
        //fnFillMasterVehDevices();
        isSearchFormError = false;
        parseSearchString();
        system.debug('searchTxtArea: '+searchTxtArea);
        system.debug('isSearchFormError:'+isSearchFormError);
        system.debug('searchValueSet: '+searchValueSet);
        if(!isSearchFormError && searchValueSet.size()>0){
            if(searchFilter == 'DeviceSerial'){
                searchDevice();
            }else if(searchFilter == 'VehicleVIN'){
                searchVehicle();
            }
            
        }
    }
    
    //A method invoked upon the 'Reset' button click
    public void fnReset(){
        searchTxtArea = '';
        initQuery();
    }
    
    //Method to parse the search string in the VF page and add to a set
    private void parseSearchString(){
        //Initiate searchValueSet
        searchValueSet = new Set<string>();

        //Parse the search criteria
        if(searchTxtArea != null && searchTxtArea.trim() != ''){
            for(String s:searchTxtArea.split('\n')){
                //Remove any spaces
                s = s.replaceAll('\\s+', '');
                searchValueSet.addAll(s.split(','));
            }
        }else{
            //Show the search form error
            isSearchFormError = true;
        }
    }
    
    //This method is invoked when the user searches with the Device information (Eg., Serial Number)
    public void searchDevice(){
        //query to search the Device   
         string strQuery = 'Select Id, Serial_Number__c, Device_Status__c, toLabel(Activation_Status__c), Model_Type__c, Customer_Number__c, Unit_Under_Warranty__c, (SELECT Id,Name,Account__c,Account__r.Name, Account__r.AccountNumber, Vehicle__r.VIN__c, Vehicle__r.Vehicle_Label__c, Device__c, Vehicle__c, OracleTOSQL_Status__c FROM Fleets__r WHERE OracleToSQL_Status__c!=\'D\') from Device__c where Serial_Number__c IN :searchValueSet LIMIT 1001';    
        
        system.debug(strQuery);
        //Reset
        availableDeviceList.clear();
        availableDeviceMap.clear();
        Integer counter = 0;
        isAvailDevListLarge = false;
        //Loop through the query results
        for(Device__c d: Database.query(strQuery)){
            if(!selectedDeviceMap.containsKey(d.Id)){
                //Counter to check if the list has more than 1000 devices
                if(counter<1000){
                    //Check if the device has any fleets 
                    if(d.fleets__r != null && d.fleets__r.size() > 0){
                        system.debug(d.Fleets__r.size());
                        for(Vehicle_Device_Map__c mvd:d.fleets__r){
                            //Check the counter if the device has active mutliple vehicle associations (error scenario)
                            if(counter<1000){
                                AllDevices objAll = new AllDevices();
                                objAll.VehDevId = mvd.Id;
                                objAll.isSelected = false;
                                objAll.strVIN = mvd.Vehicle__r.VIN__c;
                                objAll.strSrNo = d.Serial_Number__c;
                                objAll.strVehLabel = mvd.Vehicle__r.Vehicle_Label__c;
                                objAll.strActivationStatus = d.Activation_Status__c;
                                objAll.strFleetId = mvd.Account__c;
                                objAll.strFleetName = mvd.Account__r.Name;
                                objAll.custNumber =d.Customer_Number__c;
                                objAll.devId = mvd.Device__c;
                                objAll.vehId = mvd.Vehicle__c;
                                objAll.modelType = d.Model_Type__c;
                                objAll.unitUnderWrty = d.Unit_Under_Warranty__c;
                                availableDeviceMap.put(mvd.Device__c,objAll);
                                availableDeviceList.add(objAll);
                                counter++;
                            }else{
                                //if the counter exceeds 1000 records, turn on the flag - which displays a warning popup message in the console page
                                isAvailDevListLarge = true;
                                break;
                            }
                        }
                    }else{
                        AllDevices objAll = new AllDevices();
                        objAll.VehDevId = null;
                        objAll.isSelected = false;
                        objAll.strVIN = null;
                        objAll.strSrNo = d.Serial_Number__c;
                        objAll.strVehLabel = null;
                        objAll.strActivationStatus = d.Activation_Status__c;
                        objAll.strFleetId = null;
                        objAll.strFleetName = null;
                        objAll.custNumber = null;
                        objAll.devId = d.Id;
                        objAll.vehId = null;
                        objAll.modelType = d.Model_Type__c;
                        objAll.unitUnderWrty = d.Unit_Under_Warranty__c;
                        availableDeviceMap.put(d.Id,objAll);
                        availableDeviceList.add(objAll);
                        counter++;
                    }
                }else{
                    //if the counter exceeds 1000 records, turn on the flag - which displays a warning popup message in the console page
                    isAvailDevListLarge = true;
                    break;
                }
            }
        }
    }
    
    //This method is invoked when the user searches with the Vehicle information (Eg., VIN )
    public void searchVehicle(){
        //Query
        string strQuery = 'Select Id,Name,Account__c,Account__r.Name, Vehicle__r.VIN__c, Device__r.Serial_Number__c, toLabel(Device__r.Activation_Status__c), Device__r.Model_Type__c,Account__r.AccountNumber, Device__r.Customer_Number__c, Device__r.Unit_Under_Warranty__c, Vehicle__r.Vehicle_Label__c, Device__c, Vehicle__c, OracleTOSQL_Status__c FROM Vehicle_Device_Map__c WHERE OracleToSQL_Status__c!=\'D\' and Vehicle__r.VIN__c IN :searchValueSet LIMIT 1001';
        system.debug(strQuery);
        //Reset
        availableDeviceList.clear();
        availableDeviceMap.clear();
        Integer counter = 0;
        isAvailDevListLarge = false;
        //Loop through the query results
        for(Vehicle_Device_Map__c mvd: Database.query(strQuery)){
            if(!selectedDeviceMap.containsKey(mvd.Device__c)){
                //Counter to check if the list has more than 1000 records
                if(counter<1000){
                    AllDevices objAll = new AllDevices();
                    objAll.VehDevId = mvd.Id;
                    objAll.isSelected = false;
                    objAll.strVIN = mvd.Vehicle__r.VIN__c;
                    objAll.strSrNo = mvd.Device__r.Serial_Number__c;
                    objAll.strVehLabel = mvd.Vehicle__r.Vehicle_Label__c;
                    objAll.strActivationStatus = mvd.Device__r.Activation_Status__c;
                    objAll.strFleetId = mvd.Account__c;
                    objAll.strFleetName = mvd.Account__r.Name;
                    objAll.devId = mvd.Device__c;
                    objAll.vehId = mvd.Vehicle__c;
                    objAll.modelType = mvd.Device__r.Model_Type__c;
                    objAll.unitUnderWrty = mvd.Device__r.Unit_under_Warranty__c;
                    objAll.custNumber = mvd.Device__r.Customer_Number__c; 
                    availableDeviceMap.put(mvd.Device__c,objAll);
                    availableDeviceList.add(objAll);
                    counter++;
                }else{
                    //if the counter exceeds 1000 records, turn on the flag - which displays a warning popup message in the console page
                    isAvailDevListLarge = true;
                    break;
                }
            }
        }
    }
    
    
    //Method to add the devices to selected devices list 
    public void fnAdd(){
        List<CaseDevices> tmpcaseVehDevList = new List<CaseDevices>();
        system.debug('Before: '+availableDeviceList.size());
        system.debug('Before Map: '+availableDeviceMap.size());
        for(AllDevices objAll:availableDeviceList){
            if(objAll.isSelected){
                CaseDevices objSel = new CaseDevices();
                objSel.VehDevId = objAll.VehDevId;
                objSel.caseId = currCase.Id;
                objSel.strComments = '';
                objSel.strVIN = objAll.strVIN;
                objSel.strSrNo = objAll.strSrNo;
                objSel.strVehLabel = objAll.strVehLabel;
                objSel.strActivationStatus = objAll.strActivationStatus;
                objSel.strFleetId = objAll.strFleetId;
                objSel.strFleetName = objAll.strFleetName;
                objSel.isNew = true;
                objSel.devId = objAll.devId;
                objSel.vehId = objAll.vehId;
                objSel.modelType = objAll.modelType;
                objSel.unitUnderWrty = objAll.UnitUnderWrty;
                objSel.custNumber = objAll.custNumber;
                selectedDeviceMap.put(objAll.devId,objSel);              
                tmpcaseVehDevList.add(objSel);
                availableDeviceMap.remove(objAll.devId);
            }
        }
        //'tmpcaseVehDevList' to add the newly added devices on the start of the 'selectedDeviceList' rather than at the end.
        tmpcaseVehDevList.addAll(selectedDeviceList);
        selectedDeviceList.clear();
        selectedDeviceList.addAll(tmpcaseVehDevList);
        system.debug('After: '+availableDeviceList.size());
        system.debug('After Map: '+availableDeviceMap.size());
        //Update the 'availableDeviceList'
        availableDeviceList.clear();
        availableDeviceList.addAll(availableDeviceMap.values());
    }
    
    //Method to delete the selected devices
    public void fnDelete(){
        system.debug('delDeviceId=>'+delDeviceId);
        if(selectedDeviceMap.containsKey(delDeviceId)){
            CaseDevices caseDev = new CaseDevices();
            caseDev = selectedDeviceMap.get(delDeviceId);
            if(caseDev != null){
                AllDevices objAll = new AllDevices();
                objAll.VehDevId = caseDev.VehDevId;
                objAll.isSelected = false;
                objAll.strVIN = caseDev.strVIN;
                objAll.strSrNo = caseDev.strSrNo;
                objAll.strVehLabel = caseDev.strVehLabel;
                objAll.strActivationStatus = caseDev.strActivationStatus; 
                objAll.strFleetId = caseDev.strFleetId;
                objAll.strFleetName = caseDev.strFleetName; 
                objAll.custNumber = caseDev.custNumber;
                objAll.devId = caseDev.devId;
                objAll.vehId = caseDev.vehId;
                objAll.modelType = caseDev.modelType;
                objAll.unitUnderWrty = caseDev.UnitUnderWrty;
                availableDeviceMap.put(delDeviceId,objAll); 
                availableDeviceList.add(objAll);
            }
            selectedDeviceMap.remove(delDeviceId);
            selectedDeviceList.clear();
            selectedDeviceList.addAll(selectedDeviceMap.values());
        }
    }

    //Submit
    public PageReference fnSubmit(){
        try{
            Map<Id,Case_Device__c> existingDevicesMap = new Map<Id,Case_Device__c>();
            List<Case_Device__c> caseDeviceInsertList = new List<Case_Device__c>();
            List<Case_Device__c> caseDeviceUpdateList = new List<Case_Device__c>();
            List<Case_Device__c> caseDeviceDeleteList = new List<Case_Device__c>();
            
            Set<id> vehDevIdSet = new Set<id>();
      
            
            for(Case_Device__c mvd:[SELECT Id, Fleet_Account__c, Fleet_Account__r.Name, Fleet_Account__r.AccountNumber,Comments__c, Device__r.Customer_Number__c,Device__c,Disposition_Type__c FROM Case_Device__c WHERE Case__c = :currCase.Id]){
                existingDevicesMap.put(mvd.Device__c, mvd);                
            }
            
            for(CaseDevices objSel:selectedDeviceList){
                if(!existingDevicesMap.containsKey(objSel.devId)){
                    Case_Device__c objCVD = new Case_Device__c();
                    objCVD.Case__c = objSel.caseId;
                    String comments = objSel.strComments;
                    objCVD.Comments__c = (comments.length()>2000)?comments.subString(0,2000):comments;
                    objCVD.Device__c = objSel.devId;
                    objCVD.Vehicle__c = objSel.vehId;
                    objCVD.Fleet_Account__c = objSel.strFleetId;
                    objCVD.Disposition_Type__c = objSel.dispositionType;
                    caseDeviceInsertList.add(objCVD);
                } else if(existingDevicesMap.size() >0 && existingDevicesMap.get(objSel.devId) != null){
                    if((existingDevicesMap.get(objSel.devId).Comments__c != objSel.strComments) || (existingDevicesMap.get(objSel.devId).Disposition_Type__c != objSel.dispositionType)){
                        existingDevicesMap.get(objSel.devId).Comments__c = objSel.strComments;
                        existingDevicesMap.get(objSel.devId).Disposition_Type__c = objSel.dispositionType; 
                        caseDeviceUpdateList.add(existingDevicesMap.get(objSel.devId));
                    }
                    existingDevicesMap.remove(objSel.devId);
                }
            }
            if(existingDevicesMap.size() > 0){
                caseDeviceDeleteList.addAll(existingDevicesMap.values());
                delete caseDeviceDeleteList;
            }
            if(caseDeviceUpdateList.size() > 0)
                update caseDeviceUpdateList;
            if(caseDeviceInsertList.size() > 0)
                insert caseDeviceInsertList;
        } catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occurred, please contact system administrator <br> Error::'+ex.getMessage()));
            return null;        
        }

        PageReference pr = stdController.save(); 
        return pr;    
    }
    
    public boolean extendedType{get; set;}
    
    public void checkType(){
           extendedType = false;
        If(lstCaseDevice != null && lstCaseDevice.size() >0 ){
        System.debug('lstCaseDevice::'+lstCaseDevice);
               for(RA_Log_Detail__c raDet : lstCaseDevice){ 
                  if(raDet.Unit_Type_Needed_Serialised__c != null && raDet.Unit_Type_Needed_Serialised__c.containsignoreCase('Extended')){
                   extendedType = true;
                  }
              }
              
            }
    }
    
     
    //Method to Create RA for the selected devices
    public PageReference CreateRA(){     
           fnSubmit();  
           
                  
            if(currcase.Account.GP_Account_Hold__c && currcase.Account.Sub_Type__c!='RESELLER'){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'RA cannot be created for accounts that are in "ACCT HOLD" status. Please contact the Account Manager'));
          return null;
        }
               
           If(selectedDeviceList != null && selectedDeviceList.size() ==1){
              for(CaseDevices objCD1: selectedDeviceList){
              
                            if(objCD1.dispositionType != 'RA' || objCD1.unitUnderWrty== null ){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Disposition Type as RA and click Create RA button to proceed next steps'));
                                return null;
                            }
                        }
                }       
        if(selectedDeviceList != null && selectedDeviceList.size() >0){     
            Set<String> setSerialNumber = new Set<String>();
            Set<String> UniqueSrlnum = new Set<String>();
            for(CaseDevices objCDTemp: selectedDeviceList){
                if(objCDTemp.strSrNo != null){
                    setSerialNumber.add(objCDTemp.strSrNo);
                    system.debug('Set of Serial numbers'+setSerialNumber );
                }
            }       
             Map<Id,RA_Log_Detail__c> mapExistingRALogAllDetail = new Map<Id, RA_Log_Detail__c>([Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Serial_Number__c,Model_Type__c,RA_Location__c, Unit_under_warranty__c,
                        Unit_Type_Needed_Serialised__c,Quantity__c, Tracking_Number__c  from RA_Log_Detail__c where Serial_Number__c in:setSerialNumber AND RA_Log_Id__c != null and RA_Log_Id__r.RA_Status__c!= 'Cancelled']);

             Map<String, RA_Log_Detail__c> mapSerialAllExistingLogDetails= new Map<String, RA_Log_Detail__c>();
            if(mapExistingRALogAllDetail != null && mapExistingRALogAllDetail .size()>0) {
                for(RA_Log_Detail__c objRALogDetails: mapExistingRALogAllDetail.values()){
                    mapSerialAllExistingLogDetails.put(objRALogDetails.Serial_Number__c, objRALogDetails);
                    UniqueSrlnum.add(objRALogDetails.Serial_Number__c);
                }
            }                   
                        for(CaseDevices objCD1: selectedDeviceList){
                          /*  if(objCD1.dispositionType == 'None' || objCD1.unitUnderWrty== null ){
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select the Disposition Type'));
                                return null;
                            } */
                          }
                          
                        for(CaseDevices objCD2: selectedDeviceList){
                            if(currCase.Case_Sub_Reason__c == 'Possible RA'){
                                if(objCD2.dispositionType == 'RA' || objCD2.unitUnderWrty!= null ){
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'RA cannot be created for Case Sub Reason with "Possible RA"'));
                                    return null;
                                }
                            }
                        }                        
            lstCaseDevice = new List<RA_Log_Detail__c>();
            Integer raLogDetCounter = 0; 
            RA_Log__c RAlog = new RA_Log__c(Case_Id__c = currCase.CaseNumber,RA_Type__c = currCase.RA_Type__c, Case_Sub_Reason__c = currCase.Case_Sub_Reason__c, Account_Name__c = currCase.Account.Name , Case__c =currCase.Id, RA_Status__c = 'Open'  );     
             List<RA_Log__c> lstRAlogTemp = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c, RA_Serial_Cust_ID_Verified__c,
                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c, (Select Id from RA_Log_Details1__r) 
                             FROM RA_Log__c where Case_Id__c=:currCase.CaseNumber AND RA_Type__c =: currCase.RA_Type__c AND Account_Name__c =: currCase.Account.Name and Case__c =:currCase.Id
                             and order__c =: null and Emailsent__c = false and RA_Status__c != 'Cancelled' ORDER BY CreatedDate Desc];
                            
           /* for(RA_Log__c RAOrd:lstRAlogTemp){
                if(RAOrd.Orders__c !=null && RAOrd.RA_Log_Details1__r.size() > 0){
                  raLogDetCounter += RAOrd.RA_Log_Details1__r.size();                    
                }
            } 
            System.debug('raLogDetCounter:::' +raLogDetCounter);
             if(selectedDeviceList.size() == raLogDetCounter){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot change the RA information once Order is created'));
                return null;
             } */
            
             System.debug('Selected Device List:::'+ selectedDeviceList);
             boolean acctnumbmismatch = false;
             String acctNumError = '';
             List<schema.PicklistEntry> fieldPicklist = RA_Log_Detail__c.Unit_Type_Needed_Serialised__c.getDescribe().getPicklistValues();
            for(CaseDevices objCD: selectedDeviceList){
                System.debug('Case Account Number:::'+ currCase.Account.AccountNumber + 'Device Customer Number:::' +objCD.custNumber); 
                if(currCase.Fleet_Account__r.AccountNumber != objCD.custNumber && objCD.dispositionType == 'RA'){
                    acctnumbmismatch = true;
                    acctNumError += 'Device Serial #'+objCD.strSrNo+'--->'+'Customer Id: '+objCD.custNumber +'<br/>';
                } 
             } 
             if(acctnumbmismatch){ 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Customer Id for following Device (s) does not match with the Customer Id of the Fleet Account on this case. Please reconcile and make appropriate correction (s):.<br/>'+acctNumError));
                return null;
             }                            
                for(CaseDevices objCD: selectedDeviceList){                               
                        if(currCase.Case_Sub_Reason__c == 'Defective Product' || (currCase.Case_Sub_Reason__c == 'Defective Product (w/ recall)') || ( currCase.Case_Sub_Reason__c == 'Device lost in Transit')){
                            if(objCD.unitUnderWrty== 'Yes' && objCD.dispositionType == 'RA' ){                               
                                    if(lstRAlogTemp != null && lstRAlogTemp.size()>0){                                   
                                          objRAlog = lstRAlogTemp.get(0);                      
                                    }else{                                   
                                        insert RAlog;  
                                        objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c,RA_Serial_Cust_ID_Verified__c,
                                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c 
                                            FROM RA_Log__c where Id =:RAlog.Id]; 
                                    }                               
                                System.debug('objRAlog------->'+ objRAlog);                 
                                break;                               
                            } else {
                                    if(lstRAlogTemp != null && lstRAlogTemp.size()>0){
                                        objRAlog = lstRAlogTemp.get(0); 
                                    }else{
                                        insert RAlog;  
                                        objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c,RA_Serial_Cust_ID_Verified__c,
                                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c
                                            FROM RA_Log__c where Id =:RAlog.Id]; 
                                    }                       
                                    System.debug('objRAlog------->'+ objRAlog);                 
                                    break;
                            }
                        }

                        if((currCase.Case_Sub_Reason__c == 'Incorrect Part Ordered') || (currCase.Case_Sub_Reason__c == 'Damaged or Lost Device Under Contract') || (currCase.Case_Sub_Reason__c == 'Pilot Return') || (currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered') ){               
                            
                                if((objCD.unitUnderWrty== 'Yes'|| objCD.unitUnderWrty== 'No') && objCD.dispositionType == 'RA' ){
                                    
                                    if(lstRAlogTemp != null && lstRAlogTemp.size()>0){
                                        objRAlog = lstRAlogTemp.get(0);
                                    }else{
                                    insert RAlog;  
                                        objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c, RA_Serial_Cust_ID_Verified__c,
                                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c
                                            FROM RA_Log__c where Id=:RAlog.Id]; 
                                    }                       
                                    System.debug('objRAlog------->'+ objRAlog);                 
                                    break;
                                } else {
                                    if(lstRAlogTemp != null && lstRAlogTemp.size()>0){
                                        objRAlog = lstRAlogTemp.get(0); 
                                    }else{
                                        insert RAlog;  
                                        objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c,RA_Serial_Cust_ID_Verified__c,
                                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c
                                            FROM RA_Log__c where Id =:RAlog.Id]; 
                                    }                       
                                    System.debug('objRAlog------->'+ objRAlog);                 
                                    break;
                                }
                        }else   {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'RA connot be created for the Case Sub Reason selected!'));
                                    return null;
                                }
                }           
            Map<Id,RA_Log_Detail__c> mapExistingRALogDetail = new Map<Id, RA_Log_Detail__c>([Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Serial_Number__c,Model_Type__c,RA_Location__c, Unit_under_warranty__c,
                        Unit_Type_Needed_Serialised__c,Quantity__c, Tracking_Number__c  from RA_Log_Detail__c where RA_Log_Id__c =: objRaLog.Id]);
         system.debug('++++++Maping details'+ mapExistingRALogDetail);
            Map<String, RA_Log_Detail__c> mapSerialLogDetails= new Map<String, RA_Log_Detail__c>();
            if(mapExistingRALogDetail != null && mapExistingRALogDetail .size()>0) {
                for(RA_Log_Detail__c objRALogDetails: mapExistingRALogDetail.values()){
                    mapSerialLogDetails.put(objRALogDetails.Serial_Number__c, objRALogDetails);
                    System.debug('mapSerialLogDetails.size()--->' +mapSerialLogDetails.size());
                }
            }
            for(CaseDevices objCD: selectedDeviceList){
                System.debug('objCD.casDev.dispositionType------'+ objCD.dispositionType);
                System.debug('objCD.unitUnderWrty------'+ objCD.unitUnderWrty);
                System.debug('objCD.strSrNo------'+ objCD.strSrNo);
                if(currCase.Case_Sub_Reason__c == 'Defective Product' || (currCase.Case_Sub_Reason__c == 'Defective Product (w/ recall)') || ( currCase.Case_Sub_Reason__c == 'Device lost in Transit') || (currCase.Case_Sub_Reason__c == 'Pilot Return') || (currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')  ){
                    if(objCD.unitUnderWrty== 'Yes' && objCD.dispositionType == 'RA' ){                        
                            RA_Log_Detail__c objRALogDetail = new RA_Log_Detail__c();
                            if(mapSerialLogDetails.containsKey(objCD.strSrNo)){
                                objRALogDetail = mapSerialLogDetails.get(objCD.strSrNo);
                            }                        
                            objRALogDetail.RA_Log_Id__c = objRAlog.Id;
                            objRALogDetail.Serial_Number__c = objCD.strSrNo;
                            objRALogDetail.Model_Type__c = objCD.modelType;
                            objRALogDetail.Unit_under_warranty__c = objCD.unitUnderWrty;
                            objRALogDetail.Quantity__c = 1;
                            objRALogDetail.RA_Type__c = currCase.RA_Type__c; 
                            if(currCase.Case_Sub_Reason__c == 'Defective Product (w/ recall)'){
                                objRALogDetail.Flag_for_Engineering_Dept__c =true;
                            }
                            for(schema.PicklistEntry fvalue: fieldPicklist){
                                string strvalue = fvalue.getvalue();
                                if(strvalue.contains(objcd.modelType)){
                                objRALogDetail.Unit_Type_Needed_Serialised__c = strvalue;       
                                }
                                 }  
                                 if(currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered' || currCase.Case_Sub_Reason__c == 'Pilot Return'){         
                                   objRALogDetail.Unit_Type_Needed_Serialised__c = 'None Needed (Return Only)';
                            }                     
                            if(mapSerialAllExistingLogDetails.containsKey(objCD.strSrNo) && mapSerialAllExistingLogDetails.get(objCD.strSrNo) != null 
                                && mapSerialAllExistingLogDetails.get(objCD.strSrNo).RA_Log_Id__c != objRAlog.Id){
                             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'RA for the devices ' + UniqueSrlnum + ' has already been created for the Fleet Account - '+ Currcase.Fleet_Account__r.Name));
                            }else{
                                lstCaseDevice.add(objRALogDetail);
                                system.debug('lstCaseDevice for Defective product' + lstCaseDevice);
                            }                       
                    }
                } else {
                    if((currCase.Case_Sub_Reason__c == 'Incorrect Part Ordered') || (currCase.Case_Sub_Reason__c == 'Damaged or Lost Device Under Contract')){
                        if((objCD.unitUnderWrty== 'Yes' || objCD.unitUnderWrty== 'No') && objCD.dispositionType == 'RA' ){                           
                            RA_Log_Detail__c objRALogDetail = new RA_Log_Detail__c();
                            if(mapSerialLogDetails.containsKey(objCD.strSrNo)){
                                objRALogDetail = mapSerialLogDetails.get(objCD.strSrNo);
                            } 
                            objRALogDetail.RA_Log_Id__c = objRAlog.Id;
                            objRALogDetail.Serial_Number__c = objCD.strSrNo;
                            objRALogDetail.Model_Type__c = objCD.modelType;
                            objRALogDetail.Unit_under_warranty__c = objCD.unitUnderWrty;
                            objRALogDetail.Quantity__c = 1;
                            for(schema.PicklistEntry fvalue: fieldPicklist){
                                string strvalue = fvalue.getvalue();
                                if(strvalue.contains(objcd.modelType)){
                                objRALogDetail.Unit_Type_Needed_Serialised__c = strvalue;       
                                }
                            }                     
                            objRALogDetail.RA_Type__c = currCase.RA_Type__c;   
                            if(mapSerialAllExistingLogDetails.containsKey(objCD.strSrNo) && mapSerialAllExistingLogDetails.get(objCD.strSrNo) != null 
                                && mapSerialAllExistingLogDetails.get(objCD.strSrNo).RA_Log_Id__c != objRAlog.Id){ 
                              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'RA for the devices ' + UniqueSrlnum + ' has already been created for the Fleet Account - '+ Currcase.Fleet_Account__r.Name));
                            }else{
                                lstCaseDevice.add(objRALogDetail);
                                system.debug('lstCaseDevice for incorrect part' + lstCaseDevice);
                            }                            
                        }
                    }
                }
            }
            if(lstCaseDevice.size() >0){
                System.Debug('My Case Details Log ---->'+ lstCaseDevice);
                upsert lstCaseDevice;
                Map<Id,RA_Log_Detail__c> mapRALogDetail = new Map<Id, RA_Log_Detail__c>([Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c,Flag_for_Engineering_Dept__c, Serial_Number__c,Model_Type__c,RA_Location__c, Unit_under_warranty__c,
                        Unit_Type_Needed_Serialised__c,Quantity__c, Tracking_Number__c  from RA_Log_Detail__c where Id in: lstCaseDevice ]);
                        system.debug('======>RA Log details' + mapRALogDetail );
                for(Integer i=0; i< selectedDeviceList.size(); i++){ 
                    if(currCase.Case_Sub_Reason__c == 'Defective Product' || (currCase.Case_Sub_Reason__c == 'Defective Product (w/ recall)') || ( currCase.Case_Sub_Reason__c == 'Device lost in Transit') || (currCase.Case_Sub_Reason__c == 'Pilot Return') || (currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')  ){
                        if(selectedDeviceList.get(i).unitUnderWrty== 'Yes' && selectedDeviceList.get(i).dispositionType == 'RA' ){
                            CaseDevicesWithLog objCDL = new CaseDevicesWithLog();
                            objCDL.objCaseDevice = selectedDeviceList.get(i);
                            if(lstCaseDevice.size()>i && lstCaseDevice.get(i) != null && lstCaseDevice.get(i).id != null && mapRALogDetail.containsKey(lstCaseDevice.get(i).Id)){
                                objCDL.objRALogDetails = mapRALogDetail.get(lstCaseDevice.get(i).Id);
                                objCDL.objRALogDetails.RA_Type__c = currCase.RA_Type__c;                            
                                objCDL.objRALogDetails.Quantity__c = 1;
                                System.debug('I am in IF');
                            }                         
                            lstcaseDeviceWithLog.add(objCDL);
                        }
                    }else{                                           
                        if((currCase.Case_Sub_Reason__c == 'Incorrect Part Ordered') || (currCase.Case_Sub_Reason__c == 'Damaged or Lost Device Under Contract')){
                            if((selectedDeviceList.get(i).unitUnderWrty== 'Yes' || selectedDeviceList.get(i).unitUnderWrty== 'No') && selectedDeviceList.get(i).dispositionType == 'RA' ){                             
                               CaseDevicesWithLog objCDL = new CaseDevicesWithLog();
                                    objCDL.objCaseDevice = selectedDeviceList.get(i);
                                    if(lstCaseDevice.size()>i && lstCaseDevice.get(i) != null && lstCaseDevice.get(i).id != null && mapRALogDetail.containsKey(lstCaseDevice.get(i).Id)){
                                        System.debug('hi---->');
                                        objCDL.objRALogDetails = mapRALogDetail.get(lstCaseDevice.get(i).Id);
                                        objCDL.objRALogDetails.RA_Type__c = currCase.RA_Type__c;                            
                                        objCDL.objRALogDetails.Quantity__c = 1;
                                        System.debug('I am in Esle');
                                    }                                
                                    lstcaseDeviceWithLog.add(objCDL);
                            }
                        }
                    }
                   lstCaseDevice = mapRALogDetail.values();                    
                }
            }
        } else{       
            RA_Log__c RAlog = new RA_Log__c(Case_Id__c = currCase.CaseNumber,RA_Type__c = currCase.RA_Type__c, Case_Sub_Reason__c = currCase.Case_Sub_Reason__c, Account_Name__c = currCase.Account.Name , Case__c =currCase.Id, RA_Status__c = 'Open'  );     
            List<RA_Log__c> lstRAlogTemp = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c, RA_Serial_Cust_ID_Verified__c,
                             Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c  
                            FROM RA_Log__c where Case_Id__c=:currCase.CaseNumber AND RA_Type__c =: currCase.RA_Type__c AND Account_Name__c =: currCase.Account.Name and Case__c =:currCase.Id
                            and order__c =: null AND RA_Status__c != 'Cancelled' ORDER BY CreatedDate Desc];
                            
          /* for(RA_Log__c RAOrd:lstRAlogTemp){
                if(RAOrd.Orders__c !=null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot change the RA information once Order is created'));
                    return null;
                }
            } */             
                if(currCase.Case_Sub_Reason__c != 'Possible RA'){                                                          
                                if(lstRAlogTemp != null && lstRAlogTemp.size()>0){
                                    for(RA_Log__c ExtingRA: lstRAlogTemp){
                                        If(ExtingRA.Order__c == null){
                                           objRAlog = lstRAlogTemp.get(0);
                                        }
                                    }                                   
                                }else{                                    
                                    insert RAlog;                                   
                                    objRAlog = [Select Id, Name,Case_Id__c, RA_Type__c,Case_Sub_Reason__c,SendToSQL__c, Emailsent__c, Account_Name__c, Case__c,Order__c,RA_Serial_Cust_ID_Verified__c,
                                         Comments__c,RA_Status__c, Units_in_RA__c, Units_in_RA_Serialized__c, Units_in_RA_Non_Serialized__c
                                        FROM RA_Log__c where Id =:RAlog.Id]; 
                                }                       
                                System.debug('objRAlog------->'+ objRAlog);                                                                          
                } else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'RA connot be created for Case Sub Reason with "Possible RA" '));
                    return null;
                }
        }       
        If(objRAlog.Name != null && objRAlog.Case_Id__c!=null ){
        currCase.Status = 'RA Issued';
        update currCase;
        }        
         fnInitNonserialisedDeviceList() ;
         fnInitSerialisedDeviceList();
         objRAlog.Units_In_RA__c = lstNonRALogDetails.size() + lstCaseDevice.size();
         objRAlog.Units_in_RA_Serialized__c = lstCaseDevice.size();
        return Page.RALogPage;      
        //return null;
    }
    
    public List<CaseDevicesWithLog> getNonserializedDevice(){     
        return lstcaseDeviceWithLog;
    } 
    
    //Method to add Row for Nonserialized devices 
    public void fnAddRow(){
     If(objRAlog.Order__c == null && objRAlog.Emailsent__c == false && (objRAlog.RA_Status__c == 'Open')){
        lstNonRALogDetails.add( new RA_Log_Detail__c(RA_Type__c = currCase.RA_Type__c, Flag_for_Engineering_Dept__c = (objRALog.Case_Sub_Reason__c == 'Defective Product (w/ recall)') ? true : false, RA_Log_Id__c = objRAlog.Id, Unit_under_warranty__c = 'Yes',  Unit_Type_Needed_Non_Serialised__c = (objRALog.Case_Sub_Reason__c == 'Extra Part(s) Ordered' || objRALog.Case_Sub_Reason__c == 'Pilot Return') ? 'None Needed (Return Only)' : null));
        }
    }
    //Method to create Nonserialized devices  
    public PageReference fnSaveNonSerialzed(){                 
       If(objRAlog.Order__c == null && objRAlog.Emailsent__c == false){
                     upsert lstNonRALogDetails;
                    List<RA_Log_Detail__c> lstTemp =[Select Id, Name, Non_Serialized_devices__c,RA_Type__c,Reason_Returned__c,Unit_under_warranty__c, Flag_for_Engineering_Dept__c, 
                        Unit_Type_Needed_Non_Serialised__c,Quantity__c,RA_Location__c, Tracking_Number__c from RA_Log_Detail__c WHERE Id in:lstNonRALogDetails];      
                    lstNonRALogDetails =lstTemp;                  
                    }        
        return null;       
    }
    
    //Method to populate Nonserialized devices
    public void fnInitNonserialisedDeviceList(){
      lstNonRALogDetails = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Non_Serialized_devices__c, Unit_under_warranty__c,
                            Unit_Type_Needed_Non_Serialised__c,Quantity__c, RA_Location__c, Unit_Type_Needed_Serialised__c,Serial_Number__c, Tracking_Number__c  from RA_Log_Detail__c where  RA_Log_Id__c != null AND RA_Log_Id__c =:objRALog.Id and Serial_Number__c = null  order by Name desc]; 
                         
    }
    
    //Method to populate Serialized devices
    public void fnInitSerialisedDeviceList(){
      lstCaseDevice = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Serial_Number__c,Model_Type__c,RA_Location__c, Unit_under_warranty__c,
                        Unit_Type_Needed_Serialised__c,Quantity__c, Tracking_Number__c from RA_Log_Detail__c where  RA_Log_Id__c != null AND RA_Log_Id__c =:objRALog.Id AND Serial_Number__c != null ]; 
                        
    }

  //Method to delete Serialized devices   
  public Pagereference deleteSrialized(){
        If(objRAlog.Order__c == null && objRAlog.Emailsent__c == false && (objRAlog.RA_Status__c == 'Open')){
            System.debug('Value--->' +ApexPages.CurrentPage().getParameters().get('rowid'));
            //Integer SelectedRowId= Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowid'));
            System.debug('lstCaseDevice.size()--->' +lstCaseDevice.size());
                    
            List<RA_Log_Detail__c > lstSerial = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Serial_Number__c,Model_Type__c,RA_Location__c, Unit_under_warranty__c,
                            Unit_Type_Needed_Serialised__c,Quantity__c, Tracking_Number__c from RA_Log_Detail__c where Id =: delDeviceId];
            delete lstSerial;
        }
        lstCaseDevice = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Non_Serialized_devices__c, Unit_under_warranty__c,Unit_Type_Needed_Serialised__c,
                            Unit_Type_Needed_Non_Serialised__c,Quantity__c,Serial_Number__c,Model_Type__c, RA_Location__c, Tracking_Number__c  from RA_Log_Detail__c where  RA_Log_Id__c =: objRaLog.Id and Serial_Number__c != null];
        return null;
        
    }
    
     //Method to delete Non Serialized devices
     public Pagereference deleteNonserialized(){
     If(objRAlog.Order__c == null && objRAlog.Emailsent__c == false && (objRAlog.RA_Status__c == 'Open')){
            System.debug('Value--->' +ApexPages.CurrentPage().getParameters().get('rowid'));
            //Integer SelectedRowId= Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowid'));
            System.debug('lstNonRALogDetails.size()--->' +lstNonRALogDetails.size());                   
            List<RA_Log_Detail__c > lstNonserial = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Non_Serialized_devices__c, Unit_under_warranty__c,
                                Unit_Type_Needed_Non_Serialised__c,Quantity__c, RA_Location__c, Tracking_Number__c from RA_Log_Detail__c where Id =: delDeviceId ];
            delete lstNonserial;
        }     
        lstNonRALogDetails = [Select Id, Name,RA_Log_Id__c,RA_Type__c,Reason_Returned__c, Flag_for_Engineering_Dept__c, Non_Serialized_devices__c, Unit_under_warranty__c,
                            Unit_Type_Needed_Non_Serialised__c,Quantity__c, RA_Location__c, Tracking_Number__c  from RA_Log_Detail__c where  RA_Log_Id__c =: objRaLog.Id and Serial_Number__c = null];
        return null;      
    }
    
  //Method to update RA Information    
    public PageReference UpdateRA(){
         try{
        if(lstNonRALogDetails.size()== 0 && lstCaseDevice.size()==0 && objRAlog.RA_Status__c == 'Open'){       
            objRAlog.Units_In_RA__c = lstNonRALogDetails.size() + lstCaseDevice.size();
            objRAlog.Units_in_RA_Non_Serialized__c = lstNonRALogDetails.size();
            objRAlog.Units_in_RA_Serialized__c = lstCaseDevice.size();
            objRAlog.SendToSQL__c = false;
            update objRAlog;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Please select devices and then click Update RA button.'));
            return null;
        }
       If(objRAlog.Order__c == null && objRAlog.Emailsent__c == false && objRAlog.RA_Status__c == 'Open'){
        fnSaveNonSerialzed();
        objRAlog.Units_In_RA__c = lstNonRALogDetails.size() + lstCaseDevice.size();   
        objRAlog.Units_in_RA_Non_Serialized__c = lstNonRALogDetails.size();
        objRAlog.Units_in_RA_Serialized__c = lstCaseDevice.size();  
        update lstNonRALogDetails;             
        update lstCaseDevice; 
        objRAlog.SendToSQL__c = true;
        update objRAlog;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'RA Updated successfully.'));
        
       } else {
     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,' Updation on RA cannot be done when RA is not in "Open" Status and Order/Email is set.'));
        return null;
        } 
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Valid Quantity {1 to 1000}'));    
        }
     return null ;   
    }
    
    //Method to Perform Validation for Creating Order
    public Boolean performValidations(){
        Boolean isValid = true;
         if(currCase.Case_Sub_Reason__c == 'Pilot Return' || currCase.Case_Sub_Reason__c == 'Possible RA' || currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered'){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Order Cannot be placed for Case Sub Reason Selected!'));
          isValid = false;  
        }
        
        if(objRAlog.Order__c != null){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Order Already Created!'));
          isValid = false; 
         }  
          for(RA_Log_Detail__c raDet : lstNonRALogDetails){
              if(raDet.RA_Location__c == null && !(currCase.Case_Sub_Reason__c == 'Pilot Return' || currCase.Case_Sub_Reason__c == 'Possible RA' || currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select location to create Order'));
              isValid = false;
              }
              if((currCase.Case_Sub_Reason__c == 'Defective Product' && raDet.Unit_under_warranty__c == 'No')||(currCase.Case_Sub_Reason__c == 'Defective Product (w/ recall)' && raDet.Unit_under_warranty__c == 'No') || (currCase.Case_Sub_Reason__c == 'Device lost in Transit' && raDet.Unit_under_warranty__c == 'No')){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Order cannot be placed for devices which are not Under Warranty'));
              isValid = false;
              }
              if(raDet.Unit_under_warranty__c == null){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Unit Under Warranty (Yes/No)'));
              isValid = false;  
              }            
              if(raDet.Unit_Type_Needed_Non_Serialised__c == null && !(currCase.Case_Sub_Reason__c == 'Pilot Return' || currCase.Case_Sub_Reason__c == 'Possible RA' || currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Product to create Order'));
              isValid = false;
              }
                       
          }
          
          for(RA_Log_Detail__c raDet : lstCaseDevice){          
              if(raDet.RA_Location__c == null && !(currCase.Case_Sub_Reason__c == 'Pilot Return' || currCase.Case_Sub_Reason__c == 'Possible RA' || currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select location to create Order'));
              isValid = false;
              }
              if(raDet.Unit_Type_Needed_Serialised__c == null && !(currCase.Case_Sub_Reason__c == 'Pilot Return' || currCase.Case_Sub_Reason__c == 'Possible RA' || currCase.Case_Sub_Reason__c == 'Extra Part(s) Ordered')){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Product to create Order'));
              isValid = false;
              }
              if(currCase.Case_Sub_Reason__c == 'Incorrect Part Ordered'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Send Email using button below to SA for creating New opportunity'));
                isValid = false;
            }
              
          }          
          if((lstCaseDevice.size() == 0 && lstNonRALogDetails.size() == 0 )){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Order Cannot be created with Blank RA Details'));
              isValid = false;
              }
          return isValid;
    }
    
    //Method to Defualt Unit Type Needed automatically for Non-Serialized Devices selected
     public void NSUnitTypeNeeded(){        
        If(lstNonRALogDetails != null && lstNonRALogDetails.size() >0 ){      
                System.debug('lstNonRALogDetails******'+lstNonRALogDetails);
                    for(RA_Log_Detail__c raDet : lstNonRALogDetails){                                        
                                string strvalue1 = raDet.Non_Serialized_devices__c;
                                System.debug('strvalue1 ******'+strvalue1 );                            
                                raDet.Unit_Type_Needed_Non_Serialised__c = strvalue1;                           
                    }          
         }
         System.debug('lstNonRALogDetails after ******'+lstNonRALogDetails);
    }    
    
    //Method To create Order for RA case 
    public PageReference createOrder(){     
        Map<String, RA_Order_Promocode__mdt> mapOrdPromoCode = new Map<String, RA_Order_Promocode__mdt>();
        for(RA_Order_Promocode__mdt RAFieldMdt : [Select Case_Sub_Reason__c, Order_Types__c, PO_Number__c, Promo_Code__c, Shipping_Methods__c, Id From RA_Order_Promocode__mdt]){
            mapOrdPromoCode.put(RAFieldMdt.Case_Sub_Reason__c, RAFieldMdt);
        }
        
         
        try{
            System.debug('Inside Create Order');
            
            boolean checkValid = performValidations();
            
            System.debug('Messages::'+ApexPages.hasMessages());
            if(!checkValid || ApexPages.hasMessages(ApexPages.Severity.Error)){
                return null;
            }
            UpdateRA(); 
            /*List<Orders__c> ordList = [Select Id from Orders__c where Case__c =: currCase.Id];
            if(ordList.size() > 0){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Order Already Created!'));
                    return null;
            }*/
            
            
            if( objRAlog.Order__c == null ) {
                ord = new Orders__c(Account__c = currCase.AccountId, Case__c = currCase.Id, RecordTypeId = ordRecType, Order_Status__c = 'NEW',isEoOrder__c = true, Ship_To_Installer__c = 'N');                
                insert ord;
            } 
            
            if( ( objRAlog.Order__c == null ) || (ord.Order_Status__c == 'NEW') ){
                
                If(objRAlog.Order__c == null){
                    objRAlog.Order__c = ord.Id;
                }  
                If(ord.Order_Status__c == 'NEW') {
                    objRAlog.RA_Status__c = 'Processing';
                }
                
                update objRAlog;
            }    
            
            if((lstCaseDevice.size() > 0 || lstNonRALogDetails.size() > 0 )){
                Order_Product__c ordPrd;
                Map<String, decimal> uniqueLocs = new Map<String, decimal>();
                Set<String> uniqueLocations = new Set<String>();
                
                
                for(RA_Log_Detail__c raDet : lstNonRALogDetails){
                    
                   System.debug('Under Wrnty::'+raDet.Unit_under_warranty__c );
                   
                    if(!uniqueLocs.containsKey(raDet.Unit_Type_Needed_Non_Serialised__c+ raDet.RA_Location__c)){
                      
                      ordLoc = new OrderLocation__c(Location__c = raDet.RA_Location__c, Orders__c = ord.Id);
                        
                        if(mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c) != null){
                            ord.Order_Types__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Order_Types__c;
                            ord.Shipping_Methods__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Shipping_Methods__c;
                            ordLoc.Shipping_Method__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Shipping_Methods__c;
                            ord.Promo_Code__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Promo_Code__c;
                            if(mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).PO_Number__c != null){
                            ordLoc.PO_Number__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).PO_Number__c + currCase.CaseNumber;
                            }
                        }
                        
                        //if(!uniqueProd.contains(raDet.Unit_Type_Needed_Non_Serialised__c)){
                         ordPrd = new Order_Product__c(Order_Details__c = ord.Id, Quantity__c = raDet.Quantity__c  , Sales_Price__c = 0, Location__c = raDet.RA_Location__c);
                        if(raDet.Unit_Type_Needed_Non_Serialised__c != null){
                            if(raDet.Unit_Type_Needed_Non_Serialised__c.contains(')')){
                                ordPrd.Product_Name__c = raDet.Unit_Type_Needed_Non_Serialised__c.substringAfter(')');
                                ordPrd.Product_Code__c = raDet.Unit_Type_Needed_Non_Serialised__c.substringbetween('(', ')');
                            }else{
                                ordPrd.Product_Name__c = raDet.Unit_Type_Needed_Non_Serialised__c;
                            }               
                            
                        }
                        //uniqueProd.add(raDet.Unit_Type_Needed_Non_Serialised__c);
                        prodNames.add(ordPrd.Product_Code__c);
                        if(raDet.Unit_Type_Needed_Non_Serialised__c != 'None Needed (Return Only)'){
                        tempOrdProdLst.add(ordPrd);
                        }
                        uniqueLocs.put(raDet.Unit_Type_Needed_Non_Serialised__c + raDet.RA_Location__c, raDet.Quantity__c);
                        if(!uniquelocations.contains(raDet.RA_location__c)){
                        uniquelocations.add(raDet.RA_location__c);
                        ordLocLst.add(ordLoc);
                        }
                    }else{
                        uniqueLocs.put(raDet.Unit_Type_Needed_Non_Serialised__c + raDet.RA_Location__c, uniqueLocs.get(raDet.Unit_Type_Needed_Non_Serialised__c + raDet.RA_Location__c) + raDet.Quantity__c); 
                    }
                    
                   
                }
                for(RA_Log_Detail__c raDet : lstCaseDevice){          
                    System.debug('Under Wrnty::'+raDet.Unit_under_warranty__c );
                    
                    if(!uniqueLocs.containsKey(raDet.Unit_Type_Needed_Serialised__c+ raDet.RA_Location__c)){
                        ordLoc = new OrderLocation__c(Location__c = raDet.RA_Location__c, Orders__c = ord.Id);
                        
                        if(mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c) != null){
                            ord.Order_Types__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Order_Types__c;
                            ord.Shipping_Methods__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Shipping_Methods__c;
                            System.debug('Shipping Method:::' +mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Shipping_Methods__c);
                            ordLoc.Shipping_Method__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Shipping_Methods__c;
                            ord.Promo_Code__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).Promo_Code__c;
                            if(mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).PO_Number__c != null){
                            ordLoc.PO_Number__c = mapOrdPromoCode.get(objRALog.Case_Sub_Reason__c).PO_Number__c + currCase.CaseNumber;
                            }
                        }
                        
                    
                    ordPrd = new Order_Product__c(Order_Details__c = ord.Id, Quantity__c = 1 , Sales_Price__c = 0, Location__c = raDet.RA_Location__c);  
                    
                    if(raDet.Unit_Type_Needed_Serialised__c != null){
                        if(raDet.Unit_Type_Needed_Serialised__c.contains('(')){
                            ordPrd.Product_Name__c = raDet.Unit_Type_Needed_Serialised__c.substringBefore('(');
                            ordPrd.Product_Code__c = raDet.Unit_Type_Needed_Serialised__c.substringbetween('(', ')');
                        }else{
                            ordPrd.Product_Name__c = raDet.Unit_Type_Needed_Serialised__c;
                        }
                        
                    }
                    //uniqueProd.add(raDet.Unit_Type_Needed_Serialised__c);
                    prodNames.add(ordPrd.Product_Code__c);
                    if(raDet.Unit_Type_Needed_Serialised__c != 'None Needed (Return Only)'){
                    tempOrdProdLst.add(ordPrd);
                      }
                    uniqueLocs.put(raDet.Unit_Type_Needed_Serialised__c + raDet.RA_Location__c, 1);
                     if(!uniquelocations.contains(raDet.RA_location__c)){
                        uniquelocations.add(raDet.RA_location__c);
                       ordLocLst.add(ordLoc);
                     }
                    }else{
                        uniqueLocs.put(raDet.Unit_Type_Needed_Serialised__c + raDet.RA_Location__c, uniqueLocs.get(raDet.Unit_Type_Needed_Serialised__c + raDet.RA_Location__c) + 1); 
                    }
                    
                   
                }
                //update ord;
                System.debug('ordLocLst::'+ordLocLst);
                System.debug('Unique::'+uniqueLocs);
                if(ordLocLst.size() > 0 ){
                    insert ordLocLst;
                    for(OrderLocation__c ordL : ordLocLst){
                        locOrdMap.put(ordL.Location__c, ordL);
                    }
                    Location__c loc = [Select Id, ContactName__c, Phone__c, Email__c from Location__c where Id =: ordLocLst[0].Location__c Limit 1];
                    ord.Contact_Person__c = loc.ContactName__c;
                    ord.Phone__c = loc.Phone__c;
                    ord.Contact_Email__c = loc.Email__c;
                    
                }
                System.debug('locOrdMap::'+locOrdMap);
                update ord;
                
                if(tempordProdLst.size() > 0){
                    for(Product2 prd : [Select Id, Name, ProductCode from Product2 where ProductCode IN : prodNames]){
                        mapProdNames.put(prd.ProductCode, prd);
                    }
                    system.debug('uniqueLocs::'+uniqueLocs);
                    for(Order_Product__c oPrd : tempOrdProdLst){
                        if(mapProdNames.containsKey(oPrd.Product_Code__c)){
                            oPrd.Order_products__c = mapProdNames.get(oPrd.Product_Code__c).Id;
                        }
                        if(locOrdMap.get(oPrd.Location__c) != null){
                            oPrd.OrderLocationMappings__c = locOrdMap.get(oPrd.Location__c).Id;
                        }
                        if(uniqueLocs.get(oPrd.Product_name__c +'('+oPrd.Product_Code__c+')' + oPrd.Location__c) != null){
                        System.debug('Product Name::'+oPrd.Product_name__c+'Product Code::' +oPrd.Product_Code__c+'Location::'+ oPrd.Location__c);
                        oPrd.Quantity__c = uniqueLocs.get(oPrd.Product_name__c +'('+oPrd.Product_Code__c+')' + oPrd.Location__c); 
                        }
                        if(uniqueLocs.get('('+oPrd.Product_Code__c +')'+oPrd.Product_Name__c + oPrd.Location__c) != null){
                        System.debug('Product Name::'+oPrd.Product_name__c+'Product Code::' +oPrd.Product_Code__c+'Location::'+ oPrd.Location__c);
                        oPrd.Quantity__c = uniqueLocs.get('('+oPrd.Product_Code__c +')'+oPrd.Product_Name__c + oPrd.Location__c); 
                        }
                        ordProdLst.add(oPrd);
                    }
                    System.debug('ordProdLst::'+ordProdLst);
                    insert ordProdLst;
                }
                
                if(locOrdMap.size() >0){
                    List<RA_Log_Detail__c> lstRAOrderDetails =[Select Id, Order_Activities__c, RA_Location__c from RA_Log_Detail__c 
                        where RA_Log_Id__r.Order__c =:ord.id  AND   RA_Location__c in: locOrdMap.keySet()];
                    System.debug('lstRAOrderDetails::'+lstRAOrderDetails);  
                    System.debug('locOrdMap.::'+locOrdMap);
                    if(lstRAOrderDetails != null && lstRAOrderDetails.size() >0){
                        for(RA_Log_Detail__c objRALD: lstRAOrderDetails){
                            System.debug('objRALD.RA_Location__c::'+objRALD.RA_Location__c);
                            System.debug('locOrdMap.get(objRALD.RA_Location__c).Id::'+locOrdMap.get(objRALD.RA_Location__c).Id);                           
                            //objRALD.Order_Activity_Id__c = String.valueOf(locOrdMap.get(objRALD.RA_Location__c).Order_Activity_ID__c);
                            objRALD.Order_Activities__c = locOrdMap.get(objRALD.RA_Location__c).Id;
                        }
                    }
                    update lstRAOrderDetails;
                }
            }           
                
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            
        }
        
        Pagereference pg = new PageReference('/'+ord.Id);
        pg.setRedirect(true);
        
        return pg;
    }
    
    public List<SelectOption> getDispositionList() {
        List<SelectOption> options = new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = Case_Device__c.Disposition_Type__c.getDescribe();
        List<Schema.PicklistEntry> pleDisp = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry fieldV : pleDisp){
            options.add(new SelectOption(fieldV.getLabel(), fieldV.getValue()));
        }       
        return options;
    }
    
    public RA_Log__c getRALogDisplay() {
        return objRAlog;
    }   
    
    // Send Email for Incorrect Part Ordered
    public void SendEmail(){
    
        try{           
            //UpdateRA();
                if(lstCaseDevice.size() == 0){
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Email will be sent only for Incorrect Part Ordered with Serialized Devices'));
                }
                
                
                
                               
                If(((lstNonRALogDetails.size()>0 && lstCaseDevice.size()> 0) || lstCaseDevice.size()> 0) && objRALog.Emailsent__c == true){                            
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Email already Sent '));  
                                                   
                } 
                
                if(lstCaseDevice.size() > 0){
                for(RA_Log_Detail__c rld : lstCaseDevice){
                    
                        if(rld.Unit_Type_Needed_Serialised__c == null){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Unit type needed'));
                        return;
                       }
                       if(rld.RA_Location__c == null){
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select location'));
                        return;
                       }
                        
                  } 
                  }
                   
                  if(lstNonRALogDetails.size() > 0){ 
                    for(RA_Log_Detail__c rd : lstNonRALogDetails) {
                        if(rd.Unit_Type_Needed_Non_Serialised__c == null){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Non Serialised Unit type needed'));
                        return;
                       }
                       if(rd.RA_Location__c == null){
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select location'));
                        return;
                       }
                       if(rd.Quantity__c == null){
                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select Quantity'));
                        return;
                       }
                     }         
                  }                               
                                                    
                If(((lstNonRALogDetails.size()>0 && lstCaseDevice.size()> 0) || lstCaseDevice.size()> 0) && objRALog.Emailsent__c == false && objRALog.RA_Status__c == 'Open' ){
                  
                     objRALog.Emailsent__c = true; 
                     objRAlog.SendToSQL__c = true;                    
                     //UpdateRA();
                     
                     update lstNonRALogDetails;             
                     update lstCaseDevice; 
                     objRAlog.Units_In_RA__c = lstNonRALogDetails.size() + lstCaseDevice.size();
                     update objRALog;
                     EmailTemplate et=[Select id from EmailTemplate where Developername = 'Opportunity_Information_For_RA_Exchange' limit 1];   
                     OrgwideEmailAddress orgWide = [Select Id, Address from OrgwideEmailAddress where DisplayName = 'NWF Integration']; 
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     String[] ccAddresses = new String[] {};
                     ccAddresses.add(currCase.Fleet_Account__r.Email_Account_Owner__c);
                     mail.setOrgWideEmailAddressId(orgWide.Id);
                     mail.setTargetObjectId(currCase.Fleet_Account__r.SOS_Owner__c);
                     mail.setccAddresses(ccAddresses); 
                     mail.setTemplateId(et.id);  
                     mail.setSaveasActivity(false); 
                     mail.setWhatId(objRALog.Id);     
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                    
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Email Sent successfully'));                                      
                }                                                                                        
        }catch(Exception ex){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));         
        }       
    }  
   
   public List<SelectOption> getRAList() {
        List<SelectOption> options = new List<SelectOption>();       
        Schema.DescribeFieldResult fieldResult = RA_Log_Detail__c.RA_Type__c.getDescribe();
        List<Schema.PicklistEntry> pleDisp = fieldResult.getPicklistValues();             
            if(objRAlog.Case_Sub_Reason__c == 'Damaged or Lost Device Under Contract' || objRAlog.Case_Sub_Reason__c == 'Defective Product'){
                options.add(new SelectOption('Replace - Product (No return)','Replace - Product (No return)'));
            }
            if(objRAlog.Case_Sub_Reason__c == 'Extra Part(s) Ordered'){
                options.add(new SelectOption('Return - Product (New)','Return - Product (New)'));   
            }
            if(objRAlog.Case_Sub_Reason__c == 'Defective Product (w/ recall)'){
                options.add(new SelectOption('Replace - Product (w/ return)','Replace - Product (w/ return)'));
            }
            if(objRAlog.Case_Sub_Reason__c == 'Pilot Return'){
                options.add(new SelectOption('Return - Product (New)','Return - Product (New)'));
                options.add(new SelectOption('Return - Product (Open)','Return - Product (Open)'));
            }
            if(objRAlog.Case_Sub_Reason__c == 'Incorrect Part Ordered'){
                options.add(new SelectOption('Exchange - Product (New)','Exchange - Product (New)'));
                options.add(new SelectOption('Exchange - Product (Open)','Exchange - Product (Open)'));
            }  
             if(objRAlog.Case_Sub_Reason__c == 'Device lost in Transit'){
                options.add(new SelectOption('Replace - Product (No return)','Replace - Product (No return)'));
                options.add(new SelectOption('Replace - Product (w/ return)','Replace - Product (w/ return)'));
            }           
        return options;
    }
    
    Public void CancelRA(){
            If(objRAlog.RA_Status__c == 'Open') {
                objRAlog.RA_Status__c = 'Cancelled';
            }                       
        update objRAlog;
    } 
    
    public void assignUnitType(){
        
        System.debug('nonSerdevices::'+nonSerdevices+'--lstNonRAlogdetails--'+lstNonRAlogdetails);
        
        for(RA_Log_Detail__c raLog : lstNonRAlogdetails){
            
            
        }
        
    }
    
    public String nonSerdevices{get; set;}
    
    public void setDispositions(){
        String dispValue;
        if(selectedDeviceList.size() > 0){
            dispValue = 'RA'; //selectedDeviceList[0].dispositionType;
            System.debug('ddd::'+dispValue);
            for(CaseDevices cd : selectedDeviceList){
               if(cd.DispositionType == null || cd.DispositionType == 'None'){
                    cd.DispositionType = dispValue;
                    System.debug('cd.Disp::'+cd.DispositionType);
                }
            }
        
        }
    }
    public void setLocationsSerialized(){
        String locValue;
        if(lstCaseDevice.size() > 0){
            locValue = lstCaseDevice[0].RA_Location__c;
            //System.debug('ddd::'+dispValue);
            for(RA_Log_Detail__c loc : lstCaseDevice){
               // if(loc.RA_Location__c == null){
                    loc.RA_Location__c = locValue;
                    System.debug('RA.Loc::'+loc.RA_Location__c);
               // }
            }
        
        }
    }
    
    public void setLocationsNonSerialized(){
        String locValue1;
        if(lstNonRALogDetails.size() > 0){
            locValue1 = lstNonRALogDetails[0].RA_Location__c;
            //System.debug('ddd::'+dispValue);
            for(RA_Log_Detail__c loc : lstNonRALogDetails){
              //  if(loc.RA_Location__c == null){
                    loc.RA_Location__c = locValue1;
                    System.debug('RA.Loc::'+loc.RA_Location__c);
              //  }
            }
        
        }
    }
}