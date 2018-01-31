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
// File Name:       importInstallerDataFromCSVController 
// Summary:         File Uploader Controller class for parsting excel/csv data and upsert it in to SFDC
// Created On:      April-7-2015

// Modification Log:
====================
// Aravind    - 4/14/2015 - Adding Methods to handle the Affiliate Hierarchy
// Aravind    - 4/9/2015 - Adding Methods to handle the Installer Data and create new Affiliates, Contacts and Installer Certificate data
// Aravind    - 4/7/2015 - Create a base version 

*******************************************************************************/

public class ImportInstallerDataFromCSVController {
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public List<Affiliate__c> affiliatelist{get;set;}
public List<account> acclist{get;set;}
public List<contact> contactlist{get;set;}
public List<Installer_Certificate__c> installerCertificatelist{get;set;}
private Account defaultAccount = new Account();
public Map<Id, Affiliate__c> AffiliateMap;
public Map<Id, Affiliate__c> SecondaryAffiliateMap;
public Map<string, Account > ExistingAccountsMap = new Map<string, Account >();
public List<account> ExistingAccountslist{get;set;}

public List<InstallerData> listInstallerData{get;set;}

  public importInstallerDataFromCSVController(){
    csvFileLines = new String[]{};
    acclist = New List<Account>(); 
  }
  
  Public class InstallerData    {
      public string Exam_Date{get;set;}
      public string Exam_ID{get;set;}
      public string Exam_Name{get;set;}
      public string FirstName{get;set;}
      public string LastName{get;set;}
      public string EmailAddress{get;set;}
      public boolean Pass_Result{get;set;}
      public decimal User_Score{get;set;}      
      public string Phone{get;set;}
      public string City{get;set;}
      public string State{get;set;}
      public string Zip{get;set;}
      public string User_Id{get;set;}
      public string QAddress{get;set;}
      public string QCity{get;set;}
      public string QState{get;set;}
      public string QZip_Code{get;set;}
      public string QPhone_Number{get;set;}
      public string Parent_Installation_Company{get;set;}
      public string Child_Subcontracted_Company{get;set;}
      public string Last4SSN{get;set;}
      public string ContactDuplicateIdentifier{get;set;}
      public string AffiliateID{get;set;}
      public string SecondaryAffiliateID{get;set;}
      public string ParentAffiliateID{get;set;}
      public string ContactID{get;set;}
      public string AccountID{get;set;}
      
      Public InstallerData()    {
          this.Exam_Date = '';
          this.Exam_ID = '';
          this.Exam_Name = '';
          this.FirstName = '';
          this.LastName = '';
          this.EmailAddress = '';
          this.Pass_Result = true;
          this.User_Score = 0;      
          this.Phone = '';
          this.City = '';
          this.State = '';
          this.Zip = '';
          this.User_Id = '';
          this.QAddress = '';
          this.QCity = '';
          this.QState = '';
          this.QZip_Code = '';
          this.QPhone_Number = '';
          this.Parent_Installation_Company = '';
          this.Child_Subcontracted_Company = '';
          this.Last4SSN = '';
          this.ContactDuplicateIdentifier = '';
          this.AffiliateID = '';
          this.SecondaryAffiliateID = '';
          this.ParentAffiliateID = '';
          this.ContactID = '';
          this.AccountID = '';
      }   
  
  }
  
    public Pagereference importCSVFile(){
   
       list<list<string>> parsedCSV = new list<list<string>>();
       
       if(csvFileBody == null){
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.FATAL,'Choose your File First');
             ApexPages.addMessage(errormsg);
             return null;
       }
   
       try{ 
       String csvBody = EncodingUtil.base64Encode(csvFileBody);
     /*  Attachment a = new Attachment();
       a.Name=  'import file';
       a.body = csvFileBody;
       a.ContentType = 'text/plain; charset=UTF-8';   
       a.ParentId = '003e000000TYNoQ';
       insert a;
      */
        parsedCSV = VZ_Util.parseCSV(csvFileBody.toString(),true, false);     
       }
    catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Pleaseremove Questions and Answers columns and try again' + e.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }  
      try{
            getdefaultAccountId();
              
            listInstallerData = new List<InstallerData>();
         
               for(list<string> csvRecordData:parsedCSV){
                   InstallerData installer = new InstallerData() ;
                   installer.Exam_Date = csvRecordData[0];  
                   installer.Exam_ID = csvRecordData[2];  
                   installer.Exam_Name = csvRecordData[3] ;  
                   installer.FirstName = csvRecordData[10];  
                   installer.LastName = csvRecordData[9];  
                   installer.EmailAddress = csvRecordData[11];  
                   installer.Pass_Result = Boolean.ValueOf(csvRecordData[8]);   
                   installer.User_Score = Decimal.ValueOf(csvRecordData[4]); 
                   installer.Phone = csvRecordData[13];  
                   installer.City = csvRecordData[14];  
                   installer.State = csvRecordData[15];  
                   installer.Zip = csvRecordData[16];  
                   installer.User_Id = csvRecordData[18];  
                   installer.QAddress = csvRecordData[20];  
                   installer.QCity = csvRecordData[22];  
                   installer.QState = csvRecordData[24];  
                   installer.QZip_Code = csvRecordData[26];  
                   installer.QPhone_Number = csvRecordData[28];  
                   installer.Parent_Installation_Company = csvRecordData[30].toUpperCase();  
                   installer.Child_Subcontracted_Company = csvRecordData[32].toUpperCase();  
                   //installer.Last4SSN = csvRecordData[34];  
                   string uniqueIdentifier = csvRecordData[10] + csvRecordData[9] + csvRecordData[11];
                   installer.ContactDuplicateIdentifier = uniqueIdentifier.ToLowerCase();
                   
                    System.Debug(Logginglevel.ERROR,'Error ContactDuplicateIdentifier '+installer.ContactDuplicateIdentifier);             
                   listInstallerData.add(installer);   
               }
             }
           catch (Exception e)
            {
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data Please make sure input csv file is valid' + e.getMessage());
                ApexPages.addMessage(errorMessage);
                return null;
            }  
            
            System.Debug(Logginglevel.ERROR,'Error listInstallerData size'+ listInstallerData.Size());   
           getAccountList(listInstallerData);
            try{
               getInstallersWithAffiliateIdList(listInstallerData);
            }catch(Exception e){
                    System.Debug(Logginglevel.ERROR,'Error getInstallersWithAffiliateIdList '+e.getMessage()); 
                    return null;
            } 
             try{
               getInstallersWithSecondaryAffiliateIdList(listInstallerData);
            }catch(Exception e){
                    System.Debug(Logginglevel.ERROR,'Error getInstallersWithSecondaryAffiliateIdList|'+e.getMessage()); 
                    return null;
            }
            
           
             try{
               
               populateInstallersWithAccountIdList(listInstallerData);
               getInstallersWithContactIdList(listInstallerData);
            }catch(Exception e){
                    System.Debug(Logginglevel.ERROR,'Error getInstallersWithContactIdList|'+e.getMessage()); 
                    return null;
            }
             try{
               populateInstallersWithContactIds(listInstallerData);
               InsertInstallerCertificatelist(listInstallerData);
            }catch(Exception e){
                    System.Debug(Logginglevel.ERROR,'Error getInstallersWithContactIdList|'+e.getMessage()); 
                    return null;
            }
            try{
               setParentAffiliateID(listInstallerData);
            }catch(Exception e){
                    System.Debug(Logginglevel.ERROR,'Error setParentAffiliateID|'+e.getMessage()); 
                    return null;
            }
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Installer Certificate data imported successfully - Total Records - ' + listInstallerData.Size());
           ApexPages.addMessage(myMsg);
      
       
         return null;
    }
    
    private void processInstallerData(List<InstallerData> listInstallerData)
    {
        List<InstallerData> listInstallerDataWithAffiliates = new List<InstallerData>();
        
    }
    
    private Set<string> getALLUniqueAffiliateNames(List<InstallerData> listInstallerData){
        Set<string> uniqueAffiliateNames = new Set<string>();
        for(InstallerData newInstallerData : listInstallerData){
            if(!VZ_Util.IsNullOrEmpty(newInstallerData.Parent_Installation_Company))
            {
            uniqueAffiliateNames.Add(newInstallerData.Parent_Installation_Company);
            }
            if(!VZ_Util.IsNullOrEmpty(newInstallerData.Child_Subcontracted_Company))
            {
                uniqueAffiliateNames.Add(newInstallerData.Child_Subcontracted_Company );
               
            }
            
        }  
        
        System.Debug(Logginglevel.ERROR,'Error uniqueAffiliateNamesSize -|'+uniqueAffiliateNames.Size()); 
        return uniqueAffiliateNames ;
    }
    
    private Set<string> getUniqueAffiliateNames(List<InstallerData> listInstallerData){
        Set<string> uniqueAffiliateNames = new Set<string>();
        for(InstallerData newInstallerData : listInstallerData){
            uniqueAffiliateNames.Add(newInstallerData.Parent_Installation_Company);
        }  
        System.Debug(Logginglevel.ERROR,'Error uniqueAffiliateNamesSize -|'+uniqueAffiliateNames.Size()); 
        return uniqueAffiliateNames ;
    }
    private Set<string> getUniqueSecondaryAffiliateNames(List<InstallerData> listInstallerData){
        Set<string> uniqueSecondaryAffiliateNames = new Set<string>();
        for(InstallerData newInstallerData : listInstallerData){
            if(!VZ_Util.IsNullOrEmpty(newInstallerData.Child_Subcontracted_Company))
            {
                uniqueSecondaryAffiliateNames.Add(newInstallerData.Child_Subcontracted_Company );
                System.Debug(Logginglevel.ERROR,'Error getUniqueSecondaryAffiliateNames -|'+newInstallerData.Child_Subcontracted_Company); 
            }
            
        }  
        
        System.Debug(Logginglevel.ERROR,'Error uniqueSecondaryAffiliateNames -|'+uniqueSecondaryAffiliateNames.Size()); 
        return uniqueSecondaryAffiliateNames ;
    }
    
    private void setParentAffiliateID(List<InstallerData> listInstallerData){
        Set<string> uniqueAffiliateNames = getUniqueAffiliateNames(listInstallerData);
        affiliatelist = new List<Affiliate__c>();
        affiliatelist =  [SELECT id, Affiliate_Name__c FROM Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueAffiliateNames];
        Map<string, Affiliate__c> existingAffiliatesMap = new Map<string, Affiliate__c>();
        for(Affiliate__c affiliate : affiliatelist )
        {
            existingAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
        }
        
        for(InstallerData installer: listInstallerData)
        {  
            if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company)) {            
            
            }                
                        
        }
        Set<string> uniqueSecondaryAffiliateNames = getUniqueSecondaryAffiliateNames(listInstallerData);
        List<Affiliate__c> secAffiliatelist = new List<Affiliate__c>();
        List<Affiliate__c> secAffiliatelistToUpdate = new List<Affiliate__c>();
        secAffiliatelist =  [SELECT id, Affiliate_Name__c FROM Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueSecondaryAffiliateNames];       
        Map<string, Affiliate__c> existingSecAffiliatesMap = new Map<string, Affiliate__c>();
        for(Affiliate__c affiliate : secAffiliatelist )
        {
            existingSecAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
        }
        
        for(InstallerData installer: listInstallerData) {   
        
             if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company))  {
                Affiliate__c affRecord = existingSecAffiliatesMap.get(installer.Child_Subcontracted_Company);
                affRecord.Parent_Affiliate__c = existingAffiliatesMap.get(installer.Parent_Installation_Company).id;
                affRecord.Affiliate_Status__c = 'Active';            
                secAffiliatelistToUpdate.add(affRecord);
             }
        
        
        }
        
        try    {
                if(!VZ_Util.IsNullOrEmpty(secAffiliatelistToUpdate))
                {
                    System.Debug(Logginglevel.ERROR,'setParentAffiliateID - secAffiliatelistToUpdate Size ************' +secAffiliatelistToUpdate.Size()); 
                    update secAffiliatelistToUpdate;
                }
        }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'setParentAffiliateID - secAffiliatelistToUpdate Error ************' + e.getMessage()); 
        }
        return;
        
        
    }
    
    private Set<string> getUniqueContactNames(List<InstallerData> listInstallerData){
        Set<string> uniqueContactNames = new Set<string>();
        for(InstallerData newInstallerData : listInstallerData){
            uniqueContactNames.Add(newInstallerData.ContactDuplicateIdentifier);
        }  
        return uniqueContactNames ;
    }
    
    private void getdefaultAccountId(){
         List<Account> accList =  [SELECT id, Name FROM Account WHERE Name = 'Default Certified Installer Vendor' limit 1];
         defaultAccount  = accList[0];
         

    }
    
    private void  getAccountList(List<InstallerData> listInstallerData) {
         Set<string> uniqueAffiliateNames = getUniqueAffiliateNames(listInstallerData);
        List<Account> existingAccList =  [SELECT id, Name FROM Account WHERE Name in:uniqueAffiliateNames];
          ExistingAccountsMap = new Map<string, Account >();
            for(Account acc : accList )
            {
                if(!ExistingAccountsMap.containsKey(acc.Name))
                {
                    ExistingAccountsMap.put(acc.Name, acc);
                }
            }    
         return;
              
    }
   
    private List<InstallerData> getInstallersWithAffiliateIdList(List<InstallerData> listInstallerData){
        System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - Enter' + listInstallerData.Size()); 
        Set<string> uniqueAffiliateNames = getUniqueAffiliateNames(listInstallerData);
        affiliatelist =  [SELECT id, Affiliate_Name__c,Affiliate_Type__c,Affiliate_Status__c FROM Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueAffiliateNames];
        Set<Affiliate__c> createAffiliateSet = new Set<Affiliate__c>();
        Map<string, Affiliate__c> existingAffiliatesMap = new Map<string, Affiliate__c>();
       
       if(VZ_Util.IsNullOrEmpty(affiliatelist ))
       {
         System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - affiliatelist is NULL ************'); 
         
         for(InstallerData installer: listInstallerData)
            {              
                    Affiliate__c newAffiliate = new Affiliate__c();
                    newAffiliate.Affiliate_Name__c = installer.Parent_Installation_Company;
                    newAffiliate.Affiliate_Type__c = 'Vendor Installer'; 
                    newAffiliate.Affiliate_Status__c = 'Active'; 
                    /*
                    if(!VZ_Util.IsNullOrEmpty(ExistingAccountsMap)) {
                        if(ExistingAccountsMap.containsKey(installer.Parent_Installation_Company))
                        {                   
                            newAffiliate.Account__c = ExistingAccountsMap.Get(installer.Parent_Installation_Company).Id;         
                        }   else    {
                           // newAffiliate.Account__c = defaultAccount.Id;  
                        }
                    }
                    */
                    newAffiliate.Account__c = defaultAccount.Id;                    
                    createAffiliateSet.add(newAffiliate);              
            }
            
       }
       else
       {
           System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - affiliatelist is ************' + affiliatelist.Size()); 
           for(Affiliate__c affiliate : affiliatelist )
            {
               //  existingAffiliatesMap.put(affiliate.Affiliate_Name__c.toUpperCase(), affiliate );
                 existingAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
            }
            
            System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - existingAffiliatesMap '+ existingAffiliatesMap.Size()); 
            
            for(InstallerData installer: listInstallerData)
            {
                if(!existingAffiliatesMap.containsKey(installer.Parent_Installation_Company))
                {
                    Affiliate__c newAffiliate = new Affiliate__c();
                    newAffiliate.Affiliate_Name__c = installer.Parent_Installation_Company;
                    newAffiliate.Affiliate_Type__c = 'Vendor Installer'; 
                    newAffiliate.Affiliate_Status__c = 'Active';                    
                   
                   System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - installer.Parent_Installation_Company '+ installer.Parent_Installation_Company); 
                   /*
                    if(!VZ_Util.IsNullOrEmpty(ExistingAccountsMap)) {
                        if(ExistingAccountsMap.containsKey(installer.Parent_Installation_Company))
                        {                   
                            newAffiliate.Account__c = ExistingAccountsMap.Get(installer.Parent_Installation_Company).Id;         
                        }   else    {
                           // newAffiliate.Account__c = defaultAccount.Id;  
                        }
                    } */
                    newAffiliate.Account__c = defaultAccount.Id;  
                    createAffiliateSet.add(newAffiliate);
                }
                
            }           
       }
        
          
            
        try    {
            List<Affiliate__c> listNewAffiliates = new List<Affiliate__c>(createAffiliateSet);
            System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - listNewAffiliates Size ************' +listNewAffiliates.Size()); 
            insert listNewAffiliates;
        }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - listNewAffiliates Error ************' + e.getMessage()); 
        }
       
        affiliatelist =  [SELECT id, Affiliate_Name__c,Affiliate_Type__c,Affiliate_Status__c FROM Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueAffiliateNames];
        AffiliateMap = new Map<Id, Affiliate__c>(affiliatelist);
        System.Debug(Logginglevel.ERROR,'getInstallersWithAffiliateIdList - affiliatelist Size ************' +affiliatelist.Size()); 
        existingAffiliatesMap.clear();
        for(Affiliate__c affiliate : affiliatelist )
        {
             existingAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
        }
                
        for(InstallerData installer: listInstallerData)
        {
            installer.AffiliateID = existingAffiliatesMap.get(installer.Parent_Installation_Company).Id;
        }
        
        return listInstallerData;
    }
    private List<InstallerData> getInstallersWithSecondaryAffiliateIdList(List<InstallerData> listInstallerData){
        System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList - Enter' + listInstallerData.Size());        
        Set<string> uniqueSecondaryAffiliateNames = getUniqueSecondaryAffiliateNames(listInstallerData);
        affiliatelist = new List<Affiliate__c>();
        affiliatelist =  [SELECT id, Affiliate_Name__c,Affiliate_Type__c,Affiliate_Status__c FROM Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueSecondaryAffiliateNames];
        List<Affiliate__c> createAffiliateList = new List<Affiliate__c>();
        List<Affiliate__c> updateAffiliateList = new List<Affiliate__c>();
        Map<string, Affiliate__c> existingAffiliatesMap = new Map<string, Affiliate__c>();
        System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList - affiliatelist is  ************' + affiliatelist.Size() ); 
        if(VZ_Util.IsNullOrEmpty(affiliatelist))
        {
         System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList - affiliatelist is NULL ************'); 
         
         for(InstallerData installer: listInstallerData)
            {
                if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company))
                {
                    Affiliate__c newAffiliate = new Affiliate__c();
                    newAffiliate.Affiliate_Name__c = installer.Child_Subcontracted_Company;
                    newAffiliate.Affiliate_Type__c = 'Vendor Installer';  
                    newAffiliate.Affiliate_Status__c = 'Active';                                
                    createAffiliateList.add(newAffiliate);
                    
                    System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList -installer.Child_Subcontracted_Company' + installer.Child_Subcontracted_Company); 
                    
                }
                
            }
            
       }
       else
       {
            System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList - affiliatelist is not null and size ************' + affiliatelist.Size()); 
            for(Affiliate__c affiliate : affiliatelist )
            {
                 existingAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
            }
            
            for(InstallerData installer: listInstallerData)
            {
                if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company) && !existingAffiliatesMap.containsKey(installer.Child_Subcontracted_Company))
                {
                    Affiliate__c newAffiliate = new Affiliate__c();
                    newAffiliate.Affiliate_Name__c = installer.Child_Subcontracted_Company ;
                    newAffiliate.Affiliate_Type__c = 'Vendor Installer';  
                    newAffiliate.Affiliate_Status__c = 'Active';               
                    createAffiliateList.add(newAffiliate);
                }
                else if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company) && existingAffiliatesMap.containsKey(installer.Child_Subcontracted_Company))
                {
                    Affiliate__c newAffiliate = existingAffiliatesMap.get(installer.Child_Subcontracted_Company);
                    newAffiliate.Affiliate_Name__c = installer.Child_Subcontracted_Company ;
                    newAffiliate.Affiliate_Type__c = 'Vendor Installer';  
                    newAffiliate.Affiliate_Status__c = 'Active';               
                    updateAffiliateList.add(newAffiliate);
                }
            }
        }
        System.Debug(Logginglevel.ERROR,'getInstallersWithSecondaryAffiliateIdList - createAffiliateList is ************' + createAffiliateList.Size()); 
        try    {
            if(!VZ_Util.IsNullOrEmpty(createAffiliateList))
            {
                insert createAffiliateList;
            }
        }     catch (Exception e){
        }
        
        try    {
            if(!VZ_Util.IsNullOrEmpty(updateAffiliateList))
            {
                update updateAffiliateList;
            }
        }     catch (Exception e){
        }
        affiliatelist.Clear();      
        affiliatelist =  [SELECT id, Affiliate_Name__c,Affiliate_Type__c,Affiliate_Status__c From Affiliate__c WHERE Affiliate_Type__c = 'Vendor Installer' AND Affiliate_Name__c in:uniqueSecondaryAffiliateNames ];
        SecondaryAffiliateMap = new Map<Id, Affiliate__c>(affiliatelist);
        
        existingAffiliatesMap.clear();
        if(!VZ_Util.IsNullOrEmpty(affiliatelist))   {
            for(Affiliate__c affiliate : affiliatelist )
            {
                 existingAffiliatesMap.put(affiliate.Affiliate_Name__c, affiliate );
            }
                    
            for(InstallerData installer: listInstallerData)
            {   
                if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company))   {
                    installer.SecondaryAffiliateID = existingAffiliatesMap.get(installer.Child_Subcontracted_Company).Id;
                }
            }
        }
        return listInstallerData;
    }
    
    //populate Account ID or default Account ID for Contacts - Arvi
    private List<InstallerData> populateInstallersWithAccountIdList(List<InstallerData> listInstallerData){
        System.Debug(Logginglevel.ERROR,'getInstallersWithAccountIdList - Enter' + listInstallerData.Size()); 
        Account defAccount  = defaultAccount;
        Set<string> uniqueAffiliateNames = getALLUniqueAffiliateNames(listInstallerData);               
        
        ExistingAccountslist = new List<Account>();
        ExistingAccountslist =  [SELECT id, Name FROM Account WHERE  Name in:uniqueAffiliateNames];
        Map<string, Account> existingAccountsMap = new Map<string, Account>();
       
      
         System.Debug(Logginglevel.ERROR,'generateAffiliateFromAccounts - ExistingAccountslist Size ************' +ExistingAccountslist.Size()); 
                
        
        for(Account acc : ExistingAccountslist )
        {
            existingAccountsMap.put(acc.Name.toUpperCase(), acc );
        }
                
        for(InstallerData installer: listInstallerData)
        {  
        // remove account association and assign it to defaultAccount   
        /* if(!VZ_Util.IsNullOrEmpty(installer.Child_Subcontracted_Company))   {
                if(existingAccountsMap.containsKey(installer.Child_Subcontracted_Company))  {       
                    installer.AccountId = existingAccountsMap.get(installer.Child_Subcontracted_Company).Id;
                }
                else    {
                    installer.AccountId = defAccount.Id;
                }
            }
            else    {
            
                if(existingAccountsMap.containsKey(installer.Parent_Installation_Company))  {       
                    installer.AccountId = existingAccountsMap.get(installer.Parent_Installation_Company).Id;
                }
                else    {
                    installer.AccountId = defAccount.Id;
                }
            
            } */
            installer.AccountId = defAccount.Id;
        }
        System.Debug(Logginglevel.ERROR,'getInstallersWithAccountIdList -Exiting  ************'); 
        return listInstallerData;
    }
    
    private List<InstallerData> populateInstallersWithContactIds(List<InstallerData> listInstallerData){
        
        Set<string> uniqueContactIdentifier = getUniqueContactNames(listInstallerData);     
        List<Contact> contactlist =  [SELECT id, FirstName,LastName, Name,Contact_Duplicate_Identifier__c, Email FROM Contact WHERE Contact_Type__c = 'Installer' AND Contact_Duplicate_Identifier__c in: uniqueContactIdentifier LIMIT 5000];       
        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIds - uniqueContactIdentifier size  ************' + uniqueContactIdentifier.Size());          
        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIds - contactlist after size  ************' + contactlist.Size()); 
          
        
        Map<string, Contact> existingContactMap = new Map<string, Contact>();
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactlist);
         
        existingContactMap.clear();
        for(Contact contact : contactlist )
        { 
             existingContactMap.put(contact.Contact_Duplicate_Identifier__c, contact );
        }
        //System.Debug(Logginglevel.ERROR,'getInstallersWithContactIds - listInstallerData Size************' + listInstallerData.Size() + existingContactMap.Values() );        
        
     
        for(InstallerData installer: listInstallerData)
        {
            if(!VZ_Util.IsNullOrEmpty(installer.ContactDuplicateIdentifier) && existingContactMap.ContainsKey(installer.ContactDuplicateIdentifier))
            {
                Contact c = existingContactMap.get(installer.ContactDuplicateIdentifier);
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIds - existingContactMap.get(installer.ContactDuplicateIdentifier).Id ************' + c.Id);    
                installer.ContactID = c.Id;
            }
            else
            {
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIds - existingContactMap.get( else condition ************' + installer.ContactDuplicateIdentifier);    
            }
        }
        
        return listInstallerData;
    }
    
    @TestVisible 
    private List<InstallerData> getInstallersWithContactIdList(List<InstallerData> listInstallerData){
        
        
        Account defAccount  = defaultAccount;
         
        Set<string> uniqueContactIdentifier = getUniqueContactNames(listInstallerData);     
        List<Contact> contactlist =  [SELECT id, FirstName,LastName, Name,Contact_Duplicate_Identifier__c, Email FROM Contact WHERE Contact_Duplicate_Identifier__c in: uniqueContactIdentifier];       
        
        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - defaultAccountis not ************' + defaultAccount.ID); 
        List<Contact> createContactList = new List<Contact>();
        List<Contact> updateContactList = new List<Contact>();
        Map<string, Contact> existingContactMap = new Map<string, Contact>();
        
        if(VZ_Util.IsNullOrEmpty(contactlist))
        {
             System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contactlist is NULL ************'); 
             
             for(InstallerData installer: listInstallerData)
                {
                    if(!VZ_Util.IsNullOrEmpty(installer.ContactDuplicateIdentifier))
                    {
                        if(!VZ_Util.IsNullOrEmpty(AffiliateMap) && !VZ_Util.IsNullOrEmpty(AffiliateMap.get(installer.AffiliateID).Id))  {
                            Contact newContact = new Contact();
                            newContact.FirstName = installer.Firstname;
                            newContact.LastName = installer.LastName;
                            newContact.Email = installer.EmailAddress;
                            newContact.Contact_Type__c = 'Installer';
                            newContact.Certificate_Status__c = 'Current';

                            newContact.Installer_Status__c = 'Active';
                            newContact.AccountID = installer.AccountID; 
                            
                             
                            newContact.Phone =  installer.QPhone_Number; 
                            newContact.MailingStreet =  installer.QAddress;  
                            newContact.MailingCity = installer.QCity;  
                            newContact.MailingState = installer.QState;  
                            newContact.MailingPostalCode = installer.QZip_Code;                     
                            newContact.MailingCountry = 'USA';
                    
                            newContact.Affiliate_ID__c = AffiliateMap.get(installer.AffiliateID).Id;                              
                            if(!VZ_Util.IsNullOrEmpty(installer.SecondaryAffiliateID))
                            {
                                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - installer.SecondaryAffiliateID  ************' + installer.SecondaryAffiliateID); 
                                newContact.Secondary_Affiliate_ID__c = SecondaryAffiliateMap.get(installer.SecondaryAffiliateID).Id;                          
                            }
                            createContactList.add(newContact);
                        }
                    }
                    
                }
            
       }
       else
       {
            try    {
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contactlist is in else condition contactlist size  ************' + contactlist.Size()); 
            for(Contact contact : contactlist )
            {
                 existingContactMap.put(contact.Contact_Duplicate_Identifier__c, contact );
                  System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - existingContactMap -  ************' + contact.Contact_Duplicate_Identifier__c); 
                  
            }
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - listInstallerData is in else condition listInstallerData size  ************' + listInstallerData.Size()); 
            for(InstallerData installer: listInstallerData)
            {
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contactlist is in else condition installer.ContactDuplicateIdentifier  ************' + installer.ContactDuplicateIdentifier); 
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contactlist is in else condition AffiliateMap.get(installer.AffiliateID).Id  ************' + AffiliateMap.get(installer.AffiliateID).Id); 
                if(!existingContactMap.containsKey(installer.ContactDuplicateIdentifier) && !VZ_Util.IsNullOrEmpty(AffiliateMap.get(installer.AffiliateID).Id))
                {
                    Contact newContact = new Contact();
                    newContact.FirstName = installer.Firstname;
                    newContact.LastName = installer.LastName;
                    newContact.Email = installer.EmailAddress;
                    newContact.Contact_Type__c = 'Installer';
                    newContact.AccountID = installer.AccountID; 
                    newContact.Certificate_Status__c = 'Current';

                    newContact.Installer_Status__c = 'Active';
                    
                    newContact.Phone =  installer.QPhone_Number; 
                    newContact.MailingStreet =  installer.QAddress;  
                    newContact.MailingCity = installer.QCity;  
                    newContact.MailingState = installer.QState;  
                    newContact.MailingPostalCode = installer.QZip_Code;                     
                    newContact.MailingCountry = 'USA';
                    
                    newContact.Affiliate_ID__c = AffiliateMap.get(installer.AffiliateID).Id;                          
                    if(!VZ_Util.IsNullOrEmpty(installer.SecondaryAffiliateID))
                    {
                        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - installer.SecondaryAffiliateID  ************' + installer.SecondaryAffiliateID); 
                        newContact.Secondary_Affiliate_ID__c = SecondaryAffiliateMap.get(installer.SecondaryAffiliateID).Id;                          
                    }
                    createContactList.add(newContact);
                }
                else if(existingContactMap.containsKey(installer.ContactDuplicateIdentifier) && !VZ_Util.IsNullOrEmpty(AffiliateMap.get(installer.AffiliateID).Id))
                {
                    Contact newContact = existingContactMap.get(installer.ContactDuplicateIdentifier);
                    newContact.FirstName = installer.Firstname;
                    newContact.LastName = installer.LastName;
                    newContact.Email = installer.EmailAddress;
                    newContact.Contact_Type__c = 'Installer';
                    newContact.AccountID = installer.AccountID; 
                    newContact.Certificate_Status__c = 'Current';

                    newContact.Installer_Status__c = 'Active';
                    
                    newContact.Phone =  installer.QPhone_Number; 
                    newContact.MailingStreet =  installer.QAddress;  
                    newContact.MailingCity = installer.QCity;  
                    newContact.MailingState = installer.QState;  
                    newContact.MailingPostalCode = installer.QZip_Code;                     
                    newContact.MailingCountry = 'USA';
                    
                    newContact.Affiliate_ID__c = AffiliateMap.get(installer.AffiliateID).Id;                          
                    if(!VZ_Util.IsNullOrEmpty(installer.SecondaryAffiliateID))
                    {
                        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - installer.SecondaryAffiliateID  ************' + installer.SecondaryAffiliateID); 
                        newContact.Secondary_Affiliate_ID__c = SecondaryAffiliateMap.get(installer.SecondaryAffiliateID).Id;                          
                    }
                    updateContactList.add(newContact);
                }
                
            }
             }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - else Error ************' + e.getMessage()); 
        }
        }
        try    {
             System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - createContactList size  ************' + createContactList.Size()); 
            if(createContactList.Size() > 0)
            {
                insert createContactList;
            }
        }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - createContactList Error ************' + e.getMessage()); 
        }
        
        try    {
             System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - updateContactList size  ************' + updateContactList.Size()); 
            if(updateContactList.Size() > 0)
            {
                update updateContactList;
            }
        }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - updateContactList Error ************' + e.getMessage()); 
        }
        contactlist.Clear();
        uniqueContactIdentifier.Clear();
        uniqueContactIdentifier = getUniqueContactNames(listInstallerData);  
         
        contactlist =  [SELECT id, FirstName,LastName, Name,Contact_Duplicate_Identifier__c, Email FROM Contact WHERE Contact_Duplicate_Identifier__c in: uniqueContactIdentifier];  
        Map<Id, Contact> contactMap = new Map<Id, Contact>(contactlist);
         System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contactlist after size  ************' + contactlist.Size()); 
           
        existingContactMap.clear();
        for(Contact contact : contactlist )
        { System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - contact.Contact_Duplicate_Identifier__c************' + contact.Contact_Duplicate_Identifier__c +  contact.Name);     
             existingContactMap.put(contact.Contact_Duplicate_Identifier__c, contact );
        }
        System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - listInstallerData Size************' + listInstallerData.Size() + existingContactMap.Values() );        
        
        for (string id : existingContactMap.keySet())
        {
            System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - existingContactMap.loop ************' + ID);    
            System.debug(id);
            System.debug(existingContactMap.get(id));
        }

        for(InstallerData installer: listInstallerData)
        {
            if(!VZ_Util.IsNullOrEmpty(installer.ContactDuplicateIdentifier) && existingContactMap.ContainsKey(installer.ContactDuplicateIdentifier))
            {
                Contact c = existingContactMap.get(installer.ContactDuplicateIdentifier);
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - existingContactMap.get(installer.ContactDuplicateIdentifier).Id ************' + c.Id);    
                installer.ContactID = c.Id;
            }
            else
            {
                System.Debug(Logginglevel.ERROR,'getInstallersWithContactIdList - existingContactMap.get( else condition ************' + installer.ContactDuplicateIdentifier);    
            }
        }
        
        return listInstallerData;
        
    }
     private void InsertInstallerCertificatelist(List<InstallerData> listInstallerData){
       
        List<Installer_Certificate__c> listInstallerCertificateToInsert = new List<Installer_Certificate__c>();
        Set<string> uniqueContacts = new Set<String>();
        for(InstallerData installer: listInstallerData)
        {
            uniqueContacts.add(installer.ContactID);
        
        }
        
        List<Contact> ContactList =  [SELECT id, Name FROM Contact WHERE Id in:uniqueContacts ];
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(ContactList);
                
        for(InstallerData installer: listInstallerData)
        {
            Installer_Certificate__c newInstallerCertificate = new Installer_Certificate__c();
            newInstallerCertificate.Installer_Contact__c = contactsMap.get(installer.ContactID).Id;
            newInstallerCertificate.Exam_Name__c = installer.Exam_Name;
            newInstallerCertificate.Exam_Date__c = VZ_Util.setStringToDateFormat(installer.Exam_Date);            
            newInstallerCertificate.Exam_Id__c = installer.Exam_ID;
            newInstallerCertificate.Certificate_Level__c = installer.Exam_ID == '464' ? 'Basic' : '';                        
            newInstallerCertificate.User_ID__c = installer.User_ID;                                     
            newInstallerCertificate.Certified_Date__c = date.today();
            newInstallerCertificate.Exam_Result__c = 'Pass';

            listInstallerCertificateToInsert.add(newInstallerCertificate);
        }
        
        try    {
           
                insert listInstallerCertificateToInsert;
           
        }     catch (Exception e){
            System.Debug(Logginglevel.ERROR,'InsertInstallerCertificatelist - createCertificates Error ************' + e.getMessage()); 
        }
    }

   }