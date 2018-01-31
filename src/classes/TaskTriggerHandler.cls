/*
*   Author              : Siva Adapa
*   Class Name          : TaskTriggerHandler 
*   Description         : Handler class of 'Task' Trigger
*   Test Class Name     : TaskTriggerHandlerTest 
*   Created Date        : 30-Nov-2016
*
*   Modification log:
*   Author      |       Jira/User Story     | Comments
*   
*
*/

public without sharing class TaskTriggerHandler {
    
    //Variables accessible across the events
	public static List<Lead> leadLst = new List<Lead>();
	public static List<Task_Age_Config__mdt> taskAgeMtdLst;
	public static Map<String, TaskAgeMetadataWrapper> leadSrcConfigMtdMap;
    public static Map<String, Set<String>> leadSrcTaskSubMap;
	public static Set<String> allSubjSet = new Set<String>();

    //////
    ////BEFORE INSERT HELPER METHOD
    //////
    public static void handleBeforeInsert(List<Task> newTaskList){

        //Initialisation method
    	init();
    	
        //To get the Keyprefix of the Lead object
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String leadKeyPrefix = r.getKeyPrefix();
        Set<Id> leadIdSet = new Set<Id>();
        Boolean errorFlag = false;
        String errorMsg;
        
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        
        for(Task t: newTaskList){
            if((t.whoId != null && String.valueOf(t.whoId).substring(0,3) == leadKeyPrefix) && (allSubjSet!=null && allSubjSet.Contains(t.Subject))){
                leadIdSet.add(t.whoId);
                
                if(leadTaskMap.containsKey(t.whoId)){
                	errorFlag = true;
                    errorMsg = 'Error: Attempt to create a duplicate task. Please check.';
                }else{
                    leadTaskMap.put(t.whoId, t);
                }
            }
        }
        
        if(!leadIdSet.isEmpty()){
        	
            leadLst = [Select Id, Name, CreatedDate, LeadSource, Specific_Lead_Source__c, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id, createddate from Tasks where subject IN :allSubjSet and Previous_Activity_Timestamp__c!=null order by createddate DESC LIMIT 1) from Lead where Id IN:leadIdSet AND LeadSource IN :leadSrcTaskSubMap.keySet()];
        	system.debug(leadLst);
            for(Lead l: leadLst){
                if(leadTaskMap.containsKey(l.Id)){
                	if(errorFlag){
                		Trigger.new[0].addError(errorMsg);
                	}else if(l.S2L_Connected_Timestamp__c!=null){
                		Trigger.new[0].addError('Error:  Attempt to create duplicate task on the lead which was already connected.  Please check.');
                	}else{
	                    Task t = new Task();
	                    t = leadTaskMap.get(l.Id);
	                    if(leadSrcTaskSubMap.get(l.LeadSource).contains(t.subject)){  //Validate and update details only if the subject is relevant to the lead source (to avoid subject references across metadata records)
		                    t.Previous_Task_ID__c = l.tasks.size()>0?l.tasks[0].Id:null;
		                    t.Previous_Activity_Timestamp__c = l.tasks.size()>0?l.tasks[0].createddate:l.CreatedDate;
	                    }
                	}
                }
            }
        }
    }

    //////
    ////AFTER INSERT HELPER METHOD
    //////
    public static void handleAfterInsert(List<Task> newTaskList){
    	List<Task> taskToUpdLst = new List<Task>();
    	List<Lead> leadtoUpdLst = new List<Lead>();
    	
    	if(leadLst.size()>0){   //if there are any valid records from before insert event.
    		Map<Id, Lead> leadMap = new Map<Id, Lead>(leadLst);
    		
	    	for(Task t: newTaskList){
	    		if(t.Previous_Activity_Timestamp__c!=null){
	    			Lead tmpL = new Lead();
	                tmpL = leadMap.get(t.whoId);
	                
	                //get the metadata configuration for the lead source
	                TaskAgeMetadataWrapper tmpWrapperObj = leadSrcConfigMtdMap.get(tmpL.LeadSource);
	                
	                //Calculate Age on Task
	                Task tempT = new Task();
	    			tempT.Id = t.Id;
	    			//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	    			String ageTD = VZ_Util.calculateAge(t.Previous_Activity_Timestamp__c, t.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes');
	    			tempT.Activity_Age__c = Decimal.valueOf(ageTD);
	    			//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	    			tempT.Activity_Age_in_days__c = VZ_Util.calculateAge(t.Previous_Activity_Timestamp__c, t.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
	                taskToUpdLst.add(tempT);
              
	                if(tmpWrapperObj.subjPreliminaryMileStones.contains(t.Subject)){
	                	if(leadMap.get(t.whoId).Number_of_Attempts__c == 0 || leadMap.get(t.whoId).Number_of_Attempts__c == null){
	                		tmpL.Number_of_Attempts__c = 1;
	                		tmpL.S2L_First_Attempt_Timestamp__c = t.CreatedDate;
	                		tmpL.Age_to_First_Attempt__c = tempT.Activity_Age__c; //in minutes
	                		tmpL.Age_to_First_Attempt_in_days__c = tempT.Activity_Age_in_days__c; //in days
	                	}else{
	                		tmpL.Number_of_Attempts__c = leadMap.get(t.whoId).Number_of_Attempts__c+1;
	                	}
	                }else if(tmpWrapperObj.subjFinalMileStones.contains(t.Subject)){
	                	tmpL.S2L_Connected_Timestamp__c = t.CreatedDate;
	                	//for 'Lead' object => fromTimeStamp = CreatedDate and toTimeStamp = S2L_Connected_Timestamp__c
	                	String ageD =  VZ_Util.calculateAge(tmpL.CreatedDate, tmpL.S2L_Connected_Timestamp__c, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes');
	                	tmpL.Age_to_Connect__c = Decimal.valueOf(ageD);
	                	//for 'Lead' object => fromTimeStamp = CreatedDate and toTimeStamp = S2L_Connected_Timestamp__c
						tmpL.Age_to_Connect_in_days__c = VZ_Util.calculateAge(tmpL.CreatedDate, tmpL.S2L_Connected_Timestamp__c, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
						
	                	tmpL.S2L_First_Attempt_Timestamp__c = tmpL.S2L_First_Attempt_Timestamp__c == null?t.createdDate:tmpL.S2L_First_Attempt_Timestamp__c;  //if the first attempt timestamp is blank, assign timestamp to connect
	                	//If the Age to First Attempt is blank, assign the age to connect
	                	tmpL.Age_to_First_Attempt__c = tmpL.Age_to_First_Attempt__c == null?tmpL.Age_to_Connect__c:tmpL.Age_to_First_Attempt__c;
						tmpL.Age_to_First_Attempt_in_days__c = tmpL.Age_to_First_Attempt_in_days__c == null?tmpL.Age_to_Connect_in_days__c:tmpL.Age_to_First_Attempt_in_days__c;
						
						//Update the no. of attempts:  if the attempts# is null, it should be 0 if the default value set at the lead field level does not work (as it was found sometimes)
						Decimal noAtt = leadMap.get(t.whoId).Number_of_Attempts__c;
						tmpL.Number_of_Attempts__c = noAtt == null?1:noAtt+1;
	                }
	                leadtoUpdLst.add(tmpL);
	    		}
	    	}
    	
	    	if(taskToUpdLst.size()>0){
	    		update taskToUpdLst;
	    		update leadtoUpdLst;
	    	}
    	}
    }
    
    //////
    ////BEFORE UPDATE HELPER METHOD
    //////    
    public static void handleBeforeUpdate(List<Task> newUpdateList, Map <Id, Task> newUpdateMap, List<Task> oldUpdateList, Map<Id, Task> oldUpdateMap){
 	   	
    	//Initialisation method
    	init();
    	
    	//To get the Keyprefix of the Lead object
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String leadKeyPrefix = r.getKeyPrefix();
        Set<Id> leadIdSet = new Set<Id>();
		
		//Validate if the WhoId of all the incoming tasks are Leads, instead of Contacts
        for(Task t: newUpdateList){
            if(t.whoId != null && String.valueOf(t.whoId).substring(0,3) == leadKeyPrefix){
                leadIdSet.add(t.whoId);
            }
        }
        
        //Query the Lead and associated task details with valid subject and lead source eligible for age caliculation
        leadLst = [Select Id, Name, CreatedDate, LeadSource, Specific_Lead_Source__c, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id, Previous_Task_ID__c, createddate, whoId from Tasks) from Lead where Id IN: leadIdSet and LeadSource IN :leadSrcTaskSubMap.keySet()];
        
        Map<Id, String> leadLeadSourceMap = new Map<Id, String>();
        for(lead l: leadLst){
        	if(l.tasks.size()>0){
        		leadLeadSourceMap.put(l.Id, l.LeadSource);
        	}
        }
        
        for(Task t: newUpdateList){
        	if(leadLeadSourceMap.containsKey(t.whoId)){
        		Set<String> vSubjSet = new Set<String>();
        		
        		vSubjSet = leadSrcTaskSubMap.get(leadLeadSourceMap.get(t.whoId));
        		
        		Boolean isPreviousValidSubject = vSubjSet.Contains(oldUpdateMap.get(t.id).subject);
        		Boolean isNewValidSubject = vSubjSet.Contains(newUpdateMap.get(t.id).subject);
        		
        		if(oldUpdateMap.get(t.id).subject <> newUpdateMap.get(t.id).subject && (isPreviousValidSubject || isNewValidSubject)){
        			t.addError('Error: Invalid Operation - Attempt to change the task Subject from / to '+vSubjSet);
        		}
       		}
        }
    
    }
    
    //////
    ////BEFORE DELETE HELPER METHOD
    //////
    public static void handleBeforeDelete(List<Task> delTaskList){
    	//Initialisation method
    	init();
    	
    	//To get the Keyprefix of the Lead object
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String leadKeyPrefix = r.getKeyPrefix();
        Set<Id> leadIdSet = new Set<Id>();

        for(Task t: delTaskList){
            if(t.whoId != null && String.valueOf(t.whoId).substring(0,3) == leadKeyPrefix && (allSubjSet!=null && allSubjSet.Contains(t.Subject))){
                leadIdSet.add(t.whoId);
        	}
        }
        
        //Query the Lead, and all tasks which are of specific lead source and valid tasks
        leadLst = [Select Id, Name, CreatedDate, LeadSource, Specific_Lead_Source__c, Age_to_Connect__c,  Age_to_First_Attempt__c, Age_to_Connect_in_days__c,  Age_to_First_Attempt_in_days__c, S2L_First_Attempt_Timestamp__c, S2L_Connected_Timestamp__c, Number_of_Attempts__c, (Select Id, Previous_Task_ID__c, createddate, whoId, Subject from Tasks where subject IN :allSubjSet and Previous_Activity_Timestamp__c!=null) from Lead where Id IN: leadIdSet and LeadSource IN :leadSrcTaskSubMap.keySet()];
        
        //Local variables        
        Map<Id, Task> keyIsPreviousTaskOfValMap = new Map<Id, Task>();
        Map<Id, Task> keyIsNextTaskOfValMap = new Map<Id, Task>();
        Map<Id, Id> taskLeadMap = new Map<Id, Id>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>(leadLst);
        List<Task> taskFilteredLst = new List<Task>();
        List<Lead> leadsToBeUpdated = new List<Lead>();
        List<Task> tasksToBeUpdated = new List<Task>();
        
        //A list to populate all the tasks (To-be-deleted tasks + sibling tasks) related to the eligible lead
        for(lead l: leadLst){
        	for(task t:l.tasks){
        		Set<String> vLeadSources = leadSrcTaskSubMap.get(l.LeadSource);
        		if(vLeadSources!=null && vLeadSources.contains(t.Subject)){  //Validate if only the tasks with valid subjects of a lead source are included in filtered list (to avoid incorrect subject references across metadata records)
        			taskFilteredLst.add(t);
        		}
        	}
        }
        
        //Populate the maps
        for(Task tmpT: taskFilteredLst){
        	if(tmpT.Previous_Task_ID__c!=null){
        		keyIsPreviousTaskOfValMap.put(tmpT.Previous_Task_ID__c, tmpT);
        	}
        	keyIsNextTaskOfValMap.put(tmpT.Id, tmpT);
        	taskLeadMap.put(tmpT.Id, tmpT.whoId);
        }
        
        system.debug(delTaskList);
        system.debug(keyIsPreviousTaskOfValMap);
        system.debug(keyIsNextTaskOfValMap);
        system.debug(taskLeadMap);
        
        for(Task t: delTaskList){
        	if(keyIsNextTaskOfValMap.containsKey(t.Id)){  //Filter only allows the eligible lead source leads into it for further execution
        		
        		//get the metadata configuration for the lead source
        		String leadsrc = leadMap.get(t.whoId).LeadSource;
	            TaskAgeMetadataWrapper tmpWrapperObj = leadSrcConfigMtdMap.get(leadsrc);
	            				
        		if(keyIsPreviousTaskOfValMap.containsKey(t.Id)){  //when the non-latest tasks are deleted.
        			
        			Task tmpT = keyIsPreviousTaskOfValMap.get(t.Id);
        			Lead tmpL = new Lead();
        			
        			//if this is not a first task
        			if(keyIsNextTaskOfValMap.containsKey(t.Previous_Task_ID__c)){
        				tmpT.Previous_Task_ID__c = keyIsNextTaskOfValMap.get(t.Previous_Task_ID__c).Id;  //Update the Previous task in the following task
	        			tmpT.Previous_Activity_Timestamp__c = keyIsNextTaskOfValMap.get(t.Previous_Task_ID__c).CreatedDate; //Update the previous timestamp in the following task
	        			//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	        			String ageTD =  VZ_Util.calculateAge(tmpT.Previous_Activity_Timestamp__c, tmpT.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes');
	    				tmpT.Activity_Age__c = Decimal.valueOf(ageTD);
	    				//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	    				tmpT.Activity_Age_in_days__c = VZ_Util.calculateAge(tmpT.Previous_Activity_Timestamp__c, tmpT.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
        			}
        			else{  //if is a first task
        				tmpT.Previous_Task_ID__c = t.Previous_Task_ID__c;   //if the first task is deleted, Previous_Task_Id would always be null
	        			tmpT.Previous_Activity_Timestamp__c = t.Previous_Activity_Timestamp__c;  //the first task previous activity timestamp is always lead creation date
	        			//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	        			String ageTD =  VZ_Util.calculateAge(tmpT.Previous_Activity_Timestamp__c, tmpT.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Minutes');
	    				tmpT.Activity_Age__c = Decimal.valueOf(ageTD);
	    				//for 'Task' object => fromTimeStamp = Previous_Activity_Timestamp__c and toTimeStamp = CreatedDate
	        			tmpT.Activity_Age_in_days__c = VZ_Util.calculateAge(tmpT.Previous_Activity_Timestamp__c, tmpT.CreatedDate, tmpWrapperObj.workDaysPerWeek, tmpWrapperObj.workHoursPerDay, tmpWrapperObj.startTime, tmpWrapperObj.endTime, 'Days');
	        			//Update details on Lead
	        			tmpL.Age_to_First_Attempt__c = tmpT.Activity_Age__c;
	        			tmpL.Age_to_First_Attempt_in_days__c = tmpT.Activity_Age_in_days__c;
	        			tmpL.S2L_First_Attempt_Timestamp__c = tmpT.CreatedDate;
	        		}
        			
        			tasksToBeUpdated.add(tmpT);
        			
					tmpL.Id = taskLeadMap.get(t.Id);
        			Integer noOfAtt = (Integer)leadMap.get(tmpL.Id).Number_Of_Attempts__c;
        			tmpL.Number_Of_Attempts__c = (noOfAtt!=null || noOfAtt!=0 )? noOfAtt-1:0;
        			leadsToBeUpdated.add(tmpL);
        		}else{  //When the latest task is deleted or if there is only a single task
        			Lead tmpL = new Lead();
        			tmpL.Id = taskLeadMap.get(t.Id);
        			
        			if(!keyIsNextTaskOfValMap.containsKey(t.Previous_Task_ID__c)){  //if the first task is deleted 
        				tmpL.Age_to_First_Attempt__c = null;   //then reset Age to First attempt
        				tmpL.Age_to_First_Attempt_in_Days__c = null;
        				tmpL.S2L_First_Attempt_Timestamp__c = null; //then reset First attempt timestamp
        			}
        			Integer noOfAtt = (Integer)leadMap.get(tmpL.Id).Number_Of_Attempts__c;
        			tmpL.Number_Of_Attempts__c = noOfAtt!=0? noOfAtt-1:0;
        			
        			//if the final milestone subject is deleted
        			if(tmpWrapperObj.subjFinalMileStones.contains(t.Subject)){
        				tmpL.S2L_Connected_Timestamp__c = null;
        				tmpL.Age_to_Connect__c = null;
        				tmpL.Age_to_Connect_in_days__c = null;
        			}
        			leadsToBeUpdated.add(tmpL);
        		}
        	}
        }
        
        if(tasksToBeUpdated.size()>0){
        	//Update the next tasks with new age and previous activity information
        	update tasksToBeUpdated;
        }
        if(leadsToBeUpdated.size()>0){
        	//Update Lead corresponding to the task
        	update leadsToBeUpdated;
        }
        
    }
    
    //ADDIOTIONAL HELPER METHODS
    //////
    //Initialisation Method
    //////
    private static void init(){
    	//Query the Task Age Config parameters
    	taskAgeMtdLst = new List<Task_Age_Config__mdt>();
        //Map1
        leadSrcConfigMtdMap = new Map<String, TaskAgeMetadataWrapper>();
        //Map2
        leadSrcTaskSubMap = new Map<String, Set<String>>();
        //Query the methods
        taskAgeMtdLst=[Select DeveloperName, MasterLabel, IsActive__c, Preliminary_Milestones__c, Final_Milestones__c, Start_Time__c, End_Time__c, Work_Days_per_Week__c, Work_Hours_per_Day__c from Task_Age_Config__mdt where isActive__c=True];
        allSubjSet = new Set<String>();
        for(Task_Age_Config__mdt tac: taskAgeMtdLst){
        	
        	//Populate the Wrapper class
        	TaskAgeMetadataWrapper wrapperObj = new TaskAgeMetadataWrapper();
        	wrapperObj.LeadSource = tac.MasterLabel;
        	wrapperObj.workDaysPerWeek = tac.Work_Days_per_Week__c!=null?Integer.valueOf(tac.Work_Days_per_Week__c):0;
        	wrapperObj.workHoursPerDay = tac.Work_Hours_per_Day__c!=null?Integer.valueOf(tac.Work_Hours_per_Day__c):0;
        	
			wrapperObj.startTime = tac.Start_Time__c!=null?calHoursToDecimal(tac.Start_Time__c):0;
            wrapperObj.endTime = tac.End_Time__c!=null?calHoursToDecimal(tac.End_Time__c):0;
        	
	       	//Populate the Map2 - Lead Source and all its corresponding valid subjects as Key, Value
        	String subjPMS = tac.Preliminary_Milestones__c;
        	String subjFMS = tac.Final_Milestones__c;
        	set<string> subjSet = new set<string>();
        	
        	if(subjPMS != null){
        		wrapperObj.subjPreliminaryMileStones.addAll(trimStrList(subjPMS.split(',')));
        		subjSet.addAll(wrapperObj.subjPreliminaryMileStones);
        	}
        	if(subjFMS != null){
        		wrapperObj.subjFinalMileStones.addAll(trimStrList(subjFMS.split(',')));
        		subjSet.addAll(wrapperObj.subjFinalMileStones);
        	}
        	
        	leadSrcTaskSubMap.put(tac.MasterLabel, subjSet);
        	//As .values() map method returns the list of sets, which is invalid to be provided in a filter condition of SOQL query.  Hence populating the list of valid subjects for all lead sources
        	allSubjSet.addAll(subjSet);
      	
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