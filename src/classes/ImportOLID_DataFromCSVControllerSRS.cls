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
// File Name:       importOLID_DataFromCSVController 
// Summary:         File Uploader Controller class for parsing excel/csv data and upsert it in to SFDC
// Created On:      April-23-2015

// Modification Log:
====================

// Aravind    - 4/23/2015 - Create a base version 
// Sunil   - 05/25/2017 - Commented Code which deletes vehicle records : IT-1899
// Sunil  - 07/18/2017 - Commented Submitted field for vehicle records
// Sunil  - 07/18/2017 - redirectToIODS method was created
// Siva - 01/25/2018 - Improved the CSV validation on Country, Garage Name/Address and Zip code
*******************************************************************************/

public class ImportOLID_DataFromCSVControllerSRS {
    public Transient Blob csvFileBody{get;set;}
    public string Regex {get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public List<Order_Line_Item_Details__c> OLIDList = new List<Order_Line_Item_Details__c> ();
    public List<OLID_Data> listOLID_Data{get;set;}
    public string Order_GP_ERP_Order_ID = '';
    public string Order_ID {get;set;}
    public string Account_ID {get;set;}
    public Orders__c currentOrder;
    public Account currentAccount;
    public List<Location__c> listExistingLocation = new List<Location__c>();
    public List<OrderLocation__c> listExistingOrderLocation = new List<OrderLocation__c>();
    public Map<string, Location__c> existingLocationMap = new Map<string, Location__c>();
    public Map<string, OrderLocation__c> existingOrderLocationMap = new Map<string, OrderLocation__c>();
    Public boolean isOverride {get;set;}
    public boolean isSelected{ get; set; }
    public Set<string> installTypeSet;
    public Set<string> deviceTypeSet;
    public Set<string> harnessTypeSet;
    public boolean isLargeDataUpload {get; set;}
    //Added by Siva - Begin
     Map<String, String> GPItemMap;
     Map<String, List<Order_Line_Items__c>> oliDeviceMap;
     transient Decimal chunkUploadSize;
     private boolean accessoriesImportFailureFlag;
     public String GPOrderIdFromUrl {get; set;}
     Set<String> countrySet = new Set<String>();
    //Added by Siva - End
    public List<Order_Line_Item_Entry__c> insertOLIEList = new List<Order_Line_Item_Entry__c>();
    Map<String, String> csvGPInstallTypeTranslation;
    

    
    public ImportOLID_DataFromCSVControllerSRS(){
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10');
        
        csvFileLines = new String[]{};
        isSelected = true;
        installTypeSet = new Set<string>();
        deviceTypeSet = new Set<string>();
        harnessTypeSet = new Set<string>();
        isLargeDataUpload = false;
        //Fetching all the valid Install types from Custom Metadata Type
        csvGPInstallTypeTranslation = new Map<String, String>();
        accessoriesImportFailureFlag = false;
        //Get the OrderId from the URL
        Id idFromURL = ApexPages.currentPage().getParameters().get('Id');
        if(idFromURL!=null){
            Orders__c ord = [Select Id, GP_ERP_Order_ID__c from Orders__c where Id=:idFromURL];
            GPOrderIdFromUrl = ord.GP_ERP_Order_ID__c;
        }
        for(Install_Types__mdt mdt:[Select DeveloperName,MasterLabel, GP_Item_Mapping_Service_Type__c from Install_Types__mdt]){
            //installTypeSet.add(mdt.DeveloperName); 
            //installTypeSet.add(mdt.MasterLabel);
            installTypeSet.add(mdt.MasterLabel);
            csvGPInstallTypeTranslation.put(mdt.MasterLabel, mdt.GP_Item_Mapping_Service_Type__c);
        }
        //Fatching all the Device_Type__c picklist values
        Schema.DescribeFieldResult fieldResultDevType = Order_Line_Item_Details__c.Device_Type__c.getDescribe();
        List<Schema.PicklistEntry> pvalDeviceType = fieldResultDevType.getPicklistValues();
        
        for(Schema.PicklistEntry plv : pvalDeviceType){
            deviceTypeSet.add(plv.getValue());
        } 
        //Fetching all the Vehicle_Harness_Category__c picklist values
        Schema.DescribeFieldResult fieldResultHarnessCat = Order_Line_Item_Details__c.Vehicle_Harness_Category__c.getDescribe();
        List<Schema.PicklistEntry> pvalHarnessType = fieldResultHarnessCat.getPicklistValues();
        
        for(Schema.PicklistEntry plv : pvalHarnessType){
            harnessTypeSet.add(plv.getValue());
        } 
        
        //Added by Siva - Begin
        GPItemMap = new Map<String, String>();
        createGPItemCheckboxMap();
        
        //Populate the available countries set from the Location object
        Schema.DescribeFieldResult fieldResult = Location__c.Garage_Country__c.getDescribe();
        List<Schema.PicklistEntry> countryList = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : countryList){
            countrySet.add(f.getValue());
        }
        
        //oliDeviceMap = new Map<String, List<Order_Line_Items__c>>();
        //Added by Siva - End
        

        
    }
   
  Public class OLID_Data    {
         public string INSTALLTYPE  {get;set;}
         public string VIN  {get;set;}
         public string OLDVIN_REQUIREDIFTRANSFER    {get;set;}
         public string VEHICLEID_NEW    {get;set;}
         public string VEHICLEID_OLD    {get;set;}
         public string YEAR {get;set;}
         public string MAKE {get;set;}
         public string MODEL    {get;set;}
         public string COLOR {get;set;}
         public string FUELTYPE {get;set;}
         public string LICPLATE {get;set;}
         public string LICSTATE {get;set;}
         public string SERIAL_NEW   {get;set;}
         public string SERIAL_OLD_FORSWAP   {get;set;}
         public string DEVICETYPE   {get;set;}
         public string HARNESSTYPEORDERED   {get;set;}
         public string CONTACTNAME  {get;set;}
         public string EMAIL    {get;set;}
         public string PHONE    {get;set;}
         public string EXT    {get;set;}
         public string SECONDARYCONTACT {get;set;}
         public string SECONDARYEMAIL   {get;set;}
         public string SECONDARYPHONE   {get;set;}
         public string SECONDARYPHONEEXT   {get;set;}
         public string LOCATIONNAME {get;set;}
         public string GARAGEDADDRESS   {get;set;}
         public string CITY {get;set;}
         public string STATE_PROVINCE   {get;set;}
         public string COUNTRY   {get;set;}
         public string ZIP  {get;set;}
         public string NOTES    {get;set;}
         //public string TRACKINGNO   {get;set;}
         //public string SHIPPEDDATE  {get;set;}
         //public string ARRIVALDATE  {get;set;}
         //public string RA{get;set;}
         public string DEVICERETURNEDTO {get;set;}
         public string SENSOR1NAME  {get;set;}
         public string SENSOR2NAME  {get;set;}
         public string SENSOR3NAME  {get;set;}
         public string SENSOR4NAME  {get;set;}
         public string SENSOR5NAME  {get;set;}
         public string SENSOR6NAME  {get;set;}
         public string PEM  {get;set;}
         public string PelicanBox   {get;set;}
         public string NBEACable    {get;set;}
         public string Garmin   {get;set;}
         public string Quake    {get;set;}
         public string AlternatePowerAdapter    {get;set;}
         public string WindowMountGPSAntenna    {get;set;}
         public string DriverID {get;set;}
         public string MagnetMounts {get;set;}
         public string BluetoothModule  {get;set;}
         //public string SSEM {get;set;}
         //public string SEM{get;set;}
         public string GP_ERP_Order_ID {get;set;}
         public string OrderID{get;set;}
         public string LocationID{get;set;}
      
      Public OLID_Data()    {
         this.INSTALLTYPE   = '';
         this.VIN   = '';
         this.OLDVIN_REQUIREDIFTRANSFER = '';
         this.VEHICLEID_NEW = '';
         this.VEHICLEID_OLD = '';
         this.YEAR  = '';
         this.MAKE  = '';
         this.MODEL = '';
         this.COLOR = '';
         this.FUELTYPE = '';
         this.LICPLATE  = '';
         this.LICSTATE  = '';
         this.SERIAL_NEW    = '';
         this.SERIAL_OLD_FORSWAP    = '';
         this.DEVICETYPE    = '';
         this.HARNESSTYPEORDERED    = '';
         this.CONTACTNAME   = '';
         this.EMAIL = '';
         this.PHONE = '';
         this.EXT = '';
         this.SECONDARYCONTACT = '';
         this.SECONDARYEMAIL    = '';
         this.SECONDARYPHONE    = '';
         this.SECONDARYPHONEEXT    = '';
         this.LOCATIONNAME = '';
         this.GARAGEDADDRESS    = '';
         this.CITY  = '';
         this.STATE_PROVINCE    = '';
         this.COUNTRY    = '';
         this.ZIP   = '';
         this.NOTES = '';
         //this.TRACKINGNO    = '';
         //this.SHIPPEDDATE   = '';
         //this.ARRIVALDATE   = '';
         //this.RA= '';
         this.DEVICERETURNEDTO  = '';
         this.SENSOR1NAME   = '';
         this.SENSOR2NAME   = '';
         this.SENSOR3NAME   = '';
         this.SENSOR4NAME   = '';
         this.SENSOR5NAME   = '';
         this.SENSOR6NAME   = '';
         this.PEM   = '';
         this.PelicanBox    = '';
         this.NBEACable = '';
         this.Garmin    = '';
         this.Quake = '';
         this.AlternatePowerAdapter = '';
         this.WindowMountGPSAntenna = '';
         this.DriverID  = '';
         this.MagnetMounts  = '';
         this.BluetoothModule = '';
         //this.SSEM  = '';
         //this.SEM= '';
         this.GP_ERP_Order_ID ='';
         this.OrderID= '';
         this.LocationID= '';
      }   
  
  }
  
    public pagereference importCSVFile(){
    
       list<list<string>> parsedCSV = new list<list<string>>();
       list<list<string>> headerData = new list<list<string>>();
       //Reset
       isLargeDataUpload = false;
       
       if(csvFileBody == null){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.FATAL,'Choose your File First');
             ApexPages.addMessage(errormsg);
             return null;
       }
   
       try{
            ////string csvToString = EncodingUtil.base64Decode(EncodingUtil.base64Encode(csvFileBody)).toString();
            parsedCSV = VZ_Util.parseCSV(csvFileBody.toString(),true, true);
            
       }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data' + e.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }
      
        try {
        
                 headerData  = parseCSVForERPORDERID(csvFileBody.toString());
                 system.debug('headerData.size()=>'+headerData);
                 for(list<string> csvRecordData:headerData){
                     Order_GP_ERP_Order_ID  = csvRecordData[1]; 
                     System.Debug(Logginglevel.ERROR,'Error Order_GP_ERP_Order_ID '+Order_GP_ERP_Order_ID); 
                 }
        }
        catch (Exception e)    {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading Order_GP_ERP_Order_ID - Please make sure input csv file is valid  ' + e.getMessage());
                ApexPages.addMessage(errorMessage);
                return null;
        } 
        Map<integer,string> mandatoryColumnsMap = new Map<integer,string>();
        try{
            //mandatoryColumnsMap = fnGetMandatoryColumnsMap(csvFileBody.toString());
            system.debug('mandatoryColumnsMap.size()=>'+mandatoryColumnsMap.size());
        } catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading Mandatory Columns - Please make sure input csv file is valid' + ex.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;    
        }
        
         if(VZ_Util.IsNullOrEmpty(Order_GP_ERP_Order_ID)){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading Order_GP_ERP_Order_ID - Please make sure input csv file has value for Order Number');
                ApexPages.addMessage(errorMessage);
                return null;
         }
            
         try{
            //Populate related object values
            system.debug('@@@The GP ERP value is: '+Order_GP_ERP_Order_ID);
            currentOrder = [Select Id, Account__c from Orders__c where GP_ERP_Order_ID__c =:Order_GP_ERP_Order_ID limit 1];
         }
         catch (Exception e){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No Order found for GP_ERP_Order_ID - Please make sure input csv file is valid' + Order_GP_ERP_Order_ID  + e.getMessage());
                ApexPages.addMessage(errorMessage);
                return null;
         } 
        
         if(currentOrder == null || VZ_Util.IsNullOrEmpty(currentOrder.Id) ) {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No Order Found - Please make sure input csv file is valid');
                ApexPages.addMessage(errorMessage);
                return null;
         }
         Order_ID = currentOrder.Id;
         Account_ID = currentOrder.Account__c;
         //currentAccount = [Select Id, Name from Account where id =:Account_ID limit 1];            
         getLocationMapforAccount(Account_ID);
         getOrderLocationMap(Order_ID);
        //Added by Siva - Begin
        //If is a large data upload.
        boolean attachmentFlag = hasOLIDAttachment(Order_ID);
        
        GPOrderIdFromUrl = Order_GP_ERP_Order_ID;
        
        if(parsedCSV.size() > 600 || attachmentFlag){
            system.debug('ParsedCSV'+parsedCSV.size());
            Attachment att = new Attachment();
            att.body = csvFileBody;
            att.parentId = Order_ID;
            att.contentType = 'text/csv';
            att.Name=Order_GP_ERP_Order_ID+'__' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv';
            try{
                Orders__c  ord = new Orders__c (Id= Order_ID, SendICEmail__c= true);
                insert att;
                update ord;
                isLargeDataUpload = true;
                ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'SUCCESS! Your file with '+parsedCSV.size()+' vehicle(s) has been submitted for the Order \''+Order_GP_ERP_Order_ID+'\'. An installation coordinator will contact you to finalize your service request.');
                ApexPages.addMessage(infoMessage);
            }catch(Exception e){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is valid' +  e.getMessage());
                ApexPages.addMessage(errorMessage);
            }
        }else{ //Added by Siva - End
            string strErrorMsg =''; 
            List<ApexPages.Message> errMsgList = new List<ApexPages.Message>();
            try{
                listOLID_Data = new List<OLID_Data>();
                integer intLineCount = 1;
                
                for(list<string> csvRecordData:parsedCSV){
                    
                    string strMsg = fnValidateCSVRow(intLineCount, csvRecordData, mandatoryColumnsMap);
                    if(strMsg != ''){
                        ApexPages.Message validationErrorMessage = new ApexPages.Message(ApexPages.severity.ERROR,strMsg);
                        errMsgList.add(validationErrorMessage);
                    }
                    OLID_Data oliRecord = new OLID_Data() ;
                    oliRecord.INSTALLTYPE    = csvGPInstallTypeTranslation.containsKey(csvRecordData[0])?csvGPInstallTypeTranslation.get(csvRecordData[0]):csvRecordData[0];  
                    oliRecord.VIN  = csvRecordData[1];  
                    oliRecord.OLDVIN_REQUIREDIFTRANSFER    = csvRecordData[2];   
                    oliRecord.VEHICLEID_NEW    = csvRecordData[3];   
                    oliRecord.VEHICLEID_OLD    = csvRecordData[4];  
                    oliRecord.YEAR = csvRecordData[5];  
                    oliRecord.MAKE = csvRecordData[6];  
                    oliRecord.MODEL    = csvRecordData[7]; 
                    oliRecord.COLOR    = csvRecordData[8]; 
                    oliRecord.FUELTYPE    = csvRecordData[9];  
                    oliRecord.LICPLATE = csvRecordData[10];  
                    oliRecord.LICSTATE = csvRecordData[11]; 
                    oliRecord.SERIAL_NEW   = csvRecordData[12];
                    oliRecord.SERIAL_OLD_FORSWAP   = csvRecordData[13];  
                    oliRecord.DEVICETYPE   = csvRecordData[14];
                    oliRecord.HARNESSTYPEORDERED   = csvRecordData[15];  
                    oliRecord.CONTACTNAME  = csvRecordData[16];
                    oliRecord.EMAIL    = csvRecordData[17];  
                    oliRecord.PHONE    = csvRecordData[18];
                    oliRecord.EXT    = csvRecordData[19];               
                    oliRecord.SECONDARYCONTACT = csvRecordData[20]; 
                    oliRecord.SECONDARYEMAIL   = csvRecordData[21];
                    oliRecord.SECONDARYPHONE   = csvRecordData[22];
                    oliRecord.SECONDARYPHONEEXT   = csvRecordData[23];
                    oliRecord.LOCATIONNAME = csvRecordData[24];
                    oliRecord.GARAGEDADDRESS   = csvRecordData[25];
                    oliRecord.CITY = csvRecordData[26]; 
                    oliRecord.COUNTRY   = csvRecordData[27]; 
                    oliRecord.STATE_PROVINCE   = csvRecordData[28];
                    oliRecord.ZIP  = csvRecordData[29];  
                    oliRecord.NOTES    = csvRecordData[30];                    
                    //oliRecord.TRACKINGNO   = csvRecordData[25];
                    //oliRecord.SHIPPEDDATE  = csvRecordData[26];
                    //oliRecord.ARRIVALDATE  = csvRecordData[27];
                    //oliRecord.RA = csvRecordData[28];  
                    oliRecord.DEVICERETURNEDTO = csvRecordData[31];
                    oliRecord.SENSOR1NAME  = csvRecordData[32];
                    oliRecord.SENSOR2NAME  = csvRecordData[33];
                    oliRecord.SENSOR3NAME  = csvRecordData[34];
                    oliRecord.SENSOR4NAME  = csvRecordData[35];
                    oliRecord.SENSOR5NAME  = csvRecordData[36];
                    oliRecord.SENSOR6NAME  = csvRecordData[37];
                    oliRecord.PEM  = csvRecordData[38];  
                    oliRecord.PelicanBox   = csvRecordData[39];
                    oliRecord.NBEACable    = csvRecordData[40];
                    oliRecord.Garmin   = csvRecordData[41];  
                    oliRecord.Quake    = csvRecordData[42];  
                    oliRecord.AlternatePowerAdapter    = csvRecordData[43];
                    oliRecord.WindowMountGPSAntenna    = csvRecordData[44];  
                    oliRecord.DriverID = csvRecordData[45];  
                    //oliRecord.MagnetMounts = csvRecordData[46];
                    oliRecord.BluetoothModule  = csvRecordData[46];
                      
                    listOLID_Data.add(oliRecord);
                    intLineCount++;
                }
            }
            catch (Exception e)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is valid' +  e.getMessage());
                ApexPages.addMessage(errorMessage);
                return null;
            } 
            if(errMsgList.size() > 0){
                for(ApexPages.Message strMsg:errMsgList){
                    ApexPages.addMessage(strMsg);    
                }
                return null;    
            }
                
                System.Debug(Logginglevel.ERROR,'***********listOLID_Data size'+ listOLID_Data.Size());   
               
                try{
                   boolean flag = createOrderLocationAndLocationData(listOLID_Data);
                   if(!flag){
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.Error, 'Error: An unexpected error while processing all or few Garage Address(s) in your file, please review and try again.');
                        ApexPages.addMessage(myMsg);
                        return null;
                   }
                }catch(Exception e){
                    //System.Debug(Logginglevel.ERROR,'Error createOrderLocationAndLocationData '+e.getMessage());
                    return null;
                }
                
                /*String allSuccessMsg = 'SUCCESS! Your order has been uploaded, '+chunkUploadSize+' out of '+ listOLID_Data.Size()+ ' were accepted. You\'re almost done! '+'<br/>'+'Please click on \'Continue\' to proceed.';
                String partialSuccessMsg = 'ATTENTION!  Your order was partially uploaded, '+chunkUploadSize+' out of '+ listOLID_Data.Size()+ ' vehicles were accepted. There were more \"Installation Services\" or \"Accessory Installation Services\" requested than purchased. Please contact Sales to order additional accessory/installation services.'+'<br/>'+'Please click continue to submit the accepted vehicles.';
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Order Line Item Details data imported successfully - Total Records for Order# - ' + Order_GP_ERP_Order_ID + ' ----' + listOLID_Data.Size());
               //ApexPages.addMessage(myMsg);
                String allFailureMsg = 'ATTENTION! Unfortunately we were unable to process your request. The \"Installation Services\" or \"Accessory Installation Services\" requested exceeded the available balance on your order. Please contact Sales to order the necessary accessory/installation services.';
                String accessoryFailureWarningMsg = '<b>Note:</b> We were unable to process some of the accessories from the file, either those accessories were not purchased or due to insufficient balance quantity.';
                */
                
                String conditionalInstallMsg = listOLID_Data.Size() == chunkUploadSize? '' : (chunkUploadSize == 0? ' installs' : ' installs');
                String conditionalAccMsg = accessoriesImportFailureFlag? (conditionalInstallMsg == ''? (accessoriesImportFailureFlag?' accessories ':'') : ' and accessories'):'';
                //String contidionalAccMsgAllNone = isValidPrimDeviceTypeAddonOnly? conditionalInstallMsg == '';
                
                String allSuccessMsg = 'SUCCESS! Your order has been uploaded.  <b>'+chunkUploadSize+'</b> out of <b>'+ listOLID_Data.Size()+ '</b> rows were accepted. You\'re almost done! '+'<br/><br/>'+'Please click on "Continue" to proceed.';
                String partialSuccessMsg = 'ATTENTION!  Your order was partially uploaded, <b>'+chunkUploadSize+'</b> out of <b>'+ listOLID_Data.Size()+ '</b> rows were accepted. We were unable to process some of the<b>'+conditionalInstallMsg+conditionalAccMsg+'</b> on file either because they were not purchased or there is insufficient balance remaining. Please contact Sales to order additional installation services.'+'<br/><br/>'+'Please click "Continue" to submit the accepted vehicles.';
                String allFailureMsg = 'ATTENTION: Unfortunately we were unable to process your request either because the<b>'+conditionalInstallMsg+conditionalAccMsg+'</b> were not purchased or there is insufficient balance remaining. Please contact Sales to order additional installation services.';
                
                String uploadInfo = (listOLID_Data.Size() == chunkUploadSize && !accessoriesImportFailureFlag)? allSuccessMsg : (chunkUploadSize == 0? allFailureMsg : partialSuccessMsg);
                
                /*if(accessoriesImportFailureFlag){
                    uploadInfo = uploadInfo+ (chunkUploadSize == 0?'':+'<br/><br/>'+accessoryFailureWarningMsg);
                }*/
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, uploadInfo );
                ApexPages.addMessage(myMsg);
            }
         return null;
    }
    
    private Map<string,Location__c> getLocationMapforAccount(string Account_ID) {
                 
        listExistingLocation =  [Select Id, Name,Customer__c,Garage_Address1__c,Garage_City__c,Garage_State__c,Phone__c,Phone_ext__c, ContactName__c, Email__c,Alternate_Phone__c,Alternate_Phone_ext__c,Alternate_Email__c  from Location__c where Customer__c =:Account_ID limit 1000];       
        existingLocationMap.clear();
        if(!VZ_Util.IsNullOrEmpty(listExistingLocation))   {
            for(Location__c location : listExistingLocation )
            {
                 existingLocationMap.put(location.Name.toUpperCase(), location );
            }                             
        }
         System.Debug(Logginglevel.ERROR,'debug getLocationMapforAccount -|'+existingLocationMap.Size()); 
         
        return existingLocationMap;
    
    }
    
    private Map<string,OrderLocation__c> getOrderLocationMap(string Order_ID)   {
                 
        listExistingOrderLocation = [Select Id, Location__c, Orders__c from OrderLocation__c where Orders__c =:Order_ID limit 1000];   
            
        if(!VZ_Util.IsNullOrEmpty(listExistingOrderLocation))   {
            for(OrderLocation__c orderLocation : listExistingOrderLocation )
            {
                 existingOrderLocationMap.put(orderLocation.Location__c, orderLocation);
            }                             
        }
        
        return existingOrderLocationMap;
    
    }
    
    
    
    private boolean createOrderLocationAndLocationData(List<OLID_Data> listOLID_Data)   {
    
        
        List<Location__c> locationsToCreateList = new List<Location__c>();
        List<Location__c> UniquelocationsList = new List<Location__c>();
        Map<string,Location__c> newLocationsMap = new Map<string,Location__c>();
        List<OrderLocation__c > orderLocationToCreateList = new List<OrderLocation__c >();
        
        Set<string> uniqueLocationNames = new Set<string>();        
        Set<string> uniqueGarageAddress = new Set<string>();
        
        
        for(OLID_Data lOLID_Data : listOLID_Data){
            if(!VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME))
            {
                uniqueLocationNames.Add(lOLID_Data.LOCATIONNAME);
                System.Debug(Logginglevel.ERROR,'debug lOLID_Data.LOCATIONNAME -|'+lOLID_Data.LOCATIONNAME); 
            } 
            if(VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME) && !VZ_Util.IsNullOrEmpty(lOLID_Data.GARAGEDADDRESS))
            {
                if(lOLID_Data.GARAGEDADDRESS.length()>80){
                    uniqueLocationNames.add(lOLID_Data.GARAGEDADDRESS.SubString(0,80)); 
                    lOLID_Data.LOCATIONNAME = lOLID_Data.GARAGEDADDRESS.SubString(0,80);
                    System.Debug(Logginglevel.ERROR,'debug null lOLID_Data.GARAGEDADDRESS -|'+lOLID_Data.GARAGEDADDRESS); 
                }
                else    {
                   uniqueLocationNames.add(lOLID_Data.GARAGEDADDRESS);
                   lOLID_Data.LOCATIONNAME = lOLID_Data.GARAGEDADDRESS;
                   System.Debug(Logginglevel.ERROR,'debug null lOLID_Data.GARAGEDADDRESS -|'+lOLID_Data.GARAGEDADDRESS); 
                }               
                
            } 
                    
        }  
        
        for(OLID_Data lOLID_Data : listOLID_Data){
         
            if(!VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME) && !existingLocationMap.ContainsKey(lOLID_Data.LOCATIONNAME.toUpperCase()))
            {
                Location__c locationData = new Location__c();
                locationData.Name = lOLID_Data.LOCATIONNAME;
                locationData.Garage_Address1__c   =  lOLID_Data.GARAGEDADDRESS;
                locationData.ContactName__c =  lOLID_Data.CONTACTNAME;
                locationData.Email__c =  lOLID_Data.EMAIL;
                locationData.Phone__c =  lOLID_Data.PHONE;
                locationData.Phone_ext__c =  lOLID_Data.EXT;
                locationData.Alternate_Name__c = lOLID_Data.SECONDARYCONTACT;
                locationData.Alternate_Email__c =  lOLID_Data.SECONDARYEMAIL;
                locationData.Alternate_Phone__c   =  lOLID_Data.SECONDARYPHONE;
                locationData.Alternate_Phone_ext__c   =  lOLID_Data.SECONDARYPHONEEXT;
                locationData.Garage_City__c =  lOLID_Data.CITY;
                locationData.Garage_State__c   =  lOLID_Data.STATE_PROVINCE;
                locationData.Garage_Country__c   =  lOLID_Data.COUNTRY;
                locationData.Garage_Zip__c  =  lOLID_Data.ZIP;
                locationData.Customer__c  =  Account_ID;
                System.Debug(Logginglevel.ERROR,'debug lOLID_Data.LocationID -|'+lOLID_Data.LocationID); 
                
                locationsToCreateList.add(locationData);
            }  
        }  
        
        
        for(Location__c locationCreated : locationsToCreateList){
        
            if(!newLocationsMap.ContainsKey(locationCreated.Name))
            {
                newLocationsMap.put(locationCreated.Name, locationCreated);
            }           
        }
        UniquelocationsList = newLocationsMap.Values();
        
        try{
            insert UniquelocationsList;
            System.Debug(Logginglevel.ERROR,'UniquelocationsList - UniquelocationsList size ************' + UniquelocationsList.Size()); 
        }catch(Exception e){
            System.Debug(Logginglevel.ERROR,'UniquelocationsList - UniquelocationsList Error ************' + e.getMessage());
            return false;
        }

        for(Location__c locationCreated : UniquelocationsList){
        
            OrderLocation__c orderLocationToCreate = new OrderLocation__c();
            orderLocationToCreate.Orders__c = Order_ID;
            orderLocationToCreate.Location__c = locationCreated.Id;
            orderLocationToCreateList.add(orderLocationToCreate);
        }
        
        try{
            insert orderLocationToCreateList;
            System.Debug(Logginglevel.ERROR,'orderLocationToCreateList - orderLocationToCreateList size ************' + orderLocationToCreateList.Size());
        }catch(Exception e){
            System.Debug(Logginglevel.ERROR,'orderLocationToCreateList - orderLocationToCreateList Error ************' + e.getMessage()); 
            return false;
        }

        getLocationMapforAccount(Account_ID);
        getOrderLocationMap(Order_ID);
            
        for(OLID_Data lOLID_Data : listOLID_Data){
            if(!VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME) && existingLocationMap.ContainsKey(lOLID_Data.LOCATIONNAME.toUpperCase())){
                lOLID_Data.LocationID = existingLocationMap.get(lOLID_Data.LOCATIONNAME.toUpperCase()).Id;
                System.Debug(Logginglevel.ERROR,'debug lOLID_Data.LocationID -|'+lOLID_Data.LocationID); 
            }
        }  
        boolean createFlag = createOrderLineItemDetailsData(listOLID_Data);
        return createFlag;
    }
    @TestVisible
    private boolean isXString(string olidString)    {
        //system.debug('In isXString Method: '+olidString);
        //system.debug((olidString == null)?true:((olidString == '')?true:false));
        //system.debug((olidString == null)+'____'+(olidString == ''));
        if(VZ_Util.IsNullOrEmpty(olidString))   {
            return false;
        }
        else    {       
            return olidString.toUpperCase() == 'X' ? True : False;
        }
     
    }
    @TestVisible
    private boolean createOrderLineItemDetailsData(List<OLID_Data> listOLID_Data)   {
        // Commented as per Jira Ticket Number - IT 1899 - Sunil Kumar
        /*if(isOverride){
           list<Order_Line_Item_Details__c> DeleteOLIDDataList = [select id from Order_Line_Item_Details__c  where SF_Orders__c =:Order_ID]; 
            if(DeleteOLIDDataList.Size() > 0)
            {
                delete DeleteOLIDDataList;
            }     
        }*/
          
        List<Order_Line_Item_Details__c> lineItemDetailToCreateList = new List<Order_Line_Item_Details__c>();
        
        for(OLID_Data lOLID_Data : listOLID_Data){
        
            Order_Line_Item_Details__c lineItemDetail = new Order_Line_Item_Details__c();
              
            System.debug('in line detail process');
            System.debug('line items loc is '+lOLID_Data.LocationID);
            
            if(lOLID_Data.LocationID!=''){
                lineItemDetail.Location__c = lOLID_Data.LocationID;
            }else{
                return false;
            }
            System.debug('****');
            lineItemDetail.SF_Orders__c = Order_ID;
            lineItemDetail.Installation_Type__c = lOLID_Data.INSTALLTYPE;            
            lineItemDetail.VIN__c = lOLID_Data.VIN;
            lineItemDetail.No_VIN_Flag__c = lOLID_Data.VIN == null ? true:false;
            lineItemDetail.Vehicle_Label__c=lOLID_Data.VEHICLEID_NEW;
            lineItemDetail.Old_Vin__c = lOLID_Data.OLDVIN_REQUIREDIFTRANSFER;
            lineItemDetail.Old_Vehicle_Label__c=lOLID_Data.VEHICLEID_OLD;
            lineItemDetail.Year__c = lOLID_Data.YEAR;
            lineItemDetail.Make__c   = lOLID_Data.MAKE;
            lineItemDetail.Model__c = lOLID_Data.MODEL;
            lineItemDetail.Color__c = lOLID_Data.COLOR;
            lineItemDetail.Fuel_Type__c = lOLID_Data.FUELTYPE;
            lineItemDetail.License_Plate__c = lOLID_Data.LICPLATE;
            lineItemDetail.License_State__c = lOLID_Data.LICSTATE;            
            lineItemDetail.Device_Type__c = lOLID_Data.DEVICETYPE;
            lineItemDetail.Device_Serial_Number__c= lOLID_Data.SERIAL_NEW;
            lineItemDetail.Device_Serial_Number_Old__c= lOLID_Data.SERIAL_OLD_FORSWAP;
            lineItemDetail.Vehicle_Harness_Category__c= lOLID_Data.HARNESSTYPEORDERED;
            lineItemDetail.Notes__c = lOLID_Data.Notes;
            lineItemDetail.Device_Returned__c = lOLID_Data.DEVICERETURNEDTO;
            lineItemDetail.Addon_Alternate_Power_Adapter__c =  isXString(lOLID_Data.AlternatePowerAdapter);
            lineItemDetail.Addon_Driver_ID__c = isXString(lOLID_Data.DriverID);
            lineItemDetail.Addon_Quake_Satellite_Modem__c = isXString(lOLID_Data.Quake);
            lineItemDetail.Addon_Garmin_CONNECT__c = isXString(lOLID_Data.Garmin);
            lineItemDetail.Addon_Magnet_Mounts__c = isXString(lOLID_Data.MagnetMounts);       
            lineItemDetail.Addon_Bluetooth_module__c = isXString(lOLID_Data.BluetoothModule);
            lineItemDetail.Addon_NMEA_Cable__c = isXString(lOLID_Data.NBEACable);
            lineItemDetail.Addon_Pelican_Box__c = isXString(lOLID_Data.PelicanBox);
            lineItemDetail.Addon_PEM__c = isXString(lOLID_Data.PEM);
            lineItemDetail.Addon_Window_Mount_GPS_Antenna__c = isXString(lOLID_Data.WindowMountGPSAntenna);
            lineItemDetail.Sensor1__c = lOLID_Data.SENSOR1NAME;
            lineItemDetail.Sensor2__c = lOLID_Data.SENSOR2NAME;
            lineItemDetail.Sensor3__c = lOLID_Data.SENSOR3NAME;
            lineItemDetail.Sensor4__c = lOLID_Data.SENSOR4NAME;
            lineItemDetail.Sensor5__c = lOLID_Data.SENSOR5NAME;
            lineItemDetail.Sensor6__c = lOLID_Data.SENSOR6NAME;
            lineItemDetail.Activity_Notes__c = lOLID_Data.NOTES;
            lineItemDetail.GP_ERP_Order_ID__c = Order_GP_ERP_Order_ID;
            lineItemDetailToCreateList.add(lineItemDetail);
        }

        //validate the 'lineItemDetailToCreateList' list
        accessoriesImportFailureFlag = false;
        lineItemDetailToCreateList = filterCSVDataList(lineItemDetailToCreateList, true);
        chunkUploadSize = lineItemDetailToCreateList.size();
        
        try    {
           
                //Set this flag to hack the creation of ETA records on OLID after insert/update triggers
                VZ_Util.IsOLIDBulkImport = true;
                
                insert lineItemDetailToCreateList;
                
                //validate and insert the OLIE records
                filterCSVDataList(lineItemDetailToCreateList, false);
                
                map<id,Order_Line_Item_Details__c> locIdOLIDMap = new map<Id,Order_Line_Item_Details__c>();
                Map<Id, Id> orderIdAccIdMap = new Map<Id,Id>();
                Set<Id> orderIdSet = new Set<Id>();
                List<ETA_Staging__c> etaStagingList = new List<ETA_Staging__c> ();
                //Reset OLIE list
                /*inOLIEList = new List<Order_Line_Item_Entry__c>();*/
                //Prepare map of Location Id and corresponding OLID
                for(Order_Line_Item_Details__c olid:lineItemDetailToCreateList){
                    system.debug('olid.Location__c=>'+olid.Location__c + '::'+'olid.Order_Account_ID__c=>'+olid.Order_Account_ID__c+'::'+'olid.SF_Orders__c =>'+olid.SF_Orders__c );
                    locIdOLIDMap.put(olid.Location__c,olid);  
                    orderIdSet.add(olid.SF_Orders__c);
                    
                    /*Set<String> addOnSet = new Set<String>();
                    if(olid.Addon_Alternate_Power_Adapter__c){
                        String addonKey = GPItemMap.get('Addon_Alternate_Power_Adapter__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Driver_ID__c){
                        String addonKey = GPItemMap.get('Addon_Driver_ID__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Quake_Satellite_Modem__c){
                        String addonKey = GPItemMap.get('Addon_Quake_Satellite_Modem__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Garmin_CONNECT__c){
                        String addonKey = GPItemMap.get('Addon_Garmin_CONNECT__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Magnet_Mounts__c){
                        String addonKey = GPItemMap.get('Addon_Magnet_Mounts__c');
                        addOnSet.add(addonKey);
                    }      
                    if(olid.Addon_Bluetooth_module__c){
                        String addonKey = GPItemMap.get('Addon_Bluetooth_module__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_NMEA_Cable__c){
                        String addonKey = GPItemMap.get('Addon_NMEA_Cable__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Pelican_Box__c){
                        String addonKey = GPItemMap.get('Addon_Pelican_Box__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_PEM__c){
                        String addonKey = GPItemMap.get('Addon_PEM__c');
                        addOnSet.add(addonKey);
                    }
                    if(olid.Addon_Window_Mount_GPS_Antenna__c){
                        String addonKey = GPItemMap.get('Addon_Window_Mount_GPS_Antenna__c');
                        addOnSet.add(addonKey);
                    }
                    system.debug(addOnset);
                    createOLIEntryData(addOnSet, olid);
                    */
                    
                }
                /*if(inOLIEList.size() > 0){
                    insert inOLIEList;
                }*/
                
                /*  
                
                //Code related to ETA Activity Creation has been commented in this controller logic.
                //IT-804 - Contact/Alternate Contact details on ETA Activity - Begin
                Map<Id,Location__c> locationMap = new Map<Id,Location__c>([SELECT Id,ContactName__c,Phone__c,Phone_ext__c,Email__c,Alternate_Name__c,Alternate_Phone__c,Alternate_Phone_ext__c,Alternate_Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c FROM Location__c WHERE Id IN :locIdOLIDMap.keySet()]);
                //IT-804 - Contact/Alternate Contact details on ETA Activity - End
                
                //Prepare map for Order Id and corresponding account Id
                for(Orders__c order:[SELECT Id,Account__c FROM Orders__c WHERE Id IN:orderIdSet]){
                    orderIdAccIdMap.put(order.Id,order.Account__c);    
                }
                //Set eta staging based on unique locations on imported OLIDs
                for(Id locId:locIdOLIDMap.keySet()){
                    ETA_Staging__c eta = new ETA_Staging__c();
                    eta.Location__c = locIdOLIDMap.get(locId).Location__c;
                    eta.Order__c = locIdOLIDMap.get(locId).SF_Orders__c;
                    //IT-804 - Contact/Alternate Contact details on ETA Activity - Begin
                    if(locationMap.get(locId) != null){
                        eta.Contact_Name_txt__c = locationMap.get(locId).ContactName__c;
                        eta.Contact_Email_txt__c = locationMap.get(locId).Email__c;
                        eta.Contact_Phone_txt__c = locationMap.get(locId).Phone__c;
                        eta.Contact_Phone_ext_txt__c = locationMap.get(locId).Phone_ext__c;
                        eta.Alternate_Contact_Name_txt__c = locationMap.get(locId).Alternate_Name__c;
                        eta.Alternate_Contact_Email_txt__c = locationMap.get(locId).Alternate_Email__c;
                        eta.Alternate_Contact_Phone_txt__c = locationMap.get(locId).Alternate_Phone__c;
                        eta.Alternate_Contact_Phone_ext_txt__c = locationMap.get(locId).Alternate_Phone_ext__c;                     
                        eta.Garage_Address1_txt__c = locationMap.get(locId).Garage_Address1__c;
                        eta.Garage_Address2_txt__c = locationMap.get(locId).Garage_Address2__c;
                        eta.Garage_City_txt__c = locationMap.get(locId).Garage_City__c;
                        eta.Garage_Country_pl__c = locationMap.get(locId).Garage_Country__c;
                        eta.Garage_State_pl__c = locationMap.get(locId).Garage_State__c;
                        eta.Garage_Zip_txt__c = locationMap.get(locId).Garage_Zip__c; 
                    }
                    //IT-804 - Contact/Alternate Contact details on ETA Activity - End
                    if(orderIdAccIdMap.get(locIdOLIDMap.get(locId).SF_Orders__c) != null){
                        eta.Account__c =  orderIdAccIdMap.get(locIdOLIDMap.get(locId).SF_Orders__c);  
                    }
                    eta.ETA_Activity_Type__c = '6';
                    if(String.isNotBlank(locIdOLIDMap.get(locId).ETA_Assigned_Resource__c)) {                                                                             
                        eta.Assigned_Resource_ID__c = locIdOLIDMap.get(locId).ETA_Assigned_Resource__c;
                    }else {
                        eta.Assigned_Resource_ID__c = 'verizon_nwf';
                    } 
                    etaStagingList.add(eta);    
                }
                
                if(!etaStagingList.isEmpty()){
                    //Insert ETA Staging records
                    insert etaStagingList;
                    Map<Id, Id> locIdEtaIdMap = new Map<Id, Id>();
                    //Prepare map for ETA Id and its corresponding location Id
                    for(ETA_Staging__c eta:etaStagingList){
                        locIdEtaIdMap.put(eta.Location__c, eta.id);     
                    }
                    //Set ETA Staging for imported OLIDs from the ETA Id Location Id map
                    for(Order_Line_Item_Details__c olid:lineItemDetailToCreateList){
                        olid.ETA_Staging__c = locIdEtaIdMap.get(olid.Location__c);    
                    }
                    //Update OLIDs
                    update lineItemDetailToCreateList;
                }
                System.Debug(Logginglevel.ERROR,'lineItemDetailToCreateList - lineItemDetailToCreateList size ************' + lineItemDetailToCreateList.Size()); 
                */
        }catch (Exception e){
            System.Debug(Logginglevel.ERROR,'lineItemDetailToCreateList - lineItemDetailToCreateList Error ************' + e.getMessage());
        }
        
        return true;
    }
    
    public static list<list<String>> parseCSVForERPORDERID(String contents) {
            list<list<String>> allFields = new List<List<String>>();
            System.debug('enter parseCSV');
            // replace instances where a double quote begins a field containing a comma
            // in this case you get a double quote followed by a doubled double quote
            // do this for beginning and end of a field
            contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            // now replace all remaining double quotes - we do this so that we can reconstruct
            // fields with commas inside assuming they begin and end with a double quote
            contents = contents.replaceAll('""','DBLQT');
            // we are not attempting to handle fields with a newline inside of them
            // so, split on newline to get the spreadsheet rows
            list<String> lines=new list<string>();
            try {
                lines = contents.split('\n');
            } catch (System.ListException e) {
                System.debug('parseCSVForERPORDERID Limits exceeded?  '+e.getMessage());
            }
            integer num=0;
            for(string line :lines) {
       
            if(num == 0){
            num +=1;
            System.debug('parseCSVForERPORDERID lines count' + line);
                // check for blank CSV lines (only commas)
                if(line.replaceAll(',','').trim().length()==0) 
                   break;
                list<String> fields=line.split(',');    
                list<String> cleanFields=new list<String>();
                string compositeField;
                boolean makeCompositeField=false;
                for(string field : fields) {
                    if(field.startsWith('"') && field.endsWith('"')) {
                        cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                        system.debug('cleanFields:'+cleanFields);
                    } else if(field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                        system.debug('compositeField:'+compositeField);
                    } else if(field.endsWith('"')) {
                        compositeField += ',' + field;
                        cleanFields.add(compositeField.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                        makeCompositeField = false;
                        system.debug('cleanFields:'+cleanFields);
                    } else if(makeCompositeField) {
                        compositeField +=  ',' + field;
                        system.debug('compositeField**:'+compositeField);
                    } else{
                        cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                        system.debug('cleanFields:'+cleanFields);
                    }
                } 
                allFields.add(cleanFields);
                }
                else{}
            }
            
            System.debug('parseCSVForERPORDERID allFields count after' + allFields);
            return allFields;       
        }//END ParseCSV
    
    //Method to validate row data in csv file
    public string fnValidateCSVRow(Integer intLineNo, List<string> rowDataList, Map<Integer,string> mandatoryFieldsMap){
        String strMessage = '';
        
        //Mandatory fields check
        /*for(integer intColIndex:mandatoryFieldsMap.keySet()){  ////Commented as the MandatoryFieldsMap is never populated before this code execution (due to code comments) ////
            if(rowDataList[intColIndex] == null || rowDataList[intColIndex] == '' || rowDataList[intColIndex] == 'null'){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'missing ' + mandatoryFieldsMap.get(intColIndex);  
                } //else{    //Commented the else clause as the strMessage is always blank for the first validation check ///
                //    strMessage = strMessage +', ' + 'missing ' + mandatoryFieldsMap.get(intColIndex);    
                //}/
            }    
        }*/
        
        //Data format validation - Begin
        Pattern dataPattern;
        Matcher dataMatcher;
        
        //Email validation
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        dataPattern = Pattern.compile(emailRegex);
        dataMatcher = dataPattern.matcher(rowDataList[17]);
        if(!dataMatcher.matches()){
            if(strMessage == ''){
                strMessage = 'Line' + intLineNo + ': ' + 'invalid EMAIL';  
            } else{
                strMessage = strMessage +', ' + 'invalid EMAIL';
            }
        }
        //Date validation
        string dateRegex = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)';
        /*dataPattern = Pattern.compile(dateRegex);
        if(rowDataList[26].trim() != '' && rowDataList[26].trim() != 'null'){
            dataMatcher = dataPattern.matcher(rowDataList[26]);
            if(!dataMatcher.matches()){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid SHIPPEDDATE';  
                } else{
                    strMessage = strMessage +', ' + 'invalid SHIPPEDDATE';
                }
            }
        }
        if(rowDataList[27].trim() != '' && rowDataList[27].trim() != 'null'){
            dataMatcher = dataPattern.matcher(rowDataList[27]);
            if(!dataMatcher.matches()){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid ARRIVALDATE';  
                } else{
                    strMessage = strMessage +', ' + 'invalid ARRIVALDATE';
                }
            }
        }*/
        
        //Country Validation -- #IT  2830
        String userInputCountry = rowDataList[27].trim();
        
        //Added the data correction as per Jira, IT-2686 - Begin
        userInputCountry = (userInputCountry == 'US')?'USA':userInputCountry;
        rowDataList[27] = userInputCountry;
        //Added the data correction as per Jira, IT-2686 - End
        
        Boolean countryErrorFlag = false;
        if(userInputCountry != '' && userInputCountry != null){
            //if the Location country picklist does not contain the Garage Address country value
            if(!countrySet.contains(userInputCountry)){
                countryErrorFlag = true;
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'Invalid Garage Country';
                }else{
                    strMessage = strMessage +', ' + 'invalid Garage Country';
                }
            }
        }
        
        //Location and Garage Validation
        String locationName = rowDataList[24].trim();
        String garageAddress = rowDataList[25].trim();
        if((locationName == '') || (garageAddress == '' && garageAddress == null)){
            if(strMessage == ''){
                strMessage = 'Line' + intLineNo + ': ' + 'Invalid Garage Name and Address';  
            } else{
                strMessage = strMessage +', ' + 'invalid Garage Name and Address';
            }
        }

        //Zipcode validation
        String userZipCode = rowDataList[29].trim();
        
        //system.debug(rowDataList[29].trim());
        if(userZipCode != '' && userZipCode != null && !countryErrorFlag){
            
            String zipRegex='';
            if(userInputCountry=='CANADA'){           
                //zipRegex ='^(\\d{7}(\\-\\d{7})?)?$';
                //zipRegex = '^([a-zA-Z0-9]\\d{7}(\\-\\d{7})?)?$';
                zipRegex = '^(([a-zA-Z0-9]*){7,7})$'; // Working Alpha numaric
                //zipRegex = '/^[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d$/i';
                // zipRegex = '^([a-zA-Z0-9]*\\d{7}(\\-\\d{7})?)?$';
                //  zipRegex = '^[a-zA-Z0-9]{7}$'; // Perfectly working alphanumaric and length 7.
            } 
          
            if(userInputCountry=='USA'){
                zipRegex ='^(\\d{5}(\\-\\d{4})?)?$';
                String tUZip = userZipCode.split('-')[0];
                userZipCode = tUZip.leftPad(5,'0');
            }
            //Update the source zip
            rowDataList[29] = userZipCode;
            
            dataPattern = Pattern.compile(zipRegex);
            
            dataMatcher = dataPattern.matcher(userZipCode);
            if(!dataMatcher.matches()){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid ZIP';  
                } else{
                    strMessage = strMessage +', ' + 'invalid ZIP';
                }
            }
        }
        
        //VIN validation
        if(rowDataList[1].trim() != '' && rowDataList[1].trim() != 'null'){
            if(rowDataList[1].trim().length() >= 18){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid VIN';  
                } else{
                    strMessage = strMessage +', ' + 'invalid VIN';
                }
            }
        }
        //Year validation
        if(rowDataList[5].trim() != '' && rowDataList[5].trim() != 'null'){
            if(rowDataList[5].trim().length() != 4){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid YEAR';  
                } else{
                    strMessage = strMessage +', ' + 'invalid YEAR';
                }
            }
        }
        //Make validation
        if(rowDataList[6].trim() != '' && rowDataList[6].trim() != 'null'){
            if(rowDataList[6].trim().length() > 50){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid MAKE';  
                } else{
                    strMessage = strMessage +', ' + 'invalid MAKE';
                }
            }
        }
        //Model Validation
        if(rowDataList[7].trim() != '' && rowDataList[7].trim() != 'null'){
            if(rowDataList[7].trim().length() > 50){
                if(strMessage == ''){
                    strMessage = 'Line' + intLineNo + ': ' + 'invalid MODEL';  
                } else{
                    strMessage = strMessage +', ' + 'invalid MODEL';
                }
            }
        }
        //Data format validation - End
        
        //Installation Type validation
        if(!installTypeSet.contains(rowDataList[0].trim()) && rowDataList[0].trim() != ''){
            if(strMessage == ''){
                strMessage = 'Line' + intLineNo + ': ' + 'invalid INSTALL TYPE';  
            } else{
                strMessage = strMessage +', ' + 'invalid INSTALL TYPE';
            }     
        }
    
        //Device type validation 
        if(!deviceTypeSet.contains(rowDataList[14].trim()) && rowDataList[14].trim() != ''){
            if(strMessage == ''){
                strMessage = 'Line' + intLineNo + ': ' + 'invalid DEVICE TYPE';  
            } else{
                strMessage = strMessage +', ' + 'invalid DEVICE TYPE';
            }     
        }  
        
        //Harness category type validation 
        if(!harnessTypeSet.contains(rowDataList[15].trim()) && rowDataList[15].trim() != ''){
            if(strMessage == ''){
                strMessage = 'Line' + intLineNo + ': ' + 'invalid HARNESS TYPE ORDERED';  
            } else{
                strMessage = strMessage +', ' + 'invalid HARNESS TYPE ORDERED';
            }     
        } 
        
        if(strMessage != ''){
            strMessage = strMessage + '\n';
        }
        return strMessage;
    }
    
    /////The code that calls this method has been commented, hence commenting this method ///////
    /*public Map<integer,string> fnGetMandatoryColumnsMap(String strCSVBody){
        Map<integer,string> mandatoryColumnsMap = new Map<integer,string>();
        
        list<list<String>> allFields = new List<List<String>>();
        System.debug('enter parseCSV');
        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        strCSVBody = strCSVBody.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        strCSVBody = strCSVBody.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        list<String> lines=new list<string>();
        try {
            lines = strCSVBody.split('\n');
        } catch (System.ListException e) {
            System.debug('parseCSVForERPORDERID Limits exceeded?  '+e.getMessage());
        }
        if(lines.size() > 1){
            list<String> fields=lines[1].split(',');
            for(Integer intCnt=0;intCnt < fields.size();intCnt++){
                if(fields[intCnt].contains('*')){
                    mandatoryColumnsMap.put(intCnt,fields[intCnt].replace('*',''));    
                }    
            }
        }
        return mandatoryColumnsMap;
    }*/
    public PageReference redirectToIODS(){
        PageReference importVehicles = Page.SRS;
        //importVehicles.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        importVehicles.getParameters().put('id', currentOrder.Id);
        return importVehicles;
    }
    
    public PageReference redirectToIODSCancel(){
        PageReference importVehicles = Page.SRS;
        //importVehicles.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        if(currentOrder != null){
            importVehicles.getParameters().put('id', currentOrder.Id);
        }else{
            importVehicles.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        }
        
        return importVehicles;
    }    
    
    public void createGPItemCheckboxMap(){
        List<CheckBox_to_GP_Item_Mapping__mdt> gpItemCheckboxMapping  = new List<CheckBox_to_GP_Item_Mapping__mdt>();
        gpItemCheckboxMapping = [Select MasterLabel, GP_Item_Installation_Device_Name__c from CheckBox_to_GP_Item_Mapping__mdt];
        
        for(CheckBox_to_GP_Item_Mapping__mdt gpIM:gpItemCheckboxMapping){
            GPItemMap.put(gpIM.MasterLabel, gpIM.GP_Item_Installation_Device_Name__c);
            system.debug('GPItemMap: '+gpIM.MasterLabel+', '+gpIM.GP_Item_Installation_Device_Name__c);
        }
    }
    
    /*public void populateOLIdetailsMap(Id orderId){
    
        List<Order_Line_Items__c> oliDetails = [Select Id, Installation_type__c, Devices_Installed__c, Service_Type__c, TypeOfDevice__c, GP_Quantity__c, BalanceQuantity__c, Balance_Quantity__c from Order_Line_Items__c where Orders__c =:orderId];
        
        for(Order_Line_Items__c oli: oliDetails){
            String key = oli.Installation_Type__c+'_'+oli.Devices_Installed__c;
            if(oliDeviceMap.containsKey(key)){
                List<Order_Line_Items__c> oliTemp = oliDeviceMap.get(key);
                oliTemp.add(oli);
                oliDeviceMap.put(key, oliTemp);
            }else{
                List<Order_Line_Items__c> oliTemp = new List<Order_Line_Items__c>();
                oliTemp.add(oli);
                oliDeviceMap.put(key, oliTemp);
            }
        }
        system.debug(oliDeviceMap.keyset());
    }*/
    
    /*private void createOLIEntryData(Set<String> deviceSet, Order_Line_Item_Details__c olid){
        system.debug('Before Init block'+oliDeviceMap);
        //if(oliDeviceMap.size() == 0){
        if(oliDeviceMap == null){
            system.debug('In Init block');
            oliDeviceMap = new Map<String, List<Order_Line_Items__c>>();
            if(olid.SF_Orders__c != null){
                system.debug('before populateOLIdetailsMap');
                populateOLIdetailsMap(olid.SF_Orders__c);
            }
        }
        system.debug('createOLIEntryData: '+deviceSet.size());
        Set<String> assetGuardSet = new Set<String>{'Asset Guard PW (Hardwired)','Asset Guard BX (Battery Powered)'};
        Map<String, String> nullDeviceNameReference = new Map<String, String>{'5200'=>'5200', '5500'=>'5500', '6100'=>'6100 (ExpressFleet)'};
        
        List<String> insTypeTemp = new List<String>();
        insTypeTemp = olid.Installation_type__c.split(' ');
        if(insTypeTemp != null){
            for(String sDev: deviceSet){
                String key = insTypeTemp[0]+'_'+sDev;
                Order_Line_Item_Entry__c inOLIE = new Order_Line_Item_Entry__c();
                system.debug(key);
                system.debug(oliDeviceMap.containsKey(key));
                if(oliDeviceMap.containsKey(key) && olid.Id!=null){
                    for(Order_Line_Items__c oliItemTemp: oliDeviceMap.get(key)){
                        if(oliItemTemp.Balance_Quantity__c > 0){
                            inOLIE.Order_Line_Item__c = oliItemTemp.Id;
                            inOLIE.Order_Line_Item_Detail__c = olid.Id;
                            inOLIEList.add(inOLIE);
                            system.debug(inOLIE);
                            break;
                        }
                    }
                }
            }
            
            if(olid.Device_Type__c != null){
                String deviceName = (olid.Device_Type__c != null && assetGuardSet.contains(olid.Device_Type__c))? 'Asset Guard' : nullDeviceNameReference.containsKey(olid.Device_Type__c) ? nullDeviceNameReference.get(olid.Device_Type__c) : olid.Device_Type__c;
                    
                String key = insTypeTemp[0]+'_'+deviceName;
                Order_Line_Item_Entry__c inOLIE = new Order_Line_Item_Entry__c();
                system.debug(key);
                system.debug(oliDeviceMap.containsKey(key));
                if(oliDeviceMap.containsKey(key) && olid.Id!=null){
                    for(Order_Line_Items__c oliItemTemp: oliDeviceMap.get(key)){
                        if(oliItemTemp.Balance_Quantity__c > 0){
                            inOLIE.Order_Line_Item__c = oliItemTemp.Id;
                            inOLIE.Order_Line_Item_Detail__c = olid.Id;
                            inOLIEList.add(inOLIE);
                            system.debug(inOLIE);
                            break;
                        }
                    }
                }else if(!oliDeviceMap.containsKey(key) && olid.Id!=null){
                    key = insTypeTemp[0]+'_null';
                    if(oliDeviceMap.containsKey(key)){
                        for(Order_Line_Items__c oliItemTemp: oliDeviceMap.get(key)){
                            if(oliItemTemp.Balance_Quantity__c > 0){
                                inOLIE.Order_Line_Item__c = oliItemTemp.Id;
                                inOLIE.Order_Line_Item_Detail__c = olid.Id;
                                inOLIEList.add(inOLIE);
                                break;
                            }
                        }
                    }
                }
            }           
        }

       
    }*/
    
    private boolean hasOLIDAttachment(Id ordId){
        List<Attachment> attList = new List<Attachment>();
        attList = [Select Id, Name from Attachment where ParentId=:ordId];
        if(attList.size()>0){
            return true;
        }else{
            return false;
        }
    }
    
        
    //Method to filter and return only the valid OLID items to insert
    private List<Order_Line_Item_Details__c> filterCSVDataList(List<Order_Line_Item_Details__c> olidList, boolean  isValidationOnly){
        insertOLIEList = new List<Order_Line_Item_Entry__c>();
        Map<String, Decimal> oliBalanceMap = new Map<String, Decimal>();
        List<Order_Line_Item_Details__c> finalOLIDList = new List<Order_Line_Item_Details__c>();
        Set<String> assetGuardSet = new Set<String>{'Asset Guard PW (Hardwired)','Asset Guard BX (Battery Powered)'};
        Set<String> unitDeviceType = new Set<String>{'5200', '5500', '6100 (ExpressFleet)'};
            
        //To populate the Balance Map from the Order Line Items in the Order.
        List<Order_Line_Items__c> oliList = [Select Id, GP_Quantity__c, Balance_Quantity__c, Installation_Type__c, Devices_Installed__c, TypeOfDevice__c, GP_Item_Number__c, Service_Type__c from Order_Line_Items__c where Orders__c =: Order_Id];
        oliDeviceMap = new Map<String, List<Order_Line_Items__c>>();
        for(Order_Line_Items__c oliTemp: oliList){
            //In case of Unit type device type (Non-Bundle)
            if(oliTemp.TypeOfDevice__c == 'PrimaryDevice' && oliTemp.Devices_Installed__c == null && oliTemp.GP_Item_Number__c != null && oliTemp.GP_Item_Number__c.contains('UNIT')){
                oliTemp.Devices_Installed__c = 'UNITDEVICETYPE';
            }
            String deviceMapKey = oliTemp.Service_Type__c+'_'+oliTemp.Devices_Installed__c;
            //oliBalanceMap.put(deviceMapKey, oliTemp.Balance_Quantity__c);
            if(oliDeviceMap.containsKey(deviceMapKey)){
                Decimal balT = oliBalanceMap.get(deviceMapKey);
                balT += oliTemp.Balance_Quantity__c;
                oliBalanceMap.put(deviceMapKey, balT);
                
                List<Order_Line_Items__c> oliTempL = oliDeviceMap.get(deviceMapKey);
                oliTempL.add(oliTemp);
                oliDeviceMap.put(deviceMapKey, oliTempL);
            }else{
                oliBalanceMap.put(deviceMapKey, oliTemp.Balance_Quantity__c);
                oliDeviceMap.put(deviceMapKey, new List<Order_Line_Items__c>{oliTemp});
            }
        }
        system.debug(olidList.size()+' oliBalanceMap: '+oliBalanceMap);
        system.debug(oliDeviceMap.size()+'++++'+oliDeviceMap.keySet());
        
        for(Order_Line_Item_Details__c olidTemp:olidList){
            system.debug(olidList);
            Set<String> addOnSet = new Set<String>();
            //Boolean variable to flag if the OLID is valid or not
            Boolean isValidPrimDeviceType = false;
            Boolean isValidAccsType = false;
            Boolean isValidPrimDeviceTypeAddonOnly = false;
            //if Installation Type is not blank and not an 'Add-On only' type
            system.debug('olidTemp.Installation_Type__c: '+ olidTemp.Installation_Type__c);
            if(olidTemp.Installation_Type__c != null && !olidTemp.Installation_Type__c.contains('Add-On Only')){
                String primDeviceTypeKey1 = csvGPInstallTypeTranslation.containsKey(olidTemp.Installation_Type__c)?csvGPInstallTypeTranslation.get(olidTemp.Installation_Type__c):olidTemp.Installation_Type__c;
                String primDeviceTypeKey = primDeviceTypeKey1 +'_'+ olidTemp.Device_Type__c;
                //Set the flag to true only if the provided Device Type in the CSV is available for purchase in the order AND the balance is greater than 0
                if(oliBalanceMap.containsKey(primDeviceTypeKey) && (oliBalanceMap.get(primDeviceTypeKey)> 0)){
                    oliBalanceMap.put(primDeviceTypeKey, (oliBalanceMap.get(primDeviceTypeKey)-1));
                    isValidPrimDeviceType = true;
                    
                    if(!isValidationOnly){
                        //create OLIEntry
                        Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(primDeviceTypeKey), olidTemp.Id);
                        system.debug(oliE+'++++++'+primDeviceTypeKey);
                        if(oliE != null){
                            insertOLIEList.add(oliE);
                        }
                    }
                }else if(unitDeviceType.contains(olidTemp.Device_Type__c) && oliBalanceMap.containsKey(primDeviceTypeKey1 + '_UNITDEVICETYPE') && (oliBalanceMap.get(primDeviceTypeKey1 + '_UNITDEVICETYPE')> 0)){
                    primDeviceTypeKey = primDeviceTypeKey1 +'_UNITDEVICETYPE';
                    oliBalanceMap.put(primDeviceTypeKey, (oliBalanceMap.get(primDeviceTypeKey)-1));
                    isValidPrimDeviceType = true;
                    
                    if(!isValidationOnly){
                        //create OLIEntry
                        Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(primDeviceTypeKey), olidTemp.Id);
                        system.debug(oliE+'++++++'+primDeviceTypeKey);
                        if(oliE != null){
                            insertOLIEList.add(oliE);
                        }
                    }
                }else if(assetGuardSet.contains(olidTemp.Device_Type__c) && oliBalanceMap.containsKey(primDeviceTypeKey1 + '_Asset Guard') && (oliBalanceMap.get(primDeviceTypeKey1 + '_Asset Guard')> 0)){
                    primDeviceTypeKey = primDeviceTypeKey1 + '_Asset Guard';
                    oliBalanceMap.put(primDeviceTypeKey, (oliBalanceMap.get(primDeviceTypeKey)-1));
                    isValidPrimDeviceType = true;
                    
                    if(!isValidationOnly){
                        //create OLIEntry
                        Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(primDeviceTypeKey), olidTemp.Id);
                        system.debug(oliE+'++++++'+primDeviceTypeKey);
                        if(oliE != null){
                            insertOLIEList.add(oliE);
                        }
                    }
                }
            }else if(olidTemp.Installation_Type__c != null && olidTemp.Installation_Type__c.contains('Add-On Only')){
                //In the Accessory Only install type, do not validate the Device Type
                olidTemp.Device_Type__c = '';
                isValidPrimDeviceTypeAddonOnly = true;
            }
            
            //Allow only the 'Add-On Only' service type or the Primary Install types (Install, Remove, Swap etc) that could have Add-Ons
            if(isValidPrimDeviceType || isValidPrimDeviceTypeAddonOnly){
                //Form the first part of the key for the 'Add-On' specific OLI
                String addonKey1 = olidTemp.Installation_Type__c != null?olidTemp.Installation_Type__c.split(' ').get(0):olidTemp.Installation_Type__c;
                addonKey1 += ' Add-On Only';
                system.debug('addonKey1: '+addonKey1);
                
                if(olidTemp.Addon_Alternate_Power_Adapter__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Alternate_Power_Adapter__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Alternate_Power_Adapter__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Alternate_Power_Adapter__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Driver_ID__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Driver_ID__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Driver_ID__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Driver_ID__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Quake_Satellite_Modem__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Quake_Satellite_Modem__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Quake_Satellite_Modem__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Quake_Satellite_Modem__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Garmin_CONNECT__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Garmin_CONNECT__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Garmin_CONNECT__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Garmin_CONNECT__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Magnet_Mounts__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Magnet_Mounts__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Magnet_Mounts__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Magnet_Mounts__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Bluetooth_module__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Bluetooth_module__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Bluetooth_module__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Bluetooth_module__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_NMEA_Cable__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_NMEA_Cable__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_NMEA_Cable__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_NMEA_Cable__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Pelican_Box__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Pelican_Box__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Pelican_Box__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Pelican_Box__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_PEM__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_PEM__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_PEM__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_PEM__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                if(olidTemp.Addon_Window_Mount_GPS_Antenna__c){
                    //Get the Accessory name from 'Checkbox GP Item Mapping' custom Metadata to form the second part of the key
                    String addonKey2 = GPItemMap.get('Addon_Window_Mount_GPS_Antenna__c');
                    //Validate whether the accessory is available in the order or not
                    olidTemp.Addon_Window_Mount_GPS_Antenna__c = false;
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        olidTemp.Addon_Window_Mount_GPS_Antenna__c = true;
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, oliBalanceMap.get(addonKey1+'_'+addonKey2) - 1);
                        isValidAccsType = true;
                        
                        if(!isValidationOnly){
                            //create OLIEntry
                            Order_Line_Item_Entry__c oliE = createOLIEntry(getValidOLIRecordId(addonKey1+'_'+addonKey2), olidTemp.Id);
                            system.debug(oliE+'++++++'+addonKey1+'_'+addonKey2);
                            if(oliE != null){
                                insertOLIEList.add(oliE);
                            }
                        }
                    }else{
                        accessoriesImportFailureFlag = true;
                    }
                }
                
                if(olidTemp.Sensor1__c <> '' || olidTemp.Sensor1__c <> '' || olidTemp.Sensor2__c <> '' || olidTemp.Sensor3__c <> '' || olidTemp.Sensor4__c <> '' || olidTemp.Sensor5__c <> '' || olidTemp.Sensor5__c <> ''){
                    
                    String addonKey2 = 'SSEM';
                    if(oliBalanceMap.containsKey(addonKey1+'_'+addonKey2) && oliBalanceMap.get(addonKey1+'_'+addonKey2) > 0){
                        isValidAccsType = true;
                        Decimal availSensorCount = 0;
                        Decimal balanceSensorCount = oliBalanceMap.get(addonKey1+'_'+addonKey2);
                        if(olidTemp.Sensor1__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor1__c = '';
                        }
                        if(olidTemp.Sensor2__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor2__c = '';
                        }
                        if(olidTemp.Sensor3__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor3__c = '';
                        }
                        if(olidTemp.Sensor4__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor4__c = '';
                        }
                        if(olidTemp.Sensor5__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor5__c = '';
                        }
                        if(olidTemp.Sensor6__c <> '' && balanceSensorCount > 0){
                            balanceSensorCount--;
                            availSensorCount++;
                        }else{
                            olidTemp.Sensor6__c = '';
                        }
                        
                        oliBalanceMap.put(addonKey1+'_'+addonKey2, balanceSensorCount);
                    }else{
                        olidTemp.Sensor1__c = '';
                        olidTemp.Sensor2__c = '';
                        olidTemp.Sensor3__c = '';
                        olidTemp.Sensor4__c = '';
                        olidTemp.Sensor5__c = '';
                        olidTemp.Sensor6__c = '';
                        
                        accessoriesImportFailureFlag = true;
                    }
                }
                                
                //Add the OLID to the final list to be processed
                if(isValidAccsType || isValidPrimDeviceType){
                    finalOLIDList.add(olidTemp);
                }
            }
        }
        system.debug(insertOLIEList.size());
        if(!isValidationOnly){
            insert insertOLIEList;
            return null;
        }
        return finalOLIDList;
    }
    
    //Method to return the valid OLI record Id based on the key
    private Id getValidOLIRecordId(String devMapKey){
        Id returnId = null;
        system.debug('In getValidOLIRecordId: '+devMapKey+'****'+oliDeviceMap.keySet());
        if(oliDeviceMap.containsKey(devMapKey)){
            List<Order_Line_Items__c> oliTempL = oliDeviceMap.get(devMapKey);
            for(Order_Line_Items__c oli: oliTempL){
                system.debug(oli);
                if(oli.Balance_Quantity__c >0){
                    system.debug('Pass'+oli.Id);
                    return oli.Id;
                }
            }
        }
        return returnId;
    }
    
    private Order_Line_Item_Entry__c createOLIEntry(Id OrderLineItemId, Id OrderLineItemDetailId){
        system.debug(orderLineItemid+'&&&&&&'+OrderLineItemDetailId);
        if(OrderLineItemId!=null && OrderLineItemDetailId!=null){
            Order_Line_Item_Entry__c oliE = new Order_Line_Item_Entry__c();
            oliE.Order_Line_Item__c = OrderLineItemId;
            oliE.Order_Line_Item_Detail__c = OrderLineItemDetailId;
            return oliE;
        }
        return null;
    }
}