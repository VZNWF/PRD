/*
*   Author              : Siva Adapa
*   Class Name          : TaskAgeUpdateBatchClass 
*   Description         : To populate the Task age on the existing Leads, Tasks
*   Test Class Name     : TaskAgeUpdateBatchClassTest
*   Created Date        : 21-Dec-2016
*
*   Modification log:
*   Author      |       Jira/User Story     | Comments
*   
*
*
*   ****Invocation method****
*   ID batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass(**LeadSource**, **Update/Reset**, **Where Condition**));
*
*   Eg: //ID batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass('Lead Gen Partner', 'Update', ' and id=\'XXXXXXXXXX\''));
*   Eg: //ID batchprocessid = Database.executeBatch(new TaskAgeUpdateBatchClass('Lead Gen Partner', 'Reset', ''));
*/

global class TaskAgeUpdateBatchClass implements Database.Batchable<sObject>{

    global final String query;
    global final String operation;
    global final String ls;
    global final String wh;

    global static List<Task_Age_Config__mdt> taskAgeMtdLst;
    global static Map<String, TaskAgeMetadataWrapper> leadSrcConfigMtdMap;

    global TaskAgeUpdateBatchClass(String ls, String o, String w){
        //initialisation method
        init();
        operation = o;
        wh = w;
        //populate query string
        TaskAgeMetadataWrapper tmpWrapperObj = leadSrcConfigMtdMap.get(ls);
            
        String validSubj = '';
            
        for(String s: tmpWrapperObj.subjPreliminaryMileStones){
            validSubj +='\''+s+'\',';
        }
        for(String s: tmpWrapperObj.subjFinalMileStones){
            validSubj +='\''+s+'\',';
        }
            
        validSubj = validSubj.removeEnd(',');
        query = 'Select Id, Name, CreatedDate, LeadSource, Specific_Lead_Source__c, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id, createddate, Previous_Task_ID__c, Previous_Activity_Timestamp__c, Activity_Age__c, Activity_Age_in_days__c, Subject from Tasks where subject IN ('+validSubj +') order by createddate ASC) from Lead where isConverted=false and LeadSource=\''+ls+'\' '+w;

        system.debug(query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> scope){
        if(operation == 'Update'){
            init();
            
            List<Lead> leadsToBeUpdated = new List<Lead>();
            List<Task> tasksToBeUpdated = new List<Task>();
            system.debug(leadSrcConfigMtdMap);
            system.debug(scope);
            for(Lead l: scope){
                //get the metadata configuration for the lead source
                TaskAgeMetadataWrapper tmpWrapperObj = leadSrcConfigMtdMap.get(l.LeadSource);
                Integer noOfAtt = 0;
                //**** Eg1: for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = this.CreatedDate
                //**** Eg2: for 'Lead' object => fromTimeStamp = CreatedDate and toTimeStamp = S2L_Connected_Timestamp__c
                DateTime prevTimeStamp = l.CreatedDate;
                Id PreTaskId = null;
                if(tmpWrapperObj!=null){
                    for(Task t: l.tasks){
                        if(tmpWrapperObj.subjPreliminaryMileStones.contains(t.Subject)){
                            Task tTmp = new Task();
                            tTmp = t;
                            tTmp.Previous_Activity_Timestamp__c = prevTimeStamp;
                            tTmp.Previous_Task_Id__c = preTaskId;
                                    
                            tTmp.Activity_Age__c = Decimal.valueOf(VZ_Util.calculateAge(tTmp.Previous_Activity_Timestamp__c, tTmp.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes'));
                            tTmp.Activity_Age_in_days__c = VZ_Util.calculateAge(tTmp.Previous_Activity_Timestamp__c, tTmp.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
                            
                            tasksToBeUpdated.add(tTmp);
                            if(l.S2L_First_Attempt_Timestamp__c == null){
                                l.Age_to_First_Attempt__c = tTmp.Activity_Age__c;
                                l.Age_to_First_Attempt_in_days__c = tTmp.Activity_Age_in_days__c;
                                l.S2L_First_Attempt_Timestamp__c = t.CreatedDate;
                            }
                            noOfAtt++;
                            prevTimeStamp = t.CreatedDate;
                            preTaskId = t.Id;
                        }else if(tmpWrapperObj.subjFinalMileStones.contains(t.Subject)){
                            Task tTmp = new Task();
                            tTmp = t;
                            tTmp.Previous_Activity_Timestamp__c = prevTimeStamp;
                            tTmp.Previous_Task_Id__c = preTaskId;
                            tTmp.Activity_Age__c = Decimal.valueOf(VZ_Util.calculateAge(tTmp.Previous_Activity_Timestamp__c, tTmp.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes'));
                            tTmp.Activity_Age_in_days__c = VZ_Util.calculateAge(tTmp.Previous_Activity_Timestamp__c, tTmp.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
                            
                            tasksToBeUpdated.add(tTmp);
    
                            if(l.S2L_First_Attempt_Timestamp__c == null){
                                l.Age_to_First_Attempt__c = tTmp.Activity_Age__c;
                                l.Age_to_First_Attempt_in_days__c = tTmp.Activity_Age_in_days__c;
                                l.S2L_First_Attempt_Timestamp__c = t.CreatedDate;
                            }
                            l.S2L_Connected_Timestamp__c = t.CreatedDate;
                            l.Age_to_Connect__c = Decimal.valueOf(VZ_Util.calculateAge(l.CreatedDate, l.S2L_Connected_Timestamp__c, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes'));
                            l.Age_to_Connect_in_days__c = VZ_Util.calculateAge(l.CreatedDate, l.S2L_Connected_Timestamp__c, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
                            
                            noOfAtt++;
                            prevTimeStamp = t.CreatedDate;
                            preTaskId = t.Id;
                            break;
                        }
                    }
                    l.Number_of_Attempts__c = noOfAtt;
                    leadsToBeUpdated.add(l);
                }
            }
            
            if(tasksToBeUpdated.size()>0){
                Database.SaveResult[] srList = Database.update(tasksToBeUpdated,false);
                sendEmailNotifications(srList); 
            }
            if(leadsToBeUpdated.size()>0){
                Database.SaveResult[] srList = Database.update(leadsToBeUpdated,false);
                sendEmailNotifications(srList); 
            }
            
        }else if(operation == 'Reset'){
            List<Lead> leadsToBeUpdated = new List<Lead>();
            List<Task> tasksToBeUpdated = new List<Task>();
        
            for(Lead l: scope){
                
                l.Age_to_Connect__c = null;
                l.Age_to_First_Attempt__c = null;
                l.Age_to_Connect_in_days__c = null;
                l.Age_to_First_Attempt_in_days__c = null;
                l.S2L_First_Attempt_Timestamp__c = null;
                l.S2L_Connected_Timestamp__c = null;
                l.Number_of_Attempts__c = 0;
                
                for(Task t: l.tasks){
                    t.previous_activity_timestamp__c = null;
                    t.Activity_Age_in_days__c = null;
                    t.Activity_Age__c = null;
                    t.Previous_Task_Id__c = null;
                    tasksToBeUpdated.add(t);
                }
                leadsToBeUpdated.add(l);
            }
            
            if(tasksToBeUpdated.size()>0){
                Database.SaveResult[] srList = Database.update(tasksToBeUpdated,false);
                sendEmailNotifications(srList);             
            }
            if(leadsToBeUpdated.size()>0){
                Database.SaveResult[] srList = Database.update(leadsToBeUpdated,false);
                sendEmailNotifications(srList);
            }
            
        }
    }

    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage sm = new Messaging.SingleEmailMessage();
        sm.setSubject('TaskAgeUpdateBatchClass Batch Update');
        sm.setToAddresses(new String[]{Userinfo.getUserEmail()});
        String body = 'The batch job has been successfully completed <br/><br/> Query executed: '+query;
        sm.setHtmlBody(body);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sm});
        } catch(Exception e){}
    }
    
    private static void sendEmailNotifications(List<Database.SaveResult> srList){
        // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful
                        System.debug('Successfully Updated');
                    }
                    else {
                        String body;
                        // Operation failed, so get all errors and send email              
                        for(Database.Error err : sr.getErrors()) {
                            body+='The following error has occurred.  ';                    
                            body+=err.getStatusCode() + ': ' + err.getMessage();
                            body+='<br/><br/>Fields that affected this error: ' + err.getFields()+'<br\\>';
                        }
                        Messaging.SingleEmailMessage sm = new Messaging.SingleEmailMessage();
                        sm.setSubject('TaskAgeUpdateBatchClass Error Notification');
                        sm.setToAddresses(new String[]{Userinfo.getUserEmail()});
                        sm.setHtmlBody(body);
                        try{
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sm});
                        }catch(Exception e){}
                    }
                }
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
            
            //Populate the Map2 - Lead Source and all its corresponding valid subjects as Key, Value
            String subjPMS = tac.Preliminary_Milestones__c;
            String subjFMS = tac.Final_Milestones__c;
            
            if(subjPMS != null){
                wrapperObj.subjPreliminaryMileStones.addAll(trimStrList(subjPMS.split(',')));
            }
            if(subjFMS != null){
                wrapperObj.subjFinalMileStones.addAll(trimStrList(subjFMS.split(',')));
            }
        
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
    //Method to trim the string elements in the list
    //////
    private static List<String> trimStrList(List<String> inputList){
        List<String> outputList = new List<String>();
        for(String s:inputList){
            outputList.add(s.trim());
        }
        return outputList;
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
        
        private Set<String> subjPreliminaryMileStones = new Set<String>();
        private Set<String> subjFinalMileStones = new Set<String>();
    }
}