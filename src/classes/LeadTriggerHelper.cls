public with sharing class LeadTriggerHelper {

    //Member variables - Added by Siva - Begin
    private static List<Task_Age_Config__mdt> taskAgeMtdLst;
    private static Map<String, TaskAgeMetadataWrapper> leadSrcConfigMtdMap;
    //Member variables - Added by Siva - End

    public static void updateSCCSubChannel(List<Lead> leads){
        Id callCenterProfileId;
        List<User> IdsQueried  =  [SELECT ProfileId FROM User WHERE Profile.Name = 'Sales Call Center User'];
        if(IdsQueried.size() >0){
            callCenterProfileId = IdsQueried[0].ProfileId;

            Set<Id> matchingOwners = new Set<Id>(); 
            List<Id> allOwners = new List<Id>();

            for (Lead lead : leads) {
               allOwners.add(lead.OwnerId);
            }   

            //query owners 
            List<User> owners = new List<User>([SELECT ProfileId, UserRole.Name FROM User WHERE id IN: allOwners]);            
            if(owners.size() > 0){
                for (User owner : owners){
                    if((!String.isBlank(owner.ProfileId) && owner.ProfileId == callCenterProfileId) && (!String.isBlank(owner.UserRole.Name) && owner.UserRole.Name.equals('Concentrix Sales Rep') ) ){
                        matchingOwners.add(owner.Id);
                    }
                }
            }

            for (Lead lead : leads){
                if (matchingOwners.contains(lead.OwnerId)){
                    lead.SCC_Sub_Channel__c = true;
                }
                else {
                    lead.SCC_Sub_Channel__c = false;
                }                    
            }
        }//no callcenterprofileId found
        else {
            //throw excepution??
        }
    }
  //Code changes by Siva Adapa - End
    //A method checks if the lead is cloned from existing lead records and resets the Age fields, timestamps on the cloned record.
    public static void resetS2LBeforeInsert(List<Lead> newLeads){
        for(Lead l: newLeads){
            if(l.isClone()){
                l.Age_to_Connect__c = null;
                l.Age_to_First_Attempt__c = null;
                l.Age_to_Connect_in_days__c = null;
                l.Age_to_First_Attempt_in_days__c = null;
                l.S2L_First_Attempt_Timestamp__c = null;
                l.S2L_Connected_Timestamp__c = null;
                l.Number_of_Attempts__c = 0;
            }
        }
    }

    //A method to update the values on lead and corresponding opportunity upon conversion.
    public static void updateOpportunityOnConversion(List<Lead> newList, Map<Id, Lead> newMap, List<Lead> oldList, Map<Id, Lead> oldMap, String triggerEvent){
        
        //initialisation method call
        init();
        
        Map<Id, Lead> oppLeadMap = new Map<Id, Lead>();
                
        for(Lead l: newList){
            if((l.LeadSource!=null && leadSrcConfigMtdMap.containsKey(l.LeadSource)) && l.isConverted && l.ConvertedOpportunityId!=null && !oldMap.get(l.Id).isConverted){
                oppLeadMap.put(l.ConvertedOpportunityId, l);
            }
        }
        
        if(!oppLeadMap.isEmpty()){
            List<Opportunity> convOpportunityList = [Select Id, LeadSource, Name, Is_Created_From_Lead__c, CreatedDate from Opportunity where Id IN:oppLeadMap.keySet()];
            List<Opportunity> updateOpptyList;
            
            if(triggerEvent == 'BeforeUpdate'){
                for(Opportunity o: convOpportunityList){
                    //Read the values from Map
                    TaskAgeMetadataWrapper tmpMtd = new TaskAgeMetadataWrapper();
                    tmpMtd = leadSrcConfigMtdMap.get(o.LeadSource);
                    Integer workHoursPerDay = tmpMtd.workHoursPerDay;
                    Integer workDaysPerWeek = tmpMtd.workDaysPerWeek;
                    Decimal startTime = tmpMtd.startTime;
                    Decimal endTime = tmpMtd.endTime;
                    //Update the values on lead upon conversion (before update)
                    Lead tmpL = oppLeadMap.get(o.Id);
                    //Determine the fromTimeStamp while calculating the SQL.
                    DateTime fromTimeStampSQL = tmpL.S2L_Connected_Timestamp__c <> null?tmpL.S2L_Connected_Timestamp__c: tmpL.CreatedDate;

                    tmpL.SQL_in_minutes__c = Decimal.valueOf(VZ_Util.calculateAge(fromTimeStampSQL, o.CreatedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Minutes'));
                    tmpL.SQL__c = VZ_Util.calculateAge(fromTimeStampSQL, o.CreatedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Days');
                    tmpL.Sales_Qualified_Timestamp__c = o.CreatedDate;
                }
            }else if(triggerEvent == 'AfterUpdate'){
                updateOpptyList = new List<Opportunity>();
                for(Opportunity o: convOpportunityList){
                    if(!o.Is_Created_From_Lead__c){
                        
                        //Read the values from Map
                        TaskAgeMetadataWrapper tmpMtd = new TaskAgeMetadataWrapper();
                        tmpMtd = leadSrcConfigMtdMap.get(o.LeadSource);
                        Integer workHoursPerDay = tmpMtd.workHoursPerDay;
                        Integer workDaysPerWeek = tmpMtd.workDaysPerWeek;
                        Decimal startTime = tmpMtd.startTime;
                        Decimal endTime = tmpMtd.endTime;
                        
                        Lead tmpL = oppLeadMap.get(o.Id);
                        //Update the new opportunity with the values from the corresponding converted lead
                        Opportunity tmpOpp = new Opportunity();
                        tmpOpp.Id = o.Id;
                        tmpOpp.Is_Created_From_Lead__c = true;
                        tmpOpp.Sales_Qualified_Timestamp__c = tmpL.Sales_Qualified_Timestamp__c;
                        tmpOpp.Lead_Created_Date__c = tmpL.CreatedDate;
                        tmpOpp.SQL_in_minutes__c = tmpL.SQL_in_minutes__c;
                        //Determine the fromTimeStamp while calculating the SQL.
                        DateTime fromTimeStampSQL = tmpL.S2L_Connected_Timestamp__c <> null?tmpL.S2L_Connected_Timestamp__c: tmpL.CreatedDate;
                        tmpOpp.SQL__c = VZ_Util.calculateAge(fromTimeStampSQL, o.CreatedDate, workDaysPerWeek, workHoursPerDay, startTime, endTime, 'Months');
                        updateOpptyList.add(tmpOpp);
                    }
                }
            
                if(updateOpptyList.size()>0){
                    update updateOpptyList;
                }
            }
        }
    }
    
    //////
    //Initialisation Method
    //////
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
                    
            wrapperObj.startTime = tac.Start_Time__c!=null?calHoursToDecimal(tac.Start_Time__c):0;
            wrapperObj.endTime = tac.End_Time__c!=null?calHoursToDecimal(tac.End_Time__c):0;
    
            //Populate the Map1 - LeadSource and the decoded wrapper class config paratmers as Key, Value
            leadSrcConfigMtdMap.put(tac.MasterLabel, wrapperObj);
                    
        }
    }
        
    //////
    ////Method to Convert the custom text hours into the Decimal hours
    //////
    private static Decimal calHoursToDecimal(String input){
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
   //Code changes by Siva Adapa - End
}