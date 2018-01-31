@isTest(SeeAllData=True)
private class PRMLeadUpdateBatchSchedule_Test {
    private static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest static void testPRMLeadUpdateBatchSchedule() {
        List<Id> leads = new List<Id>();
        List<Id> opportunities = new List<Id>();
        Lead lead = testUtils.createLead();
        leads.add(lead.Id);
        Account account = testUtils.createAccount();
        Opportunity opportunity = testUtils.createOpportunity(account);
        opportunities.add(opportunity.Id);
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, New PRMLeadUpdateBatchSchedule(new List<Id> {lead.Id}, new List<Id> {opportunity.Id}, true));
         
        // Get the information from the CronTrigger API object
        CronTrigger ct = [
            SELECT  Id, CronExpression, TimesTriggered, NextFireTime
            FROM    CronTrigger 
            WHERE   id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}