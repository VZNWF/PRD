/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Sunil Kumar
// File Name:       VinLookupController 
// Summary:         Controller for dynamic VIN search page
// Created On:      03/15/2017

// Modification Log:
// removed hardware type - Rod Nazaire 12/1/2017
====================

*******************************************************************************/
global class VinLookupController {

    //variables    
    public string criteria {get; set;}
    public string accountNameToSearch {get; set;}
    public string VINNumber {get; set;}
    public Harness_Guide__c harObj {get; set;} 
    //Added 16th March
    public String harObjMake{get;set;}
    public String harObjModel{get;set;}
    public String harObjYearTo{get;set;}
    //public String hardwareType{get;set;}
    public String proAlign{get;set;}
    public List<Harness_Guide__c> hgList{get;set;}
    public Harness_Guide__c hGfs{get;set;}
    
    public String txtAccountName{get;set;}
    //Default Constructor
    public VinLookupController(ApexPages.StandardController controller){
        harObj = (Harness_Guide__c)controller.getRecord();
        System.Debug('Inside Constructor :'+harObj );
        hgList=new List<Harness_Guide__c>();
    }
    
    //To search for accounts
    public void performSearch(){
        ApexPages.getMessages().clear();
        try{        
            String SFDCQuery = getQuery();
            if(SFDCQuery != null){
                //querying salesforce accounts
                System.Debug('query here:'+SFDCQuery);
                hgList= Database.query(SFDCQuery);
                System.Debug('hgList Here:'+hgList +'List size:'+hgList.size());
                if(hgList.size()==0 || hgList==null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No Data found for the particular Search Criteria.'));
                }
            }else{
                throw new myCustomException('Invalid Search Parameters');
            }        
        }
        catch(myCustomException myCE){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid search parameters. Please correct and run search again.'));
        }
    }
    
    public List<SelectOption> getOptions(){
        List<SelectOption> options=new List<SelectOption>();
        Integer i;
        List<String> iList=new List<String>();
        Integer YearEnd = datetime.now().year() + 1;
        for(i=YearEnd;i>=1990;i--){
            iList.add(String.ValueOf(i));  
        }
            options.add(new SelectOption('--None--','--None--'));
        for(String s:iList){
             options.add(new SelectOption(s,s));
        }       
        System.Debug(options);
        return options;
    }
    
     public List<SelectOption> getProducts(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Harness_Guide__c.Product_Alignment__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;    
     }
    
     //Added for site Issue
   @RemoteAction
    global static List<Harness_Guide__c> getCompany() {
       
       List<Harness_Guide__c> hgList = DataBase.query('SELECT id,Company_Name__c from Harness_Guide__c '); 
       return hgList ;
    }
     //Added for site Issue
     
     public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Harness_Guide__c.FieldSets.Search.getFields();
    }
    
    public string getQuery(){
   
        System.Debug('Query Constructing Method Called'+harObjYearTo);
        String query='Select ';        
        
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        
        query += 'Id  FROM Harness_Guide__c where';
        
        System.Debug('Query before condition :'+query);
        String condition='';
       /** if(VINNumber !=null && VINNumber!=''){
            if(condition==null || condition==''){
                condition = ' VIN_Number__c= \'' + VINNumber + '\'';
            }
            else{
                condition += ' AND  VIN_Number__c= \'' + VINNumber + '\'';
            }
        }*/
        if(harObjMake  != null && harObjMake  !=''){
            if(condition==null || condition==''){
                condition = '  Make__c = \'' +harObjMake + '\'';
            }
            ELSE{
                condition += ' AND Make__c = \'' +harObjMake + '\'';
            }
        }
        
        if(harObjModel != null && harObjModel  !=''){
            if(condition==null || condition==''){
                condition = '  Model__c = \'' +harObjModel + '\'';
            }
            else{
                condition += ' AND  Model__c = \'' +harObjModel + '\'';
            }
        }
        
        if(harObjYearTo  != null && harObjYearTo !='' && harObjYearTo != '--None--'){
            if(condition==null || condition==''){
                System.Debug('Indside 1');
                condition = ' Year_To__c >= \'' + harObjYearTo + '\' and Year_From__c <= \'' +harObjYearTo + '\'';
            }
            else{
                System.Debug('Indside 2');
                condition += ' AND  Year_To__c >= \'' + harObjYearTo + '\' and Year_From__c <= \'' +harObjYearTo + '\'';
            }
        }
        
      /*   if(hardwareType  != '--None--'){
            if(condition==null || condition==''){
                condition = '';
                 '  Hardware_Type__c = \'' +hardwareType + '\'';  rod 11/30/17
           }
            else{
                condition += '';
                 ' AND  Hardware_Type__c = \'' +hardwareType + '\''; rod 11/30/17 
            }
         }
        */
        
        
        if(accountNameToSearch !=null && accountNameToSearch !='' ){
            if(condition==null || condition==''){
                condition = '   Company_Name__c =\'' +accountNameToSearch + '\'';  
            }
            else{
                condition += ' AND Company_Name__c =\'' +accountNameToSearch + '\'';
            } 
        }
        
        if(proAlign!=null && proAlign!='' &&  proAlign!='--None--'){
             if(condition==null || condition==''){
                condition = '  Product_Alignment__c = \'' +proAlign+ '\'';
            }
            else{
                condition += ' AND  Product_Alignment__c = \'' +proAlign+ '\'';
            }
        
        }
        
        if( accountNameToSearch !=null && accountNameToSearch !='' && VINNumber!=null && VINNumber !='' ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please provide value either for VIN or Company'));
            query=null;
        }
        else if(condition !=null && condition !=''){
            query=query+condition;
        }
        else if(condition ==null || condition ==''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please enter Search Criteria to filter corresponding data'));
            query=null;    
        }
        System.Debug('Condition formed :'+query +'value ::'+txtAccountName);
        return query;
       
    }
    
    public List<SelectOption> getHardwareValues(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Harness_Guide__c.Hardware_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('--None--','--None--'));
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }    
    
    
    global void getVINDataMethod(){
        If(VINNumber != ''){
        VinWSClass.getVINData(VINNumber);
        if(VinWSClass.checkVal==true){
        System.Debug('Val Now:'+VinWSClass.checkVal);
            harObjMake = VinWSClass.vinMap.get('make');
            harObjModel = VinWSClass.vinMap.get('model');
            harObjYearTo = VinWSClass.vinMap.get('year');
        }
        else{
            harObjMake = '';
            harObjModel = '';
            harObjYearTo = '';

        }
      }
    }
    
    //creating my own custom exception to throw
    public class myCustomException extends Exception {}
}