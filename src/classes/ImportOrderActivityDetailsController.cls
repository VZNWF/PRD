public class ImportOrderActivityDetailsController{


    public Blob csvFileBody{get;set;}
    public string Order_ID {get;set;}
    public string Account_ID {get;set;}
    public string PONUMBER {get;set;}
    public List<OLID_Data> listOLID_Data{get;set;}
    public string OrderNumber= '';
    public Orders__c currentOrder;
    //public OrderLocation__c ponum;
    public Account currentAccount;
    public List<OrderLocation__c> listExistingOrderLocation = new List<OrderLocation__c>();
    public List<Location__c> listExistingLocation = new List<Location__c>();
    public Map<string, Location__c> existingLocationMap = new Map<string, Location__c>();
    public Map<string, OrderLocation__c> existingOrderLocationMap = new Map<string, OrderLocation__c>();
    public List<OrderLocation__c> listLocationOrder {get; set;}
    public Boolean blnDisplayOrder {get; set;}
    
    public ImportOrderActivityDetailsController(){
        listLocationOrder = new List<OrderLocation__c>();
        blnDisplayOrder = false;
        csvFileBody = null;
    }
    
    Public class OLID_Data    {
        public string ALTERNATEEMAIL  {get;set;}
        public string ALTENATENAME  {get;set;}
        public string ALTERNATEPHONE    {get;set;}
        public string GARAGEDADDRESS1    {get;set;}
        public string GARAGEADDRESS2    {get;set;}
        public string GARAGECITY {get;set;}
        public string GARAGECOUNTRY {get;set;}
        public string GARAGESTATE    {get;set;}
        public string GARAGEZIP {get;set;}
        public string NAME {get;set;}
        public string PHONE   {get;set;}
        public string CONTACTNAME {get;set;}
        public string PONUMBER   {get;set;}
        public List<OLID_Data> listOLID_Data{get;set;}
        public string Order_ID {get;set;}
        public string ORDERNUMBER   {get;set;}
        public string OrderID{get;set;}
        public string LocationID{get;set;}
        public string LOCATIONNAME {get;set;}
        public string EMAIL {get;set;}
        public string SHIPCOMPANY {get;set;}
        
        Public OLID_Data()    {
            this.ALTERNATEEMAIL   = '';
            this.ALTENATENAME   = '';
            this.ALTERNATEPHONE = '';
            this.GARAGEDADDRESS1 = '';
            this.GARAGEADDRESS2 = '';
            this.GARAGECITY  = '';
            this.GARAGECOUNTRY  = '';
            this.GARAGESTATE = '';
            this.GARAGEZIP  = '';
            this.NAME  = '';
            this.PHONE    = '';
            this.CONTACTNAME    = '';
            this.PONUMBER    = '';
            this.ORDERNUMBER    = '';
            this.OrderID= '';
            this.LocationID= '';  
            this.LOCATIONNAME ='';
            this.EMAIL ='';
            this.SHIPCOMPANY  ='';
        }        
    }
    
    public PageReference dosubmit(){

        system.debug('test');

        PageReference pr = new PageReference(System.Label.ImportOrderActivity); // uploading the data here
        pr.setRedirect(true);
        return pr;
    }
    
    public Pagereference importfile() {
        System.debug('Hello - i am in');
       // System.debug('file details ---'+ csvFileBody.toString());
        
        list<list<string>> parsedCSV = new list<list<string>>();
        list<list<string>> headerData = new list<list<string>>();
        Map<integer,string> mandatoryColumnsMap = new Map<integer,string>();
        
        if(csvFileBody == null){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.FATAL,'Choose your File First');
             ApexPages.addMessage(errormsg);
             return null;
        }
   
        try{ 
            parsedCSV = VZ_Util.parseCSV(csvFileBody.toString(),true, true);
         
        }catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please remove columns and try again' + e.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }         
        try {
        
            headerData  = parseCSVForERPORDERID(csvFileBody.toString());
            system.debug('headerData.size()=>'+headerData.size());
            for(list<string> csvRecordData:headerData){  
                System.Debug('csvRecordData---->' + csvRecordData);
                OrderNumber=csvRecordData.get(0);
                System.Debug('OrderNumber---->' + OrderNumber);
                //System.Debug('OrderNumber0---->' + csvRecordData.get(0)); 
                //System.Debug('OrderNumber1---->' + csvRecordData.get(1)); 
                //System.Debug('OrderNumber3---->' + csvRecordData.get(3)); 
                //System.Debug('csvRecordData---->' + csvRecordData); 
            }
        }
        catch (Exception e)    {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading ORDER Number - Please make sure input csv file is valid' + e.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }
        
       /* try{
            //mandatoryColumnsMap = fnGetMandatoryColumnsMap(csvFileBody.toString());
            system.debug('mandatoryColumnsMap.size()=>'+mandatoryColumnsMap.size());
        }catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading Mandatory Columns - Please make sure input csv file is valid' + ex.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;    
        } */ 
        if(VZ_Util.IsNullOrEmpty(OrderNumber)){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while reading OrderNumber - Please make sure input csv file is valid');
            ApexPages.addMessage(errorMessage);
            return null;
        }
        try{
            //Populate related object values
            system.debug('@@@The Order value is: '+OrderNumber);
            currentOrder = [Select Id,Name, Account__c from Orders__c where Name =:OrderNumber limit 1];
            //ponum= [Select Id,Name,Orders__r.name,PO_Number__c from OrderLocation__c where Orders__r.name =:OrderNumber limit 1];
        }
        catch (Exception e)    {
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No Order found for OrderNumber - Please make sure input csv file is valid' + OrderNumber  + e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'No Order found for OrderNumber - Please make sure to input csv file with valid'  + OrderNumber);
            ApexPages.addMessage(errorMessage);
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
        //PONUMBER = ponum.PO_Number__c;
        currentAccount = [Select Id, Name from Account where id =:Account_ID limit 1];            
        getLocationMapforAccount(Account_ID);
        getOrderLocationMap(Order_ID);

        string strErrorMsg =''; 
        List<ApexPages.Message> errMsgList = new List<ApexPages.Message>();
        try{
            listOLID_Data = new List<OLID_Data>();
            integer intLineCount = 1;
            
            for(list<string> csvRecordData:parsedCSV){                
                string strMsg = fnValidateCSVRow(intLineCount, csvRecordData);
                if(strMsg != ''){
                    ApexPages.Message validationErrorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Please make sure to input csv file with two letter STATE');
                    errMsgList.add(validationErrorMessage);
                }
                OLID_Data oliRecord = new OLID_Data() ;
                oliRecord.ALTERNATEEMAIL    = csvRecordData[0];  
                oliRecord.ALTENATENAME  = csvRecordData[1];  
                oliRecord.ALTERNATEPHONE    = csvRecordData[2];   
                oliRecord.GARAGEDADDRESS1    = csvRecordData[3];   
                oliRecord.GARAGEADDRESS2    = csvRecordData[4];  
                oliRecord.GARAGECITY = csvRecordData[5];       
                oliRecord.GARAGECOUNTRY = csvRecordData[6];  
                oliRecord.GARAGESTATE    = csvRecordData[7];  
                oliRecord.GARAGEZIP = csvRecordData[8];  
                oliRecord.NAME = csvRecordData[9];
                oliRecord.LOCATIONNAME = csvRecordData[9];              
                oliRecord.PHONE   = csvRecordData[10];
                oliRecord.CONTACTNAME= csvRecordData[11];             
                oliRecord.PONUMBER   = csvRecordData[12];
                oliRecord.EMAIL   = csvRecordData[13];
                oliRecord.SHIPCOMPANY   = csvRecordData[14];
                oliRecord.ORDERNUMBER   = OrderNumber;   

                listOLID_Data.add(oliRecord);
                intLineCount++;
            }
        }catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is valid' +  e.getMessage());
            ApexPages.addMessage(errorMessage);
            //return null;
        } 
        if(errMsgList.size() > 0){
            for(ApexPages.Message strMsg:errMsgList){
              ApexPages.addMessage(strMsg);    
            }
            return null;    
        }
            
        System.Debug(Logginglevel.ERROR,'***********listOLID_Data size'+ listOLID_Data.Size());   
       
        try{
           createOrderLocationAndLocationData(listOLID_Data);
        }catch(Exception e){
            System.Debug(Logginglevel.ERROR,'Error createOrderLocationAndLocationData '+e.getMessage()); 
            return null;
        } 
        String strApexMsg;
        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Order Line Item Details data imported successfully - Total Records for Order# - ' + OrderNumber + ' ----' + listOLID_Data.Size());
        if(listLocationOrder.size() >0){
            strApexMsg = 'Order Line Item Details data imported successfully - Order# - ' + OrderNumber;
        }else{
            strApexMsg = 'No new locations created - Order# - ' + OrderNumber;
        }
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, strApexMsg );
        ApexPages.addMessage(myMsg);
        return null;
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
            System.debug('line' + line);
        if(num == 0){
        num +=1;
        System.debug('parseCSVForERPORDERID lines count' + lines.Size());
            // check for blank CSV lines (only commas)
            if(line.replaceAll(',','').trim().length()==0) 
               break;
            list<String> fields=line.split(','); 
            System.debug('fields' + fields);
            list<String> cleanFields=new list<String>();
            string compositeField;
            boolean makeCompositeField=false;
            for(string field : fields) {
                if(field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                } else if(field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if(field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                    makeCompositeField = false;
                } else if(makeCompositeField) {
                    compositeField +=  ',' + field;
                } else{
                    cleanFields.add(field.replaceAll('DBLQT','"').removeStart('"').removeEnd('"'));
                }
            }  
            allFields.add(cleanFields);
            }
            else{}
        }
        
        System.debug('parseCSVForERPORDERID allFields count after' + allFields.Size());
        return allFields;       
    }//END ParseCSV

    
    
    private Map<string,Location__c> getLocationMapforAccount(string Account_ID) {
                 
        listExistingLocation =  [Select Id, Name,Customer__c,Garage_Address1__c,Garage_City__c,Garage_State__c,Phone__c, ContactName__c, Email__c,Alternate_Phone__c,Alternate_Email__c  from Location__c where Customer__c =:Account_ID limit 1000];       
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
    
    private Map<string,OrderLocation__c> getOrderLocationMap(string Order_ID){             
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
        Map<string,String> newLocationsPONumberMap = new Map<string,String>();
        Set<string> uniqueLocationNames = new Set<string>();        
        Set<string> uniqueGarageAddress = new Set<string>();
        
        
        for(OLID_Data lOLID_Data : listOLID_Data){ 
            
            
            
            if(!VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME))
            {
                uniqueLocationNames.Add(lOLID_Data.LOCATIONNAME);
                System.Debug(Logginglevel.ERROR,'debug lOLID_Data.LOCATIONNAME -|'+lOLID_Data.LOCATIONNAME); 
            } 
            if(VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME) && !VZ_Util.IsNullOrEmpty(lOLID_Data.GARAGEDADDRESS1))
            {
                if(lOLID_Data.GARAGEDADDRESS1.length()>80){
                    uniqueLocationNames.add(lOLID_Data.GARAGEDADDRESS1.SubString(0,80)); 
                    lOLID_Data.LOCATIONNAME = lOLID_Data.GARAGEDADDRESS1.SubString(0,80);
                    System.Debug(Logginglevel.ERROR,'debug null lOLID_Data.GARAGEDADDRESS -|'+lOLID_Data.GARAGEDADDRESS1); 
                }
                else    {
                   uniqueLocationNames.add(lOLID_Data.GARAGEDADDRESS1);
                   lOLID_Data.LOCATIONNAME = lOLID_Data.GARAGEDADDRESS1;
                   System.Debug(Logginglevel.ERROR,'debug null lOLID_Data.GARAGEDADDRESS -|'+lOLID_Data.GARAGEDADDRESS1); 
                }               
                
            }            
                    
        }  
        
        for(OLID_Data lOLID_Data : listOLID_Data){
         
            if(!VZ_Util.IsNullOrEmpty(lOLID_Data.LOCATIONNAME) && !existingLocationMap.ContainsKey(lOLID_Data.LOCATIONNAME.toUpperCase()))
            {
                Location__c locationData = new Location__c();
                locationData.Name = lOLID_Data.LOCATIONNAME;
                locationData.Garage_Address1__c   =  lOLID_Data.GARAGEDADDRESS1;
                locationData.Garage_Address2__c   =  lOLID_Data.GARAGEADDRESS2;           
                locationData.ContactName__c =  lOLID_Data.CONTACTNAME;
                locationData.Email__c =  lOLID_Data.EMAIL;
                locationData.Phone__c =  lOLID_Data.PHONE;
                locationData.Alternate_Email__c =  lOLID_Data.ALTERNATEEMAIL;
                locationData.Alternate_Phone__c   =  lOLID_Data.ALTERNATEPHONE;
                locationData.Alternate_Name__c   =  lOLID_Data.ALTENATENAME;
                locationData.Garage_City__c =  lOLID_Data.GARAGECITY;
                locationData.Garage_State__c   =  lOLID_Data.GARAGESTATE;
                locationData.Garage_Country__c   =  lOLID_Data.GARAGECOUNTRY;
                locationData.Garage_Zip__c  =  lOLID_Data.GARAGEZIP;                
                locationData.Ship_Company__c =  lOLID_Data.SHIPCOMPANY;
                System.Debug('debug locationData.Ship_Company__c----->'+locationData.Ship_Company__c);
                System.Debug('debug lOLID_Data.SHIPCOMPANY----->'+ lOLID_Data.SHIPCOMPANY); 
                System.Debug('debug locationData.Ship_Company__c.length()----->'+ locationData.Ship_Company__c.length());                   
                if(locationData.Ship_Company__c.length() ==1){
                    locationData.Ship_Company__c  =  currentAccount.name;
                }
                
                //locationData.PO_Number__c =  lOLID_Data.PONUMBER;
                locationData.Customer__c  =  Account_ID;
                System.Debug('debug lOLID_Data.Ship_Company__c----->'+ locationData.Ship_Company__c);   
                System.Debug(Logginglevel.ERROR,'debug lOLID_Data.LocationID -|'+lOLID_Data.LocationID);
                
                locationsToCreateList.add(locationData);
                newLocationsPONumberMap.put(locationData.Name, lOLID_Data.PONUMBER);
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
           
        }catch (Exception e){
            System.Debug(Logginglevel.ERROR,'UniquelocationsList - UniquelocationsList Error ************' + e.getMessage()); 
        }
        for(Location__c locationCreated : UniquelocationsList){        
            OrderLocation__c orderLocationToCreate = new OrderLocation__c();
            orderLocationToCreate.Orders__c = Order_ID;
            if(newLocationsPONumberMap.containsKey(locationCreated.Name)){
                orderLocationToCreate.PO_Number__c = newLocationsPONumberMap.get(locationCreated.Name);
            }
            orderLocationToCreate.Location__c = locationCreated.Id;
            orderLocationToCreateList.add(orderLocationToCreate);
        }   
        system.debug('Show PO NUmber is the orerlocation' +  PONUMBER);
        system.debug('Show Order_ID is the orerlocation' +  Order_ID);     
         
        try{           
            insert orderLocationToCreateList;
            System.Debug(Logginglevel.ERROR,'orderLocationToCreateList - orderLocationToCreateList size ************' + orderLocationToCreateList.Size()); 
            listLocationOrder = [Select Id, Name, Orders__c, Location__c, Location__r.Name, Location__r.Phone__c,
                    Location__r.Alternate_Email__c,Location__r.Alternate_Name__c,Location__r.Alternate_Phone__c,Location__r.Garage_Address1__c,Location__r.Garage_Address2__c,
                    Location__r.Garage_City__c,Location__r.Garage_Country__c,Location__r.Garage_State__c,Location__r.Garage_Zip__c,Location__r.ContactName__c, Location__r.Email__c,
                    Location__r.Ship_Company__c,PO_Number__c FROM OrderLocation__c where id in:orderLocationToCreateList]; 
            blnDisplayOrder = true;
        }catch (Exception e){
            System.Debug(Logginglevel.ERROR,'orderLocationToCreateList - orderLocationToCreateList Error ************' + e.getMessage()); 
        }
        return true;
    }  
    
    public string fnValidateCSVRow(Integer intLineNo, List<string> rowDataList){
        String strMessage = '';
                
          if(rowDataList[7].trim() != '' && rowDataList[1].trim() != 'null'){
            if(rowDataList[7].trim().length() > 2 || rowDataList[7].trim().length() < 2){
                
                    strMessage = strMessage +', ' + 'invalid STATE';
                }
            }
                    
        return strMessage;
    } 
  
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
    } */
    
    
    
    
    
        
    

   }