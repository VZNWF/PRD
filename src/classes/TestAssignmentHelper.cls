/**
 * Test class for AssignmentHelper
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
@isTest(SeeAllData=false)
private class TestAssignmentHelper {
    @isTest static void testAssignNewWelcomeCalls() {   
        // NOTE: the DEFAULT_WELCOME_CALL_QUEUE must exist -- even though SeeAllData = false the test can (and should) still see it
        Group queue = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName = :WelcomeCallAssignmentHelper.DEFAULT_WELCOME_CALL_QUEUE];
        System.assertNotEquals(null, queue);
        User u = DecsOnD.TestUtils.createTestUser(false, false);
        u.Available_for_Assignment__c = true;
        insert u;
        User u2 = DecsOnD.TestUtils.createTestUser(false, false);
        u2.Available_for_Assignment__c = true;
        insert u2;
        GroupMember gm = new GroupMember(GroupId = queue.Id, UserOrGroupId = u.Id);
        System.runAs(u) {
            insert gm;
        } 
        GroupMember gm2 = new GroupMember(GroupId = queue.Id, UserOrGroupId = u2.Id);
        System.runAs(u2) {
            insert gm2;
        }      
        // Start with a helper that does not throw an exception on error
        WelcomeCallAssignmentHelper helper = new WelcomeCallAssignmentHelper(false);
        // Except error on null list of calls
        String result = helper.assignNewWelcomeCalls(null);
        System.assertNotEquals(null, result);

        // Now create a helper that does throw exception on error
        helper = new WelcomeCallAssignmentHelper(true);
        try {
            // Except error on empty list of calls
            helper.assignNewWelcomeCalls(new Welcome_Call__c[]{});
            System.assert(false, 'Exception expected');
        }
        catch (DecsOnD.ApplyPolicyException e){}

        // Test with one call
        Welcome_Call__c call = new Welcome_Call__c(OwnerId = u2.Id);
        helper.assignNewWelcomeCalls(new Welcome_Call__c[]{call});
        System.assertNotEquals(null, call.OwnerId);

        // Test with multiple calls
        call = new Welcome_Call__c();
        Welcome_Call__c call2 = new Welcome_Call__c(OwnerId= u.Id);
        Welcome_Call__c[] calls = new Welcome_Call__c[]{call, call2};
        helper.assignNewWelcomeCalls(calls);
        System.assertNotEquals(null, call.OwnerId);
        System.assertNotEquals(null, call2.OwnerId);
        System.assertNotEquals(call.OwnerId, call2.OwnerId);
    }

    @isTest static void testAssignNewLeads() {   
        User u = DecsOnD.TestUtils.createTestUser(false, false);
        u.Available_for_Assignment__c = true;
        insert u;
        u = [select Id, username, Name, firstname, lastname, alias, email, profileid from User where username=:u.username];
        Group q = new Group(Name = 'TestQueue', Type = 'Queue');
        User currentUser = new User(Id = Userinfo.getUserId());
        System.runAs(currentUser) {
            insert q;
            q = [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Queue' AND Name=:q.Name];
            QueueSObject queueMapping = new QueueSObject(QueueId=q.Id, SobjectType='Lead');
            insert queueMapping;
        }

        GroupMember gm = new GroupMember(GroupId = q.Id, UserOrGroupId = u.Id);
        System.runAs(currentUser) {
            insert gm;
        }

        Lead l = DecsOnD.TestUtils.createTestLead(currentUser, false);
        l.State = 'CA';        
        insert l;
  
        DecsOnD.TestUtils.initializeTestSetup();
        DecsOnD__Policy__c policy = DecsOnD.TestUtils.createTestPolicy('Lead', 'Assignment', true);
        DecsOnD.TestUtils util = new DecsOnD.TestUtils();
        String mockResponse = util.getMockDecisionPointConfig(Lead.sObjectType).toJSON(true);
        DecsOnD.TestUtils.setMockJSONResponseForTest(mockResponse, 200);

        System.assertNotEquals(u.Name, l.Owner.Name);

        DecsOnD.PolicyInvocationContext policyContext = new DecsOnD.PolicyInvocationContext(policy);
        DecsOnD.PolicyActionContext actionContext = new DecsOnD.PolicyActionContext(policyContext, l);
        
        // Without RoundRobin the lead will get assigned to the queue
        DecsOnD.PolicyActionRecord actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('queue', q.Name);

        actionRec.action.prepare(actionRec);
        l = [SELECT Id, Name, Owner.Name FROM Lead WHERE Id=:l.Id];
        System.assertNotEquals(u.Name, l.Owner.Name);

        actionRec.action.apply(actionRec);
        l = [SELECT Id, Name, Owner.Name FROM Lead WHERE Id=:l.Id];
        System.assertEquals(q.Name, l.Owner.Name);
        
        // With RoundRobin the lead will get assigned to the user
        actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('queue', q.Name);
        actionRec.addActionParameter('AssignmentMode', 'RoundRobin');
        
        actionRec.action.prepare(actionRec);
        actionRec.action.apply(actionRec);
        l = [SELECT Id, Name, Owner.Name FROM Lead WHERE Id=:l.Id];
        System.assertEquals(u.Name, l.Owner.Name);
/*

        PolicyActionHandler.applyAction(actionRec);
        l = [SELECT Id, Name, Owner.Name FROM Lead WHERE Id=:l.Id];
        System.assertEquals(u.Name, l.Owner.Name);
*/
    }
}