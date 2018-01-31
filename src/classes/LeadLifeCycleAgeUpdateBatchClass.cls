/*
*   Author              : Siva Adapa
*   Class Name          : LeadLifeCycleAgeUpdateBatchClass 
*   Description         : To populate the age on the existing Opportunities with details from Leads
*   Test Class Name     : LeadLifeCycleAgeUpdateBatchClassTest
*   Created Date        : 17-Jan-2017
*
*   Modification log:
*   Author      |       Jira/User Story     | Comments
*   
*
*
*   ****Invocation method****
*   ID batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass(**LeadSource**, **Update/Reset**, **Where Condition**));
*
*   Eg: //ID batchprocessid = Database.executeBatch(new LeadLifeCycleAgeUpdateBatchClass('Lead Gen Partner', 'Update', ' and id=\'XXXXXXXXXX\''));
*   Eg: //ID batchprocessid = Database.executeBatch(new LeadLifeCycleAgeUpdateBatchClass('Lead Gen Partner', 'Reset', ''));
*/


global with sharing class LeadLifeCycleAgeUpdateBatchClass implements Database.Batchable<sObject> {
    
    global final string query;
    global final String op;
    global final String ls;
    global final String wh; 

    global static List<Task_Age_Config__mdt> taskAgeMtdLst;
    global static Map<String, TaskAgeMetadataWrapper> leadSrcConfigMtdMap;
    
    global LeadLifeCycleAgeUpdateBatchClass(String leadsource, String operation, String whereCondition){
        ls=leadsource;
        op=operation;
        wh=whereCondition;
        
        init();

        //populate query string
        TaskAgeMetadataWrapper tmpWrapperObj = leadSrcConfigMtdMap.get(ls);
        
        query = 'Select Id, Name, isClosed, StageName, SQL_in_minutes__c, Lead_Created_Date__c, SQL__c, Actual_Sales_Closed_Timestamp__c, SRL_in_minutes__c, SRL__c, SOL_in_minutes__c, SOL__c, MQL_in_minutes__c, MQL__c, SAL_in_minutes__c, SAL__c, Sales_Accepted_Timestamp__c, Market_Qualified_Timestamp__c, Sales_Qualified_Timestamp__c, Is_Created_From_Lead__c, CreatedDate  from Opportunity where leadsource = \''+ls+'\' '+wh;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        //call initilisation method
        init();
        
        List<Opportunity> opptyListToBeUpdated = new List<Opportunity>();
        
        if(op == 'Reset'){
            for(Opportunity opp: scope){
                if(opp.Is_Created_From_Lead__c){
                    Opportunity tmpOpp = new Opportunity();
                    tmpOpp.Id = opp.Id;
                    tmpOpp.Is_Created_From_Lead__c = false;
                    tmpOpp.SQL_in_minutes__c = null;
                    tmpOpp.SQL__c = null;
                    tmpOpp.SRL_in_minutes__c = null;
                    tmpOpp.SRL__c = null;
                    tmpOpp.SOL_in_minutes__c = null;
                    tmpOpp.SOL__c = null;
                    tmpOpp.MQL_in_minutes__c = null;
                    tmpOpp.MQL__c = null;
                    tmpOpp.SAL_in_minutes__c = null;
                    tmpOpp.SAL__c = null;
                    tmpOpp.Sales_Accepted_Timestamp__c = null;
                    tmpOpp.Market_Qualified_Timestamp__c = null;
                    tmpOpp.Sales_Qualified_Timestamp__c = null;
                    tmpOpp.Lead_Created_Date__c = null;
                    tmpOpp.Actual_Sales_Closed_Timestamp__c = null;
                    opptyListToBeUpdated.add(tmpOpp);
                }
            }
        }else if(op == 'Update'){
            Set<Id> oppIdSet = new Set<Id>();
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>();
            for(Opportunity opp: scope){
                oppIdSet.add(opp.Id);
                opptyMap.put(opp.Id, opp);
            }
            
            List<Lead> convOpptyLeads = new List<Lead>();
            convOpptyLeads = [Select Id, Name, convertedOpportunityId, Create_Date_and_Time__c, LastModifiedDate, CreatedDate, Specific_Lead_Source__c, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c from Lead where isConverted=true and LeadSource =:ls and ConvertedOpportunityId IN :oppIdSet];
            
            TaskAgeMetadataWrapper tmpMtd = new TaskAgeMetadataWrapper();
            system.debug(leadSrcConfigMtdMap);
            tmpMtd = leadSrcConfigMtdMap.get(ls);
            Integer workHoursPerDay = tmpMtd.workHoursPerDay;
            Integer workDaysPerWeek = tmpMtd.workDaysPerWeek;
            Decimal startTime = tmpMtd.startTime;
            Decimal endTime = tmpMtd.endTime;
            
            List<OpportunityFieldHistory> opptyStageHistory = [Select Id, Field, OpportunityId, NewValue, OldValue, CreatedDate from OpportunityFieldHistory Where OpportunityId IN :oppIdSet Order by CreatedDate ASC];
            Map<Id, DateTime> oppHistoryClosedDateMap = new Map<Id, DateTime>();
            for(OpportunityFieldHistory ofh: opptyStageHistory){
                if(ofh.NewValue == 'Closed Won' || ofh.NewValue == 'Closed Lost'){
                    oppHistoryClosedDateMap.put(ofh.OpportunityId, ofh.CreatedDate);
                }
            }
            
            for(Lead tmpL: convOpptyLeads){
                Opportunity opp = new Opportunity();
                opp.Id = tmpL.convertedOpportunityId;
                opp.SAL_in_minutes__c = tmpL.Age_to_Connect__c;
                opp.SAL__c = tmpl.Age_to_Connect_in_days__c;
                opp.MQL_in_minutes__c = tmpL.Age_to_First_Attempt__c;
                opp.MQL__c = tmpl.Age_to_First_Attempt_in_days__c;
                opp.Market_Qualified_Timestamp__c = tmpL.S2L_First_Attempt_Timestamp__c;
                opp.Sales_Accepted_Timestamp__c = tmpL.S2L_Connected_Timestamp__c;
                opp.Lead_Created_Date__c = tmpL.Create_Date_and_Time__c;
                opp.Is_Created_From_Lead__c = true;
                opp.Sales_Qualified_Timestamp__c = opptyMap.get(opp.Id).CreatedDate;
                
                //Get the opportunity closed date time from history object
                Datetime closedDateTime = oppHistoryClosedDateMap.containsKey(opp.Id)?oppHistoryClosedDateMap.get(opp.Id): null;
                
                //Determine the fromTimeStamp while calculating the SQL.
                DateTime fromTimeStampSQL = tmpL.S2L_Connected_Timestamp__c <> null?tmpL.S2L_Connected_Timestamp__c: tmpL.CreatedDate;
                
                opp.SQL__c = VZ_Util.calculateAge(fromTimeStampSQL, tmpL.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                opp.SQL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(fromTimeStampSQL, tmpL.LastModifiedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                
                //Update closed timestamp and the SRL, SOL only if the current opportunty stage is closed
                if(closedDateTime!=null && opptyMap.get(opp.Id).isClosed){
                    opp.Actual_Sales_Closed_Timestamp__c = closedDateTime;
                    opp.SRL__c = VZ_Util.calculateAge(opp.Sales_Qualified_Timestamp__c, opp.Actual_Sales_Closed_Timestamp__c, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                    opp.SRL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(opp.Sales_Qualified_Timestamp__c, opp.Actual_Sales_Closed_Timestamp__c, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                    opp.SOL__c = VZ_Util.calculateAge(opp.Lead_Created_Date__c, opp.Actual_Sales_Closed_Timestamp__c, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                    opp.SOL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(opp.Lead_Created_Date__c, opp.Actual_Sales_Closed_Timestamp__c, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                }
                opptyListToBeUpdated.add(opp);
            }
        }
        if(opptyListToBeUpdated.size()>0){
            Database.SaveResult[] srList = Database.update(opptyListToBeUpdated,false);
            sendEmailNotifications(srList); 
        }
    }

    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage sm = new Messaging.SingleEmailMessage();
        sm.setSubject('LeadLifeCycleAgeUpdateBatchClass Batch Update');
        sm.setToAddresses(new String[]{Userinfo.getUserEmail()});
        String body = 'The batch job has been successfully completed <br/><br/> Query executed: '+query;
        sm.setHtmlBody(body);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sm});
        } catch(Exception e){}
    }
    
    private static void init(){
        //Query the Task Age Config parameters
        taskAgeMtdLst = new List<Task_Age_Config__mdt>();
        //Map1
        leadSrcConfigMtdMap = new Map<String, TaskAgeMetadataWrapper>();

        //Query the methods
        taskAgeMtdLst=[Select DeveloperName, MasterLabel, IsActive__c, Preliminary_Milestones__c, Final_Milestones__c, Start_Time__c, End_Time__c, Work_Days_per_Week__c, Work_Hours_per_Day__c from Task_Age_Config__mdt where isActive__c=True];

        for(Task_Age_Config__mdt tac: taskAgeMtdLst){
            
            //Populate the Wrapper class
            TaskAgeMetadataWrapper wrapperObj = new TaskAgeMetadataWrapper();
            wrapperObj.LeadSource = tac.MasterLabel;
            wrapperObj.workDaysPerWeek = tac.Work_Days_per_Week__c!=null?Integer.valueOf(tac.Work_Days_per_Week__c):0;
            wrapperObj.workHoursPerDay = tac.Work_Hours_per_Day__c!=null?Integer.valueOf(tac.Work_Hours_per_Day__c):0;
            
            wrapperObj.startTime = tac.Start_Time__c!=null?calHoursInDec(tac.Start_Time__c):0;
            wrapperObj.endTime = tac.End_Time__c!=null?calHoursInDec(tac.End_Time__c):0;
            
            //Populate the Map1 - LeadSource and the decoded wrapper class config paratmers as Key, Value
            leadSrcConfigMtdMap.put(tac.MasterLabel, wrapperObj);
        }
    }
    
    //////
    ////Method to Convert the custom text hours into the Decimal hours
    //////
    private static Decimal calHoursInDec(String input){
        List<String> inputArray = input.split(':');
            
        Integer inHr = inputArray[0].isNumeric()?Integer.valueOf(inputArray[0]):0;
        Decimal inMin = inputArray.size()>1?Decimal.valueOf(inputArray[1]):0;
            
        inHr = (inHr>=0 && inHr<24) ? inHr : 0;
        inMin = (inMin >=0 && inMin<60) ?(inMin/60):(inMin >=60)? 0 : 0;
        Decimal inTime = inHr + inMin.setScale(2, System.RoundingMode.HALF_UP);
        
        return inTime;
    }
    
    //////
    //Wrapper Class of Task_Age_Config__mdt
    //////
    private class TaskAgeMetadataWrapper{
        private String LeadSource;
        private Decimal startTime;
        private Decimal endTime;
        private Integer workDaysPerWeek;
        private Integer workHoursPerDay;

    }
    
    private static void sendEmailNotifications(List<Database.SaveResult> srList){
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful
                System.debug('Successfully Updated');
            }
            else{
                 String body;
            
                 for(Database.Error err : sr.getErrors()) {
                    body+='The following error has occurred.  ';                    
                    body+=err.getStatusCode() + ': ' + err.getMessage();
                    body+='<br/><br/>Fields that affected this error: ' + err.getFields()+'<br\\>';
                 }
                 Messaging.SingleEmailMessage sm = new Messaging.SingleEmailMessage();
                 sm.setSubject('LeadLifeCycleAgeUpdateBatchClass Error Notification');
                 sm.setToAddresses(new String[]{Userinfo.getUserEmail()});
                 sm.setHtmlBody(body);
                 try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sm});
                 }
                 catch(Exception e){}
            }
        }
    }
}