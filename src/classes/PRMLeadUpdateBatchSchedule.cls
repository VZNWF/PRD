/****************************************************************
Created: 18 Mar 2014
Author: Krishna Tatta (CodeScience)
Purpose : Schedule class to run PRMLeadUpdateBatch class
To schedule, execute anonymous the following: 
	PRMLeadUpdateBatchSchedule cls1 = new PRMLeadUpdateBatchSchedule();
	String sch1 = '0 0 * * * ?'; // run at the start of every hour
	System.schedule('Verizon Lead Import', sch1, cls1);

Modifications:
******************************************************************/
global class PRMLeadUpdateBatchSchedule implements Schedulable {
	private boolean isTestRunning = false;
	global List<Id> updatedLeadIds = new List<Id>();
	global List<Id> updatedOppIds = new List<Id>();
	
	public PRMLeadUpdateBatchSchedule(List<Id> leadIds, List<Id> oppIds){ 
		this(leadIds, oppIds, false);
	}
	
	public PRMLeadUpdateBatchSchedule(List<Id> leadIds, List<Id> oppIds, boolean isTest) {
		isTestRunning = isTest;
		if(leadIds != null) {
			updatedLeadIds.addAll(leadIds);
		}
		if(oppIds != null) {
			updatedOppIds.addAll(oppIds);
		}
	}
	
	global void execute(SchedulableContext sc) {
	   	PRMLeadUpdateBatch batch = new PRMLeadUpdateBatch(updatedLeadIds, updatedOppIds,isTestRunning);
	   	system.debug('are lead ids null in schedulable? : ' + updatedLeadIds == null);
	   	system.debug('are opp ids null in schedulable?: ' + updatedOppIds == null);
	   	Id batchId = database.executeBatch(batch,20);	
	}
}