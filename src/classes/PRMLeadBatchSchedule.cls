/****************************************************************
Created: 8 Mar 2014
Author: Krishna Tatta (CodeScience)
Purpose : Schedule class to run PRMLeadBatch class
To schedule, execute anonymous the following: 
	PRMLeadBatchSchedule cls1 = new PRMLeadBatchSchedule();
	String sch1 = '0 0 * * * ?'; // run at the start of every hour
	System.schedule('Verizon Lead Import', sch1, cls1);

Modifications:
******************************************************************/
global class PRMLeadBatchSchedule implements Schedulable{         
  global void execute(SchedulableContext sc) {
   	PRMLeadBatch batch = new PRMLeadBatch(false);
   	Id batchId = database.executeBatch(batch);
  }
}