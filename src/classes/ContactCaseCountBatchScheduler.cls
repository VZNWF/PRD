/*
    Name: ContactCaseCountBatchScheduler
    Test Class : CustomerProfileSettingsControllerTest
    Description:  Scheduler class to execute the batch class 'ContactCaseCountBatchUpdate'.
    Modification History:
    Author      Jira                Date        Description

        
*/

global class ContactCaseCountBatchScheduler implements System.Schedulable {
    global void execute(SchedulableContext sc){
    	ContactCaseCountBatchUpdate c = new ContactCaseCountBatchUpdate('Update', sc.getTriggerId());
    	Id batchprocessid = Database.executeBatch(c);
    }
}