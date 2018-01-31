/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          
// File Name:       OrderProcessingSolutionNew 
// Summary:         Class for IODS Screen
// Created On:      

// Modification Log:
====================
// Sunil   - 04/26/2017 - Added Code to Conditionally Render Child Account Field : IT-1601
// Sunil   - 05/25/2017 - Commented Code which deletes vehicle records : IT-1899
************************************************************************************************************/
global without sharing class OrderProcessingSolutionNew {
    String[] filelines = new String[]{};
    String nameFile {get;set;}
    global string documentURL{get;set;}
    global Integer documentSize{get;set;}
    global String csvHeaders{get;set;}
    public String UnzippedFile {get; set;}
    public String searchTerm {get; set;}
    global static Integer accountSize {get; set;}
   // global static  Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Order_Line_Item_Details__c.fields.getMap();
    global static set<String> apiNames  = Order_Line_Item_Details__c.sObjectType.getDescribe().fields.getMap().keySet();
      public static List<String> filenames = new List<String>();
   
   
    public static List<String> filenames1 = new List<String>();
   
   
   public List<document> documentList;
    global OrderProcessingSolutionNew() 
    {
    searchterm= null;
    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');
        csvHeaders=json.serialize(CSVHeaders__c.getAll().keyset());
        documentList=[select id,name,body,BodyLength from document where Name='Vehicle_Template'];
        if(documentList.size()>0)
        {
            //String documentURL='/servlet/servlet.FileDownload?file=';
          //documentURL=documentURL+documentList[0].id;
           documentURL=documentList[0].id;
           documentSize=documentList[0].BodyLength;
         
        }
        
        
    }

     public class WrapperOrder
     {
        public String Id1;   
        public String name;     
        public String address;     
        public String phone;    
        public string usrname;
        public string usremail;
        public string usrphone; 
        public string childacc;
     }  
     
     public class WrapperPurchasedService
     {
        public string Id1;
        public String service;     
        public String device;     
        public Decimal orderQty; 
        public Decimal balance;   
        public String Devicetype;  

     }  
     public class WrapperLocation
    {
        public String Id1;
        public String Used;
        public String GarageAddress1;
        public String GarageAddress2;
        public String GarageCity;
        public String GarageState;
        public String Country;
        public String Zip;
        
        public String ContactName;
        public String Email;
        public String LocationName;
        public String Phone;
        public String AltContactName;
        public String AltEmail;
        public String AltPhone;
        public List<WrapperVehicle> vehicles = new List<WrapperVehicle>();
        public Boolean isSubmitted;
        //public Integer vehicleCounter;
    }
     public class WrapperVehicle
    {
        public String Id1;   
        public String LocationName;     
        public String Service;
        public String VIN;
        public String VehicleLabel;
        public String OLDVIN;
        public String OldVehicleLabel;
        public String Year;
        public String Make;
        public String Model;
        public String LicensePlate;
        public String LicenseState;
        public String Color;
        public String FuelType;
        public String DeviceType;
        public String Serial;
        public String OldSerial;
        public String Harness;
        public String DeviceReturned;
        //public List<String> Accessories;
        public String Accessories;
        public String Sensor1;
        public String Sensor2;
        public String Sensor3;
        public String Sensor4;
        public String Sensor5;
        public String Sensor6;
        public String Notes;
        public String locId;
        public Boolean isSubmitted;
        
     }
     public class WraperOrderLineDevices
     {
         public String Id1;
         public String InstallationDevices;
        // public String DeviceTypes;
         public String InstallType;
         
     }
     public Attachment attachment {
        get {
        if (attachment == null)
        attachment = new Attachment();
        return attachment;
        }
        set;
     }
  public String attachId{set;get;}
  
  //Added for site Issue
   @RemoteAction
    global static List<Account> getAccount(String OrderId) {
       Orders__c ordRec= new Orders__c();
       ordRec = [Select Id,Account__c,Child_Account__c from Orders__c where Id=:OrderId ];
       List<account> accList = [SELECT Id, Name  FROM Account where ParentId =:ordRec.Account__c];
       return accList;
    }
    
    //Added for Site Issue

  public PageReference upload1() {
        string orderid=ApexPages.currentPage().getParameters().get('id');
        List<Orders__c> lstOrders = new List<Orders__c>(); 
        lstOrders = [SELECT Id,GP_ERP_Order_ID__c FROM Orders__c WHERE Id=:orderid];
        PageReference pageRef;
        pageRef = new PageReference('/apex/blankPage');
        if(attachment.name==null || attachment.body==null || attachment.body.size()==0 || attachment.name.trim()=='')
        {
            system.debug('file is emty');
            attachId = 'false';
            return pageRef;     
        }
        if(attachment.body.size() > 10485760)
        {
            attachId = 'limit exceeded';
            return pageRef;
        }
        
        nameFile = attachment.body.toString();
        filelines = nameFile.split('\n');
        system.debug('filelines[0]=>'+filelines[0]);
        
        if(filelines.size() < 3){
            system.debug('no data in file');
            attachId = 'no data';
            return pageRef;       
        } else{
            List<string> firstRowList = new List<string>();
            firstRowList.addAll(filelines[0].split(','));
            if(firstRowList.size() < 2 || firstRowList[1].trim() == ''){
                system.debug('no order number');
                attachId = 'OrderNumberMissing';
                return pageRef;      
            } else if(lstOrders.size() == 0){
                system.debug('in correct order number');
                attachId = 'IncorrectOrderNumber';
                return pageRef;     
            }else{
                if(firstRowList[1].trim() != lstOrders[0].GP_ERP_Order_ID__c){
                    system.debug('no order number');
                    attachId = 'IncorrectOrderNumber';
                    return pageRef;    
                }
            }
            List<string> fileHeaderList = new List<string>();
            fileHeaderList.addAll(filelines[1].split(','));
            Set<String> csHeadersSet = CSVHeaders__c.getAll().keySet();
            Set<string> fileHeaderSet = new Set<string>();
            for(string strHeader: fileHeaderList){
                fileHeaderSet.add(strHeader.trim());    
            }
            
            List<string> fieldValuesList = new List<string>();
            fieldValuesList = filelines[2].split(',');
            Map<string,string> fielNameValueMap = new Map<string,string>();
            system.debug('csHeadersSet.size()=>'+csHeadersSet.size());
            system.debug('fileHeaderList.size()=>'+fileHeaderList.size());
            if(csHeadersSet.size() != fileHeaderList.size()){
                system.debug('headers mismatch');
                attachId = 'columns missing';
                return pageRef;    
            } else{
                for(string strHeader:csHeadersSet){
                    if(!fileHeaderSet.contains(strHeader)){
                        system.debug('headers mismatch');
                        attachId = 'columns missing';
                        return pageRef;    
                    }    
                }
                for(integer i=0;i<fieldValuesList.size();i++){
                    fielNameValueMap.put(fileHeaderList[i],fieldValuesList[i]);     
                }
                for(string strHeader:csHeadersSet){
                    if(strHeader.contains('*') && fielNameValueMap.get(strHeader) != null){
                        if(fielNameValueMap.get(strHeader) == 'null' || fielNameValueMap.get(strHeader) == ''){
                            system.debug('Mandatory field missing');
                            attachId = 'Mandatory field missing';
                            return pageRef;     
                        }
                    }  
                }
            }
        }
        
        String[] inputvalues = new String[]{};
        String[] data1 = new String[]{};
        inputvalues = filelines[1].split(',');
        List<String> headers = new List<String>();
        Map<String,String> m = new Map<String,String>();
        for(Integer j=0;j<inputvalues.size();j++)
        {
            if(inputvalues[j].trim() != '')
            {
                headers.add(inputvalues[j]);
                m.put(inputvalues[j],'');
            }
        }
        /*
        Set<String> keys = CSVHeaders__c.getAll().keySet();
        Boolean flag;
        Integer count=0;
        system.debug('@@@@@@Keys size'+keys);
        system.debug('@@@@@@headers.size()'+headers.size());
        */
        
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = orderid; // the record the file is attached to
        //attachment.contentType='text/pdf';
        //attachment.IsPrivate = true;
        Orders__c  ord = new Orders__c (Id= orderId, SendICEmail__c= true);
        
        try {
            system.debug('attachment=>'+attachment);
            insert attachment;
            update ord;
            //attachId=attachment.Id;
            attachId='true';
            
        } catch (DMLException e) {
            system.debug('Exception=>'+e.getMessage());  
            attachId='false';
            return pageRef;
        } finally {
            attachment = new Attachment(); 
        }
        system.debug('attachId=>'+attachId);
        system.debug('pageRef=>'+pageRef);
        return pageRef;
    }
     
    
    /*public PageReference CallWebService() {
        List<String> stringlist;
        PageReference pageRef = new PageReference('/apex/blankPage');
     System.debug('sending Method started executing ....');
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
         MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
        staticResource.fullName = RESOURCE_NAME1;
        staticResource.contentType = 'application/zip';
        staticResource.description = 'Temporary upload to unzip file for user ' + UserInfo.getName();
        staticResource.cacheControl = 'private';
        System.debug('zyx');
        staticResource.content = EncodingUtil.base64Encode(attachment.body);
        System.debug('xyz');
        staticresourcelist.add(staticResource);
        system.debug('ccc');
         MetadataService.AsyncResult[] AsyncResult = service.create(staticresourcelist);
        System.debug('>>>>>>>> Inserted successfully...');
        for(MetadataService.AsyncResult asyRlt : AsyncResult){
            asynResultIds.add(asyRlt.Id);
        }
        MetadataService.AsyncResult[] aysncResults;
        aysncResults = service.checkStatus(asynResultIds);
        Integer count = 0;
       
        for(Integer i = 0 ; i<aysncResults.size() ; i++){
            while(aysncResults[i].state != 'Complete'){
            count++;
            if(count == 25)
                break;
            else
                aysncResults = service.checkStatus(asynResultIds);
            }  
            if(aysncResults[i].done){   
                if(aysncResults[i].state == 'Error'){
                   System.debug('error occured');
                }
            else{ 
                System.debug('@@@@@  Entered else statement inn exportostaticresource..');
                 StaticResource statres = [SELECT Id,Body,LastModifiedDate FROM StaticResource WHERE Name = :RESOURCE_NAME1];
                 String link = '/resource/'+statres.LastModifiedDate.getTime()+'/'+RESOURCE_NAME1+'/xl/sharedStrings.xml'; 
                 
               
                 PageReference pg = new PageReference(link);
                 
                 String UnzippedFile = pg.getContent().toString();
                 System.debug('unzipped file is '+UnzippedFile);
                 stringlist = new List<String>();
             
                    while(UnzippedFile.contains('<t>'))
                    {
                    System.debug('string is '+UnzippedFile);
                    Integer firstindex=UnzippedFile.indexOf('<t>');
                    Integer lastindex=UnzippedFile.indexOf('</t>');
                    System.debug('first index is '+firstindex);
                    System.debug('last index is '+lastindex);
                    String reqstring=UnzippedFile.substring(firstindex+3,lastindex);
                    stringlist.add(reqstring);
                    
                    System.debug('required string is '+reqstring);
                    UnzippedFile=UnzippedFile.substring(lastindex+4);
                    }
                    System.debug('stringlist is '+stringlist);
               
            }            
          }
        }
        System.debug('sending Method started executing ....');
        MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
        service1.SessionHeader = new MetadataService.SessionHeader_element();
        service1.SessionHeader.sessionId = UserInfo.getSessionId();
         MetadataService.StaticResource staticResource1 = new MetadataService.StaticResource();
        staticResource1.fullName = RESOURCE_NAME2;
        staticResource1.contentType = 'application/zip';
        staticResource1.description = 'Temporary upload to unzip file for user ' + UserInfo.getName();
        staticResource1.cacheControl = 'private';
        System.debug('zyx');
        //have to changed
        staticResource1.content = EncodingUtil.base64Encode(documentList[0].body);
        System.debug('xyz');
        staticresourcelist1.add(staticResource1);
        system.debug('ccc');
         MetadataService.AsyncResult[] AsyncResult1 = service1.create(staticresourcelist1);
        System.debug('>>>>>>>> Inserted successfully...');
        for(MetadataService.AsyncResult asyRlt : AsyncResult1){
            asynResultIds1.add(asyRlt.Id);
        }
        MetadataService.AsyncResult[] aysncResults1;
        aysncResults1 = service1.checkStatus(asynResultIds1);
       Integer count1 = 0;
       
        for(Integer i = 0 ; i<aysncResults1.size() ; i++){
            while(aysncResults1[i].state != 'Complete'){
            count1++;
            if(count1 == 25)
                break;
            else
                aysncResults1 = service1.checkStatus(asynResultIds1);
            }  
            if(aysncResults1[i].done){   
                if(aysncResults1[i].state == 'Error'){
                   System.debug('error occured');
                   //Attachment a = [select name from attachment where id=:attachment.id];
                    //delete a;
                    attachId='false';
                    MetadataService.AsyncResult[] AsyncResultdel = service.deleteMetadata(staticresourcelist);
                    MetadataService.AsyncResult[] AsyncResultdel1 = service.deleteMetadata(staticresourcelist1);
                    return pageRef;
                }
            else{ 
                System.debug('@@@@@  Entered else statement inn exportostaticresource..');
                 StaticResource statres = [SELECT Id,Body,LastModifiedDate FROM StaticResource WHERE Name = :RESOURCE_NAME2];
                 String link = '/resource/'+statres.LastModifiedDate.getTime()+'/'+RESOURCE_NAME2+'/xl/sharedStrings.xml'; 
                 
               
                 PageReference pg = new PageReference(link);
                 
                 String UnzippedFile1 = pg.getContent().toString();
                 System.debug('unzipped file is '+UnzippedFile1);
                 Set<String> stringlist1 = new Set<String>();
                 Integer ct=0;
                    while(UnzippedFile1 .contains('<t>'))
                    {
                        ct++;
                    System.debug('string is '+UnzippedFile1);
                    Integer firstindex=UnzippedFile1.indexOf('<t>');
                    Integer lastindex=UnzippedFile1.indexOf('</t>');
                    System.debug('first index is '+firstindex);
                    System.debug('last index is '+lastindex);
                    String reqstring=UnzippedFile1.substring(firstindex+3,lastindex);
                    stringlist1.add(reqstring);
                    
                    System.debug('required string is '+reqstring);
                    UnzippedFile1 =UnzippedFile1.substring(lastindex+4);
                    }
                    System.debug('stringlist1 is '+stringlist1);
                    
                    
                    Integer ct1=0;
                    Set<String> stlist=new Set<String>();
                    for(String s:stringlist)
                    {
                        ct1++;
                        if(ct1 <= stringlist1.size())
                        stlist.add(s);
                        else
                        break;
                        
                    }
                    
                    System.debug('stlist is '+stlist);
                     boolean flag=false;
                    for(String o : stringlist1){
                    if(!stlist.contains(o) ){
                        flag=true;
                    }
                    }
                   
                    if(flag == true)
                    {
                    System.debug('error');
                    //Attachment a = [select name from attachment where id=:attachment.id];
                    //delete a;
                    attachId='false';
                    MetadataService.AsyncResult[] AsyncResultdel = service.deleteMetadata(staticresourcelist);
                    MetadataService.AsyncResult[] AsyncResultdel1 = service.deleteMetadata(staticresourcelist1);
                    return pageRef;
                    }
                    else
                    {
                    System.debug('success');
                    attachId='true';
                    }                    
                    
                   
                   MetadataService.AsyncResult[] AsyncResultdel = service.deleteMetadata(staticresourcelist);
                   MetadataService.AsyncResult[] AsyncResultdel1 = service.deleteMetadata(staticresourcelist1);
                   
                   
            }            
          }
        }
 
       // return null;
       return pageRef;
    }   
   
    public static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        System.debug('inside service');
        return service;     
    }*/
    /* global  String getDocumentURL()
     {
        //String documentURL='/servlet/servlet.FileDownload?file=';
        List< document > documentList=[select id,name from document where Name='Vehicle Template'];
        if(documentList.size()>0)
        {
          //documentURL=documentURL+documentList[0].id;
          return documentList[0].id;
        }
        return null;
     }*/
     @RemoteAction
     global static String getPrimaryDevices(String param)
     {
         /*List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param AND TypeOfDevice__c='PrimaryDevice'];
         List<WraperOrderLineDevices> wrapperOrderLineDevices=new List<WraperOrderLineDevices>();         
         for(Order_Line_Items__c li:lineItems)
         {
           WraperOrderLineDevices wol=new WraperOrderLineDevices();
           wol.Id1=li.Id;
           wol.InstallationDevices=li.Devices_Installed__c;
           //wol.DeviceTypes=li.TypeOfDevice__c;
           wol.InstallType=li.Installation_Type__c;         
           wrapperOrderLineDevices.add(wol);
         }*/
        List<String> list_of_primary_devices = new List<String>();
        Schema.DescribeFieldResult fieldResult =Order_Line_Item_Details__c.Device_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            list_of_primary_devices.add(f.getValue());
        } 
        
         return JSON.serialize(list_of_primary_devices);
         
         //return JSON.serialize(wrapperOrderLineDevices);
     }
         
      
    
     @RemoteAction
     global static String getInstallTypes(String param)
     {
         List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param ];
         set<String> InstallDevicesTypes=new set<String>();         
         for(Order_Line_Items__c li:lineItems)
         {
           
           InstallDevicesTypes.add(li.Installation_Type__c);
          
         }
         return JSON.serialize(InstallDevicesTypes);
     }
    
     @RemoteAction
    global static String getHarnessCategory()
    {
        List<String> list_of_harness_category = new List<String>();
        Schema.DescribeFieldResult fieldResult =Order_Line_Item_Details__c.Vehicle_Harness_Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            list_of_harness_category.add(f.getValue());
        } 
        
         return JSON.serialize(list_of_harness_category);
    }
     @RemoteAction
    global static String getDeviceRetCategory()
    {
        List<String> list_of_deviceRet_category = new List<String>();
        Schema.DescribeFieldResult fieldResult =Order_Line_Item_Details__c.Device_Returned__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            list_of_deviceRet_category.add(f.getValue());
        } 
        
         return JSON.serialize(list_of_deviceRet_category);
    }   
     @RemoteAction
     global static String getSecondaryDevices(String param)
     {
         //List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param AND TypeOfDevice__c='AddOns' and Devices_Installed__c!='Harness' and ( not Devices_Installed__c  LIKE '%sensor%')];
         List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param AND TypeOfDevice__c='AddOns' and Devices_Installed__c!='Harness' and (Devices_Installed__c != 'Sensor1' AND Devices_Installed__c != 'Sensor 1') AND (Devices_Installed__c != 'Sensor2' AND Devices_Installed__c != 'Sensor 2') AND (Devices_Installed__c != 'Sensor3' AND Devices_Installed__c != 'Sensor 3') AND (Devices_Installed__c != 'Sensor4' AND Devices_Installed__c != 'Sensor 4') AND (Devices_Installed__c != 'Sensor5' AND Devices_Installed__c != 'Sensor 5') AND (Devices_Installed__c != 'Sensor6' AND Devices_Installed__c != 'Sensor 6')];
         List<WraperOrderLineDevices> wrapperOrderLineDevices=new List<WraperOrderLineDevices>();
         
         for(Order_Line_Items__c li:lineItems)
         {
           WraperOrderLineDevices wol=new WraperOrderLineDevices();
           wol.Id1=li.Id;
           wol.InstallationDevices=li.Devices_Installed__c;
           //wol.DeviceTypes=li.TypeOfDevice__c;
           wol.InstallType=li.Installation_Type__c;     
           wrapperOrderLineDevices.add(wol);
         }
     return JSON.serialize(wrapperOrderLineDevices);
     }
   /*  @RemoteAction
    global static String getLocations(String param)
    {
        Orders__c o=[select NavigateToCard__c,Account__c from Orders__c where id = :param];
        
        List<OrderLocation__C> orderlocs=[select Location__c from OrderLocation__C where Orders__c=:param];
        List<Location__c> Locations=new List<Location__c>();
        if(o.NavigateToCard__c==2||o.NavigateToCard__c==3)
        {
            set<String> locIds=new set<String>();
            for(OrderLocation__C ol:orderlocs)
            {
                locIds.add(ol.Location__c);
            }
            Locations=[select Id,ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name,Phone__c, Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c from Location__c where Id in :locIds];
        }
        else if(o.NavigateToCard__c==0 ||o.NavigateToCard__c==null)
        {
           // Orders__c o=[select Account__c from Orders__c where id = :param];
            String accId = o.Account__c;
            Locations=[select Id,ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name,Phone__c, Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c from Location__c where Customer__c =: accId];
        }
        Set<WrapperLocation> listLoc=new Set<WrapperLocation>();
        for(Location__c loc:Locations){            
               WrapperLocation wrapperLocation=new WrapperLocation();
               wrapperLocation.Id1=loc.Id;
               wrapperLocation.GarageAddress1=loc.Garage_Address1__c;  
               wrapperLocation.GarageAddress2=loc.Garage_Address2__c; 
               wrapperLocation.GarageCity=loc.Garage_City__c;  
               wrapperLocation.GarageState=loc.Garage_State__c;
               wrapperLocation.Country=loc.Garage_Country__c;
               wrapperLocation.Zip=loc.Garage_Zip__c;
               wrapperLocation.ContactName=loc.ContactName__c;
               wrapperLocation.Email=loc.Email__c;
               wrapperLocation.LocationName=loc.Name;
               wrapperLocation.Phone=loc.Phone__c;
               wrapperLocation.AltContactName=loc.Alternate_Name__c;
               wrapperLocation.AltEmail=loc.Alternate_Email__c;
               wrapperLocation.AltPhone=loc.Alternate_Phone__c;
               listLoc.add(wrapperLocation);    
               
        }
        return JSON.serialize(listLoc);
    }*/
     @RemoteAction
    global static Integer getCardNumber(String orderId)
    {
         Orders__c o=[select NavigateToCard__c from Orders__c where id = :orderId];
         if(o.NavigateToCard__c==null)
            return 0;
         return Integer.valueOf(o.NavigateToCard__c);
         
    }
  
      
    
     @RemoteAction
      // global static Boolean saveRecord(String orderId,Integer cardno,String locationJson,String lineItemJson,boolean submitted){
       global static Boolean saveRecord(String orderId,Integer cardno,String locationJson,String lineItemJson,string strUserName,string strUserEmail,string strUserPhone,string strChildAcc, boolean submitted){
      
        Orders__c o=[select User_Email__c,Name__c,User_Phone__c, Account__c,Child_Account__c,NavigateToCard__c, GP_ERP_Order_ID__c from Orders__c where id = :orderId];        
        String accId = o.Account__c;   
        System.Debug('Child_Account__c:'+o.Child_Account__c);
            o.User_Email__c = strUserEmail;
            o.Name__c = strUserName;
            o.User_Phone__c = strUserPhone;
            o.Child_Account__c=strChildacc;
           if(submitted){
             o.Submitted_by_IODS__c = true;
           }
                        
            System.debug('Arvi******* inside orderRecord.usrphone ' + strUserPhone);
            
        
         update o;
         
        
        //query orderline items 
        List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:orderId AND TypeOfDevice__c='AddOns' ];
         List<String> OrderLineDevices=new List<String>();         
         for(Order_Line_Items__c li:lineItems)
         {
           OrderLineDevices.add(li.Devices_Installed__c);//get the addon names
         } 
         
         
        Savepoint sp = Database.setSavepoint(); 
        system.debug('orderId'+orderId);
        
        try
        {
            List<WrapperLocation> locationRec=(List<WrapperLocation>)System.JSON.deserialize(locationJson,List<WrapperLocation>.class); 
            List<WrapperPurchasedService> lineItemRec=(List<WrapperPurchasedService>)System.JSON.deserialize(lineItemJson,List<WrapperPurchasedService>.class); 
            o.NavigateToCard__c=cardno;
            System.debug('inside try');
            if(submitted){
             o.Submitted_by_IODS__c = false;
           }
            update o;
           
           List<Order_Line_Items__c> itemList = new List<Order_Line_Items__c>();
            for(WrapperPurchasedService ps:lineItemRec)
            {
                Order_Line_Items__c item = new Order_Line_Items__c();
                if(ps.Id1!=null && ps.Id1!='')
                {
                    item.id=ps.Id1;
                    item.BalanceQuantity__c = ps.balance;
                    itemList.add(item);
                } 
                
            }
            System.debug('updating line item');
            update itemList;
            System.debug('lien item updated');
            List<Location__c> locations=new List<Location__c>();
           
            for(WrapperLocation wl:locationRec)
            {
                Location__c loc=new Location__c();
                if(wl.Id1!=null && wl.Id1!='')
                {
                    loc.id=wl.Id1;
                }                
                loc.Garage_Address1__c=wl.GarageAddress1;
                loc.Garage_Address2__c=wl.GarageAddress2;
                loc.Garage_City__c=wl.GarageCity;
                loc.Garage_State__c=wl.GarageState;
                loc.Garage_Country__c= wl.Country;                
                loc.Garage_Zip__c=wl.Zip;
                if(accId!=null)
                    loc.Customer__c=accId;
                //Fix for IT-548 - Begin
                loc.Name=wl.LocationName.replaceAll( '\\s+', ' ');
                //Fix for IT-548 - End
                loc.ContactName__c=wl.ContactName;
                loc.Email__c=wl.Email;
                loc.Phone__c=wl.Phone; 
                loc.Alternate_Name__c=wl.AltContactName;
                loc.Alternate_Email__c=wl.AltEmail;
                loc.Alternate_Phone__c=wl.AltPhone; 
                if(submitted)
                    loc.isSubmitted__c=true;
                            
                locations.add(loc);            
            }            
            upsert locations;
            
            
             List<Order_Line_Item_Details__c> lineItemDetailList = new List<Order_Line_Item_Details__c>();
             set<Id> ContainedLineItemDetails =new set<Id>();
           
            
            for(Integer m=0;m<locations.size();m++)
            {
                if(locationRec[m].vehicles != null)
                {
                    for(WrapperVehicle wv:locationRec[m].vehicles)
                    {
                        Order_Line_Item_Details__c lineItemDetail = new Order_Line_Item_Details__c();
                        System.debug('id is '+wv.Id1);
                         if(wv.Id1!=null && wv.Id1!='')
                         {
                             lineItemDetail.id=wv.Id1;                            
                             ContainedLineItemDetails.add(wv.Id1);
                         }  
                         else
                         {
                            lineItemDetail.SF_Orders__c = orderId;
                         }
                        System.debug('in line detail process');
                        System.debug('line items loc is '+wv.locId);
                        if(wv.locId ==null || wv.locId =='')
                            lineItemDetail.Location__c = locations[m].id;
                        System.debug('****');
                        
                        lineItemDetail.Installation_Type__c = wv.Service;
                        
                        lineItemDetail.VIN__c = wv.VIN;
                        lineItemDetail.Vehicle_Label__c=wv.VehicleLabel;
                        lineItemDetail.Old_Vin__c = wv.OLDVIN;
                       
                        lineItemDetail.Old_Vehicle_Label__c=wv.OldVehicleLabel;
                        lineItemDetail.Year__c = wv.Year;
                        lineItemDetail.Make__c   = wv.Make;
                        lineItemDetail.Model__c = wv.Model;
                        lineItemDetail.License_Plate__c = wv.LicensePlate;
                        lineItemDetail.License_State__c = wv.LicenseState;
                        lineItemDetail.Color__c = wv.Color;
                        lineItemDetail.Fuel_Type__c = wv.FuelType;
                        lineItemDetail.Device_Type__c = wv.DeviceType;
                        lineItemDetail.Device_Serial_Number__c= wv.Serial;
                        lineItemDetail.Device_Serial_Number_Old__c= wv.OldSerial;
                        lineItemDetail.Device_Returned__c= wv.DeviceReturned;
                        lineItemDetail.Vehicle_Harness_Category__c= wv.Harness;
                        
                        for(String s:OrderLineDevices)
                        {                          
                            String temp=s.replaceAll( '\\s+', '_');
                            temp='Addon_'+temp+'__c';
                            if(apiNames.contains(temp.toLowerCase()))
                                lineItemDetail.put(temp,false);
                        }                        
                        if(wv.Harness!=null && wv.Harness.trim()!='')
                        {
                            
                            lineItemDetail.Addon_Harness__c = true;
                        }
                        List<String> usedAccessories=wv.Accessories.split(','); 
                        system.debug(wv.Accessories);  
                        system.debug(usedAccessories);
                        System.debug('****usedAccessories*****'+usedAccessories);
                         System.debug('****wv.Accessories*****'+wv.Accessories);
                        for(String s:usedAccessories)
                        {     
                            if(s.trim()!='')
                            {                     
                                String temp=s.replaceAll( '\\s+', '_');
                                temp='Addon_'+temp+'__c';
                                System.debug('****temp*****'+temp);
                                if(apiNames.contains(temp.toLowerCase()))
                                   lineItemDetail.put(temp,true);
                                 else
                                  System.debug('****NOOOOO*****');
                                   
                            }
                        }                        
                            
                        System.debug('****lineItemDetail*****'+lineItemDetail);
                        lineItemDetail.Sensor1__c= wv.Sensor1;
                        lineItemDetail.Sensor2__c= wv.Sensor2;
                        lineItemDetail.Sensor3__c= wv.Sensor3;
                        lineItemDetail.Sensor4__c= wv.Sensor4;
                        lineItemDetail.Sensor5__c= wv.Sensor5;
                        lineItemDetail.Sensor6__c= wv.Sensor6;
                        lineItemDetail.Activity_Notes__c= wv.Notes;
                        if(submitted){
                            lineItemDetail.isSubmitted__c=true;
                        }
                            
                        
                        if(o.GP_ERP_Order_ID__c != null)
                        lineItemDetail.GP_ERP_Order_ID__c = o.GP_ERP_Order_ID__c;
                        else
                        lineItemDetail.GP_ERP_Order_ID__c = 'xxx';
                        lineItemDetailList.add(lineItemDetail);
                        
                    }
                }
            }        
            System.debug('line item detail list is '+lineItemDetailList); 
            //checkForDeletedRecords(orderId,ContainedLineItemDetails); // Commented as per Jira Ticket Number - IT 1899 - Sunil Kumar
            upsert lineItemDetailList;
           
            System.debug('line item detail upserted');
            List<OrderLocation__C> orderlocs=[select Location__c from OrderLocation__C where Orders__c=:orderId];
            delete orderlocs;
            system.debug(locations);
            List<OrderLocation__C> newOrderlocs=new List<OrderLocation__C>();
            for(Location__c loc:locations)
            {
                OrderLocation__C ol=new OrderLocation__C();
                ol.Location__c=loc.Id;
                ol.Orders__c=orderId;
                newOrderlocs.add(ol);
            }
            insert newOrderlocs;
            return true;       
        }
        catch(Exception e)
        {
            System.debug('exception thrown');
            system.debug('e=>'+e.getMessage());
            if(sp!=null)
                Database.rollback(sp);
                
            
            return false;
        }
    }
     // Commented as per Jira Ticket Number - IT 1899 - Sunil Kumar       
    /*global static void checkForDeletedRecords(String orderId,set<Id> ContainedLineItemDetails){
        System.debug('check for deleted rec');
        Map<Id,Order_Line_Item_Details__c> queryvehicles=new Map<Id,Order_Line_Item_Details__c>([select id,Location__c,SF_Orders__c from Order_Line_Item_Details__c where SF_Orders__c =:orderId]);
        set<Id> oldvehicles=queryvehicles.keySet();
        oldvehicles.removeall(ContainedLineItemDetails);
        List<Order_Line_Item_Details__c> deletedVehicles=[select id,Location__c,SF_Orders__c from Order_Line_Item_Details__c where Id in :oldvehicles];
        System.debug('check for deleted rec1');
        delete deletedVehicles;     
    }*/
    
   
    @RemoteAction
    global static String getShipingInfo(String param)
     {
            List<Orders__c> orders = [select id,name,GP_ERP_Order_ID__c,GP_Customer_PO_Nbr__c,GP_Create_Date__c,Account__c,Ship_To_Address_1__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_State__c,Ship_To_Zip__c from Orders__c where id=:param];
            List<Account> acc = [select id, name from Account where id=:orders[0].Account__c];
            //List<Orders__c> orders=[select name,Contact__c from Orders__c where id='a0Ge0000002bQgC'];
            //List<Contact> con = [select id,AccountId from Contact where id=:orders[0].Contact__c];
            //List<Account> acc=[select name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry from Account where id=:con[0].AccountId];
            System.debug('acc name is '+acc[0].Name);
            String shippingAddress1='<font color="#707070" size="1.5"><b>Customer</b></font>'+':'+' ';
            
            if(acc[0].name!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+acc[0].name+'</font>'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'<font color="#707070" size="1.5"><b>Ship to Address</b></font>'+':'+' ';
            else
            shippingAddress1=shippingAddress1+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'<font color="#707070" size="1.5"><b>Ship to Address</b></font>'+':'+' ';
            
            //shippingAddress1=shippingAddress1+'<b>Ship to Address:</b>'+'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            
            if(orders[0].Ship_To_Address_1__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].Ship_To_Address_1__c+'</font>'+','+' ';
            
            if(orders[0].Ship_To_City__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].Ship_To_City__c+'</font>'+','+' ';
           
            if(orders[0].Ship_To_State__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].Ship_To_State__c+'</font>'+','+' ';
            
            if(orders[0].Ship_To_Zip__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].Ship_To_Zip__c+'</font>'+','+' ';
            
            if(orders[0].Ship_To_Country__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].Ship_To_Country__c+'</font>'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            
            shippingAddress1=shippingAddress1+'<font color="#707070" size="1.5"><b>PO #</b></font>'+':'+' ';
            if(orders[0].GP_Customer_PO_Nbr__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].GP_Customer_PO_Nbr__c+'</font>'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            else
            shippingAddress1=shippingAddress1+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            
            shippingAddress1=shippingAddress1+'<font color="#707070" size="1.5"><b>NWF Order #</b></font>'+':'+' ';
            if(orders[0].GP_ERP_Order_ID__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].GP_ERP_Order_ID__c+'</font>'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            else
            shippingAddress1=shippingAddress1+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp'+'&nbsp';
            
            shippingAddress1=shippingAddress1+'<font color="#707070" size="1.5"><b>Placed</b></font>'+':'+' ';
            if(orders[0].GP_Create_Date__c!=null)
            shippingAddress1=shippingAddress1+'<font color="#404040" size="1.5">'+orders[0].GP_Create_Date__c+'</font>';
      
            return shippingAddress1;
        
      }   
       @RemoteAction
    global static String getOrder(String param)
     {
         //Tech M offshore : Added Child_Account__c to SOQL below  
         List<Orders__c> orders=[select Id, Account__r.Name,Account__r.address__c,Account__r.Phone, User_Email__c, Name__c,Child_Account__c,Child_Account__r.Name, User_Phone__c from Orders__c where id=:param];   
         if(orders.size() != 1)
         return 'fail';
         WrapperOrder wo=new WrapperOrder();       
         wo.name=orders[0].Account__r.Name;
         wo.address=orders[0].Account__r.address__c;
         wo.phone=orders[0].Account__r.Phone;
         wo.usrname = orders[0].Name__c;
         wo.Id1 = orders[0].Id;
         wo.usremail = orders[0].User_Email__c;
         wo.usrphone = orders[0].User_Phone__c;
         wo.childacc = orders[0].Child_Account__c;
         System.Debug('wo.childacc:'+wo.childacc+'33:::'+orders[0].Child_Account__c);
         String JSONString = JSON.serialize(wo);
         system.debug('getOrder JSONString is '+JSONString);
         return JSONString;      
    }
    
    @RemoteAction
    global static String getPurchasedService(String param)
     {
              
         List<Order_Line_Items__c> lineItems=[select Id,Orders__c,Installation_Type__c,TypeOfDevice__c,Devices_Installed__c,GP_Quantity__c,BalanceQuantity__c from Order_Line_Items__c where Orders__c=:param];   
         System.Debug('Offshore Debug Fetched Line Items:'+lineItems +'List size:'+lineItems.size());
         List<WrapperPurchasedService> wo=new List<WrapperPurchasedService>();  
         Map<String,String> m = new Map<String,String>();
         for(Order_Line_Items__c items:lineItems)    
         { 
             WrapperPurchasedService wrapperService = new WrapperPurchasedService();
             
            //Tech M Offshore :IT -256 
            //if(m.get(items.Installation_Type__c+items.Devices_Installed__c)==null){//( (items.Installation_Type__c!=null && items.Installation_Type__c!='' ) &&(items.Devices_Installed__c !=null && items.Devices_Installed__c!='') ){ 
             //Eliminated unneccessary condition placed by Tech-M Offshore as part of IT-256 ((items.Devices_Installed__c !=null && items.Devices_Installed__c!=''))
             if(items.Installation_Type__c!=null && items.Installation_Type__c!='' ){
                m.put(items.Installation_Type__c+items.Devices_Installed__c,'');
                wrapperService.Id1=items.Id;
                wrapperService.Devicetype= items.TypeOfDevice__c;
                wrapperService.service = items.Installation_Type__c;
                wrapperService.device = items.Devices_Installed__c;
                wrapperService.orderQty = items.GP_Quantity__c;
                wrapperService.balance = items.BalanceQuantity__c;
                //Tech M Offshore :IT -256 
                wo.add(wrapperService);
            }
            //wo.add(wrapperService);
            //Tech M Offshore :IT -256 
         }
         String JSONString = JSON.serialize(wo);
         system.debug('*****JSONString is '+JSONString);
         return JSONString;      
    }
    @RemoteAction
    global static String getStateCountryvalues()
    {
         Map<String,List<String>> picklistoptions= DependentOptions.GetDependentOptions('Location__c','Garage_Country__c','Garage_State__c');
         List<stateCountry> countries=new List<stateCountry>();
         for(String s:picklistoptions.keyset())
         {
             stateCountry sc=new stateCountry();
             sc.controlValue=s;
             sc.dependentvalues=picklistoptions.get(s);
             countries.add(sc);
         }
         String JSONString = JSON.serialize(countries);
         system.debug(JSONString);
         return JSONString;         
    }
    public class stateCountry
    {
        String controlValue;
        List<String> dependentvalues=new List<String>();
    }
    @RemoteAction
     global static String getLicenseState(String param)
     {
       Schema.describeFieldResult res = Order_Line_Item_Details__c.License_State__c.getDescribe();
        List<Schema.pickListEntry> ple = res.getPickListValues();
        List<String> licenseStateList = new List<String>();
        for(Schema.pickListEntry entry:ple)
        {
            String licenseState = entry.getValue();
            licenseStateList.add(licenseState);
        }
        return JSON.serialize(licenseStateList);
       
        
     }
     
     
     
      @RemoteAction
     global static String getFuelType(String param)
     {
        
       Schema.describeFieldResult res = Order_Line_Item_Details__c.Fuel_Type__c.getDescribe();
        List<Schema.pickListEntry> ple = res.getPickListValues();
        List<String> fuelList = new List<String>();
        for(Schema.pickListEntry entry:ple)
        {
            String fueltype = entry.getValue();
            fuelList.add(fueltype);
        }
        return JSON.serialize(fuelList);
        
     }
      
     @RemoteAction
    global static String getLocationsAndVeh(String param)
    {
     system.debug('apiNames===>'+apiNames);
        Orders__c o=[select NavigateToCard__c,Account__c from Orders__c where id = :param];
        
        List<String> addOns = new List<String>();
        List<String> addOnsnew = new List<String>();
        //List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param AND TypeOfDevice__c='AddOns' and Devices_Installed__c!='Harness' and ( not Devices_Installed__c  LIKE '%sensor%') ];
        List<Order_Line_Items__c> lineItems=[select id,Devices_Installed__c,TypeOfDevice__c,Installation_Type__c from Order_Line_Items__c where Orders__c=:param AND TypeOfDevice__c='AddOns' and Devices_Installed__c!='Harness' and (Devices_Installed__c != 'Sensor1' AND Devices_Installed__c != 'Sensor 1') AND (Devices_Installed__c != 'Sensor2' AND Devices_Installed__c != 'Sensor 2') AND (Devices_Installed__c != 'Sensor3' AND Devices_Installed__c != 'Sensor 3') AND (Devices_Installed__c != 'Sensor4' AND Devices_Installed__c != 'Sensor 4') AND (Devices_Installed__c != 'Sensor5' AND Devices_Installed__c != 'Sensor 5') AND (Devices_Installed__c != 'Sensor6' AND Devices_Installed__c != 'Sensor 6')];
        for(Order_Line_Items__c items:lineItems)
        {
        addOns.add(items.Devices_Installed__c);
        }
        system.debug('899999999'+addOns);
        for(String addOn:addOns)
        {
        if(addOn.trim()!='')
                {                    
                    String temp=addOn.replaceAll( '\\s+', '_');
                    temp='Addon_'+temp+'__c';
                    //if(vehicle.get(temp) == true)
                    if(apiNames.contains(temp.toLowerCase()))
                         addOnsnew.add(temp);
                }
        }
        system.debug(addOnsnew);
        Set<String> newset = new Set<String>();
        List<String> newlist = new List<String>();
        Set<String> newset1 = new Set<String>();
        List<String> newlist1 = new List<String>();
        newset.addAll(addOnsnew);
        newlist.addAll(newset);
        newset1.addAll(addOns);
        newlist1.addAll(newset1);
        System.debug('new set is '+newset);
        System.debug('new list is '+newlist);
        System.debug('new set1 is '+newset1);
        System.debug('new list1 is '+newlist1);
        String substrnew='';
        /*String substr=null;
        for(String substr:addOnsnew)
        {
            substr=substr+',';
            substrnew=substr;
        }*/
        
        for(Integer k=0;k<newset.size();k++)
        {
            substrnew = substrnew + newlist.get(k)+',';
        }
        
        List<OrderLocation__C> orderlocs=[select Location__c from OrderLocation__C where Orders__c=:param];
        List<Location__c> Locations=new List<Location__c>();
        if(o.NavigateToCard__c==2||o.NavigateToCard__c==3)
        {
            set<String> locIds=new set<String>();
            Set<WrapperLocation> listLoc=new Set<WrapperLocation>();
            for(OrderLocation__C ol:orderlocs)
            {
                locIds.add(ol.Location__c);
            }
            //Locations=[select Id,isSubmitted__c,ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name,Phone__c,Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c,(select name, isSubmitted__c, Old_Vehicle_Label__c, License_State__c, Vehicle_Label__c, Vehicle_Harness_Category__c, Installation_Type__c, Year__c, Make__c, Model__c, VIN__c, Old_Vin__c, License_Plate__c,Fuel_Type__c, Color__c, Device_Type__c, Device_Serial_Number__c, Device_Serial_Number_Old__c, Addon_Harness__c, Addon_Alternate_Power_Adapter__c, Addon_Bluetooth_module__c, Addon_Driver_ID__c, Addon_Garmin_CONNECT__c, Addon_Magnet_Mounts__c, Addon_NMEA_Cable__c, Addon_Pelican_Box__c, Addon_Pigtail__c, Addon_PEM__c, Addon_Quake_Satellite_Modem__c, Addon_Window_Mount_GPS_Antenna__c,Sensor1__c, Sensor2__c, Sensor3__c, Sensor4__c, Sensor5__c, Sensor6__c,Activity_Notes__c from Order_Line_Item_Details__r where SF_Orders__c=:param) from Location__c where Id in :locIds];
            Locations=Database.query('select Id,isSubmitted__c,ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name,Phone__c, Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c,(select name, isSubmitted__c, Old_Vehicle_Label__c, License_State__c, Vehicle_Label__c, Vehicle_Harness_Category__c, Installation_Type__c, Year__c, Make__c, Model__c, VIN__c, Old_Vin__c, License_Plate__c,Fuel_Type__c, Color__c, Device_Type__c, Device_Serial_Number__c, Device_Serial_Number_Old__c, Sensor1__c, Sensor2__c, Sensor3__c, Sensor4__c, Sensor5__c, Sensor6__c,'+substrnew+'Activity_Notes__c from Order_Line_Item_Details__r where SF_Orders__c=:param) from Location__c where Id in :locIds');
            //Locations=Database.query('select Id,isSubmitted__c,ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name,Phone__c, Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c,(select name, isSubmitted__c, Old_Vehicle_Label__c, License_State__c, Vehicle_Label__c, Vehicle_Harness_Category__c, Installation_Type__c, Year__c, Make__c, Model__c, VIN__c, Old_Vin__c, License_Plate__c,Fuel_Type__c, Color__c, Device_Serial_Number__c, Device_Serial_Number_Old__c, Sensor1__c, Sensor2__c, Sensor3__c, Sensor4__c, Sensor5__c, Sensor6__c,'+substrnew+'Activity_Notes__c from Order_Line_Item_Details__r where SF_Orders__c=:param) from Location__c where Id in :locIds');
            for(Location__c loc:locations)
            {
                
                WrapperLocation wrapperLocation=new WrapperLocation();
                
                wrapperLocation.Id1=loc.Id;
                wrapperLocation.GarageAddress1=loc.Garage_Address1__c;  
                wrapperLocation.GarageAddress2=loc.Garage_Address2__c; 
                wrapperLocation.GarageCity=loc.Garage_City__c;  
                wrapperLocation.GarageState=loc.Garage_State__c;
                wrapperLocation.Country=loc.Garage_Country__c;
                wrapperLocation.Zip=loc.Garage_Zip__c;
                wrapperLocation.ContactName=loc.ContactName__c;
                wrapperLocation.Email=loc.Email__c;
                wrapperLocation.LocationName=loc.Name;
                wrapperLocation.Phone=loc.Phone__c;
                wrapperLocation.AltContactName=loc.Alternate_Name__c;
                wrapperLocation.AltEmail=loc.Alternate_Email__c;
                wrapperLocation.AltPhone=loc.Alternate_Phone__c;
                wrapperLocation.isSubmitted=loc.isSubmitted__c;
                if(loc.Order_Line_Item_Details__r!=null&& !loc.Order_Line_Item_Details__r.isempty())
                    wrapperLocation.Used='('+String.valueof(loc.Order_Line_Item_Details__r.size())+')';
                for(Order_Line_Item_Details__c vehicle:loc.Order_Line_Item_Details__r)
                {
                    WrapperVehicle wrapperVehicle = new WrapperVehicle();
                    wrapperVehicle.Id1=vehicle.Id;
                    wrapperVehicle.LocationName=loc.name; 
                    wrapperVehicle.Service=vehicle.Installation_Type__c;
                    wrapperVehicle.VIN=vehicle.VIN__c;  
                    wrapperVehicle.VehicleLabel=vehicle.Vehicle_Label__c;   
                    wrapperVehicle.OLDVIN=vehicle.Old_Vin__c;
                    wrapperVehicle.OldVehicleLabel=vehicle.Old_Vehicle_Label__c;
                    wrapperVehicle.Year=vehicle.Year__c;
                    wrapperVehicle.Make=vehicle.Make__c;
                    wrapperVehicle.Model=vehicle.Model__c;
                    wrapperVehicle.LicensePlate=vehicle.License_Plate__c;
                    wrapperVehicle.LicenseState=vehicle.License_State__c; 
                    wrapperVehicle.Color=vehicle.Color__c; 
                    wrapperVehicle.FuelType=vehicle.Fuel_Type__c;   
                    wrapperVehicle.DeviceType=vehicle.Device_Type__c;
                    wrapperVehicle.Serial=vehicle.Device_Serial_Number__c;
                    wrapperVehicle.OldSerial=vehicle.Device_Serial_Number_Old__c;
                    wrapperVehicle.Harness=vehicle.Vehicle_Harness_Category__c;
                    wrapperVehicle.isSubmitted=vehicle.isSubmitted__c;
                   // wrapperVehicle.isSubmitted=true;
                    List<String> checkedAddons = new List<String>();
                    
                   /* for(Integer i=0;i<addOns.size();i++)
                    {
                        if(vehicle.get(i) == 'true')
                        {
                            checkedAddons.add(addOns.get(i));
                        }
                    }*/
                    
                    
                    for(Integer k=0;k<newset.size();k++)
                    {
                        //substrnew = substrnew + newlist.get(k)+',';
                        System.debug('in for '+newlist.get(k));
                        System.debug('in for1 '+vehicle.get(newlist.get(k)));
                        
                        if(vehicle.get(newlist.get(k)) ==true)
                        {
                            checkedAddons.add(newlist1.get(k));
                        }
                    }
                    
                    
                    System.debug('checked addons is '+checkedAddons);
                    /*List<String> addOns = new List<String>();
                    if(vehicle.Addon_Alternate_Power_Adapter__c)
                     addOns.add('Power Adapter');
                     if(vehicle.Addon_Bluetooth_module__c)
                     addOns.add('Bluetooth module');
                     if(vehicle.Addon_Driver_ID__c)
                     addOns.add('Driver ID');
                     if(vehicle.Addon_Garmin_CONNECT__c)
                     addOns.add('Garmin CONNECT');
                     if(vehicle.Addon_Harness__c)
                     addOns.add('Harness');
                     if(vehicle.Addon_Magnet_Mounts__c)
                     addOns.add('Magnet Mounts');
                     if(vehicle.Addon_NMEA_Cable__c)
                     addOns.add('NMEA Cable');
                     if(vehicle.Addon_Pelican_Box__c)
                     addOns.add('Pelican Box');
                     if(vehicle.Addon_PEM__c)
                     addOns.add('PEM');
                     if(vehicle.Addon_Pigtail__c)
                     addOns.add('Pigtail');
                     if(vehicle.Addon_Quake_Satellite_Modem__c)
                     addOns.add('Quake Satellite Modem');
                     if(vehicle.Addon_Window_Mount_GPS_Antenna__c)
                     //var=var+','+Schema.getGlobalDescribe().get('Order_Line_Item_Details__c').getDescribe().fields.getMap().get('Addon_Window_Mount_GPS_Antenna__c').getDescribe().getLabel();
                     addOns.add('Window Mount GPS Antenna');*/
                     
                     
                     if(checkedAddons.isEmpty() == true)
                     wrapperVehicle.Accessories='';
                    else
                    {
                    //wrapperVehicle.Accessories=Json.serialize(addOns);
                    //String jsonstr=Json.serialize(addOns);
                    //System.debug('old string is '+jsonstr);
                    //String newstr=jsonstr.substring(1,jsonstr.length()-1);
                    //System.debug('new string is '+newstr);
                    //wrapperVehicle.Accessories=newstr;
                    String st='';
                    integer cnt = 0;
                     for(String s:checkedAddons)
                     {
                        cnt++;
                        if(cnt<checkedAddons.size())
                        st=st+s+',';
                        else
                        st=st+s;
                        
                     }
                     System.debug(st);
                    wrapperVehicle.Accessories=st;
                    }
                    
                    wrapperVehicle.Sensor1=vehicle.Sensor1__c;
                    wrapperVehicle.Sensor2=vehicle.Sensor2__c;
                    wrapperVehicle.Sensor3=vehicle.Sensor3__c;
                    wrapperVehicle.Sensor4=vehicle.Sensor4__c;
                    wrapperVehicle.Sensor5=vehicle.Sensor5__c;
                    wrapperVehicle.Sensor6=vehicle.Sensor6__c;
                    wrapperVehicle.Notes=vehicle.Activity_Notes__c;
                    wrapperVehicle.locId=loc.Id;
                    wrapperLocation.vehicles.add(wrapperVehicle);
                }
               
                listLoc.add(wrapperLocation);
                
            }
             return JSON.serialize(listLoc);
        }
        else if(o.NavigateToCard__c==0 ||o.NavigateToCard__c==null)
        {
           // Orders__c o=[select Account__c from Orders__c where id = :param];
            String accId = o.Account__c;
            Locations=[select Id,isSubmitted__c, ContactName__c,Customer__c,Email__c,Garage_Address1__c,Garage_Address2__c,Garage_City__c,Garage_Country__c,Garage_State__c,Garage_Zip__c,Name, Alternate_Email__c,Alternate_Name__c,Alternate_Phone__c,Phone__c from Location__c where Customer__c =: accId];
            Set<WrapperLocation> listLoc=new Set<WrapperLocation>();
            for(Location__c loc:Locations){            
               WrapperLocation wrapperLocation=new WrapperLocation();
               wrapperLocation.Id1=loc.Id;
               wrapperLocation.GarageAddress1=loc.Garage_Address1__c;  
               wrapperLocation.GarageAddress2=loc.Garage_Address2__c; 
               wrapperLocation.GarageCity=loc.Garage_City__c;  
               wrapperLocation.GarageState=loc.Garage_State__c;
               wrapperLocation.Country=loc.Garage_Country__c;
               wrapperLocation.Zip=loc.Garage_Zip__c;
               wrapperLocation.ContactName=loc.ContactName__c;
               wrapperLocation.Email=loc.Email__c;
               wrapperLocation.LocationName=loc.Name;
               wrapperLocation.AltContactName=loc.Alternate_Name__c;
               wrapperLocation.AltEmail=loc.Alternate_Email__c;
               wrapperLocation.AltPhone=loc.Alternate_Phone__c;
               wrapperLocation.Phone=loc.Phone__c;
               
               wrapperLocation.isSubmitted=loc.isSubmitted__c;
               listLoc.add(wrapperLocation);    
               
        }
        return JSON.serialize(listLoc);
        }
        else
        return null;
       
    }
    public static void populateETAStaging(List<WrapperLocation> locations)
    {
    /*List<ETAStaging__c> stagings=new List<ETAStaging__c>();
        for(WrapperLocation loc:locations)
        {
            ETAStaging__c staging=new ETAStaging__c();
            staging.Garage_Address1__c=loc.GarageAddress1;
            staging.Garage_Address2__c=loc.GarageAddress2;
            staging.Garage_City__c=loc.GarageCity;
            staging.Garage_State__c=loc.GarageState;
            staging.Country__c=loc.Country;
            staging.Garage_Zip__c=loc.Zip;
            stagings.add(staging);
        }
        insert stagings;*/
    } 
    //aDDED CHILD aCCOUNT
    @RemoteAction
    global static Boolean submitRecord(String orderId,Integer cardno,String locationJson,String lineItemJson,string strUserName,string strUserEmail,string strUserPhone,string strChildAcc)
    {   
    //  Boolean result= saveRecord(orderId,cardno,locationJson,lineItemJson,true);
       Boolean result= saveRecord(orderId,cardno,locationJson,lineItemJson,strUserName,strUserEmail, strUserPhone,strChildAcc, true);
     
      if(result==true)
      {
          List<WrapperLocation> locationRec=(List<WrapperLocation>)System.JSON.deserialize(locationJson,List<WrapperLocation>.class);
         // populateETAStaging(locationRec);
          return true;
      }
      else    
     
      return false;
    }
    /*Added Below Code to Conditionally Render Child Account Field : IT-1601 - Sunil Kumar*/
    @RemoteAction
    global static Integer getCount(String OrderId) {
       Orders__c ordRec= new Orders__c();
       ordRec = [Select Id,Account__c from Orders__c where Id=:OrderId ];
       Account acc = new Account();
       acc = [SELECT Id, Name ,Sub_Type__c  FROM Account where Id =:ordRec.Account__c]; 
       if(acc != null && (acc.Sub_Type__c == 'RESELLER' || acc.Sub_Type__c == 'RESELLER-PP' || acc.Sub_Type__c == 'VAR')){
           accountSize = 1;
       }
       else{
           accountSize = 0;
       } 
       //accountSize = accList.size();
       return accountSize;
    }
    /* End of Code Update */
}