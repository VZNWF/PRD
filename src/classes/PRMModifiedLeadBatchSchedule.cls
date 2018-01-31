/****************************************************************
Created: 10 Apr 2014
Author: Krishna Tatta (CodeScience)
Purpose : Schedule class to run PRMModifiedLeadBatch class
To schedule, execute anonymous the following: 
	PRMModifiedLeadBatchSchedule cls1 = new PRMModifiedLeadBatchSchedule();
	String sch1 = '0 0 * * * ?'; // run at the start of every hour
	System.schedule('Verizon existing Lead Import', sch1, cls1);

Modifications:
******************************************************************/
global class PRMModifiedLeadBatchSchedule implements Schedulable{         
  global void execute(SchedulableContext sc) {
   	PRMModifiedLeadBatch batch = new PRMModifiedLeadBatch(false);
   	Id batchId = database.executeBatch(batch);
  }
}