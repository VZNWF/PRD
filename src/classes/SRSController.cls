/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Sunil Kumar Sirangi
// File Name:       SRSController 
// Summary:         Controller for new IODS site page
// Created On:      06-08-2017

// Modification Log:
====================
// Sunil      - 06-08-2017 - Created Controller to handle the logic for IODS new design - IT-1931
// Siva A	  - 10-28-2017 - Worked on the update balance quantity and 'schedule new service' dynamic rendering functionality.
// Tiresh     - 12-18-2017 - Replaced the Notes__c field to Activity_Notes__c and decresed the field limit from 2000 to 256 IT-2634
// Tiresh     - 12-14-2017 - Implemented View locaton functionality IT-2555
// Siva A	  - 01/05/2018 - Incorporated the pagination - Search, Submit All Vehicles, Location Filter - IT-2715, IT-2802
*******************************************************************************/
global class SRSController{
    public list<Location__c> locationList {get; set;}
    public LocationWrapper locationWrapper {get; set;} // to hold location input data 
    public LocationWrapper addlocationWrapper {get; set;} // to hold location input data
    public VehicleWrapper vehicleWrapper {get; set;} // to hold vehicle input data   
    public list<SelectedLocationWrapper> selectedLocationWrapperList {get; set;}
    public list<SelectedVehicleWrapper> selectedVehicleWrapperList {get; set;}
    public string orderId;
    public Id accountId;
    public Orders__c orderRecord {get; set;}
    public map<Id,Integer> locVehicleCountMap {get; set;}
    public integer allVehiclesCount {get; set;}
    public string VINNumber {get; set;}
    public String selectedLocationVeh{get; set;} // to set the value of location on Vehicle screen
    public Boolean selectedLocationVehFlag{get; set;} // to hide/display the location column when a location is selected
    private  list<Order_Line_Item_Details__c> vehicleList ;
    public list<SelectedVehicleWrapper> submittedVehicleWrapperList {get; set;}
    public Boolean noVINDataFlag {get; set;} // Flag to display alert when VIN number returns no data
    public Boolean locationStateFlag {get; set;} 
    //public Map<String,Integer> installQuantityMap {get; set;} // to display purchased services
    public Map<String,Integer> remainingServices {get; set;} // to hold remaining balances
    public String remainingQuantity {get; set;} // to display remaining services  
    public String editvehicle {get; set;} // parameter to hold edited vehicle record Id
    public Boolean displayChildAccount {get; set;} // to display child account field for resellers
    public String childAccountName {get; set;} // to hold Child Account value
    public List<Location__c> preferredDatesLocationList {get; set;}
    public Integer availableServices {get; set;}
    global string documentURL {get; set;} // to download vehicle template
    global string documentURL1 {get; set;} // to download User Video 
    global string documentURL2 {get; set;} // to download User Guide  
    global Integer documentSize {get; set;}
    global String csvHeaders {get; set;} // to validate column headers of csv file    
    public List<document> documentList; 
    public List<document> documentList1;
    public List<document> documentList2;  
    public Integer leftBalance {get ;set;}   
    public string listValue {get;set;}
    public Map<String,Integer> locationRecCountMap {set;get;}
    private Map<Id,List<Order_Line_Item_Details__c>> locVehicleMap;
    private Map<String,List<Id>> installOrderLineItemMap;
    private list<Order_Line_Items__c> orderLineItemsList;
    private List<Harness_Guide__c> harnessList = new List<Harness_Guide__c>();
    private Map<String,Integer> serviceBalances = new Map<String,Integer>();
    public list<selectOption> states{get;set;}
    
    //added by Siva - Begin
    Map<String, List<Order_Line_Items__c>> orderLineItemMap;
    //transient Map<String, Integer> balanceQuantityMap;
    public Map<String, balanceQuantity> finalQuantityMap;
    private Map<String, Set<String>> accessoriesMap;
    public List<balanceQuantity> balanceQuantityList {get; set;}
    public Set<String> serviceTypeSet {get; set;}
    public Set<String> availableAccessoriesSet {get; set;}
    public Set<String> deviceTypeSet {get; set;}
    private Set<String> assetGuardSet = new Set<String>{'Asset Guard PW (Hardwired)','Asset Guard BX (Battery Powered)'};
    public Decimal availSensorCount {get; set;}
    private Decimal availedSensorCount;
    transient Set<String> selectedAccessoriesSet;
    Map<String, Set<String>> selectedAccessoriesMap;
    private List<Order_Line_Item_Entry__c> oLIEntries;
    public Map<String, Integer> sensorCountInstallTypeMap;
    private Map<Id, Order_Line_Item_Details__c> oliDetailEntryMap;
    private Map<String, Set<String>> availableDevicesMap;
    private Map<String, Set<String>> editDeviceMap;
    private Map<String, Service_Type_Display_Message__mdt> serviceTypeDataDct;
    //Pagination specific member variables -- Start
    public String searchVariableNewTable {get; set;}
    public String searchVariableSubmittedTable {get; set;}
    public boolean resetNewSearchFlag {get; set;}
    public boolean resetSubmittedSearchFlag {get; set;}
    public boolean searchSRSSubmittedFlag {get; set;}
    public boolean searchSRSNewFlag {get; set;}
    public boolean disableEditofLocation{get; set;}
    private boolean locationFilterOnNewFlag;
    public boolean resetLocationFilterOnNewFlag {get; set;}
    private boolean locationFilterOnSubmittedFlag;
    public boolean resetLocationFilterOnSubmittedFlag {get; set;}
    public decimal noOfSubmittedFilteredRecords {get; set;}
    public decimal noOfNewFilteredRecords {get; set;}
    public String filterLocationName {get; set;}
    public Integer sizeOfSubmittedRecords{get;set;} 
    public Integer noOfSubmittedRecords{get; set;} 
    //public List<SelectOption> paginationSizeOptionsForSubmitted{get;set;}
    public Integer noOfPageForSubmitted{get;set;}
    public Integer sizeOfNewRecords{get;set;}
    public Integer noOfNewRecords{get; set;} 
    //public List<SelectOption> paginationSizeOptionsForNew{get;set;}
    public Integer noOfPageForNew{get;set;}
    //Pagination specific member variables -- End
    
    public String submitAllStatusMessage {get; set;}
    //added by Siva - End
    
    //Added by Siva - Start
    public class balanceQuantity{
        public String installType {get; set;}
        public String serviceType {get; set;}
        public String installDevice {get; set;}
        public Integer GPQuantity {get; set;}
        public Integer GPBalance {get; set;}
        public boolean isAddon {get; set;}
        public boolean isPrimaryDevice {get; set;}
        public String key {get; set;}
        
    }
    //Added by Siva - End
    
    //public string listValue {get;set;}
    // constructor to intilaize variables
    public SRSController(){
        //Add the following header to resolve the compatibility issues in IE
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        resetNewSearchFlag = false;
        resetSubmittedSearchFlag = false;
        searchSRSSubmittedFlag = false;
        searchSRSNewFlag = false;
        locationFilterOnNewFlag = false;
        resetLocationFilterOnNewFlag = false;
        locationFilterOnSubmittedFlag = false;
        resetLocationFilterOnSubmittedFlag = false;
        getDisplayMessagesMetadata();
        locationList = new list<location__c>();
        listValue = '';
        locationWrapper = new LocationWrapper();
        addlocationWrapper = new LocationWrapper(); 
        selectedLocationWrapperList = new list<SelectedLocationWrapper>();
        vehicleWrapper = new VehicleWrapper();        
        selectedVehicleWrapperList = new list<SelectedVehicleWrapper>(); 
        allVehiclesCount = 0;
        vehicleList = new list<Order_Line_Item_Details__c>();
        submittedVehicleWrapperList = new list<SelectedVehicleWrapper>();
        //Added by Siva - Begin
        orderLineItemMap = new Map<String, List<Order_Line_Items__c>>();
        //balanceQuantityMap = new Map<String, Integer>();
        finalQuantityMap = new Map<String, balanceQuantity>();
        balanceQuantityList = new List<balanceQuantity>();
        serviceTypeSet = new Set<String>();
        availableAccessoriesSet = new Set<String>();
        deviceTypeSet = new Set<String>();
        accessoriesMap = new Map<String, Set<String>>();
        availSensorCount = 0;
        availedSensorCount = 0;
        oliDetailEntryMap = new Map<Id, Order_Line_Item_Details__c>();
        availableDevicesMap = new Map<String, Set<String>>();
        editDeviceMap = new Map<String, Set<String>>();
        oLIEntries = new List<Order_Line_Item_Entry__c>();
        selectedAccessoriesMap = new Map<String, Set<String>>();
        
        /* S ####$$$$ */
        
        sizeOfSubmittedRecords = 10;
        /*paginationSizeOptionsForSubmitted = new List<SelectOption>();
        paginationSizeOptionsForSubmitted.add(new SelectOption('5','5'));
        paginationSizeOptionsForSubmitted.add(new SelectOption('10','108'));
        paginationSizeOptionsForSubmitted.add(new SelectOption('20','20'));
        paginationSizeOptionsForSubmitted.add(new SelectOption('50','50'));
        paginationSizeOptionsForSubmitted.add(new SelectOption('100','100'));*/
        
        
        sizeOfNewRecords = 10;
        /*paginationSizeOptionsForNew = new List<SelectOption>();
        paginationSizeOptionsForNew.add(new SelectOption('5','5'));
        paginationSizeOptionsForNew.add(new SelectOption('10','10'));
        paginationSizeOptionsForNew.add(new SelectOption('20','20'));
        paginationSizeOptionsForNew.add(new SelectOption('50','50'));
        paginationSizeOptionsForNew.add(new SelectOption('100','100'));*/
        
        /* E ####$$$$ */
        
        
        //Added by Siva - End
        
        //selectedLocationVehFlag = false;
        //selectedLocationVeh = null;
        displayChildAccount = false;
        locationStateFlag = false;
        
        editvehicle = null;
        locAccDetails();
        locationDetails();
        fetchHarnessData();
        
        fetchlocationVehicles(); /* S ####$$$$ E */
        setSRSSubmitted = null;
        fetchSubmittedLocationVehicles();
        setSRSNew = null;
        fetchNewLocationVehicles();
        
        updateBalanceQuantity();
        
        //Added by Siva - begin
        //vehWrapperAvailableAccessories(vehicleWrapper); //Should be called after the updateBalanceQuantity method
        //Added by Siva - End
        //balanceLeft();
        displayChildAccount();
        csvHeaders=json.serialize(CSVHeaders__c.getAll().keyset());
        documentList=[select id,name,body,BodyLength from document where Name IN ('Vehicle_Template_SRS', 'Help', 'Video')];
        for(document d : documentList )
        {
      
           if(d.Name == 'Vehicle_Template_SRS')
           {
                documentURL=d.id;
                documentSize=d.BodyLength;
                
            }   
            
           if(d.Name == 'Help')
           {
                documentURL1=d.id;
                documentSize=d.BodyLength;
                
                
            }     
           
           if(d.Name == 'Video')
           {
                documentURL2=d.id;
                documentSize=d.BodyLength;
            
            }   
        }
        //Calling the get state method
        locationWrapper.country = 'USA';
        addlocationWrapper.country = 'USA';
        states=new list<selectOption>();
        getStates(); 
        disableEditofLocation=false;       
    }
    
    // parameter variable and accountid of the order
    public void locAccDetails(){
        orderId = ApexPages.currentPage().getParameters().get('id');
        orderRecord = [Select Id,Name,Account__c,Child_Account__c,Child_Account__r.Name,GP_ERP_Order_ID__c from Orders__c where Id=:orderid];        
        accountId = orderRecord.Account__c;
        childAccountName = orderRecord.Child_Account__r.Name; // if child account already exists display it.
    }    
    
    // To display available locations
    public pagereference locationDetails(){
        selectedLocationWrapperList.clear();        
        //System.debug('*********113******');
        
        map<id,integer> locationOrderLineMap = new map<id,integer>();
        list<Location__c> locationList = [Select Id,Name,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_State__c,Garage_Country__c,Garage_Zip__c,Preferred_Install_Date_Time_1__c,Preferred_Install_Date_Time_2__c from Location__c where Customer__c =: accountId order by createddate desc limit 800];
        
        
        list<Order_Line_Item_Details__c> ordList = [Select Id,Location__c from Order_Line_Item_Details__c where Location__c =: locationList AND SF_Orders__c =: orderId and issubmitted__c = false ];
        
        for(Order_Line_Item_Details__c olD: ordList){
            if(locationOrderLineMap.containsKey(olD.Location__c)){
                integer count = locationOrderLineMap.get(olD.Location__c);
                locationOrderLineMap.put(olD.Location__c,count++);              
            }else{
                locationOrderLineMap.put(olD.Location__c,1);
            }           
        }
        
        for(Location__c loc :locationList ){
            SelectedLocationWrapper slw = new SelectedLocationWrapper();
            if(locationOrderLineMap.containsKey(loc.Id) && locationOrderLineMap.get(loc.Id) > 0){
                slw.isLocSelected = true;                
            }else{
                slw.isLocSelected = false;
            }
            slw.selectedLocation = loc;
            selectedLocationWrapperList.add(slw);
        }
        showSelectedLocations();
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        return pageRef;
    } 
    
    /* public void locationDetails(){
    selectedLocationWrapperList.clear();        
    for(Location__c loc : [Select Id,Name,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_State__c,Garage_Country__c,Garage_Zip__c,Preferred_Install_Date_Time_1__c,Preferred_Install_Date_Time_2__c,(Select Id from Order_Line_Item_Details__r where SF_Orders__c =: orderId and issubmitted__c = false) from Location__c where Customer__c =: accountId order by createddate desc LIMIT 800]){
    SelectedLocationWrapper slw = new SelectedLocationWrapper();
    if(loc.Order_Line_Item_Details__r.size() > 0){
    slw.isLocSelected = true;                
    }else{
    slw.isLocSelected = false;
    }
    slw.selectedLocation = loc;
    selectedLocationWrapperList.add(slw);
    }
    showSelectedLocations();
    } */
    
    // To display selected locations
    public void showSelectedLocations(){
        //system.debug('***inside showSelectedLocations');
        locationList.clear(); 
        for(SelectedLocationWrapper sl : selectedLocationWrapperList){
            if(sl.isLocSelected == true){
                locationList.add(sl.selectedLocation); 
            }
        }
        fetchNewLocationVehicles();
        fetchlocationVehicles();
    }
    

    //Pagination StandardSetController for Submitted table
    public ApexPages.StandardSetController setSRSSubmitted {
        get {
            if(searchSRSSubmittedFlag){  //To exclude 'false' and 'null' scenarios
                List<Order_Line_Item_Details__c> olidList = new list<Order_Line_Item_Details__c>();
                if(searchVariableSubmittedTable != ''){
                    String searchVariableSubmittedTable1 = '*'+searchVariableSubmittedTable+'*';
                    List<List<SObject>> searchresultList = [FIND :searchVariableSubmittedTable1 IN ALL FIELDS RETURNING Order_Line_Item_Details__c(Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c, License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                         Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c, Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c,Not_a_Vehicle__c where SF_Orders__c =: OrderId and isSubmitted__c = true)];
        
                    olidList = (List<Order_Line_Item_Details__c>) searchResultList.get(0);
                    Set<Id> olidIdSet = new Set<Id>();
                    for(Order_Line_Item_Details__c olidT: olidList){
                        olidIdSet.add(olidT.Id);
                    }
                    
                    setSRSSubmitted = new ApexPages.StandardSetController(olidList);
                    setSRSSubmitted.setPageSize(sizeOfSubmittedRecords);
                    noOfSubmittedFilteredRecords = setSRSSubmitted.getResultSize(); 
                    //noOfSubmittedRecords = olidList.size();
                
                    noOfPageForSubmitted = 1;
                    if(noOfSubmittedFilteredRecords !=  null && noOfSubmittedFilteredRecords !=0){
                        noOfPageForSubmitted =  (Integer)(noOfSubmittedFilteredRecords/(Decimal)sizeOfSubmittedRecords).round(System.RoundingMode.CEILING);
                        //noOfPageForSubmitted = ((noOfSubmittedRecords - tmpPageCal) / sizeOfSubmittedRecords) + (tmpPageCal >= 0 ? 1 : 0);
                    }
                    //return new ApexPages.StandardSetController(olidList);
                    searchSRSSubmittedFlag = false;
                }
            }else if(locationFilterOnSubmittedFlag){
            	vehicleList = new List<Order_Line_Item_Details__c>();
            	if(selectedLocationVeh != null && locVehicleMap.containsKey(selectedLocationVeh)){
                	vehicleList.addAll(locVehicleMap.get(selectedLocationVeh));
                }
                
                List<Order_Line_Item_Details__c> submittedVehicleList = new List<Order_Line_Item_Details__c>();
                if(!vehicleList.isEmpty()){
                    for(Order_Line_Item_Details__c vehicle : vehicleList){
                        if(vehicle.isSubmitted__c){
                            submittedVehicleList.add(vehicle);                  
                        }
                    }
                }
                
                setSRSSubmitted = new ApexPages.StandardSetController(submittedVehicleList);
                setSRSSubmitted.setPageSize(sizeOfSubmittedRecords);  
                noOfSubmittedFilteredRecords = setSRSSubmitted.getResultSize();
                
                noOfPageForSubmitted = 1;
                if(noOfSubmittedFilteredRecords !=  null && noOfSubmittedFilteredRecords !=0){
                    noOfPageForSubmitted =  (Integer)(noOfSubmittedFilteredRecords/(Decimal)sizeOfSubmittedRecords).round(System.RoundingMode.CEILING);
                }
            	//Set the flags
            	locationFilterOnSubmittedFlag = false;
            	resetLocationFilterOnSubmittedFlag = true;
            }else if(setSRSSubmitted == null){
            	vehicleList = new List<Order_Line_Item_Details__c>();
                allVehiclesCount = 0;
                locVehicleCountMap = new map<Id,Integer>();
                vehicleList.clear();
                selectedLocationVehFlag = true;        
                locVehicleMap = new Map<Id,List<Order_Line_Item_Details__c>>();        
                /*set<Id> locIdSet = new set<Id>();
                for(Location__c loc: [Select Id,Name from Location__c where Customer__c =: accountId LIMIT 800]){
                    locIdSet.add(loc.id);
                }*/
                
                for(Order_Line_Item_Details__c OlItem : [Select Id,Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c,
                                                         License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                         Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,
                                                         Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c,Not_a_Vehicle__c  
                                                         from Order_Line_Item_Details__c where location__r.customer__c=:accountId AND SF_Orders__c =: orderId order by CreatedDate DESC]){
                    if(locVehicleMap.containskey(OlItem.location__c)){
                        locVehicleMap.get(OlItem.location__c).add(OlItem);
                    }else{
                        list<Order_Line_Item_Details__c> oList = new list<Order_Line_Item_Details__c>();
                        oList.add(OlItem);
                        locVehicleMap.put(OlItem.location__c,oList); 
                    }
                }
                
                for(Id locId : locVehicleMap.keyset()){
                    locVehicleCountMap.put(locId,locVehicleMap.size());
                }
                
                
                //oliDetailEntryMap = new Map<Id, Order_Line_Item_Details__c>([Select Id, Name, (select Id, Installed_Device__c, Order_Line_Item__r.TypeOfDevice__c, Order_Line_Item__r.Devices_Installed__c from Order_Line_Item_Entries__r) from Order_Line_Item_Details__c where SF_Orders__c =: orderId]);
                
                for(Id locId : locVehicleCountMap.keySet()){
                    allVehiclesCount = allVehiclesCount + 1;
                }
                
                for(String loc : locVehicleMap.keySet()){
	                vehicleList.addAll(locVehicleMap.get(loc));     
                }    
	                
                List<Order_Line_Item_Details__c> submittedVehicleList = new List<Order_Line_Item_Details__c>();
                if(!vehicleList.isEmpty()){
                    for(Order_Line_Item_Details__c vehicle : vehicleList){
                        if(vehicle.isSubmitted__c){
                            submittedVehicleList.add(vehicle);                   
                        }
                    }
                }

                setSRSSubmitted = new ApexPages.StandardSetController(submittedVehicleList);
                setSRSSubmitted.setPageSize(sizeOfSubmittedRecords);  
                noOfSubmittedRecords = setSRSSubmitted.getResultSize();
                
                noOfPageForSubmitted = 1;
                if(noOfSubmittedRecords !=  null && noOfSubmittedRecords !=0){
                    noOfPageForSubmitted =  (Integer)(noOfSubmittedRecords/(Decimal)sizeOfSubmittedRecords).round(System.RoundingMode.CEILING);
                }
            }
            return setSRSSubmitted;
        }
        set;
    }
      
    //Changes the size of pagination
    /*public PageReference refreshSubmittedPageSize() {
        setSRSSubmitted.setPageSize(sizeOfSubmittedRecords);
        //noOfPageForSubmitted = 1;
        if(noOfSubmittedRecords !=  null && noOfSubmittedRecords !=0){
            noOfPageForSubmitted =  (Integer)(noOfSubmittedRecords/(Decimal)sizeOfSubmittedRecords).round(System.RoundingMode.CEILING);
            //noOfPageForSubmitted = ((noOfSubmittedRecords - tmpPageCal) / sizeOfSubmittedRecords) + (tmpPageCal >= 0 ? 1 : 0);
        }
        fetchSubmittedLocationVehicles();
        return null;
    }*/
    
    // Initialize setSRSSubmitted and return a list of record
    public void fetchSubmittedLocationVehicles(){
        submittedVehicleWrapperList = new list<SelectedVehicleWrapper>();
        resetSubmittedSearchFlag = false;
        searchSRSSubmittedFlag = false;
        searchVariableSubmittedTable = '';

        List<Order_Line_Item_Details__c> olidListTempSubm = (list<Order_Line_Item_Details__c>)setSRSSubmitted.getRecords();
        submittedVehicleWrapperList = generateVehicleWrapperData(olidListTempSubm);
                
        /*submittedVehicleWrapperList = new list<SelectedVehicleWrapper>();
        List<Order_Line_Item_Details__c> submittedVehicleList = new List<Order_Line_Item_Details__c>();
        submittedVehicleList = setSRSSubmitted.getRecords();
        system.debug('submittedVehicleList :: '+submittedVehicleList);
        if(!submittedVehicleList.isEmpty()){
            submittedVehicleWrapperList.clear();
            submittedVehicleWrapperList = generateVehicleWrapperData(submittedVehicleList);
        }*/
    }
    
    /** returns the First page of the page set*/
    public void submittedFirst() {
        setSRSSubmitted.first();
        fetchSubmittedLocationVehicles();
    }
    
    /** returns the Last page of the page set*/
    public void submittedLast() {
        setSRSSubmitted.last();
        fetchSubmittedLocationVehicles();
    }
    
    /** Returns the Previous page of the page set*/
    public void submittedPrevious() {
        setSRSSubmitted.previous();
        fetchSubmittedLocationVehicles();
    }
    
    /** Returns the Next page of the page set*/
    public void submittedNext() {
        setSRSSubmitted.next();
        fetchSubmittedLocationVehicles();
    }
    
    //Pagination StandardSetController for New Table
    public ApexPages.StandardSetController setSRSNew {
        get {
            if(searchSRSNewFlag){  //To exclude 'false' and 'null' scenarios
                List<Order_Line_Item_Details__c> olidList = new list<Order_Line_Item_Details__c>();
                if(searchVariableNewTable != ''){
                    String searchVariableNewTable1 = '*'+searchVariableNewTable+'*';
                    List<List<SObject>> searchresultList = [FIND :searchVariableNewTable1 IN ALL FIELDS RETURNING Order_Line_Item_Details__c(Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c, License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                             Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c, Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c,Not_a_Vehicle__c where SF_Orders__c =: OrderId and isSubmitted__c = false)];
            
                    olidList = (List<Order_Line_Item_Details__c>) searchResultList.get(0);
                    Set<Id> olidIdSet = new Set<Id>();
                    for(Order_Line_Item_Details__c olidT: olidList){
                        olidIdSet.add(olidT.Id);
                    }
                    setSRSNew = new ApexPages.StandardSetController(olidList);
                    setSRSNew.setPageSize(sizeOfNewRecords);
                    noOfNewFilteredRecords = setSRSNew.getResultSize(); 
                    
                    noOfPageForNew = 1;
                    if(noOfNewFilteredRecords !=  null && noOfNewFilteredRecords !=0){
                        noOfPageForNew =  (Integer)(noOfNewFilteredRecords/(Decimal)sizeOfNewRecords).round(System.RoundingMode.CEILING);
                        //noOfPageForNew = ((noOfNewRecords - tmpPageCal) / sizeOfNewRecords) + (tmpPageCal >= 0 ? 1 : 0);
                    }
                    searchSRSNewFlag = false;
                }
            }else if(locationFilterOnNewFlag){
            	vehicleList = new List<Order_Line_Item_Details__c>();
            	if(selectedLocationVeh != null && locVehicleMap.containsKey(selectedLocationVeh)){
                	vehicleList.addAll(locVehicleMap.get(selectedLocationVeh));
                }
                
                List<Order_Line_Item_Details__c> newVehicleList = new List<Order_Line_Item_Details__c>();
                if(!vehicleList.isEmpty()){
                    for(Order_Line_Item_Details__c vehicle : vehicleList){
                    	filterLocationName = vehicle.Location__r.Name;
                        if(!vehicle.isSubmitted__c){
                            newVehicleList.add(vehicle);                  
                        }
                    }
                }

                setSRSNew = new ApexPages.StandardSetController(newVehicleList);
                setSRSNew.setPageSize(sizeOfNewRecords);
                noOfNewFilteredRecords = setSRSNew.getResultSize(); 
                    
                noOfPageForNew = 1;
                if(noOfNewFilteredRecords !=  null && noOfNewFilteredRecords !=0){
                    noOfPageForNew =  (Integer)(noOfNewFilteredRecords/(Decimal)sizeOfNewRecords).round(System.RoundingMode.CEILING);
                    //noOfPageForNew = ((noOfNewRecords - tmpPageCal) / sizeOfNewRecords) + (tmpPageCal >= 0 ? 1 : 0);
                }
            	//Set the flags
            	locationFilterOnNewFlag = false;
            	resetLocationFilterOnNewFlag = true;
            }else if(setSRSNew == null){
            	vehicleList = new List<Order_Line_Item_Details__c>();
                allVehiclesCount = 0;
                locVehicleCountMap = new map<Id,Integer>();
                vehicleList.clear();
                selectedLocationVehFlag = true;        
                locVehicleMap = new Map<Id,List<Order_Line_Item_Details__c>>();        
                /*set<Id> locIdSet = new set<Id>();
                for(Location__c loc: [Select Id,Name from Location__c where Customer__c =: accountId LIMIT 800]){
                    locIdSet.add(loc.id);
                }*/
                locationRecCountMap = new Map<String,Integer>();
                for(Order_Line_Item_Details__c OlItem : [Select Id,Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c,
                                                         License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                         Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,
                                                         Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c,Not_a_Vehicle__c  
                                                         from Order_Line_Item_Details__c where location__r.customer__c=:accountId AND SF_Orders__c =: orderId order by CreatedDate DESC]){
                    if(locVehicleMap.containskey(OlItem.location__c)){
                        locVehicleMap.get(OlItem.location__c).add(OlItem);
                    }else{
                        list<Order_Line_Item_Details__c> oList = new list<Order_Line_Item_Details__c>();
                        oList.add(OlItem);
                        locVehicleMap.put(OlItem.location__c,oList); 
                    }
                    
                    if(!OlItem.isSubmitted__c){
			            if(!locationRecCountMap.containsKey(OlItem.location__c)){
			                locationRecCountMap.put(OlItem.location__c,1);
			            }else{
			                locationRecCountMap.put(OlItem.location__c,(locationRecCountMap.get(OlItem.location__c))+1);
			            }
                    }
                }
                
                for(Id locId : locVehicleMap.keyset()){
                    locVehicleCountMap.put(locId,locVehicleMap.size());
                }
                                
                //oliDetailEntryMap = new Map<Id, Order_Line_Item_Details__c>([Select Id, Name, (select Id, Installed_Device__c, Order_Line_Item__r.TypeOfDevice__c, Order_Line_Item__r.Devices_Installed__c from Order_Line_Item_Entries__r) from Order_Line_Item_Details__c where SF_Orders__c =: orderId]);
                
                for(Id locId : locVehicleCountMap.keySet()){
                    allVehiclesCount = allVehiclesCount + 1;
                }
                
               	for(String loc : locVehicleMap.keySet()){
	                vehicleList.addAll(locVehicleMap.get(loc));     
                }

                List<Order_Line_Item_Details__c> newVehicleList = new List<Order_Line_Item_Details__c>();
                if(!vehicleList.isEmpty()){
                    for(Order_Line_Item_Details__c vehicle : vehicleList){
                        if(!vehicle.isSubmitted__c){
                            newVehicleList.add(vehicle);                  
                        }
                    }
                }
                /*if(!newVehicleList.isEmpty()){
                    selectedVehicleWrapperList.clear();
                    selectedVehicleWrapperList = generateVehicleWrapperData(newVehicleList);
                }*/
                
                setSRSNew = new ApexPages.StandardSetController(newVehicleList);
                setSRSNew.setPageSize(sizeOfNewRecords);  
                noOfNewRecords = setSRSNew.getResultSize();
                //noOfPageForNew = 1;
                if(noOfNewRecords !=  null && noOfNewRecords !=0){
                    noOfPageForNew =  (Integer)(noOfNewRecords/(Decimal)sizeOfNewRecords).round(System.RoundingMode.CEILING);
                    //noOfPageForNew = ((noOfNewRecords - tmpPageCal) / sizeOfNewRecords) + (tmpPageCal >= 0 ? 1 : 0);
                }
            }
            return setSRSNew;
        }
        set;
    }
    
    //Changes the size of pagination
    /*public PageReference refreshNewPageSize() {
        setSRSNew.setPageSize(sizeOfNewRecords);
        noOfNewRecords = setSRSNew.getResultSize();
        if(noOfNewRecords !=  null && noOfNewRecords !=0){
            noOfPageForNew =  (Integer)(noOfNewRecords/(Decimal)sizeOfNewRecords).round(System.RoundingMode.CEILING);
            //noOfPageForNew = ((noOfNewRecords - tmpPageCal) / sizeOfNewRecords) + (tmpPageCal >= 0 ? 1 : 0);
        }  
        fetchNewLocationVehicles();
        return null;
    }*/
    
    
    public void fetchNewLocationVehicles(){

        resetNewSearchFlag = false;
        searchSRSNewFlag = false;
        searchVariableNewTable = '';
        //setSRSNEW = null;
        List<Order_Line_Item_Details__c> olidListTempNew = (list<Order_Line_Item_Details__c>)setSRSNew.getRecords();
        selectedVehicleWrapperList = generateVehicleWrapperData(olidListTempNew);
        
        /*
        List<Order_Line_Item_Details__c> newVehicleList = new List<Order_Line_Item_Details__c>();
        newVehicleList = setSRSNew.getRecords();
        if(!newVehicleList.isEmpty()){
            selectedVehicleWrapperList.clear();
            selectedVehicleWrapperList = generateVehicleWrapperData(newVehicleList);
        }*/    
    }
    
    /** returns the First page of the page set*/
    public void newFirst() {
        setSRSNew.first();
        fetchNewLocationVehicles();
    }
    
    /** returns the Last page of the page set*/
    public void newLast() {
        setSRSNew.last();
        fetchNewLocationVehicles();
    }
    
    /** Returns the Previous page of the page set*/
    public void newPrevious() {
        setSRSNew.previous();
        fetchNewLocationVehicles();
    }
    
    /** Returns the Next page of the page set*/
    public void newNext() {
        setSRSNew.next();
        fetchNewLocationVehicles();
    }
    
    /*  E ####$$$$ */
    
    // to display count of vehicles for each location for a given order 
    /*public void fetchlocationVehicles(){
        allVehiclesCount = 0;
        locVehicleCountMap = new map<Id,Integer>();
        vehicleList.clear();
        selectedLocationVehFlag = true;        
        locVehicleMap = new Map<Id,List<Order_Line_Item_Details__c>>();        
        set<Id> locIdSet = new set<Id>();
        for(Location__c loc: [Select Id,Name from Location__c where Customer__c =: accountId LIMIT 800]){
            locIdSet.add(loc.id);
        }
        
        for(Order_Line_Item_Details__c OlItem : [Select Id,Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c,
                                                 License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                 Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,
                                                 Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c,Not_a_Vehicle__c  
                                                 from Order_Line_Item_Details__c where location__c =: locIdSet AND SF_Orders__c =: orderId order by CreatedDate DESC]){
                                                     if(locVehicleMap.containskey(OlItem.location__c)){
                                                         locVehicleMap.get(OlItem.location__c).add(OlItem);
                                                     }else{
                                                         list<Order_Line_Item_Details__c> oList = new list<Order_Line_Item_Details__c>();
                                                         oList.add(OlItem);
                                                         locVehicleMap.put(OlItem.location__c,oList); 
                                                     }               
                                                 }
        
        for(Id locId : locVehicleMap.keyset()){
            locVehicleCountMap.put(locId,locVehicleMap.size());
        }
        
        
        oliDetailEntryMap = new Map<Id, Order_Line_Item_Details__c>([Select Id, Name, (select Id, Installed_Device__c, Order_Line_Item__r.TypeOfDevice__c, Order_Line_Item__r.Devices_Installed__c from Order_Line_Item_Entries__r) from Order_Line_Item_Details__c where SF_Orders__c =: orderId]);
        
        for(Id locId : locVehicleCountMap.keySet()){
            allVehiclesCount = allVehiclesCount + 1;
        }
        
        
        for(String loc : locVehicleMap.keySet()){
            vehicleList.addAll(locVehicleMap.get(loc));     
        }
        List<Order_Line_Item_Details__c> newVehicleList = new List<Order_Line_Item_Details__c>();
        List<Order_Line_Item_Details__c> submittedVehicleList = new List<Order_Line_Item_Details__c>();
        if(!vehicleList.isEmpty()){
            for(Order_Line_Item_Details__c vehicle : vehicleList){
                if(vehicle.isSubmitted__c){
                    submittedVehicleList.add(vehicle);                   
                }
                else{
                    newVehicleList.add(vehicle);
                }
            }
        }
        if(!newVehicleList.isEmpty()){
            selectedVehicleWrapperList.clear();
            selectedVehicleWrapperList = generateVehicleWrapperData(newVehicleList);
            locationRecCountMap = new Map<String,Integer>();
            for(SelectedVehicleWrapper sw:selectedVehicleWrapperList)
            {
                Integer count = 0;
                if(!locationRecCountMap.containsKey(sw.selectedVehicle.location__r.Id))
                {
                    locationRecCountMap.put(sw.selectedVehicle.location__r.Id,count+1);
                }
                else
                {
                    count = locationRecCountMap.get(sw.selectedVehicle.location__r.Id);
                    count = count + 1;
                    locationRecCountMap.put(sw.selectedVehicle.location__r.Id,count);
                }
            } 
        }
        if(!submittedVehicleList.isEmpty()){
            submittedVehicleWrapperList.clear();
            submittedVehicleWrapperList = generateVehicleWrapperData(submittedVehicleList);
        } 
    }*/
    
    //to display the all location and vehicle information
    public void fetchlocationVehicles(){
        resetNewTableFn();
        resetSubmittedTableFn();
    }
    
    // to display vehicle table per each location    
    public void fetchVehicles(){
            
        locationFilterOnNewFlag = true;
        resetLocationFilterOnNewFlag = true;
        fetchNewLocationVehicles();
        
        locationFilterOnSubmittedFlag = true;
        resetLocationFilterOnSubmittedFlag = true;
        fetchSubmittedLocationVehicles();
        
        /*if(selectedLocationVeh != null){
            vehicleList =  locVehicleMap.get(ID.valueOf(selectedLocationVeh));           
        }
        List<Order_Line_Item_Details__c> newVehicleList = new List<Order_Line_Item_Details__c>();
        List<Order_Line_Item_Details__c> submittedVehicleList = new List<Order_Line_Item_Details__c>();
        if(!vehicleList.isEmpty()){
            for(Order_Line_Item_Details__c vehicle : vehicleList){
                if(vehicle.isSubmitted__c){
                    submittedVehicleList.add(vehicle);                   
                }
                else{
                    newVehicleList.add(vehicle);
                }
            }
        }
        if(!newVehicleList.isEmpty()){
            selectedVehicleWrapperList.clear();
            selectedVehicleWrapperList = generateVehicleWrapperData(newVehicleList);
        }
        if(!submittedVehicleList.isEmpty()){
            submittedVehicleWrapperList.clear();
            submittedVehicleWrapperList = generateVehicleWrapperData(submittedVehicleList);
        }*/
    }
    
    // method to generate vehicle data with select chekbox included for each vehicle
    
    public List<SelectedVehicleWrapper> generateVehicleWrapperData(List<Order_Line_Item_Details__c> vehicleList){
        List<SelectedVehicleWrapper> vehicleWrapperList = new List<SelectedVehicleWrapper>();
        Set<Id> olidIdset = new Set<Id>();
        for(Order_Line_Item_Details__c olidT: vehicleList){
            olidIdset.add(olidT.Id);
        }
        
        oliDetailEntryMap = new Map<Id, Order_Line_Item_Details__c>([Select Id, Name, (select Id, Installed_Device__c, Order_Line_Item__r.TypeOfDevice__c, Order_Line_Item__r.Devices_Installed__c from Order_Line_Item_Entries__r) from Order_Line_Item_Details__c where Id IN:olidIdSet]);
            
        for(Order_Line_Item_Details__c olid : vehicleList){
            SelectedVehicleWrapper slv = new SelectedVehicleWrapper();
            slv.isVehSelected = false;
            slv.selectedVehicle = olid;
            slv.serviceTypeLabel = serviceTypeDataDct.containsKey(slv.selectedVehicle.Installation_Type__c)?(serviceTypeDataDct.get(slv.selectedVehicle.Installation_Type__c).UI_Service_Type_Label__c != ''? serviceTypeDataDct.get(slv.selectedVehicle.Installation_Type__c).UI_Service_Type_Label__c: serviceTypeDataDct.get(slv.selectedVehicle.Installation_Type__c).Label):slv.selectedVehicle.Installation_Type__c;
            
            String str = '';
        
            Order_Line_Item_Details__c olidTemp = oliDetailEntryMap.get(olid.Id);
            for(Order_Line_Item_Entry__c oliE: olidTemp.Order_Line_Item_Entries__r){
                if(oliE.Order_Line_Item__r.TypeOfDevice__c!= 'PrimaryDevice' && oliE.Order_Line_Item__r.Devices_Installed__c!='SSEM'){
                    str += oliE.Installed_Device__c+', ';
                }
            }
            /*if(olid.Addon_Alternate_Power_Adapter__c){
            str = str + 'Alternate Power Adapter'+';';
            }
            if(olid.Addon_Bluetooth_module__c){
            str = str + 'Bluetooth Module'+';';
            }
            if(olid.Addon_Driver_ID__c){
            str = str + 'Driver ID'+';';               
            }
            if(olid.Addon_Garmin_CONNECT__c){
            str = str + 'Garmin'+';';
            }
            if(olid.Addon_Magnet_Mounts__c){
            str = str + 'Magnet Mounts'+';';
            }
            if(olid.Addon_NMEA_Cable__c){
            str = str + 'NMEA'+';';
            }
            if(olid.Addon_PEM__c){
            str = str + 'PEM'+';';
            }
            if(olid.Addon_Pelican_Box__c){
            str = str + 'Pelican Box'+';';
            }
            if(olid.Addon_Quake_Satellite_Modem__c){
            str = str + 'Quake Satellite Modem'+';';
            }
            if(olid.Addon_Window_Mount_GPS_Antenna__c){
            str = str + 'Window Mount GPS Antenna'+';';
            }
            str = str.removeEnd(';');
            */
            
            str = str.removeEnd(', ');
            slv.accessories = str;
            vehicleWrapperList.add(slv);
        }
        return vehicleWrapperList;
    } 
    
    public void setLocationState(){
        locationStateFlag = true;
    }
    
    public void locationSelected(){
        vehicleWrapper.location = selectedLocationVeh;
    }
    
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> countryList = countryValues();        
        for(String s : countryList){
            options.add(new SelectOption(s,s));            
        }
        locationWrapper.country = 'USA';
        addlocationWrapper.country = 'USA';
        return options;
    }
    
    
    public void getStates(){
        List<SelectOption> options = new List<SelectOption>();
        states=new list<selectOption>();
        Map<String,List<String>> picklistoptions= DependentOptions.GetDependentOptions('Location__c','Garage_Country__c','Garage_State__c');
        
        List<String> stateList = new List<String>();
        //system.debug('------------->Country:'+locationWrapper.country+'*****:'+addlocationWrapper.country);
        if(locationWrapper.country == '' && addlocationWrapper.country == ''){
            stateList = picklistoptions.get('USA');
        }
        else if(addLocationWrapper.country != null && addLocationWrapper.country != '' ){
            stateList = picklistoptions.get(addlocationWrapper.country);
        }
        /*else{
stateList = picklistoptions.get(locationWrapper.country);
} 
*/  
        if(stateList != null && !stateList.isEmpty() && stateList.size() > 0){        
            options.add(new SelectOption('--select--','--select--'));
            for(String s : stateList){
                options.add(new SelectOption(s,s));            
            }
            //return options;
        }
        else{
            options.add(new SelectOption('--none--','--none--'));
            //return options;
        }  
        states=options;  
    }
    
    
    // Service Types
    public List<SelectOption> getServiceType(){
        List<SelectOption> options = new List<SelectOption>();
        /*Set<String> uniqueServices = new Set<String>();
for(Order_Line_Items__c oli : orderLineItemsList){
if(!uniqueServices.contains(oli.Service_Type__c)){
if(editVehicle != null){
options.add(new SelectOption(oli.Service_Type__c,oli.Service_Type__c));
uniqueServices.add(oli.Service_Type__c);
}
else if(editVehicle == null){
if(serviceBalances != null){
if(serviceBalances.get(oli.Service_Type__c) > 0){
options.add(new SelectOption(oli.Service_Type__c,oli.Service_Type__c));
uniqueServices.add(oli.Service_Type__c);
}    
}else{
options.add(new SelectOption(oli.Service_Type__c,oli.Service_Type__c));
uniqueServices.add(oli.Service_Type__c);
}
}
} 
}
options.sort();
*/
        //Added by Siva - Begin
        if(editVehicle != null){
            serviceTypeSet.add(vehicleWrapper.serviceType);
            List<String> serviceTypeListTemp = new List<String>();
            serviceTypeListTemp.addAll(serviceTypeSet);
            serviceTypeListTemp.sort();
            serviceTypeSet.clear();
            serviceTypeSet.addAll(serviceTypeListTemp);
        }
        
        for(String sTemp: serviceTypeSet){
            String sLabel = serviceTypeDataDct.containsKey(sTemp)?(serviceTypeDataDct.get(sTemp).UI_Service_Type_Label__c != ''?serviceTypeDataDct.get(sTemp).UI_Service_Type_Label__c:serviceTypeDataDct.get(sTemp).Label):sTemp;
            options.add(new SelectOption(sTemp,sLabel));
        }
        //Added by Siva - End
        return options;
    }
    
    // Device Types
    public List<SelectOption> getDeviceType(){
        //updateBalanceQuantity();
        List<SelectOption> options = new List<SelectOption>();
        Set<String> sSet = new Set<String>();
        List<String> tDeviceTypeList = new List<String>();
        Set<String> tDeviceTypeSet = new Set<String>();
        /*Schema.DescribeFieldResult fieldResult = Order_Line_Item_Details__c.Device_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        options.add(new SelectOption('',''));
        for( Schema.PicklistEntry f : ple)
        {
        options.add(new SelectOption(f.getValue(),f.getValue()));
        }*/
        //Added by Siva - Begin
        //Show the chosen deviceType in the Edit mode (especially when the balance is 0)
        Set<String> unitDeviceType = new Set<String>{'5200', '5500', '6100 (ExpressFleet)'};

        if(editVehicle != null && vehicleWrapper.serviceType != null){
            String deviceType = assetGuardSet.contains(vehicleWrapper.deviceType)?'Asset Guard':((unitDeviceType.contains(vehicleWrapper.deviceType) && editDeviceMap.containsKey(vehicleWrapper.serviceType+'_null'))?null:vehicleWrapper.deviceType);
            String keyT = vehicleWrapper.serviceType+'_'+deviceType;
            sSet = editDeviceMap.containsKey(keyT)?editDeviceMap.get(keyT):(availableDevicesMap.containsKey(vehicleWrapper.serviceType)?availableDevicesMap.get(vehicleWrapper.serviceType):new Set<String>{''});
                
            //Add the remaining available devices
            if(availableDevicesMap.containsKey(vehicleWrapper.serviceType)){
                sSet.addAll(availableDevicesMap.get(vehicleWrapper.serviceType));
            }
        }else{        
            if(vehicleWrapper.serviceType == null){
                sSet.add('');
            }else{
                sSet = availableDevicesMap.containsKey(vehicleWrapper.serviceType)?availableDevicesMap.get(vehicleWrapper.serviceType):new Set<String>{''};
            }
        }
        options.add(new SelectOption('',''));
        //Check for the blank service type scenarios upon page load
        
        /*if(vehicleWrapper.serviceType == null){
        sSet.add('');
        }else{
        sSet = availableDevicesMap.containsKey(vehicleWrapper.serviceType)?availableDevicesMap.get(vehicleWrapper.serviceType):new Set<String>{''};
        }*/
        for(String dTypeTemp: sSet){
            //for(String dTypeTemp: deviceTypeSet){
            if(dTypeTemp == 'Asset Guard'){
                for(String sAssGuardTemp: assetGuardSet){
                    tDeviceTypeList.add(sAssGuardTemp);
                }
            }else if(dTypeTemp == '' || dTypeTemp == null){
                /*Schema.DescribeFieldResult fieldResult = Order_Line_Item_Details__c.Device_Type__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
                for( Schema.PicklistEntry f : ple){
                    if(!assetGuardSet.contains(f.getValue())){
                        tDeviceTypeList.add(f.getValue());
                    }
                }*/
                
                tDeviceTypeList.addAll(unitDeviceType);
                
            }else{
                tDeviceTypeList.add(dTypeTemp);
            }
        }
        tDeviceTypeList.sort();
        
        tDeviceTypeSet.addAll(tDeviceTypeList);
        
        for(String sDTSet: tDeviceTypeSet){
            options.add(new SelectOption(sDTSet, sDTSet));
        }
        //Added by Siva - End
        return options; 
    }
    
    // query data from harness guide 
    public list<Harness_Guide__c> fetchHarnessData(){ 
        list<Harness_Guide__c> harness = [Select id,Year_From__c,Year_To__c,Make__c,Model__c,Harness_Type__c from Harness_Guide__c limit 50000];
        return harness;
    }
    
    
    // Year
    public List<SelectOption> getYear(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        for(Integer i = Date.Today().Year()+1; i>=1981; i--){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));             
        }
        return options;
    }
    
    
    public List<SelectOption> getMake(){
        List<SelectOption> options = new List<SelectOption>();
        Set<String> uniqueMake = new Set<String>();    
        List<String> allMakes = new List<String>();        
        for(Harness_Guide__c dhc : fetchHarnessData()){
            if(vehicleWrapper.year != null){
                Decimal fromYear = Decimal.ValueOf(dhc.Year_From__c);
                Decimal toYear = Decimal.ValueOf(dhc.Year_To__c);
                if(fromYear <= Decimal.ValueOf(vehicleWrapper.year) && toYear >= Decimal.ValueOf(vehicleWrapper.year)){
                    uniqueMake.add(dhc.Make__c);
                }  
            }    
        }
        
        // If make is not found in Harness Guide,add it.
        if(vehicleWrapper.make != null && !uniqueMake.contains(vehicleWrapper.make)){
            uniqueMake.add(vehicleWrapper.make);
        }
        
        allMakes.addAll(uniqueMake);
        allMakes.sort();
        options.add(new SelectOption('',''));
        if(!allMakes.isEmpty() && allMakes.Size() >0){
            for(String str : allMakes){
                options.add(new SelectOption(str,str)); 
            }
        }   
        return options;
    }
    
    
    // Model    
    public List<SelectOption> getModel(){
        List<SelectOption> options = new List<SelectOption>();
        Set<String> uniqueModel = new Set<String>();  
        List<String> allModels = new List<String>();
        for(Harness_Guide__c dhc : fetchHarnessData()){
            if(dhc.Make__c == vehicleWrapper.make){
                uniqueModel.add(dhc.Model__c);
            }     
        }
        
        // If model is not found in Harness Guide,add it.
        //system.debug('***vehicleWrapper.model'+vehicleWrapper.model);
        if(vehicleWrapper.model != null && !uniqueModel.contains(vehicleWrapper.model)){
            uniqueModel.add(vehicleWrapper.model);
        }
        
        allModels.addAll(uniqueModel);
        allModels.sort();
        options.add(new SelectOption('',''));
        
        if(!allModels.isEmpty() && allModels.Size() >0){
            for(String str : allModels){
                options.add(new SelectOption(str,str)); 
            }
        }   
        options.add(new SelectOption('Other','Other')); 
        return options;
    }
    
    
    // Return to 
    public List<SelectOption> getReturnTO(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));        
        options.add(new SelectOption('Customer','Customer'));
        options.add(new SelectOption('Installer','Installer'));
        return options; 
    }
    
    public List<SelectOption> getColors(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--Select--','--Select--'));
        Set<String> uniqueColor = new Set<String>();
        for(Color__mdt color : [Select DeveloperName,MasterLabel FROM Color__mdt]){
            options.add(new SelectOption(color.DeveloperName,color.DeveloperName));
            uniqueColor.add(color.DeveloperName);
        }
        if(!String.isEmpty(vehicleWrapper.color) && !uniqueColor.contains(vehicleWrapper.color)){
            options.add(new SelectOption(vehicleWrapper.color,vehicleWrapper.color));
        }
        //options.add(new SelectOption('Other','Other'));
        options.sort();
        return options;
    }
    
    // License State    
    public List<SelectOption> getLicenseStates(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Order_Line_Item_Details__c.License_State__c.getDescribe();
        //Uncomment below line to fix the License Plate picklist to display USA and Canada values and comment above line.
        //Schema.DescribeFieldResult fieldResult =Location__c.Garage_State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        options.add(new SelectOption('--NONE--','--NONE--'));       
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(),f.getValue()));
        }
        return options;
    }
    
    // Fuel Types
    public List<SelectOption> getFuelTypes(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Order_Line_Item_Details__c.Fuel_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getValue(),f.getValue()));
        }
        return options;
    }
    
    // Harness Types
    public List<SelectOption> getHarnessTypes(){
        List<SelectOption> options = new List<SelectOption>();
        if(vehicleWrapper.year != null && vehicleWrapper.make != null && vehicleWrapper.model != null){
            for(Harness_Guide__c dhc : fetchHarnessData()){
                Decimal fromYear = Decimal.ValueOf(dhc.Year_From__c);
                Decimal toYear = Decimal.ValueOf(dhc.Year_To__c);
                if((toYear >= Decimal.valueof(vehicleWrapper.year) && fromYear <= Decimal.valueof(vehicleWrapper.year)) && dhc.Make__c == vehicleWrapper.make  && dhc.Model__c == vehicleWrapper.model){
                    if(dhc.Harness_Type__c != null){
                        String[] harness = dhc.Harness_Type__c.split(';');
                        for(String str : harness){
                            options.add(new SelectOption(str,str));
                        }
                    }    
                }   
            }
        }
        else if(!String.isEmpty(vehicleWrapper.inputYear) && !String.isEmpty(vehicleWrapper.inputMake) && !String.isEmpty(vehicleWrapper.inputModel)){
            //system.debug('**inside input:'+vehicleWrapper.inputYear+vehicleWrapper.inputMake+vehicleWrapper.inputModel);
            for(Harness_Guide__c dhc : fetchHarnessData()){
                Decimal fromYear = Decimal.ValueOf(dhc.Year_From__c);
                Decimal toYear = Decimal.ValueOf(dhc.Year_To__c);
                if((toYear >= Decimal.valueof(vehicleWrapper.inputYear) && fromYear <= Decimal.valueof(vehicleWrapper.inputYear)) && dhc.Make__c == vehicleWrapper.inputMake  && dhc.Model__c == vehicleWrapper.inputModel){
                    if(dhc.Harness_Type__c != null){
                        String[] harness = dhc.Harness_Type__c.split(';');
                        for(String str : harness){
                            options.add(new SelectOption(str,str));
                        }
                    }    
                }   
            }
        }
        
        if(vehicleWrapper.deviceType == '6100 (ExpressFleet)'){
            options.clear();
            options.add(new SelectOption('Express Fleet Harness (6100)','Express Fleet Harness (6100)'));
        }
        else if(vehicleWrapper.deviceType == 'Asset Guard PW (Hardwired)' || vehicleWrapper.deviceType == 'Asset Guard BX (Battery Powered)'){
            options.clear();
            options.add(new SelectOption('--No Harness--','--No Harness--'));
        }
        // when harness type not found in harness guide
        if(options.isEmpty()){
            Schema.DescribeFieldResult fieldResult = Harness_Guide__c.Harness_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
            options.add(new SelectOption('--Select--','--Select--'));
            for( Schema.PicklistEntry f : ple)
            {
                options.add(new SelectOption(f.getValue(),f.getValue()));
            }   
        }    
        //   options.sort();
        return options;
    }
    
    // available locations
    /* public List<SelectOption> getAccountLocations(){
List<SelectOption> options = new List<SelectOption>();
//List<SelectOption> options1 = new List<SelectOption>();
// List<Location__c> locList = [Select Id,Name from Location__c where Customer__c =: accountId order by createddate desc LIMIT 800];
List<Location__c> locList = [Select Id,Name from Location__c where Customer__c =: accountId ];
List<Location__c> locList1 = [Select Id,Name from Location__c where Customer__c =: accountId order by Name desc LIMIT 800];
//List<Location__c> locList = [Select Id,Name,createddate from Location__c where Customer__c =: accountId order by createddate,name desc LIMIT 800];
if(!locList.isEmpty()){
for(Location__c loc : locList){
options.add(new SelectOption(loc.Id,loc.name));  
//options1.sort();
}
//for(Location__c loc1 : locList1){
//options.add(new SelectOption(loc1.Id,loc1.name));  
// options1.sort();
//}
if(selectedLocationVeh != null){
vehicleWrapper.location = selectedLocationVeh;
}
else if(editVehicle == null){
vehicleWrapper.location = locList[0].Id;
}
}
else{
options.add(new SelectOption('',''));    
}
//  options.sort();
//options1.sort();
return options;
}

public List<SelectOption> getAccountLocations(){
List<SelectOption> options = new List<SelectOption>();
List<Location__c> locList = [Select Id,Name from Location__c where Customer__c =: accountId order by createddate desc LIMIT 800];
//List<Location__c> locList = [Select Id,Name,createddate from Location__c where Customer__c =: accountId order by createddate,name desc LIMIT 800];
if(!locList.isEmpty()){
for(Location__c loc : locList){
options.add(new SelectOption(loc.Id,loc.name));  

}
if(selectedLocationVeh != null){
vehicleWrapper.location = selectedLocationVeh;
}
else if(editVehicle == null){
vehicleWrapper.location = locList[0].Id;
}
}
else{
options.add(new SelectOption('',''));    
}
//  options.sort();
return options;
}*/
    
    public List<SelectOption> getAccountLocations(){
        List<SelectOption> options = new List<SelectOption>();
        Location__c obj = new Location__c();
        List<Location__c> locList = [Select Id,Name from Location__c where Customer__c =: accountId order by createddate DESC LIMIT 800];
        if(locList!=null && locList.size()>0){
            obj = locList[0];
            locList.sort();
            
        }
        //List<Location__c> locList = [Select Id,Name,createddate from Location__c where Customer__c =: accountId order by createddate,name desc LIMIT 800];
        if(!locList.isEmpty()){
            for(Location__c loc : locList){
                options.add(new SelectOption(loc.Id,loc.name));  
                
            }
            if(selectedLocationVeh != null){
                vehicleWrapper.location = selectedLocationVeh;
            }
            else if(editVehicle == null){
                vehicleWrapper.location = obj.Id;
            }
        }
        else{
            options.add(new SelectOption('',''));    
        }
        //  options.sort();
        return options;
    }
    
    
    
    public List<String> countryValues(){
        Map<String,List<String>> picklistoptions= DependentOptions.GetDependentOptions('Location__c','Garage_Country__c','Garage_State__c');
        List<String> countries=new List<String>();
        for(String s:picklistoptions.keyset()){
            countries.add(s);
        }
        return countries;
    }
    
    public class SelectedLocationWrapper{
        public boolean isLocSelected {get;set;}
        public Location__c selectedLocation {get;set;}
        //public String preferredInstallDateTime1 {get;set;}
        //public String preferredInstallDateTime2 {get;set;}
    }
    
    public class SelectedVehicleWrapper{
        public boolean isVehSelected {get;set;}
        public Order_Line_Item_Details__c selectedVehicle {get; set;}
        public string accessories {get; set;}
        public string serviceTypeLabel {get; set;}
    }
    
    
    // method to fetch Year/Make/Model based on VIN value
    public void getVINDataMethod(){
        noVINDataFlag = false;
        //system.debug('***inside class');
        // to reset values when a new VIN number entered and not found
        vehicleWrapper.make = '';
        vehicleWrapper.model = '';
        vehicleWrapper.year = null;
        VinWSClass.getVINData(VINNumber);
        if(VinWSClass.checkVal==true){
            vehicleWrapper.make = VinWSClass.vinMap.get('make');
            vehicleWrapper.model = VinWSClass.vinMap.get('model');
            vehicleWrapper.year = VinWSClass.vinMap.get('year');
        }
        //system.debug('**vehicleWrapper.year:'+vehicleWrapper.year);
        //system.debug('**vehicleWrapper.make:'+vehicleWrapper.make);
        //system.debug('**vehicleWrapper.model:'+vehicleWrapper.model);
        if(vehicleWrapper.year == null && vehicleWrapper.make == '' && vehicleWrapper.model == ''){
            noVINDataFlag = true;
        }
    }
    
    
    // method to save locations to a particular Account based on the Order Id 
    
    public void savedLocation(){
        Location__c loc = new Location__c();
        loc.Customer__c = accountId;
        loc.Name = locationWrapper.locationName<>'' ? locationWrapper.locationName : addlocationWrapper.locationName;
        loc.Garage_Address1__c = locationWrapper.address1<>'' ? locationWrapper.address1 : addlocationWrapper.address1;
        loc.Garage_Address2__c = locationWrapper.address2<>'' ? locationWrapper.address2 : addlocationWrapper.address2;
        //loc.Garage_Country__c = locationWrapper.country<>'' ? locationWrapper.country : addlocationWrapper.country;
        loc.Garage_Country__c = addlocationWrapper.country;
        loc.Garage_City__c = locationWrapper.city<>'' ? locationWrapper.city : addlocationWrapper.city;
        loc.Garage_State__c = locationWrapper.state<>'--select--' ? locationWrapper.state : addlocationWrapper.state;
        loc.Garage_Zip__c = locationWrapper.zip<>'' ? locationWrapper.zip : addlocationWrapper.zip;
        loc.ContactName__c = locationWrapper.contactName<>'' ? locationWrapper.contactName : addlocationWrapper.contactName;
        loc.Email__c = locationWrapper.email<>'' ? locationWrapper.email : addlocationWrapper.email;
        loc.Phone__c = locationWrapper.phone<>'' ? locationWrapper.phone : addlocationWrapper.phone;
        loc.Phone_ext__c = locationWrapper.phoneext<>'' ? locationWrapper.phoneext : addlocationWrapper.phoneext;
        loc.Alternate_Name__c = locationWrapper.alternateContactName<>'' ? locationWrapper.alternateContactName : addlocationWrapper.alternateContactName;
        loc.Alternate_Email__c = locationWrapper.alternateEmail<>'' ? locationWrapper.alternateEmail : addlocationWrapper.alternateEmail;
        loc.Alternate_Phone__c = locationWrapper.alternatePhone<>'' ? locationWrapper.alternatePhone : addlocationWrapper.alternatePhone;
        loc.Alternate_Phone_ext__c = locationWrapper.alternatePhoneext<>'' ? locationWrapper.alternatePhoneext : addlocationWrapper.alternatePhoneext;
        
        try{
            insert loc;
            selectedLocationVeh = null; // to fix location select issue.                      
        }
        Catch(Exception e){
            system.debug('***error in save location method:'+'***Line Number:'+e.getLineNumber()+'***Message:'+e.getMessage());
        }    
    }
    
    
    // method to save vehicles to Order    
    
    public void savedVehicle(){
        //Orders__c order = [select id,GP_ERP_Order_ID__c from Orders__c where id = :orderId];
        
        Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c(); 
        if(editVehicle != null){
            olid.Id = editvehicle;        
        }
        olid.Location__c = vehicleWrapper.location;
        olid.SF_Orders__c = orderId;
        olid.Installation_Type__c = vehicleWrapper.serviceType;
        olid.VIN__c = vehicleWrapper.VINNumber;
        olid.No_VIN_Flag__c = vehicleWrapper.noVINnumber;
        olid.Not_a_Vehicle__c = vehicleWrapper.notAVehicle; 
        olid.Year__c = vehicleWrapper.year <> null ? vehicleWrapper.year : vehicleWrapper.inputYear;
        olid.Make__c = vehicleWrapper.make <> null ? vehicleWrapper.make : vehicleWrapper.inputMake;
        olid.Model__c = vehicleWrapper.model <> null ? vehicleWrapper.model : vehicleWrapper.inputModel <> null ? vehicleWrapper.inputModel : vehicleWrapper.otherModel; 
        olid.Old_Vin__c = vehicleWrapper.oldVIN;
        olid.Vehicle_Label__c = vehicleWrapper.vehicleLabel;
        olid.License_Plate__c = vehicleWrapper.licensePlate;
        olid.License_State__c = vehicleWrapper.licenseState <> '--NONE--' ? vehicleWrapper.licenseState : '';
        olid.Color__c = vehicleWrapper.color <> 'Other' ? vehicleWrapper.color : vehicleWrapper.otherColor;
        olid.Fuel_Type__c = vehicleWrapper.fuelType;
        olid.Device_Type__c = vehicleWrapper.deviceType;
        olid.Device_Serial_Number__c = vehicleWrapper.serial;
        olid.Device_Serial_Number_Old__c = vehicleWrapper.oldSerial; 
        olid.Vehicle_Harness_Category__c = (vehicleWrapper.harnessType <> '--Select--' &&  vehicleWrapper.harnessType <> '--No Harness--' ) ? vehicleWrapper.harnessType : '';
        olid.Device_Returned__c = vehicleWrapper.returnTo; 
        olid.Activity_Notes__c = vehicleWrapper.notes;
        system.debug('vehicleWrapper.sensor1: '+vehicleWrapper.sensor1+', vehicleWrapper.sensor2: '+vehicleWrapper.sensor2);
        olid.Sensor1__c = vehicleWrapper.sensor1;
        olid.Sensor2__c = vehicleWrapper.sensor2;
        olid.Sensor3__c = vehicleWrapper.sensor3;
        olid.Sensor4__c = vehicleWrapper.sensor4;
        olid.Sensor5__c = vehicleWrapper.sensor5;
        olid.Sensor6__c = vehicleWrapper.sensor6;
        
        olid.GP_ERP_Order_ID__c = orderRecord.GP_ERP_Order_ID__c<>null ? orderRecord.GP_ERP_Order_ID__c : 'xxxxx';
        
        
        olid.Addon_Alternate_Power_Adapter__c = false;
        olid.Addon_Bluetooth_module__c = false;
        olid.Addon_Driver_ID__c = false;
        olid.Addon_Garmin_CONNECT__c = false;
        olid.Addon_Magnet_Mounts__c = false;
        olid.Addon_NMEA_Cable__c = false;
        olid.Addon_PEM__c = false;
        olid.Addon_Pelican_Box__c = false;
        olid.Addon_Quake_Satellite_Modem__c = false;
        olid.Addon_Window_Mount_GPS_Antenna__c = false;
        olid.Addon_Buzzer__c = false;  //Added by Siva
        olid.GP_ERP_Order_ID__c = orderRecord.GP_ERP_Order_ID__c<>null ? orderRecord.GP_ERP_Order_ID__c : 'xxxxx';
        //Added by Siva - Begin
        List<Order_Line_Item_Details__c> upsertOLIDList = new List<Order_Line_Item_Details__c>();
        List<Order_Line_Item_Entry__c> upsertOLIEList = new List<Order_Line_Item_Entry__c>();
        List<Order_Line_Item_Entry__c> deleteOLIEList = new List<Order_Line_Item_Entry__c>();
        selectedAccessoriesSet = new Set<String>();
        
        
        //To delete the OLIE of the deleted accessories
        oLIEntries = new List<Order_Line_Item_Entry__c>();
        oLIEntries = [Select Id, Order_Line_Item__c, Order_Line_Item__r.Devices_Installed__c, Order_Line_Item_Detail__c, Sensor_Name__c from Order_Line_Item_Entry__c where Order_Line_Item_Detail__c =: editVehicle];
        
        Map<Id, Order_Line_Item_Entry__c> validateOLIEntryMap = new Map<Id, Order_Line_Item_Entry__c>();
        for(Order_Line_Item_Entry__c oliEntry: oLIEntries){
            validateOLIEntryMap.put(oliEntry.Id, oliEntry);
        }
        
        //Added by Siva - End
        
        for(SelectOption so : vehicleWrapper.selectedAccessories){
            //Added by Siva - Begin
            selectedAccessoriesSet.add(so.getValue());
            Order_Line_Item_Entry__c orderLIE = new Order_Line_Item_Entry__c();
            boolean createOLIEntryFlag = false;
            if(editVehicle != null){
                //Boolean doesOLIEntryExists = validateOLIEntry(so.getValue(), olid.Installation_Type__c, null, null);
                Id existingOLIEntryId = validateOLIEntry(so.getValue(), olid.Installation_Type__c, null, null);
                if(existingOLIEntryId == null){
                    createOLIEntryFlag = true;
                }else{
                    validateOLIEntryMap.remove(existingOLIEntryId);
                }
            }else{
                createOLIEntryFlag = true;
            }
            
            
            if(createOLIEntryFlag){
                orderLIE = createOLIEntry(so.getValue(), olid.Installation_Type__c, null, null);
                upsertOLIEList.add(orderLIE);
            }
            //Added by Siva - End
            
            if(so.getValue() == 'Alternate Power Adapter'){
                olid.Addon_Alternate_Power_Adapter__c = true;
            }
            else if(so.getValue() == 'Bluetooth Extension'){
                olid.Addon_Bluetooth_module__c = true;
            }
            else if(so.getValue() == 'Driver ID'){
                olid.Addon_Driver_ID__c = true;
            }
            else if(so.getValue() == 'Garmin Connect'){
                olid.Addon_Garmin_CONNECT__c = true;
            }
            else if(so.getValue() == 'Magnet Mounts'){
                olid.Addon_Magnet_Mounts__c = true;
            }
            else if(so.getValue() == 'NMEA'){
                olid.Addon_NMEA_Cable__c = true;
            }
            else if(so.getValue() == 'Port Expansion Module'){
                olid.Addon_PEM__c = true;
            }
            else if(so.getValue() == 'Pelican Box'){
                olid.Addon_Pelican_Box__c = true;
            }
            else if(so.getValue() == 'Quake Satellite Modem'){
                olid.Addon_Quake_Satellite_Modem__c = true;
            }
            else if(so.getValue() == 'Window Mount GPS Antenna'){
                olid.Addon_Window_Mount_GPS_Antenna__c = true;
            }
            else if(so.getValue() == 'Buzzer'){
                olid.Addon_Buzzer__c = true;
            }
        }
        
        /*Set<Id> availOLIESetTemp = new Set<Id>();
        for(Order_Line_Item_Entry__c oliEntry: oLIEntries){
        //Check if there are any unselected OLIEntries and non-duplicate selected accessories
        Boolean isAvail = selectedAccessoriesSet.contains(oliEntry.Order_Line_Item__r.Devices_Installed__c) && !availOLIESetTemp.contains(oliEntry.Order_Line_Item__c);
        sendEmailMethod(isAvail+'%%%%%%'+selectedAccessoriesSet.contains(oliEntry.Order_Line_Item__r.Devices_Installed__c)+', '+ availOLIESetTemp.contains(oliEntry.Order_Line_Item__c)+', '+oliEntry.Order_Line_Item__r.Devices_Installed__c, 'selectedAccessoriesSet.contains(oliEntry.Order_Line_Item__r.Devices_Installed__c) && !availOLIESetTemp.contains(oliEntry.Order_Line_Item__c)');
        
        if(!isAvail){
        deleteOLIEList.add(oliEntry);
        }else{
        availOLIESetTemp.add(oliEntry.Order_Line_Item__c);
        }
        }*/
        
        
        
        
        //Added by Siva - Begin
        if(!serviceTypeDataDct.get(vehicleWrapper.serviceType).isAddon__c){
            //if(vehicleWrapper.deviceType != null){
            String deviceTypeTemp = vehicleWrapper.deviceType;
            //Override deviceTypeTemp if is of any Asset Guard values
            if(assetGuardSet.contains(vehicleWrapper.deviceType)){
                deviceTypeTemp = 'Asset Guard';
            }
            
            boolean createOLIEntryFlag = false;
            if(editVehicle != null){
                Id existingOLIEntryId = validateOLIEntry(null, olid.Installation_Type__c, deviceTypeTemp, null);
                if(existingOLIEntryId == null){
                    createOLIEntryFlag = true;
                }else{
                    validateOLIEntryMap.remove(existingOLIEntryId);
                }
            }else{
                createOLIEntryFlag = true;
            }
            
            if(createOLIEntryFlag){
                //Create the OLIE record for the OLID record
                Order_Line_Item_Entry__c orderLIE = new Order_Line_Item_Entry__c();
                orderLIE = createOLIEntry(null, olid.Installation_Type__c, deviceTypeTemp, null);
                upsertOLIEList.add(orderLIE);
            }
            
        }else{
            vehicleWrapper.deviceType = '';
        }
        
        //Update Delete OLIE list
        if(validateOLIEntryMap.size()>0){
            deleteOLIEList.addAll(validateOLIEntryMap.values());
        }
        //Added by Siva - End
        
        
        
        upsertOLIDList.add(olid);
        
        Savepoint sp = Database.setSavepoint();
        try{
            //Added by Siva - Begin
            //Insert/Update the OLID record
            if(upsertOLIDList.size()>0){
                upsert upsertOLIDList;
            }
            
            //Insert/Update the OLIE record with the OLID record Id
            for(Order_Line_Item_Entry__c oliE: upsertOLIEList){
                oliE.Order_Line_Item_Detail__c = upsertOLIDList[0].Id;
            }
            
            if(upsertOLIEList.size()>0){
                upsert upsertOLIEList;
            }
            
            //Delete the removed OLIE (Edit scenario)
            if(deleteOLIEList.size()>0){
                delete deleteOLIEList;
            }  
            //Added by Siva - End
            //Method call to update Balances           
            updateBalanceQuantity();
            
            //Reset form
            clearVehForm();
                        
            //Reset Search
	        resetNewTableFn();
	        resetSubmittedTableFn();
            
        }
        Catch(Exception e){
            system.debug('***error in save vehicle method:'+'***Line Number:'+e.getLineNumber()+'***Message:'+e.getMessage());
            Database.rollback(sp);
        }
    }
    
    // method to edit the vehicle record
    public void editVehicleRecord(){
        if(editvehicle != null){
            //Added by Siva - Begin
            updateBalanceQuantity();
            //Added by Siva - End
            //system.debug('***editvehicle:'+editvehicle);
            Order_Line_Item_Details__c olid =  [Select Id,Name,location__c,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c,Not_a_Vehicle__c,
                                                License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c,
                                                Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,
                                                Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c, Availed_Sensors_Count__c, (Select Id, Order_Line_Item__c, Order_Line_Item__r.TypeOfDevice__c, Order_Line_Item__r.Devices_Installed__c, Sensor_Name__c from Order_Line_Item_Entries__r order by Order_Line_Item__r.Devices_Installed__c ASC)
                                                from Order_Line_Item_Details__c where Id =: editvehicle];
            
            vehicleWrapper = new VehicleWrapper();
            vehicleWrapper.location = olid.Location__c;
            vehicleWrapper.serviceType = olid.Installation_Type__c;
            vehicleWrapper.VINNumber = olid.VIN__c;
            vehicleWrapper.noVINnumber = olid.No_VIN_Flag__c;
            vehicleWrapper.notAVehicle = olid.Not_a_Vehicle__c;
            if(!vehicleWrapper.notAVehicle){
                vehicleWrapper.year = olid.Year__c;
                vehicleWrapper.make = olid.Make__c;
                vehicleWrapper.model = olid.Model__c; 
            }else{
                vehicleWrapper.inputYear = olid.Year__c;
                vehicleWrapper.inputMake = olid.Make__c;
                vehicleWrapper.inputModel = olid.Model__c; 
            }
            vehicleWrapper.oldVIN = olid.Old_Vin__c;            
            vehicleWrapper.vehicleLabel = olid.Vehicle_Label__c;
            vehicleWrapper.licensePlate = olid.License_Plate__c;
            vehicleWrapper.licenseState = olid.License_State__c;
            vehicleWrapper.color = olid.Color__c;
            vehicleWrapper.fuelType = olid.Fuel_Type__c;
            vehicleWrapper.deviceType = olid.Device_Type__c;
            vehicleWrapper.serial = olid.Device_Serial_Number__c;
            vehicleWrapper.oldSerial = olid.Device_Serial_Number_Old__c; 
            vehicleWrapper.harnessType = olid.Vehicle_Harness_Category__c;
            vehicleWrapper.returnTo = olid.Device_Returned__c;
            vehicleWrapper.notes = olid.Activity_Notes__c;        
            vehicleWrapper.sensor1 = olid.Sensor1__c;
            vehicleWrapper.sensor2 = olid.Sensor2__c; 
            vehicleWrapper.sensor3 = olid.Sensor3__c;
            vehicleWrapper.sensor4 = olid.Sensor4__c;
            vehicleWrapper.sensor5 = olid.Sensor5__c;
            vehicleWrapper.sensor6 = olid.Sensor6__c; 
            if(vehicleWrapper.sensor1 != null || vehicleWrapper.sensor2 != null || vehicleWrapper.sensor3 != null || vehicleWrapper.sensor4 != null || vehicleWrapper.sensor5 != null || vehicleWrapper.sensor6 != null){
                vehicleWrapper.sensorFlag = true;
            }
            vehicleWrapper.accessories = new list<string>();
            /*Set<String> accessoriesSet = new Set<String>();
            if(olid.Addon_Alternate_Power_Adapter__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Alternate Power Adapter','Alternate Power Adapter'));
            accessoriesSet.add('Alternate Power Adapter');
            }
            if(olid.Addon_Bluetooth_module__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Bluetooth Module','Bluetooth Module'));
            accessoriesSet.add('Bluetooth Module');
            }
            if(olid.Addon_Driver_ID__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Driver ID','Driver ID')); 
            accessoriesSet.add('Driver ID');               
            }
            if(olid.Addon_Garmin_CONNECT__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Garmin','Garmin'));
            accessoriesSet.add('Garmin');
            }
            if(olid.Addon_Magnet_Mounts__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Magnet Mounts','Magnet Mounts'));
            accessoriesSet.add('Magnet Mounts');
            }
            if(olid.Addon_NMEA_Cable__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('NMEA','NMEA'));
            accessoriesSet.add('NMEA');
            }
            if(olid.Addon_PEM__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('PEM','PEM'));
            accessoriesSet.add('PEM');
            }
            if(olid.Addon_Pelican_Box__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Pelican Box','Pelican Box'));
            accessoriesSet.add('Pelican Box');
            }
            if(olid.Addon_Quake_Satellite_Modem__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Quake Satellite Modem','Quake Satellite Modem'));
            accessoriesSet.add('Quake Satellite Modem');
            }
            if(olid.Addon_Window_Mount_GPS_Antenna__c){
            vehicleWrapper.selectedAccessories.add(new SelectOption('Window Mount GPS Antenna','Window Mount GPS Antenna'));
            accessoriesSet.add('Window Mount GPS Antenna');
            }
            vehicleWrapper.availableAccessories = new list<SelectOption>();
            for(Accessories__mdt accs : [Select DeveloperName,MasterLabel from Accessories__mdt]){
            if(!accessoriesSet.contains(accs.MasterLabel)){
            vehicleWrapper.availableAccessories.add(new SelectOption(accs.MasterLabel,accs.MasterLabel));
            }
            } */
            
            //Added by Siva - Begin
            availSensorCount = olid.Availed_Sensors_Count__c;
            Set<String> vehAvailableAccessoriesSet = accessoriesMap.get(vehicleWrapper.serviceType);
            List<Order_Line_Item_Entry__c> olidEntries = olid.Order_Line_Item_Entries__r;
            
            for(Order_Line_Item_Entry__c oliE: olidEntries){
                if(oliE.Order_Line_Item__r.TypeOfDevice__c == 'Add-On Only'){
                    String devInstalled = oliE.Order_Line_Item__r.Devices_Installed__c;
                    if(selectedAccessoriesMap.containsKey(vehicleWrapper.serviceType)){
                        Set<String> selAccSet = selectedAccessoriesMap.get(vehicleWrapper.serviceType);
                        selAccSet.add(devInstalled);
                        selectedAccessoriesMap.put(vehicleWrapper.serviceType, selAccSet);
                    }else{
                        Set<String> selAccSet = new Set<String>();
                        selAccSet.add(devInstalled);
                        selectedAccessoriesMap.put(vehicleWrapper.serviceType, selAccSet);
                    }
                    //selAccSet.add(devInstalled);
                    vehicleWrapper.selectedAccessories.add(new SelectOption(devInstalled, devInstalled));
                }
            }
            Set<String> availAccSet = new Set<String>();
            //system.debug('VehicleWrapper.servicetype'+vehicleWrapper.serviceType);
            Set<String> accSetT = AccessoriesMap.get(vehicleWrapper.serviceType);
            //system.debug(accSetT);
            
            if(accSetT!=null){
                availAccSet.addAll(accSetT);
                //Remove the Sensor 
                availAccSet.remove('Sensors');
            }
            
            
            if(selectedAccessoriesMap.get(vehicleWrapper.serviceType) != null){
                availAccSet.removeAll(selectedAccessoriesMap.get(vehicleWrapper.serviceType));
            }
            
            //availAccSet.removeAll(selAccSet);
            //To Order the Available Accessories List
            List<String> availableAccessoriesListTemp = new List<String>();
            availableAccessoriesListTemp.addAll(availAccSet);
            
            availableAccessoriesListTemp.sort();
            
            for(String sAvailAccs: availableAccessoriesListTemp){
                vehicleWrapper.availableAccessories.add(new SelectOption(sAvailAccs, sAvailAccs));
            }
            
            //Added by Siva - End
        } 
    }
    //method to update remaining number of install/swap/transfer/removal/troubleshoot
    
    public void updateBalanceQuantity(){
        orderLineItemsList = new list<Order_Line_Items__c>();
        list<Order_Line_Item_Details__c> orderLineItemDetailsList = new list<Order_Line_Item_Details__c>();
        //installQuantityMap = new Map<String,Integer>();
        remainingQuantity = '';
        availableServices = 0;
        remainingServices = new Map<String,Integer>();
        
        //Added by Siva - Begin
        //balanceQuantityMap = new Map<String, Integer>();
        availableDevicesMap = new Map<String, Set<String>>();
        editDeviceMap = new Map<String, Set<String>>();
        balanceQuantityList = new List<balanceQuantity>();
        finalQuantityMap = new Map<String, balanceQuantity>();
        accessoriesMap = new Map<String, Set<String>>();
        //Added by Siva - End
        
        orderLineItemsList = [Select Id,Name,GP_Quantity__c,Installation_Type__c,Service_Type__c,BalanceQuantity__c, Balance_Quantity__c, Devices_Installed__c, TypeOfDevice__c from Order_Line_Items__c where Orders__c =: orderId order by Service_Type__c ASC];
        orderLineItemDetailsList = [Select Id,Name,Installation_Type__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c, Availed_Sensors_Count__c from Order_Line_Item_Details__c where SF_Orders__c =: orderId];
        
        //Added by Siva - Begin
        availedSensorCount = 0;
        sensorCountInstallTypeMap = new Map<String, Integer>();
        //Parse the Order Line Item Details for Sensors
        for(Order_Line_Item_Details__c lineItem : orderLineItemDetailsList){
            //Added by Siva - Begin
            if(lineItem.Availed_Sensors_Count__c > 0){
                List<String> insType = lineItem.Installation_Type__c.split(' ');
                if(insType!=null){
                    String key = insType[0]+' Add-On Only_SSEM';
                    if(sensorCountInstallTypeMap.containsKey(key)){
                        Integer cTemp = sensorCountInstallTypeMap.get(key);
                        cTemp += Integer.valueOf(lineItem.Availed_Sensors_Count__c);
                        sensorCountInstallTypeMap.put(key, cTemp);
                    }else{
                        sensorCountInstallTypeMap.put(key, Integer.valueOf(lineItem.Availed_Sensors_Count__c));
                    }
                }
            }
        }
        //Added by Siva - End
        // to prevent schedule new service if purchases are completed
        for(Order_Line_Items__c oli : orderLineItemsList){
            If(oli.BalanceQuantity__c > 0 || oli.BalanceQuantity__c == null){
                availableServices = availableServices+1;
            }
            
            //Added by Siva - Begin
            String deviceMapKey = oli.Service_Type__c+'_'+oli.Devices_Installed__c;
            
            //Populate a map with the key as the Installation Type + type of device installed with value as its corresponding Order Line Item Id
            if(orderLineItemMap.containsKey(deviceMapKey)){
                List<Order_Line_Items__c> oliItemsListTemp = orderLineItemMap.get(deviceMapKey);
                oliItemsListTemp.add(oli);
                orderLineItemMap.put(deviceMapKey, oliItemsListTemp);
            }else{
                List<Order_Line_Items__c> oliItemsListTemp = new List<Order_Line_Items__c> ();
                oliItemsListTemp.add(oli);
                orderLineItemMap.put(deviceMapKey, oliItemsListTemp);
            }
            balanceQuantity bQ = new balanceQuantity();
            system.debug('oli.TypeOfDevice__c :: '+oli.TypeOfDevice__c);
            if(oli.TypeOfDevice__c!=null && oli.TypeOfDevice__c == 'PrimaryDevice'){
                bQ.isPrimaryDevice = true;
                bQ.isAddon = false;
                bQ.serviceType = oli.Service_Type__c;
                bQ.installType = oli.Installation_Type__c;
                bQ.installDevice = oli.Devices_Installed__c;
                
                bQ.key = oli.Installation_Type__c;
                
                //Map key reset
                deviceMapKey = oli.Service_Type__c;
            }else if(oli.TypeOfDevice__c!=null && oli.TypeOfDevice__c == 'Add-On Only'){
                bQ.isPrimaryDevice = false;
                bQ.isAddon = true;
                bQ.serviceType = oli.Service_Type__c;
                bQ.installType = oli.Installation_Type__c;
                //if Device installed is 'SSEM', display as 'Sensors'
                bQ.installDevice = oli.Devices_Installed__c == 'SSEM'?'Sensors':oli.Devices_Installed__c;
                
                
                bQ.key = bQ.installDevice;
                //Insert the main Installation Type with 0 quantity for grouping purposes
                if(!finalQuantityMap.containsKey(oli.Installation_Type__c)){
                    balanceQuantity bQ1 = new balanceQuantity();
                    bQ1.isPrimaryDevice = true;
                    bQ1.isAddon = false;
                    bQ1.installType = oli.Installation_Type__c;
                    bQ1.serviceType = bQ1.installType;
                    bQ1.installDevice = '';
                    bQ1.GPBalance = 0;
                    bQ1.GPQuantity = 0;
                    bQ1.key = bQ1.installType;              
                    
                    finalQuantityMap.put(bQ1.key, bQ1);
                    
                }
            }
            
            if(finalQuantityMap.containsKey(deviceMapKey)){
                balanceQuantity bQTemp = finalQuantityMap.get(deviceMapKey);
                if(bQ != null){
                    bQ.GPQuantity = bQTemp.GPQuantity + Integer.valueOf(oli.GP_Quantity__c);
                    bQ.GPBalance = sensorCountInstallTypeMap.containsKey(deviceMapKey)? (bQ.GPQuantity - sensorCountInstallTypeMap.get(deviceMapKey)) :(bQTemp.GPBalance + Integer.valueOf(oli.Balance_Quantity__c));
                        }
            }else{
                bQ.GPQuantity = Integer.valueOf(oli.GP_Quantity__c);
                bQ.GPBalance = sensorCountInstallTypeMap.containsKey(deviceMapKey)? (bQ.GPQuantity - sensorCountInstallTypeMap.get(deviceMapKey)) : Integer.valueOf(oli.Balance_Quantity__c);
            }
            system.debug('startTest :'+bQ);
            //if(bQ.GPBalance > 0){
            if(bQ.isAddOn){
                if(bQ.installDevice == 'Sensors'){
                    availSensorCount += bQ.GPBalance;
                }
                if(accessoriesMap.containsKey(bQ.installType)){
                    Set<String> tAccSet = new Set<String>();
                    tAccSet = accessoriesMap.get(bQ.installType);
                    if(bQ.GPBalance > 0){
                        tAccSet.add(bQ.installDevice);
                        
                        List<String> tSortList = new List<String>();
                        tSortList.addAll(tAccSet);
                        tSortList.sort();
                        
                        tAccSet.clear();
                        tAccSet.addAll(tSortList);
                        serviceTypeSet.add(bQ.serviceType);
                    }
                    accessoriesMap.put(bQ.installType, tAccSet);
                    accessoriesMap.put(bQ.serviceType, tAccSet);
                }else{
                    Set<String> tAccSet = new Set<String>();
                    if(bQ.GPBalance > 0){
                        tAccSet.add(bQ.installDevice);
                        serviceTypeSet.add(bQ.serviceType);
                        
                    }
                    accessoriesMap.put(bQ.installType, tAccSet);
                    accessoriesMap.put(bQ.serviceType, tAccSet);
                }
                availableAccessoriesSet.add(bQ.installDevice);
            }else{
                deviceTypeSet.add(bQ.installDevice);
                editDeviceMap.put((oli.Service_Type__c+'_'+oli.Devices_Installed__c), new Set<String>{oli.Devices_Installed__c});
                if(availableDevicesMap.containsKey(bQ.serviceType)){
                    Set<String> tempSet = availableDevicesMap.get(bQ.serviceType);
                    if(bQ.GPBalance > 0 && oli.Balance_Quantity__c > 0){
                        tempSet.add(bQ.installDevice);
                        serviceTypeSet.add(bQ.serviceType);
                    }
                    availableDevicesMap.put(bQ.serviceType, tempSet);
                }else{
                    Set<String> tempDevSet = new Set<String>();
                    if(bQ.GPBalance > 0 && oli.Balance_Quantity__c > 0){
                        tempDevSet.add(bQ.installDevice);
                        serviceTypeSet.add(bQ.serviceType);
                    }
                    availableDevicesMap.put(bQ.serviceType, tempDevSet);
                }
            }
            //}
            
            finalQuantityMap.put(deviceMapKey, bQ);
            //Added by Siva - End
            
        } 
        
        /*for(Order_Line_Items__c olis : orderLineItemsList){
        if(installQuantityMap.get(olis.Service_Type__c) != null){
        Integer quantity = installQuantityMap.get(olis.Service_Type__c);
        quantity = quantity+Integer.valueOf(olis.GP_Quantity__c);
        installQuantityMap.put(olis.Service_Type__c,quantity);
        }
        else{
        installQuantityMap.put(olis.Service_Type__c,Integer.valueOf(olis.GP_Quantity__c));
        } 
        }*/ 
        //Added by Siva - Begin
        balanceQuantityList.addAll(finalQuantityMap.values());
        
        //Added by Siva - End
        
        // form the map of installation type and their usage count.
        /*for(Order_Line_Item_Details__c lineItem : orderLineItemDetailsList){


        //Added by Siva - Begin
        if(lineItem.Availed_Sensors_Count__c > 0){
        List<String> insType = lineItem.Installation_Type__c.split(' ');
        
        
        if(insType!=null){
        String key = insType[0]+' Add-On Only_SSEM';
        
        if(sensorCountInstallTypeMap.containsKey(key)){
        Integer cTemp = sensorCountInstallTypeMap.get(key);
        cTemp += Integer.valueOf(lineItem.Availed_Sensors_Count__c);
        sensorCountInstallTypeMap.put(key, cTemp);
        }else{
        sensorCountInstallTypeMap.put(key, Integer.valueOf(lineItem.Availed_Sensors_Count__c));
        }
        }
        }
        
        for(String sKeyTemp: sensorCountInstallTypeMap.keySet()){
        if(finalQuantityMap.containsKey(sKeyTemp)){
        BalanceQuantity bqTemp = new BalanceQuantity();
        bqTemp = finalQuantityMap.get(sKeyTemp);
        bqTemp.GPBalance = sensorCountInstallTypeMap.get(sKeyTemp);
        bqTemp.GPBalance = (bQTemp.GPQuantity - bqTemp.GPBalance) >=0 ? (bQTemp.GPQuantity - bqTemp.GPBalance) : 0;
        availSensorCount = bqTemp.GPBalance;
        finalQuantityMap.put(sKeyTemp,bqTemp);
        }
        }
        //Added by Siva - End
        
        
        // for service types install/swap/transfer/removal/troubleshoot - Quantity should be reduced in both services & if accessories is choosen it should also be reflected.
        if(lineItem.Installation_Type__c == 'Install' || lineItem.Installation_Type__c == 'Swap' || lineItem.Installation_Type__c == 'Transfer' || lineItem.Installation_Type__c == 'Removal' || lineItem.Installation_Type__c == 'Troubleshoot'){
        if(remainingServices.get(lineItem.Installation_Type__c) != null){
        Integer count = remainingServices.get(lineItem.Installation_Type__c) + 1;
        remainingServices.put(lineItem.Installation_Type__c,count);     
        }
        else{
        remainingServices.put(lineItem.Installation_Type__c,1);
        }
        if(IODSControllerHelper.calculateAccessoriesCount(lineItem) != 0){
        String str = lineItem.Installation_Type__c + ' Add-On Only';  
        if(remainingServices.get(str) != null){
        Integer count = remainingServices.get(str) + IODSControllerHelper.calculateAccessoriesCount(lineItem);
        remainingServices.put(str,count);     
        }
        else{
        remainingServices.put(str,IODSControllerHelper.calculateAccessoriesCount(lineItem));
        }  
        }
        }else if(lineItem.Installation_Type__c == 'Install Add-On Only' || lineItem.Installation_Type__c == 'Swap Add-On Only' || lineItem.Installation_Type__c == 'Transfer Add-On Only' || lineItem.Installation_Type__c == 'Removal Add-On Only' || lineItem.Installation_Type__c == 'Troubleshoot Add-On Only'){
        if(remainingServices.get(lineItem.Installation_Type__c) != null){
        Integer count = remainingServices.get(lineItem.Installation_Type__c) + IODSControllerHelper.calculateAccessoriesCount(lineItem);
        remainingServices.put(lineItem.Installation_Type__c,count);     
        }
        else{
        remainingServices.put(lineItem.Installation_Type__c,IODSControllerHelper.calculateAccessoriesCount(lineItem));
        }
        }
        }*/
                
                /*if(installQuantityMap!=null)
        {
        for(String str : installQuantityMap.keySet()){
        if(installQuantityMap!=null && remainingServices!=null)
        {
        Integer balance=0;
        if((str!=null && str!='') && installQuantityMap.containsKey(str) && remainingServices.containsKey(str))
        balance = installQuantityMap.get(str)-(remainingServices.get(str) != null ? remainingServices.get(str) : 0);
        if(balance!=null)
        remainingQuantity = remainingQuantity+' '+str+':'+String.valueOf(balance);
        }
        }
        }
        }
        
        public void balanceLeft(){
        serviceBalances = new Map<String,Integer>();
        leftBalance = 0;
        Integer balance=0;
        if(installQuantityMap != null){
        for(String str : installQuantityMap.keySet()){
        if((str!=null && str!='') && installQuantityMap.containsKey(str) && remainingServices.containsKey(str))
        balance = installQuantityMap.get(str)-(remainingServices.get(str) != null ? remainingServices.get(str) : 0);
        if(balance < 0){
        leftBalance = leftBalance+balance;
        }
        serviceBalances.put(str,balance);
        }
        }
        system.debug('***serviceBalances method:'+serviceBalances);
        }*/
                /*for(String str : installQuantityMap.keySet()){
        Integer balance = installQuantityMap.get(str)-(remainingServices.get(str) != null ? remainingServices.get(str) : 0);
        remainingQuantity = remainingQuantity+' '+str+':'+String.valueOf(balance);
        }*/
    }
    
    /*public void balanceLeft(){
        serviceBalances = new Map<String,Integer>();
        leftBalance = 0;
        if(installQuantityMap != null){
            for(String str : installQuantityMap.keySet()){
                Integer balance = installQuantityMap.get(str)-(remainingServices.get(str) != null ? remainingServices.get(str) : 0);
                if(balance < 0){
                    leftBalance = leftBalance+balance;
                }
                serviceBalances.put(str,balance);
            }
        }
        //system.debug('***serviceBalances method:'+serviceBalances);
    }*/
    
    //Method to query the available new locations for Preferred Data and Time
    public void preferredDateLocationsData(){
        //reset location list
        Map<Id, String> locIdNameMap = new Map<Id, String>();
        //Commented by Siva - Begin
        /*Set<Id> locationIdSet = new Set<Id>();
        List<Order_Line_Item_Details__c> olidList = [Select Location__c from Order_Line_Item_Details__c where SF_Orders__c =: orderId and issubmitted__c = false];
        for(Order_Line_Item_Details__c olid: olidList){
            locationIdSet.add(olid.Location__c);
        }  
        
        for(Location__c loc : [Select Id,Name,Preferred_Install_Date_Time_1__c,Preferred_Install_Date_Time_2__c from Location__c where Customer__c =: accountId and Id IN:locationIdSet order by createddate desc]){
            preferredDatesLocationList.add(loc);
        }*/
        //Commented by Siva - End
        
        List<Order_Line_Item_Details__c> olidList = [Select Location__c, Location__r.Name, Location__r.Preferred_Install_Date_Time_1__c, Location__r.Preferred_Install_Date_Time_2__c from Order_Line_Item_Details__c where SF_Orders__c =: orderId and issubmitted__c = false Order by Location__r.CreatedDate desc];
        for(Order_Line_Item_Details__c olid: olidList){
            if(olid.Location__c != null){
            	locIdNameMap.put(olid.Location__c, olid.Location__r.Name);
            }
        }
        preferredDatesLocationList = new list<Location__c>();
        //Iterate through the available new locations and populate the list
        for(Id locId: locIdNameMap.keySet()){
            Location__c lTemp = new Location__c();
           	lTemp.id = locId;
           	lTemp.Name = locIdNamemap.get(locId);
           	lTemp.Preferred_Install_Date_Time_1__c = null;
           	lTemp.Preferred_Install_Date_Time_2__c = null;
           	preferredDatesLocationList.add(lTemp);
        }
    }
    
    // method to submit all vehicles in a single request
    public void submitAllVehicles(){
    	submitAllStatusMessage = 'Your order request has been submitted. An installation coordinator will contact you shortly to confirm your appointment.';
    	boolean errorFlag = false;
        List<location__c> updateLocationList = new List<Location__c>();
        
        preferredDatesLocationList = new List<location__C>();
        try{
            if(!String.isBlank(listValue)){
                if(listValue.contains('>>')){
                    list<String>  cmpList = new list<String>();
                    cmpList = listValue.split('>>');
                    
                    if(cmpList.size()>0){
                        for(String str : cmpList){
                            if(str.contains(';')){
                                list<String>  lstValues = str.split(';');
                                System.debug('lstValues===>>'+lstValues);
                                Location__c oL = new Location__c(id = lstValues.get(2));
                                if(lstValues.get(0).length()!=2){
                                    try{
                                        oL.Preferred_Install_Date_Time_1__c = parsedate(lstValues.get(0));
                                    }catch(exception e){
                                        oL.Preferred_Install_Date_Time_1__c = null;
                                    }    
                                }else{
                                    
                                    oL.Preferred_Install_Date_Time_1__c = null;
                                }
                                if(lstValues.get(1).length()!=2){
                                    try{
                                        oL.Preferred_Install_Date_Time_2__c = parsedate(lstValues.get(1));
                                    }catch(exception e){
                                        oL.Preferred_Install_Date_Time_2__c = null;
                                    }
                                }   else{
                                    oL.Preferred_Install_Date_Time_2__c = null;
                                }                            
                                preferredDatesLocationList.add(oL);
                                //System.debug('added in the list===>>'+oL);
                            }
                        }
                    }
                }
            }
            
        }catch(exception e){
            system.debug('Gone wrong'+e.getMessage()+'Line No: -'+e.getLineNumber());
        }
        
        //System.debug('new list::==>'+preferredDatesLocationList);
        if(!preferredDatesLocationList.isEmpty() && preferredDatesLocationList.size() > 0){
            update preferredDatesLocationList;
        }
        
        
        /*sendEmailMethod('***'+preferredDatesLocationWrapperList, 'preferredDatesLocationWrapperList Outside');
        if(preferredDatesLocationWrapperList.size()>0){
        	//for(Location__c locTemp: preferredDatesLocationWrapperList){
        	for(SRSController.locationSchedulerWrapper locTemp: preferredDatesLocationWrapperList){
        		
        		if(locTemp.locPrefInstall_DateTime1 <> '' || locTemp.locPrefInstall_DateTime2 <> ''){
					Location__c locTempV = new Location__c();
					locTempV.Id = locTemp.locId;
					locTempV.Name = locTemp.locName;
					locTempV.Preferred_Install_Date_Time_1__c = parsedate(locTemp.locPrefInstall_DateTime1);
					locTempV.Preferred_Install_Date_Time_2__c = parsedate(locTemp.locPrefInstall_DateTime2);
					updateLocationList.add(locTempV);
        		}
        	}
        }
        //set the save point
        //savepoint spUpdLocList = Database.setSavePoint(); 
        //Check if the list has updatable records
        sendEmailmethod(updateLocationList.size()+',', 'updateLocationList.size()');
        if(updateLocationList.size() > 0){
        	try{
        		update updateLocationList;
        	}catch(Exception e){
        		submitAllStatusMessage = 'An unexpected error occurred, please try again later.';
        		errorFlag = true;
        	}	
        }
        sendEmailmethod(errorFlag+',', 'errorFlag');
        //Validate if there is any error/rollback while updating locations and allow only if there are no errors
        */
        if(!errorFlag){
	        List<Order_Line_Item_Details__c> toSubmitVehicleList = new List<Order_Line_Item_Details__c>();
			//Query for all records eligible for submission
			for(Order_Line_Item_Details__c oliDetails : [Select Id, isSubmitted__c from Order_Line_Item_Details__c where SF_Orders__c =: orderId and issubmitted__c = false LIMIT 600]){
				oliDetails.isSubmitted__c = true; 
				toSubmitVehicleList.add(oliDetails);
			}
			//Check if the list has updatable records
			if(!toSubmitVehicleList.isEmpty()){
				try{
					update toSubmitVehicleList;
				}
				catch(Exception e){
					submitAllStatusMessage = 'An unexpected error occurred, please try again later.';
					//Database.rollback(spUpdLocList);
				}
			}
        }
        /*preferredDatesLocationList = new List<location__C>();
        try{
            if(!String.isBlank(listValue)){
                if(listValue.contains('>>')){
                    list<String>  cmpList = new list<String>();
                    cmpList = listValue.split('>>');
                    
                    if(cmpList.size()>0){
                        for(String str : cmpList){
                            if(str.contains(';')){
                                list<String>  lstValues = str.split(';');
                                System.debug('lstValues===>>'+lstValues);
                                Location__c oL = new Location__c(id = lstValues.get(2));
                                if(lstValues.get(0).length()!=2){
                                    try{
                                        oL.Preferred_Install_Date_Time_1__c = parsedate(lstValues.get(0));
                                    }catch(exception e){
                                        oL.Preferred_Install_Date_Time_1__c = null;
                                    }    
                                }else{
                                    
                                    oL.Preferred_Install_Date_Time_1__c = null;
                                }
                                if(lstValues.get(1).length()!=2){
                                    try{
                                        oL.Preferred_Install_Date_Time_2__c = parsedate(lstValues.get(1));
                                    }catch(exception e){
                                        oL.Preferred_Install_Date_Time_2__c = null;
                                    }
                                }   else{
                                    oL.Preferred_Install_Date_Time_2__c = null;
                                }                            
                                preferredDatesLocationList.add(oL);
                                //System.debug('added in the list===>>'+oL);
                            }
                        }
                    }
                }
            }
            
        }catch(exception e){
            system.debug('Gone wrong'+e.getMessage()+'Line No: -'+e.getLineNumber());
        }
        
        //System.debug('new list::==>'+preferredDatesLocationList);
        if(!preferredDatesLocationList.isEmpty() && preferredDatesLocationList.size() > 0){
            update preferredDatesLocationList;
        }
        
        List<Order_Line_Item_Details__c> toSubmitVehicleList = new List<Order_Line_Item_Details__c>();
        if(!selectedVehicleWrapperList.isEmpty()){
            for(SelectedVehicleWrapper svw : selectedVehicleWrapperList){
                svw.selectedVehicle.isSubmitted__c = true; 
                toSubmitVehicleList.add(svw.selectedVehicle);
            }
        }
        if(!toSubmitVehicleList.isEmpty()){
            update toSubmitVehicleList;
        }
        */
        //Reset Search
        resetNewTableFn();
        resetSubmittedTableFn();
    }
    
    //Method to parse the date
    public dateTime parsedate(String str){
        //System.debug('str >>'+str);
        String strDate = str;
        datetime dT ;
        
        List<String>  lstD = str.split(' ');
        
        //System.debug('lstD >>'+lstD);
        
        Date newDate = Date.parse(lstD.get(0));
        
        list<string>  lstTime =  lstD.get(1).split(':'); 
        //System.debug('lstTime >>'+lstTime);
        String timeVal =  lstD.get(2);
        Integer tVal= Integer.ValueOf(lstTime.get(0));
        
        if(timeVal == 'PM' && tVal != 12){
            tVal  = 12+ Integer.valueOf(lstTime.get(0));
        }else if(timeVal == 'AM' && tVal == 12){
            tVal = 0;
        }
        
        Time myTime = Time.newInstance(tVal, integer.ValueOf(lstTime.get(1)), 0, 0);
        dT = DateTime.newInstance(newDate, myTime); 
        
        return dT;
        
    }
    // method to delete vehicles
    public PageReference deleteSelectedVehicles(){
        List<Order_Line_Item_Details__c> toDeleteVehicleList = new List<Order_Line_Item_Details__c>();
        if(!selectedVehicleWrapperList.isEmpty()){
            for(SelectedVehicleWrapper svw : selectedVehicleWrapperList){
                if(svw.isVehSelected == true){                   
                    toDeleteVehicleList.add(svw.selectedVehicle);
                }
            }
        }
        if(!toDeleteVehicleList.isEmpty()){
            delete toDeleteVehicleList;
            updateBalanceQuantity();
        }
        resetNewTableFn();
        //PageReference pageRef = ApexPages.currentPage();
        //pageRef.getParameters().put('Id', ApexPages.currentPage().getParameters().get('Id'));
        //pageRef.setRedirect(false);
        //return pageRef;
        return null;
    }
    
    // method to duplicate/clone the vehicles (only copies few fields)
    public PageReference duplicateSelectedVehicles(){
        List<Order_Line_Item_Details__c> toCloneVehicleList = new List<Order_Line_Item_Details__c>();
        Map<Id, Id> olidCloneIdMap = new Map<Id, Id>();
        List<Id> selectedOLID = new List<Id>();
        if(!selectedVehicleWrapperList.isEmpty()){
            for(SelectedVehicleWrapper svw : selectedVehicleWrapperList){
                if(svw.isVehSelected == true){
                    Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c();
                    olid.Location__c = svw.selectedVehicle.Location__c;
                    olid.SF_Orders__c = svw.selectedVehicle.SF_Orders__c;
                    olid.GP_ERP_Order_ID__c = svw.selectedVehicle.GP_ERP_Order_ID__c;
                    olid.Order_Line_Items__c = svw.selectedVehicle.Order_Line_Items__c;
                    olid.Year__c = svw.selectedVehicle.Year__c;
                    olid.Make__c = svw.selectedVehicle.Make__c;
                    olid.Model__c = svw.selectedVehicle.Model__c;
                    olid.No_VIN_Flag__c = svw.selectedVehicle.No_VIN_Flag__c;
                    olid.Not_a_Vehicle__c = svw.selectedVehicle.Not_a_Vehicle__c;
                    olid.License_State__c = svw.selectedVehicle.License_State__c;
                    olid.Color__c = svw.selectedVehicle.Color__c;
                    olid.Fuel_Type__c = svw.selectedVehicle.Fuel_Type__c;
                    olid.Device_Type__c = svw.selectedVehicle.Device_Type__c;                   
                    olid.Addon_Alternate_Power_Adapter__c = svw.selectedVehicle.Addon_Alternate_Power_Adapter__c;
                    olid.Addon_Bluetooth_module__c = svw.selectedVehicle.Addon_Bluetooth_module__c;
                    olid.Addon_Buzzer__c = svw.selectedVehicle.Addon_Buzzer__c;
                    olid.Addon_Driver_ID__c = svw.selectedVehicle.Addon_Driver_ID__c;
                    olid.Addon_Garmin_CONNECT__c = svw.selectedVehicle.Addon_Garmin_CONNECT__c;
                    olid.Addon_Magnet_Mounts__c = svw.selectedVehicle.Addon_Magnet_Mounts__c;
                    olid.Addon_NMEA_Cable__c = svw.selectedVehicle.Addon_NMEA_Cable__c;
                    olid.Addon_PEM__c = svw.selectedVehicle.Addon_PEM__c;
                    olid.Addon_Pelican_Box__c = svw.selectedVehicle.Addon_Pelican_Box__c;
                    olid.Addon_Quake_Satellite_Modem__c = svw.selectedVehicle.Addon_Quake_Satellite_Modem__c;
                    olid.Addon_Window_Mount_GPS_Antenna__c = svw.selectedVehicle.Addon_Window_Mount_GPS_Antenna__c;                   
                    olid.Vehicle_Harness_Category__c = svw.selectedVehicle.Vehicle_Harness_Category__c;
                    olid.Installation_Type__c = svw.selectedVehicle.Installation_Type__c;
                    toCloneVehicleList.add(olid);
                    selectedOLID.add(svw.selectedVehicle.Id);
                }
            }
        }
        if(!toCloneVehicleList.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            
            try{
                insert toCloneVehicleList;
                
                //Map to store the keys of the old and cloned Ids
                for(Integer i=0; i<toCloneVehicleList.size(); i++){
                    olidCloneIdMap.put(selectedOLID.get(i), toCloneVehicleList.get(i).Id);
                }
                
                List<Order_Line_Item_Entry__c> oliEntryTempList = new List<Order_Line_Item_Entry__c>();
                List<Order_Line_Item_Entry__c> oliEntryInsertList = new List<Order_Line_Item_Entry__c>();
                oliEntryTempList = [Select Id, Name, Order_Line_Item__c, Order_Line_Item_Detail__c from Order_Line_Item_Entry__c where Order_Line_Item_Detail__c IN:olidCloneIdMap.keyset()];
                
                
                for(Order_Line_Item_Entry__c olieTemp: oliEntryTempList){
                    Order_Line_Item_Entry__c olieTmpIns = new Order_Line_Item_Entry__c();
                    olieTmpIns.Order_Line_Item__c = olieTemp.Order_Line_Item__c;
                    olieTmpIns.Order_Line_Item_Detail__c = olidCloneIdMap.get(olieTemp.Order_Line_Item_Detail__c);
                    oliEntryInsertList.add(olieTmpIns);
                }
                
                if(oliEntryInsertList.size()>0){
                    insert oliEntryInsertList;
                    
                }
                //Update Balance
                updateBalanceQuantity();
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(myMsg);
                Database.rollback(sp);
                
            }         
        }
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    // method to clear location input fields
    public void clearForm(){
        locationWrapper = new LocationWrapper();
        addlocationWrapper = new LocationWrapper();
    }
    
    // method to clear vehicle input form
    public void clearVehForm(){
        vehicleWrapper = new VehicleWrapper();
        locationStateFlag = false; 
        editvehicle = null;
    }
    
    // method to import csv file
    public PageReference importCSVFile(){
        PageReference importVehicles = Page.Import_OrderLineItemDetailsSRS;
        importVehicles.getParameters().put('id', orderId);       
        return importVehicles;
    }
    
    // logic to display child account field
    public void displayChildAccount(){
        Account acc = new Account();
        acc = [SELECT Id, Name ,Sub_Type__c FROM Account where Id =:accountId]; 
        if(acc != null && (acc.Sub_Type__c == 'RESELLER' || acc.Sub_Type__c == 'RESELLER-PP' || acc.Sub_Type__c == 'VAR')){
            displayChildAccount = true;    
        }
        else{
            displayChildAccount = false;
        }
    }
    
    @RemoteAction
    global static List<Account> getAccount(String OrderId) {
        Orders__c ordRec= new Orders__c();
        ordRec = [Select Id,Account__c,Child_Account__c from Orders__c where Id=:OrderId ];
        List<account> accList = [SELECT Id, Name  FROM Account where ParentId =:ordRec.Account__c];
        return accList;
    }
    
    public void saveChildAccount(){
        //system.debug('**childAccountName:'+childAccountName);
        if(!String.isEmpty(childAccountName)){
            Account acc = [Select Id From Account where Name=:childAccountName Limit 1];
            if(acc != null){
                orderRecord.Child_Account__c = acc.Id;
                update orderrecord;
            }
        }
    }
    
    //Added by Siva - Begin
    public Id fetchOLID(String sdType){
        Id returnId;
        List<Order_Line_Items__c> tempOLIList = orderLineItemMap.get(sdType);
        
        
        string temp = '';
        for(String s: orderLineItemMap.keySet()){
            temp += s +', ';
        }
        
        if(orderLineItemMap.containsKey(sdType)){
            List<Order_Line_Items__c> oliItemsListTemp = orderLineItemMap.get(sdType);
            for(Order_Line_Items__c oli: oliItemsListTemp){
                if(oli.Balance_Quantity__c>0){
                    returnId = oli.Id;
                    break;
                }else if(editVehicle!=null){
                    returnId = oli.Id;
                    break;
                }
            }
        }
        
        return returnId;
    }
    
    /*public void vehWrapperAvailableAccessories(VehicleWrapper vW){
        List<SelectOption> options = new List<SelectOption>();
        if(availableAccessoriesSet.contains('SSEM')){
        availableAccessoriesSet.remove('SSEM');
        
        }
        for(String sAvailAccsSet: availableAccessoriesSet){
        options.add(new SelectOption(sAvailAccsSet, sAvailAccsSet));
        
        
        }
        
        vW.availableAccessories = new List<SelectOption>();
        vW.availableAccessories.addAll(options);
    }*/
    
    //Method to pull the relevant accessories in VF page upon Service Type change in 'Schedule New Service' modal window
    public void fetchAvailableAccessories(){

        List<SelectOption> options = new List<SelectOption>();
        vehicleWrapper.selectedAccessories = new List<SelectOption>();
        Set<String> selAccSet = new Set<String>();
        
        if(selectedAccessoriesMap.containsKey(vehicleWrapper.serviceType)){
            selAccSet = selectedAccessoriesMap.get(vehicleWrapper.serviceType);
            for(String sTemp: selAccSet){
                vehicleWrapper.selectedAccessories.add(new SelectOption(sTemp, sTemp));
                
            }
            
        }
        Set<String> availAccsList = new Set<String>();
        
        if(accessoriesMap.containsKey(vehicleWrapper.serviceType)){
            availAccsList.addAll(accessoriesMap.get(vehicleWrapper.serviceType));
        }
        for(String sAvailAcc: availAccsList){
            //Show the available accessories which are not selected, and not Sensors.
            if(!selAccSet.contains(sAvailAcc) && sAvailAcc!='Sensors'){
                options.add(new SelectOption(sAvailAcc, sAvailAcc));
            }
        }
        
        vehicleWrapper.availableAccessories = new List<SelectOption>();
        vehicleWrapper.availableAccessories.addAll(options);
        
        //Reset
        selAccSet = new Set<String>();
        selectedAccessoriesMap.put(vehicleWrapper.serviceType, selAccSet);
        
        //vehicleWrapper = new VehicleWrapper();
        vehicleWrapper.sensorFlag = false;
        vehicleWrapper.deviceType = '';
        vehicleWrapper.harnessType = '';
        
        vehicleWrapper.sensor1 = '';
        vehicleWrapper.sensor2 = ''; 
        vehicleWrapper.sensor3 = '';
        vehicleWrapper.sensor4 = '';
        vehicleWrapper.sensor5 = '';
        vehicleWrapper.sensor6 = '';
        
        List<String> sType = vehicleWrapper.serviceType!=null? vehicleWrapper.serviceType.split(' '):null;
        
        if(sType!=null){
            String key = sType[0]+' Add-On Only_SSEM';
            availSensorCount = (finalQuantityMap.containsKey(key)) ? finalQuantityMap.get(key).GPBalance : 0;
        }
        
    }
    
    //Method to create the OLIEntry record
    public Order_Line_Item_Entry__c createOLIEntry(String selAccs, String insType, String devType, String sensorName){
        Order_Line_Item_Entry__c oliE = new Order_Line_Item_Entry__c();
        String deviceName = (devType != null && assetGuardSet.contains(devType))? 'Asset Guard' : devType;
        
        //String oliKey = (selAccs != null)? ((deviceName!=null)? (insType + ' Add-On Only'+'_'+selAccs) : (insType+'_'+selAccs)): (insType+'_'+deviceName);
        String oliKey = (serviceTypeDataDct.get(insType).isAddon__c)?((selAccs != null)? (insType+'_'+selAccs) : (insType +'_'+deviceName)) : ((selAccs != null)? (insType+' Add-On Only'+'_'+selAccs) : (insType+'_'+deviceName));
            
        oliE.order_line_item__c = fetchOLID(oliKey);
        oliE.order_line_item__c = oliE.order_line_item__c == null? fetchOLID(insType+'_null'): oliE.order_line_item__c;
        oliE.order_line_item_Detail__c = null;
        oliE.Sensor_Name__c = sensorName;
        
        
        return oliE;
    }

    //Method to validate the OLIEntry record
    private Id validateOLIEntry(String selAccs, String insType, String devType, String sensorName){
        String deviceName = (devType != null && assetGuardSet.contains(devType))? 'Asset Guard' : devType;

        String oliKey = insType+'_'+deviceName;
        if(serviceTypeDataDct.containsKey(insType)){
            oliKey = (serviceTypeDataDct.get(insType).isAddon__c)?((selAccs != null)? (insType+'_'+selAccs) : (insType +'_'+deviceName)) : ((selAccs != null)? (insType+' Add-On Only'+'_'+selAccs) : (insType+'_'+deviceName));
        }
        
        Id oliId = fetchOLID(oliKey);
        oliId = (oliId == null)? fetchOLID(insType+'_null'): oliId;
        
        for(Order_Line_Item_Entry__c oliE: oLIEntries){
            if(oliE.Order_Line_Item__c == oliId){
                return oliE.Id;
            }
        }
        return null;
    }
    
    //Method to get the help texts for the service types from the custom metadata
    private void getDisplayMessagesMetadata(){
        serviceTypeDataDct = new Map<String, Service_Type_Display_Message__mdt>();
        List<Service_Type_Display_Message__mdt> sTDMList = [Select Id, MasterLabel, Display_Message__c, UI_Service_Type_Label__c, isAddon__c from Service_Type_Display_Message__mdt];
        for(Service_Type_Display_Message__mdt sTDM: sTDMList){
            serviceTypeDataDct.put(sTDM.MasterLabel, sTDM);
        }
    }
    
    //Get the display Message directly based the service type chosen by the user
    public String getDisplayMessage(){
        if(serviceTypeDataDct.containsKey(vehicleWrapper.serviceType)){
            return serviceTypeDataDct.get(vehicleWrapper.serviceType).Display_Message__c;
        }
        return '';
    }
    
    public boolean getIsSensorCheckboxDisabled(){
        if(editVehicle!=null && (vehicleWrapper.sensorFlag == true)){  //explicit true comparison to avoid the error in when the sensorFlag is null
            return false;
        }
        List<String> sType = vehicleWrapper.serviceType!=null? vehicleWrapper.serviceType.split(' '):null;
        
        if(sType!=null){
            String key = sType[0]+' Add-On Only_SSEM';
            return finalQuantityMap.containsKey(key)? finalQuantityMap.get(key).GPBalance <= 0: true;
        }
        //vehicleWrapper.sensorFlag = false;            
        return true;
    }
    
    //Redirect the users if there is an attachment
    public PageReference redirectCustomerSRS(){
        
        List<Attachment> attList = new List<Attachment>();
        attList = [Select Id from Attachment where Parentid =:OrderId LIMIT 1];
        
        if(attList.size()>0){
            PageReference pg = Page.Import_OrderLineItemDetailsSRS;
            
            pg.getParameters().put('Id', OrderId);
            pg.getParameters().put('userRedirect', 'true');
            pg.setRedirect(true);
            return pg;
        }else{
            return null;
        }
    }
    
    //Method to Search the table in the new sction
    public pagereference searchNewTableFn(){
        resetNewSearchFlag = searchVariableNewTable<>''?true:false;
        searchSRSNewFlag = resetNewSearchFlag;
        //if the search criteria is blank, reset it
        if(!resetNewSearchFlag){
            setSRSNEW = null;
            selectedLocationVeh = null;
        }
        List<Order_Line_Item_Details__c> olidListTemp = (list<Order_Line_Item_Details__c>)setSRSNew.getRecords();
        selectedVehicleWrapperList = generateVehicleWrapperData(olidListTemp);
        
        //To refresh the page
        pagereference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    //Method to reset the search criteria on the table in the new section to bring the default vehicle (OLIDs list)
    public void resetNewTableFn(){
        resetNewTableVal();
        //reset location filter
        selectedLocationVeh = null;
        
        List<Order_Line_Item_Details__c> olidListTemp = (list<Order_Line_Item_Details__c>)setSRSNew.getRecords();
        selectedVehicleWrapperList = generateVehicleWrapperData(olidListTemp);
    }
    
    //Helper method for value reset
    public void resetNewTableVal(){
    	resetNewSearchFlag = false;
        searchSRSNewFlag = false;
        searchVariableNewTable = '';
        setSRSNEW = null;
        locationFilterOnNewFlag = false;
        resetLocationFilterOnNewFlag = false;
    }
    
    //Method to Search the table in the submitted section
    public void searchSubmittedTableFn(){
        resetSubmittedSearchFlag = searchVariableSubmittedTable<>''?true:false;
        searchSRSSubmittedFlag = resetSubmittedSearchFlag;
        if(!resetSubmittedSearchFlag){
            setSRSSubmitted = null;
        }
        List<Order_Line_Item_Details__c> olidListTemp = (list<Order_Line_Item_Details__c>)setSRSSubmitted.getRecords();
        submittedVehicleWrapperList = generateVehicleWrapperData(olidListTemp);
    }
    
    //Helper method for value reset
    public void resetSubmittedTableVal(){
    	resetSubmittedSearchFlag = false;
        searchSRSSubmittedFlag = false;
        searchVariableSubmittedTable = '';
        setSRSSubmitted = null;
        locationFilterOnSubmittedFlag = false;
        resetLocationFilterOnSubmittedFlag = false;
    }
    
    //Method to reset the search criteria on the table in the new section to bring the default vehicle (OLIDs list)
    public void resetSubmittedTableFn(){
        resetSubmittedTableVal();
        List<Order_Line_Item_Details__c> olidListTemp = (list<Order_Line_Item_Details__c>)setSRSSubmitted.getRecords();
        submittedVehicleWrapperList = generateVehicleWrapperData(olidListTemp);
    }
    
    //Method for Cancel button
    public pagereference reloadOnCancel(){
    	PageReference pageref = ApexPages.currentPage();
    	pageref.setRedirect(false);
    	return pageref;
    }
    
    public void updateFlagValues()
    {
     disableEditofLocation=false;
    }
    public void getAllvalues()
    {
        Location__c locList = [Select Id,Name,Garage_Address1__c,Garage_Address2__c,Garage_Country__c,Garage_City__c,Garage_State__c,Garage_Zip__c,ContactName__c,Email__c,Phone__c,Phone_ext__c,Alternate_Name__c,Alternate_Email__c,Alternate_Phone__c,Alternate_Phone_ext__c from Location__c where id=:vehicleWrapper.location];
        //tempLocList = locList;
       /* set<string> submittedLocationids=new set<string>();
        List<ETA_Staging__c> ETA=[select id,Location__c from ETA_Staging__c where location__c=:vehicleWrapper.location limit 1];
        
        if(ETA.size()>0 || ETA.size()<=0 )
        {
            disableEditofLocation=true;
        } */
        disableEditofLocation=true;
        //locatonid=vehicleWrapper.location;
        //system.debug('---->'+locatonid);
        //addlocationWrapper.locationid=vehicleWrapper.location;
        addlocationWrapper.locationid=locList.Id;
        system.debug('$$$$$$$$$$$$$$$$$----->'+addlocationWrapper.locationid);
        addlocationWrapper.locationName=locList.Name;
        addlocationWrapper.address1=locList.Garage_Address1__c;
        addlocationWrapper.address2=locList.Garage_Address2__c;
        addlocationWrapper.country=locList.Garage_Country__c;
        addlocationWrapper.city=locList.Garage_City__c;
        addlocationWrapper.state=locList.Garage_State__c;
        addlocationWrapper.zip=locList.Garage_Zip__c;
        addlocationWrapper.contactName=locList.ContactName__c;
        addlocationWrapper.email=locList.Email__c;
        addlocationWrapper.phone=locList.Phone__c;
        addlocationWrapper.phoneext=locList.Phone_ext__c;
        addlocationWrapper.alternateContactName=locList.Alternate_Name__c;
        addlocationWrapper.alternateEmail=locList.Alternate_Email__c;
        addlocationWrapper.alternatePhone=locList.Alternate_Phone__c;
        addlocationWrapper.alternatePhoneext=locList.Alternate_Phone_ext__c;
    }
}