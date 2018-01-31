/**
 * Test class for assignment helper classes
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
@isTest(SeeAllData=false)
private class TestAssignmentHelpers {
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

        User currentUser = new User(Id = Userinfo.getUserId());
        integer numLeads = 10;
        Lead[] leads = DecsOnD.TestUtils.createTestLeads(numLeads, currentUser, false);
        for (Lead l : leads) {
            l.State = 'CA';        
        }
        insert leads;
  
        leads = [select Id, Name, OwnerId from Lead];
        System.assertEquals(numLeads, leads.size());
        System.assertEquals(currentUser.Id, leads[0].OwnerId);

        DecsOnD.TestUtils.initializeTestSetup();
        DecsOnD__Policy__c policy = DecsOnD.TestUtils.createTestPolicy('Lead', 'Assignment', true);
        DecsOnD.TestUtils util = new DecsOnD.TestUtils();
        LeadAssignmentHelper.mockPolicyResponse = util.getMockDecisionPointConfig(Lead.sObjectType).toJSON(true);

        // Do not throw exception on error
        LeadAssignmentHelper helper = new LeadAssignmentHelper(false);
        // Assignment will fail since we can't make an actual callout
        String jsonResponse = null;
        for (integer i=0;i<numLeads;i++) {
            if (jsonResponse==null) {
                jsonResponse = '[';
            } else {
                jsonResponse += ',';
            }
            jsonResponse += '{"status": "OK"}';
        }
        jsonResponse += ']';
        LeadAssignmentHelper.mockDecisionResponseBatch = jsonResponse;
        
        System.assertEquals(null, helper.assignNewLeads(leads, false));
        leads = [select Id, Name, OwnerId from Lead];
        System.assertEquals(numLeads, leads.size());
        System.assertEquals(currentUser.Id, leads[0].OwnerId);

        System.assertEquals(null, helper.assignNewLeads(leads, true));
        leads = [select Id, Name, OwnerId from Lead];
        // No assignment done -- we did not provide a fully formed response
        System.assertEquals(numLeads, leads.size());
        System.assertEquals(currentUser.Id, leads[0].OwnerId);
    }

    // Invoke standard AssignOwner action, which will invoke the CustomAssignmentHelper class
    @isTest static void testCustomAssignmentHelper() {   
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
    }
    // Test helper methods for Stacked Round Robin Algorithm 
    @isTest static void testStackedRoundRobinAlgorithm() {   
        DecsOnD.TestUtils.initializeTestSetup();
        DecsOnD__Policy__c policy = DecsOnD.TestUtils.createTestPolicy('Lead', 'Assignment', true);
        DecsOnD.TestUtils util = new DecsOnD.TestUtils();
        String mockResponse = util.getMockDecisionPointConfig(Lead.sObjectType).toJSON(true);
        DecsOnD.TestUtils.setMockJSONResponseForTest(mockResponse, 200);
        DecsOnD.PolicyInvocationContext context = new DecsOnD.PolicyInvocationContext(policy);

        Group queue = createTestQueue('TestQueue', 'Lead', true);
        System.assertEquals('Queue', queue.Type);
        Group queue2 = createTestQueue('TestQueue2', 'Lead', true);
        Group grp = createTestPublicGroup('TestGroup', true);
        Group grp2 = createTestPublicGroup('TestGroup2', true);

        User usr1 = DecsOnD.TestUtils.createTestUser(false, false);
        usr1.Agent_Rating__c = 'A';
        usr1.Available_for_Assignment__c = true;
        usr1.LastName = 'User 1';
        User usr2 = DecsOnD.TestUtils.createTestUser(false, false);
        usr2.Agent_Rating__c = 'A';
        usr2.Available_for_Assignment__c = true;
        usr2.LastName = 'User 2';
        User usr3 = DecsOnD.TestUtils.createTestUser(false, false);
        usr3.Agent_Rating__c = 'B';
        usr3.Available_for_Assignment__c = true;
        usr3.LastName = 'User 3';
        User usr4 = DecsOnD.TestUtils.createTestUser(false, false);
        usr4.Agent_Rating__c = 'C';
        usr4.Available_for_Assignment__c = true;
        usr4.LastName = 'User 4';
        User[] users = new User[]{usr1, usr2, usr3, usr4}; 
        insert users;
        // Tricks to make sure we retrieve the right fields
        Map<Id, User> userMap = new Map<Id, User>(users);
        users = [select Id, Name, FirstName, LastName, Username, Agent_Rating__c, Available_for_Assignment__c from user where Id in :userMap.keySet()];
        userMap = new Map<Id, User>(users);
        usr1 = userMap.get(usr1.Id);
        usr2 = userMap.get(usr2.Id);
        usr3 = userMap.get(usr3.Id);
        usr4 = userMap.get(usr4.Id);

        User[] queueUsers = new User[]{usr1, usr2, usr3, usr4};
        System.assertEquals(4, addGroupMembers(queue, queueUsers, true).size());
        System.assertEquals(2, addGroupMembers(queue2, new User[]{usr1, usr3}, true).size());
        User[] groupUsers = new User[]{usr3, usr4};
        System.assertEquals(2, addGroupMembers(grp, groupUsers, true).size());
        System.assertEquals(2, addGroupMembers(grp2, new User[]{usr2, usr4}, true).size());
        CustomAssignmentHelper helper = new CustomAssignmentHelper();

        DecsOnD__ConfigurationSetting__c setting = helper.createNewSetting(queue.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING, CustomAssignmentHelper.CUSTOM_ALGORITHM_NAME);
        System.assertNotEquals(null, setting);
        System.assert(String.isBlank(setting.DecsOnD__PolicyName__c));
        System.assert(String.isBlank(setting.DecsOnD__Object__c));

        System.assertEquals(null, helper.policyInvocationContext);
        helper.initialize(context, true, true);
        System.assertNotEquals(null, helper.policyInvocationContext);

        DecsOnD__ConfigurationSetting__c[] settings = new DecsOnD__ConfigurationSetting__c[]{};
        // queue and grp are valid
        // queue2 and grp2 are not valid
        setting = helper.createNewSetting(queue.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING, CustomAssignmentHelper.CUSTOM_ALGORITHM_NAME);
        System.assertEquals(queue.Id, setting.DecsOnD__ElementName__c);
        System.assertEquals(CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING, setting.DecsOnD__SettingType__c);
        System.assertEquals(CustomAssignmentHelper.CUSTOM_ALGORITHM_NAME, setting.DecsOnD__Value__c);
        System.assertEquals(policy.Name, setting.DecsOnD__PolicyName__c);
        System.assertEquals(policy.DecsOnD__Applies_to__c, setting.DecsOnD__Object__c);
        settings.add(setting);
        settings.add(helper.createNewSetting(queue2.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING, 'Bla'));
        settings.add(helper.createNewSetting(grp.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING, CustomAssignmentHelper.CUSTOM_ALGORITHM_NAME));
        settings.add(helper.createNewSetting(grp2.Id, CustomAssignmentHelper.MIN_AGENT_RATING_SETTING, 'Bla'));
        settings.add(helper.createNewSetting(grp2.Id, CustomAssignmentHelper.ASSIGNMENTS_IN_ROUND_SETTING, 'Bla'));

        insert settings;
        System.assertNotEquals(null, queue.Id);

        Map<Id, Group> groups = new Map<Id, Group>();
        groups.put(queue.Id, queue);
        groups.put(queue2.Id, queue2);
        groups.put(grp.Id, grp);
        groups.put(grp2.Id, grp2);

        System.assertEquals(null, helper.customSettingsByGroup);        
        helper.loadCustomSettingsByGroup(groups);
        System.assertNotEquals(null, helper.customSettingsByGroup);        
        System.assertEquals(groups.size(), helper.customSettingsByGroup.size());        
        Map<String, DecsOnD__ConfigurationSetting__c> groupSettings = helper.customSettingsByGroup.get(queue.Id);
        System.assertNotEquals(null, groupSettings);        
        System.assertEquals(1, groupSettings.size());        

        // Testing this method will implicitly test underlying ones
        setting = helper.getGroupSetting(queue.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING);
        System.assertNotEquals(null, setting);
        setting = helper.getGroupSetting(queue.Id, CustomAssignmentHelper.MIN_AGENT_RATING_SETTING);
        System.assertEquals(null, setting);
        setting = helper.getGroupSetting(queue.Id, CustomAssignmentHelper.ASSIGNMENTS_IN_ROUND_SETTING);
        System.assertEquals(null, setting);

        setting = helper.getGroupSetting(queue2.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING);
        System.assertNotEquals(null, setting);

        setting = helper.getGroupSetting(grp.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING);
        System.assertNotEquals(null, setting);

        setting = helper.getGroupSetting(grp2.Id, CustomAssignmentHelper.CUSTOM_ALGORITHM_SETTING);
        System.assertEquals(null, setting);

        Map<Id, List<User>> usersbyGroup = helper.loadGroupMembers(groups);
        System.assertNotEquals(null, usersbyGroup);
        System.assertEquals(groups.size(), usersbyGroup.size());
        System.assertEquals(queueUsers.size(), usersbyGroup.get(queue.Id).size());
        System.assertEquals(groupUsers.size(), usersbyGroup.get(grp.Id).size());
        setting = helper.getGroupSetting(queue.Id, CustomAssignmentHelper.MIN_AGENT_RATING_SETTING);
        System.assertNotEquals(null, setting);
        setting = helper.getGroupSetting(queue.Id, CustomAssignmentHelper.ASSIGNMENTS_IN_ROUND_SETTING);
        System.assertNotEquals(null, setting);
        System.assertEquals('2', setting.DecsOnD__Value__c);

        // Create a new helper with a regular action
        User currentUser = new User(Id = Userinfo.getUserId());
        Lead l = DecsOnD.TestUtils.createTestLead(currentUser, false);
        l.State = 'CA';        
        insert l;
        // ==============
        // Test properly configured stacked ranking
        // ==============
        DecsOnD.PolicyActionContext actionContext = new DecsOnD.PolicyActionContext(context, l);
        DecsOnD.PolicyActionRecord actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('queue', queue.Name);
        actionRec.addActionParameter('AssignmentMode', DecsOnD.AssignmentHelper.MODE_ROUND_ROBIN);
        actionRec.action.prepare(actionRec);
        helper = CustomAssignmentHelper.lastHelper;
        User[] expectedUsers = new User[]{usr1, usr2, usr1, usr2, usr3, usr1, usr2, usr3, usr4, usr1, usr2, usr1, usr2, usr3, usr1, usr2, usr3, usr4};
        // Start at index 1 -- first user will already be selected when the action is prepared
        for (integer i=1;i<expectedUsers.size();i++) {
            User expectedUser = expectedUsers[i];
            User assignedUser = helper.getAssignedOwner(queue, actionRec.actionParameters);
            String msg = '[Iteration ' + i + '] Expected: ' + expectedUser.Name + '. Actual: ' + assignedUser.Name;
            System.assertEquals(expectedUser.Agent_Rating__c, assignedUser.Agent_Rating__c, msg);
        }

        actionContext = new DecsOnD.PolicyActionContext(context, l);
        actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('group', grp.Name);
        actionRec.addActionParameter('AssignmentMode', DecsOnD.AssignmentHelper.MODE_ROUND_ROBIN);
        actionRec.action.prepare(actionRec);
        helper = CustomAssignmentHelper.lastHelper;
        expectedUsers = new User[]{usr3, usr3, usr4, usr3, usr3, usr4, usr3, usr3, usr4};
        for (integer i=1;i<expectedUsers.size();i++) {
            User expectedUser = expectedUsers[i];
            User assignedUser = helper.getAssignedOwner(grp, actionRec.actionParameters);
            String msg = '[Iteration ' + i + '] Expected: ' + expectedUser.Name + '. Actual: ' + assignedUser.Name;
            System.assertEquals(expectedUser.Agent_Rating__c, assignedUser.Agent_Rating__c, msg);
        }

        // ==============
        // Test improperly configured stacked ranking -- should fall back to regular round robin
        // ==============
        actionContext = new DecsOnD.PolicyActionContext(context, l);
        actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('queue', queue2.Name);
        actionRec.addActionParameter('AssignmentMode', DecsOnD.AssignmentHelper.MODE_ROUND_ROBIN);
        actionRec.action.prepare(actionRec);
        helper = CustomAssignmentHelper.lastHelper;
        expectedUsers = new User[]{usr1, usr3, usr1, usr3};
        for (integer i=1;i<expectedUsers.size();i++) {
            User expectedUser = expectedUsers[i];
            User assignedUser = helper.getAssignedOwner(queue2, actionRec.actionParameters);
            String msg = '[Iteration ' + i + '] Expected: ' + expectedUser.Name + '. Actual: ' + assignedUser.Name;
            
        }

        actionContext = new DecsOnD.PolicyActionContext(context, l);
        actionRec = new DecsOnD.PolicyActionRecord(actionContext, new DecsOnD.AssignOwnerAction());
        actionRec.addActionParameter('group', grp2.Name);
        actionRec.addActionParameter('AssignmentMode', DecsOnD.AssignmentHelper.MODE_ROUND_ROBIN);
        actionRec.action.prepare(actionRec);
        helper = CustomAssignmentHelper.lastHelper;
        expectedUsers = new User[]{usr2, usr4, usr2, usr4};
        for (integer i=1;i<expectedUsers.size();i++) {
            User expectedUser = expectedUsers[i];
            User assignedUser = helper.getAssignedOwner(grp2, actionRec.actionParameters);
            String msg = '[Iteration ' + i + '] Expected: ' + expectedUser.Name + '. Actual: ' + assignedUser.Name;
            
        }
    }

    public static Group createTestQueue(String name, String objType, boolean performInsert) {
        name = randomizeName(name);
        Group newQueue = new Group(Name = name, Type = 'Queue');
        if (performInsert) {
//          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(new User(Id = Userinfo.getUserId())) {
                insert newQueue;
                if (objType!=null) {
                    newQueue = [SELECT Id, RelatedId, Name, DeveloperName, Type, Email FROM Group WHERE Type='Queue' AND Name=:name];
                    QueueSObject queueMapping = new QueueSObject(QueueId=newQueue.Id, SobjectType=objType);
                    insert queueMapping;
                }
            }
        }
        return newQueue;        
    }

    public static Group createTestPublicGroup(String name, boolean insertIntoDB) {
        name = randomizeName(name);
        String devName = name + '_DEV';
        Group newGroup = new Group(Name = name,DeveloperName = devname, Type = 'Regular');
        if (insertIntoDB) {
//          User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs(new User(Id = Userinfo.getUserId())) {
                insert newGroup;
                newGroup = [SELECT Id, RelatedId, Name, DeveloperName, Type, Email FROM Group WHERE Type='Regular' AND Name=:name];
            }
        }
        return newGroup;
        
    }
    public static GroupMember[] addGroupMembers(Group theGroup, User[] users, boolean insertIntoDB) {
        GroupMember[] groupMembers = new GroupMember[]{};
        for (User u : users) {
            GroupMember gm = new GroupMember();
            gm.GroupId = theGroup.Id;
            gm.UserOrGroupId = u.Id;
            groupMembers.add(gm);
        }
        if (insertIntoDB) {
            System.runAs(new User(Id = Userinfo.getUserId())) {
                insert groupMembers;
                groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :theGroup.Id and UserOrGroupId in :users];
            }
        }
        return groupMembers;
    }

    public static GroupMember[] addGroupMembers(Group theGroup, Group[] groups, boolean insertIntoDB) {
        GroupMember[] groupMembers = new GroupMember[]{};
        for (Group g : groups) {
            GroupMember gm = new GroupMember();
            gm.GroupId = theGroup.Id;
            gm.UserOrGroupId = g.Id;
            groupMembers.add(gm);
        }
        if (insertIntoDB) {
            System.runAs(new User(Id = Userinfo.getUserId())) {
                insert groupMembers;
                groupMembers = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :theGroup.Id and UserOrGroupId in :groups];
            }
        }
        return groupMembers;
    }

    public static GroupMember[] addGroupMembers(Group theGroup, UserRole[] roles, boolean insertIntoDB) {
        Group[] groups = [select Id, Name, Type, RelatedId from Group where RelatedId in :roles];
        return addGroupMembers(theGroup, groups, insertIntoDB);
    }

    public static String randomizeName(String baseName) {
        Long randomNumber = Math.roundToLong(Math.random()*10000000);
        return baseName + '_' + System.currentTimeMillis() + '_' + randomNumber;
    }

}