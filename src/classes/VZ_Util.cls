/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Aravind Rajamanickam
// File Name:       VZ_Util
// Summary:         Utility Helper class for supporting frequent operation
// Created On:      March-11-2015
// Company:         Verizon Networkfleet

// Modification Log:
====================

// Aravind    - 3/11/2015 - Create a base version of Util methods 

*******************************************************************************/

public class VZ_Util {
    public static boolean IsOLIDBulkImport = false;
    
    public static set<Id> ETAStagingIdSet{
        get{
            if(ETAStagingIdSet == null){
                ETAStagingIdSet = new Set<id>();
            }
            return ETAStagingIdSet;
        }
        set;
    }
    public static string StringToMD5Hash(string inputString)    {
        return EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(inputString)));
    }    
    public static string GetCurrentDateTimeInISO8601Format()    {    
        //return  json.serialize(datetime.now());
        return datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'-07:00\''); //working format hash generator - http://www.md5hashgenerator.com/ ISO Time - http://wwp.greenwichmeantime.com/info/iso.htm
//        return datetime.now().format('yyyy-MM-dd'); 
        //return datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    }    
    public static string GetAuthString(string password)    {   // md5(now+md5(password))        
        string authString = GetCurrentDateTimeInISO8601Format() + StringToMD5Hash(password);
        return StringToMD5Hash(authString);        
    }  
    public static string GetAuthString(string password, string ISODate)    {   // md5(now+md5(password))        
        string authString = ISODate + StringToMD5Hash(password);
        return StringToMD5Hash(authString);        
    }  
          
    public static boolean IsNullOrEmpty(string input){
        return (input == null)?true:((input == '')?true:false);
    }
    public static boolean IsNullOrEmpty(string input, boolean trimInput){
        return (input == null)?true:((input.trim() == '')?true:false);
    }
    public static String MakeNullEmpty(string input){
        return (input == null)?'':input;
    }   
    public static boolean IsNullOrEmpty(List<String> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(List<sObject> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(Map<string,sObject> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(Map<string,List<sObject>> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(Map<Integer,sObject> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(Map<Id,String> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    public static boolean IsNullOrEmpty(Map<Id,sObject> input){
        return (input == null)?true:((input.size() == 0)?true:false);
    }
    
    public static boolean IsValidEmail(String email) {
        
        // Regular Expression for email
        String emailRegex =  '^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$';
        
        Pattern MyPattern = Pattern.compile(emailRegex);
        
        // then instantiate a new Matcher object ?MyMatcher?
        Matcher MyMatcher = MyPattern.matcher(email);
        
        if (!MyMatcher.matches()) {
            return false;
        }
        else{
            return true;
        }
    }
    public static boolean IsValidNumber(String num, Integer length) {
        
        // Regular Expression for numeric
        String numRegex =  '^\\d{' + String.valueOf(length) + '}$';
        
        Pattern MyPattern = Pattern.compile(numRegex);
        
        // then instantiate a new Matcher object ?MyMatcher?
        Matcher MyMatcher = MyPattern.matcher(num);
        
        if (!MyMatcher.matches()) {
            return false;
        }
        else{
            return true;
        }
    }
    public static string ConvertNewLineToBreaks(string inText)
    {
       String retVal = '';
       if (inText != null){
          // retVal = inText.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
           retVal = inText.replaceAll('\n','<br/>');
       }
       System.debug('ConvertNL2Break: input=' + inText + '; output=' + retVal);
       return retVal;
    }
    public static string ConvertBreaksToNewLine(string inText)
    {
        String retVal = '';
        if (inText != null){
            retVal = inText.replaceAll('<br/>','\n');
            retVal = retVal.replaceAll('<br />','\n');
        }
        System.debug('ConvertBreak2NL: input=' + inText + '; output=' + retVal);
        return retVal;
    
    }
    public static Boolean IsListContains(List<string> listInput, String searchInput){
        Boolean containsVal = false;
        if(!IsNullOrEmpty(listInput)){
            for(String sip :listInput){
                if(sip == searchInput){
                    containsVal = true; 
                    break;
                }
            }
        }
        return containsVal;
    }
    public static Datetime ConvertToLocalTimezone(Datetime dt){
        return Datetime.valueof(string.valueOf(dt));
    }
    
    public static List<String> GetPicklistValues(String ObjectApi_name,String Field_name){ 
            List<String> lstPickvals=new List<String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                lstPickvals.add(a.getValue());//add the value  to our final list
            }
    
          return lstPickvals;
     }
     
     // --------------------------------------------------------
    //  parseDate; null is invalid Date; yyyy-mm-dd and locale-specific e.g. mm/dd/yyyy or dd/mm/yyyy formats supported
    //  --------------------------------------------------------
    public static Date parseDate(String inDate) {
        Date    dateRes     = null;
        //  1 - Try locale specific mm/dd/yyyy or dd/mm/yyyy    
        try {
            String candDate     = inDate.substring(0,Math.min(10,inDate.length()));// grab date portion only m[m]/d[d]/yyyy , ignore time
            dateRes     = Date.parse(candDate);
        }
        catch (Exception e) {}
    
        if (dateRes == null) {
        //  2 - Try yyyy-mm-dd          
            try {
                String candDate     = inDate.substring(0,10);           // grab date portion only, ignore time, if any
                dateRes             = Date.valueOf(candDate);
            }
            catch (Exception e) {} 
        }
        
        return dateRes;
    }

    public static Date setStringToDateFormat(String myDate) {
       String[] myDateOnly = myDate.split(' ');
       String[] strDate = myDateOnly[0].split('/');
       Integer myIntDate = integer.valueOf(strDate[1]);
       Integer myIntMonth = integer.valueOf(strDate[0]);
       Integer myIntYear = integer.valueOf(strDate[2]);
       Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
       return d;
    }

     public static list<list<String>> parseCSV(String contents,Boolean skipHeaders, boolean skip2) {
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
                System.debug('Limits exceeded?  '+e.getMessage());
            }
            integer num=0;
            for(string line :lines) {
            if(num == 0 && skip2)
            { num +=1; }
            else    {
            System.debug('lines count' + lines.Size());
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
            }
            if(skipHeaders && skip2) {
                
                allFields.remove(0);
            }
            if(skipHeaders && !skip2) {
                allFields.remove(0);
            }
            System.debug('allFields count after' + allFields.Size());
            return allFields;       
        }//END ParseCSV

    //Added by Siva Adapa - Begin
        //////
        //This method calculates the Age of two specific date fields defined for each sObjecttype, inMinutes is a boolean to switch
        //between the number and string format of the calculated age (displayed to user)
        //////
        public static String calculateAge(DateTime fromTimeStamp, DateTime toTimeStamp, Integer workDaysPerWeek, Integer workHoursPerDay, Decimal startTime, Decimal endTime, String returnFormat){
            
            //**** fromTimeStamp should always be less than toTimeStamp
            //**** Eg1: for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = this.CreatedDate
            //**** Eg2: for 'Lead' object => fromTimeStamp = CreatedDate and toTimeStamp = S2L_Connected_Timestamp__c
            
            //**** returnFormat => 'Minutes'(decimal) or 'Days'(dd hh mm) or 'Months'(MM DD HH)
            
            Datetime t1 = fromTimeStamp;
            Datetime t2 = toTimeStamp;
            String returnVal = null;
    
            if(t1!=null && t2!=null && t1<=t2 && (returnFormat!=null && returnFormat!='')){
                //Find the difference of the two dates from the pivot date
                Date pivotDate = t1.date().addMonths(-2).toStartofWeek().addDays(1);
                Datetime pivotDateTime = DateTime.newInstance(pivotDate, Time.newInstance(0,0,0,0));
                system.debug(pivotDateTime);
                system.debug(t1);
                system.debug(t2);
                double pAge1 = calculateWorkHours(pivotDateTime, t1, workDaysPerWeek, workHoursPerDay, startTime, endTime);
                double pAge2 = calculateWorkHours(pivotDateTime, t2, workDaysPerWeek, workHoursPerDay, starttime, endTime);
                
                Decimal ageInHrs = pAge2 - pAge1;
                system.debug('Difference ageInHrs: '+ageInHrs+'; pAge2= '+pAge2+', pAge1= '+pAge1);
                
                if(returnFormat == 'Days'){
                    //Returns age in days, hours and minutes => dd hh mm format
                    Decimal preMin = ageInHrs - (Integer)ageInHrs;
                    Integer minutes = Integer.valueOf((preMin*60).round(system.RoundingMode.half_UP));
                    //Rounding Off to the hour
                    if(minutes>59){
                        minutes = 0;
                        ageInHrs+=1;
                    }
                    
                    Integer hours = Math.mod(Integer.valueOf(ageInHrs), workHoursPerDay);
                    Integer days = Integer.valueOf(Math.floor(ageInHrs)/(workHoursPerDay));
                    
                    system.debug(days+'d '+hours+'h '+minutes+'m');
                    returnVal = days+'d '+hours+'h '+minutes+'m';
                }else if(returnFormat == 'Minutes'){
                    //Returns age in minutes
                    Decimal calcMins = ageInHrs*60;
                    returnVal = String.valueOf(calcMins.setScale(1, system.roundingmode.half_up));
                }else if(returnFormat == 'Months'){
                    //Returns age in months, days and hours => MM DD HH format
                    Date d1 = t1.date();
                    Date d2 = t2.date();
                    Integer months = d1.monthsBetween(d2);
                    
                    //Calculate the date-to-date month calculation, and the days, hours thereafter.
                    months = t1.addMonths(months) > t2? months - 1: months;
                    DateTime pivotT1 = t1.addMonths(months);
                    
                    pAge1 = calculateWorkHours(pivotDateTime, pivotT1, workDaysPerWeek, workHoursPerDay, startTime, endTime);
                    pAge2 = calculateWorkHours(pivotDateTime, t2, workDaysPerWeek, workHoursPerDay, starttime, endTime);
                    ageInHrs = pAge2 - pAge1;
                    system.debug('Difference ageInHrs in Months: '+ageInHrs+'; pAge2= '+pAge2+', pAge1= '+pAge1);
                    
                    Decimal preMin = ageInHrs - (Integer)ageInHrs;
                    Integer minutes = Integer.valueOf((preMin*60).round(system.RoundingMode.half_UP));
                    //Rounding Off to the hour
                    if(minutes>59){
                        minutes = 0;
                        ageInHrs+=1;
                    }
                    
                    Integer days = Integer.valueOf(Math.floor(ageInHrs)/(workHoursPerDay));
                    Integer hours = Math.mod(Integer.valueOf(ageInHrs), workHoursPerDay);
                    
                    returnVal = months+'M '+days+'d '+hours+'h';
                }
            }
            return returnVal;
        }

        //////
        //This method calculates the number of working hours between startDateTime and  endDateTime, based on the Work days per week and work hours per day
        //and returns the difference in hours
        //////
        private static double calculateWorkHours(DateTime startDateTime, DateTime endDateTime, Integer workDaysPerWeek, Integer workHoursPerDay, Decimal startTime, Decimal endTime){
            //Convert from DateTime to Date to calculate the days between these two dates
            Date cDate = endDateTime.date();
            Date pDate = startDateTime.date();
            system.debug('endDateTime: '+endDateTime+', startDateTime: '+startDateTime);
            system.debug('cDate: '+cDate+', pDate: '+pDate);
            
            //Get time
            Time cTime = endDateTime.time();
            Time pTime = startDateTime.time();
            Date tmpDate = System.Today();
            
            //Calculate weeks
            Integer w= (Integer)pDate.daysBetween(cDate)/7;
            //Calculate days
            Integer d= Math.mod(pDate.daysBetween(cDate),7);
            
            system.debug(DateTime.newInstance(tmpDate, cTime).getTime());
            system.debug(DateTime.newInstance(tmpDate, pTime).getTime());
            //Find the difference of time in milliseconds and calculate hours from milliseconds
            Double h = (DateTime.newInstance(tmpDate, cTime).getTime() - DateTime.newInstance(tmpDate, pTime).getTime())/(1000.0*60.0*60.0); 
    
            system.debug('workDaysPerWeek: '+workDaysPerWeek+', workHoursPerDay: '+workHoursPerDay);
            system.debug('startTime: '+startTime+', endTime: '+endTime);
            double hrs1 = workHoursPerDay*(workDaysPerWeek*w);
            double hrs2 = workHoursPerDay*(Math.min(workDaysPerWeek, Math.mod(d,7)));
            //calculate the difference in the time w.r.t. the startTime and endTime of the day, if 'hrs2' reaches the limit of work hours in a week, then skip the calculation (Weekend scenario)
            double hrs3 = hrs2 < workDaysPerWeek*workHoursPerDay? (h < startTime? ((endTime-startTime)-workHoursPerDay) : ((h < = endTime) ? (h-startTime): (endTime-startTime))):((endTime-startTime)-workHoursPerDay);
            double calcHrs = hrs1 + hrs2 + hrs3;
                
            system.debug(calcHrs);
    
            return calcHrs;
        }
    //Added by Siva Adapa - End        
    
}