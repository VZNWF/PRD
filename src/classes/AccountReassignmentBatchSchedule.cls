/**
 * Class to schedule reassignment of certain accounts after a specified delay
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
global class AccountReassignmentBatchSchedule implements Schedulable{         
    public static final String REASSIGNMENT_POLICY = 'Reassignment';
    public static final String WHERE_CLAUSE_BASE = 'Acct_Type__c = \'End Customer\' and Sub_Type__c = \'SMB\'';
    public static final integer NUM_DAYS_DELAY = 210;
    
    global void execute(SchedulableContext sc) {
        String operation = 'Reassign accounts';
        try {
            integer numberOfDaysDelay = NUM_DAYS_DELAY;
            NWF_App_Settings__c setting = NWF_App_Settings__c.getInstance('Default');
            if(setting != null && setting.Account_Reassignment_Days__c != null) {
                numberOfDaysDelay = integer.valueOf(setting.Account_Reassignment_Days__c);
            }

            if (Test.isRunningTest() && (mockPolicyResponse!=null)) {
                DecsOnD.TestUtils.setMockJSONResponseForTest(mockPolicyResponse, 200);
            }
            DecsOnD.PolicyInvocationContext invocationContext = new DecsOnD.PolicyInvocationContext(Account.sObjectType, REASSIGNMENT_POLICY);

            DateTime now = DateTime.now();
            DateTime targetDate = now.addDays(-numberOfDaysDelay);
            DateTime targetDateAfter = targetDate.addDays(1);
            String whereClause = String.format('{0} and Completed_Account_Set_up__c >= {1} and Completed_Account_Set_up__c < {2}', 
                new String[]{WHERE_CLAUSE_BASE, targetDate.format('YYYY-MM-dd\'T\'00:00:00\'Z\''), targetDateAfter.format('YYYY-MM-dd\'T\'00:00:00\'Z\'')});

            DecsOnD.BatchExecutePolicy batch = new DecsOnD.BatchExecutePolicy(invocationContext, whereClause);
            batch.sessionId = UserInfo.getSessionId();
            if (batch.sessionId==null) batch.sessionId = 'BatchSession';
            batch.createExecutionRecord = !String.isBlank(invocationContext.policy.DecsOnD__Log_level__c);
            System.debug(String.format('Reassigning accounts using query: {0} [Creating execution records: {1}]', 
                    new String []{batch.query, String.valueOf(batch.createExecutionRecord)}));

            if (Test.isRunningTest() && (mockDecisionResponseBatch!=null)) {
                DecsOnD.TestUtils.setMockJSONResponseForTest(mockDecisionResponseBatch, 200);
            }
            Database.executeBatch(batch);
        }
        catch (Exception e) {
            AssignmentHelperBase helper = new AssignmentHelperBase(false);
            helper.reportError(operation, e);
        }
    }
    @TestVisible private static String mockPolicyResponse = null;
    @TestVisible private static String mockDecisionResponseBatch = null;
}