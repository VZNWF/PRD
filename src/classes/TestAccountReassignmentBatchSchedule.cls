/**
 * Test class for AccountReassignmentBatchSchedule
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
@isTest(SeeAllData=false)
public with sharing class TestAccountReassignmentBatchSchedule {
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   @IsTest
   public static void testScheduleBatch() {
        User u = DecsOnD.TestUtils.createTestUser(false, false);
        u.Available_for_Assignment__c = true;
        insert u;
        u = [select Id, username, Name, firstname, lastname, alias, email, profileid from User where username=:u.username];

        User currentUser = new User(Id = Userinfo.getUserId());
        integer numAccounts = 10;
        Account[] accounts = DecsOnD.TestUtils.createTestAccounts(numAccounts, currentUser, false);
        for (Account a: accounts) {
            
        }
        insert accounts;
  
        accounts = [select Id, Name, OwnerId from Account];
        System.assertEquals(numAccounts, accounts.size());
        System.assertEquals(currentUser.Id, accounts[0].OwnerId);

        DecsOnD.TestUtils.initializeTestSetup();
        DecsOnD__Policy__c policy = DecsOnD.TestUtils.createTestPolicy('Account', 'Reassignment', true);
        DecsOnD.TestUtils util = new DecsOnD.TestUtils();
        AccountReassignmentBatchSchedule.mockPolicyResponse = util.getMockDecisionPointConfig(Account.sObjectType).toJSON(true);

        String jsonResponse = null;
        for (integer i=0;i<numAccounts;i++) {
            if (jsonResponse==null) {
                jsonResponse = '[';
            } else {
                jsonResponse += ',';
            }
            jsonResponse += '{"status": "OK"}';
        }
        jsonResponse += ']';
        AccountReassignmentBatchSchedule.mockDecisionResponseBatch = jsonResponse;

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('TestAccountReassignmentBatchSchedule',
                        CRON_EXP,
                        new AccountReassignmentBatchSchedule());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
 
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

      // Verify the scheduled job hasn't run yet.
      // TODO 

      Test.stopTest();

      // Now that the scheduled job has executed after Test.stopTest(),
      // check that the accounts are reassigned
      // TODO 
   }
}