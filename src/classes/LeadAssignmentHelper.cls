/**
 * Helper class for Lead assignment
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
public class LeadAssignmentHelper extends AssignmentHelperBase {
    public static final String ASSIGNMENT_POLICY = 'Assignment';
    public LeadAssignmentHelper() {
        super();
    }
    public LeadAssignmentHelper(LoggingLevel logLevel) {
        super(logLevel);
    }
    public LeadAssignmentHelper(boolean throwExceptionOnError) {
        super(throwExceptionOnError);
    }

    public String assignNewLeads(Lead[] leads, boolean createExecutionRecord) {
        String operation = 'Assign new leads';
        try {
            if (leads==null) throw new DecsOnD.ApplyPolicyException('null lead list');
            if (leads.size()==0) throw new DecsOnD.ApplyPolicyException('empty lead list');
            if (Test.isRunningTest() && (mockPolicyResponse!=null)) {
                DecsOnD.TestUtils.setMockJSONResponseForTest(mockPolicyResponse, 200);
           }
            DecsOnD.PolicyInvocationContext invocationContext = new DecsOnD.PolicyInvocationContext(Lead.sObjectType, ASSIGNMENT_POLICY);
            DecsOnD.BatchExecutePolicy batch = new DecsOnD.BatchExecutePolicy(invocationContext);
            batch.sessionId = UserInfo.getSessionId();
            if (batch.sessionId==null) batch.sessionId = 'BatchSession';
            batch.createExecutionRecord = createExecutionRecord;
            System.debug(String.format('[Policy {0}.{1}] Applying policy to {2} leads', 
                        new String []{invocationContext.getMainRecordTypeName(), invocationContext.getPolicyName(), leads.size().format()}));
            if (Test.isRunningTest() && (mockDecisionResponseBatch!=null)) {
                DecsOnD.TestUtils.setMockJSONResponseForTest(mockDecisionResponseBatch, 200);
           }
            batch.execute(null,leads);
            return null;
        }
        catch (Exception e) {
            return reportError(operation, e);
        }
    }
    @TestVisible private static String mockPolicyResponse = null;
    @TestVisible private static String mockDecisionResponseBatch = null;
    
}