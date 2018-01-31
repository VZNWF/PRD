/**
 * Base class for assignment helpers
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
public virtual class AssignmentHelperBase {
    public boolean throwExceptionOnError = false;
    public LoggingLevel logLevel = LoggingLevel.ERROR;

    public AssignmentHelperBase() {}
    public AssignmentHelperBase(LoggingLevel logLevel) {
        this.logLevel = logLevel;
    }
    public AssignmentHelperBase(boolean throwExceptionOnError) {
        this.throwExceptionOnError = throwExceptionOnError;
    }

    public String reportError(String operation, String msg) {
        return reportError(operation, msg, null);
    }

    public String reportError(String operation, Exception e) {
        return reportError(operation, 'Internal error', e);
    }

    public String reportError(String operation, String msg, Exception e) {
        return reportError(operation, msg, e, this.logLevel, this.throwExceptionOnError);
    }

    public static String reportError(String operation, String msg, Exception e, LoggingLevel level, boolean throwException) {
        if (String.isBlank(msg)) msg = 'Unknown error';
        if (String.isBlank(operation)) operation = '<unknown operation>';
        if (level==null) level = LoggingLevel.DEBUG;
        String msgTemplate = '{0} failed: {1}';
        String[] msgParams = new String[]{operation, msg};
        if (e!=null) {
            msgTemplate = '{0} failed: {1} [Details: {2}]';
            msgParams.add(e.getMessage());
        }
        if (throwException) {
            throw new DecsOnD.ApplyPolicyException(msgTemplate, msgParams, e);
        } else {
            String fullMsg = String.format(msgTemplate, msgParams);
            System.debug(level, fullMsg);
            return fullMsg;
        }
    }

    // -----------------------
    // Obsolete assignment helper methods -- replaced by calls to upgraded Decisions on Demand app
    // -----------------------
/*  
    public User[] findNextEligibleUsers(Group grp, DecsOnD__Policy__c policy, integer numUsersRequested) {      
        if (policy==null) return null;
        return findNextEligibleUsers(grp, policy.DecsOnD__Applies_to__c, policy.Name, numUsersRequested);
    }

    public User[] findNextEligibleUsers(Group grp, String objectType, String policyName, integer numUsersRequested) {       
        if (grp==null) return null;
        if (numUsersRequested<=0) return null;
        Map<Id, GroupMember> memberRecords = queryGroupMemberInfo(grp);
        if (memberRecords.size()==0) return null;
        Set<Id> memberIds = new Set<Id>();
        for (GroupMember memberRecord : memberRecords.values()) {
            memberIds.add(memberRecord.UserOrGroupId);
        }
//      List<User> usrs = [select Id, Name, Available_for_Assignment__c from User where Id in :memberIds and Available_for_Assignment__c = true];
        // First check for (sub)groups that are roles. The membership is defined separately, so we need to collect the role Ids
        Group[] roleGroups = [select Id, RelatedId from Group where Type = 'Role' and RelatedId != null and Id in :memberIds];
        Set<Id> roleIds = null;
        if (roleGroups.size()>0) {
            roleIds = new Set<Id>();
            for (Group roleGroup: roleGroups) {
                roleIds.add(roleGroup.RelatedId);
            }
            System.debug(LoggingLevel.INFO, String.format('Found {0} (sub)groups of type Role', new String[]{roleIds.size().format()}));
        }
        Map<Id, User> usrs = queryUsers(memberIds, roleIds);
        System.debug(LoggingLevel.INFO, 'Found ' + usrs.size() + ' total available users');
        if (usrs.size()==0) return usrs.values();
        DecsOnD__ConfigurationSetting__c lastAssignedUserSetting = null;
        DecsOnD__ConfigurationSetting__c[] settings = [Select DecsOnD__ElementName__c, DecsOnD__Value__c  From DecsOnD__ConfigurationSetting__c 
                          Where DecsOnD__SettingType__c = 'RoundRobinLastUser' And DecsOnD__ElementName__c = :grp.Id And DecsOnD__Object__c =:objectType And DecsOnD__PolicyName__c =:policyName];
        if (settings.size()==0) {
            lastAssignedUserSetting = new DecsOnD__ConfigurationSetting__c(DecsOnD__ElementName__c = grp.Id , DecsOnD__SettingType__c = 'RoundRobinLastUser', DecsOnD__Object__c = objectType, DecsOnD__PolicyName__c = policyName);
            String fullName = 'RoundRobinLastUser.' + objectType + '.' + policyName + '.' + grp.Id;
            lastAssignedUserSetting.DecsOnD__External_ID__c = fullName;
            lastAssignedUserSetting.Name = grp.Id + '_' + System.currentTimeMillis();
        } else {
            lastAssignedUserSetting = settings[0];
        }
        List<User> availableUsers = usrs.values();
        integer usrIndex = 0;
        User lastAssignedUser = null;
        Id lastAssignedUserId = lastAssignedUserSetting.DecsOnD__Value__c;
        if (!String.isBlank(lastAssignedUserId)) {
            // Find index of first user after the one that was last assigned
            for (User usr : availableUsers) {
                usrIndex++;
                if (usr.Id==lastAssignedUserId) {
                    lastAssignedUser = usr;
                    System.debug(LoggingLevel.INFO, 'Last assigned user was  ' + lastAssignedUser.Name);
                    break;
                }
            }
            if (lastAssignedUser==null) {
                // This is normal the first time the code is used
                System.debug(LoggingLevel.INFO, 'Unable to find last assigned user with ID  ' + lastAssignedUserId);
            }
        }
        List<User> selectedUsers = new List<User>();
        // Make a list of numUsersRequested eligible users
        while (selectedUsers.size()<numUsersRequested) {
            // Rotate back to start of list if needed, using the same user more than once if necessary
            usrIndex = Math.mod(usrIndex, availableUsers.size());
            User usr = availableUsers[usrIndex];
            selectedUsers.add(usr);
            usrIndex++;
        }

        lastAssignedUser = selectedUsers.get(selectedUsers.size()-1);
        System.debug(LoggingLevel.INFO, 'Last assigned user updated to  ' + lastAssignedUser.Name);
        lastAssignedUserSetting.DecsOnD__Value__c = lastAssignedUser.Id;
        upsert lastAssignedUserSetting;
        return selectedUsers;
    }

    public Map<Id, GroupMember> queryGroupMemberInfo(Group grp) {
        if (grp==null) return null;
        return queryGroupMemberInfo(new Set<Id>{grp.Id});
    }

    public Map<Id, GroupMember> queryGroupMemberInfo(Set<Id> groupIds) {
        if (groupIds==null) return null;

        Map<Id, GroupMember> membersMap = new Map<Id, GroupMember>([select Id, GroupId, UserOrGroupId from GroupMember where GroupId in :groupIds order by Id]);
        if (membersMap.size()==0) return membersMap;

        String groupIdPrefix = Group.sObjectType.getDescribe().getKeyPrefix();
        Set<Id> subGroupIds = new Set<Id>();
        for (GroupMember memberRecord : membersMap.values()) {
            Id userOrGroupId = memberRecord.UserOrGroupId;
            if (String.valueOf(userOrGroupId).startsWith(groupIdPrefix)) {
                subGroupIds.add(userOrGroupId);
            }
        }

//        if (!Utilities.isEmptyMap(parentGroupMap)) {
        if (subGroupIds.size()>0) {
            System.debug('**** Recursively loading group members for the following sub-groups: ' + subGroupIds);
            membersMap.putAll(queryGroupMemberInfo(subGroupIds));
        }
        System.debug('**** Total members loaded: ' + membersMap.size().format());
        return membersMap;
    }

    public Map<Id, User> queryUsers(Set<Id> userIds, Set<Id> roleIds) {        
        if (userIds==null) {
            if (roleIds==null) {
                return null;                
            } else {
                userIds = new Set<Id>();
            }
        } else if (roleIds==null) {
            roleIds = new Set<Id>();
        }
        return new Map<Id, User>([select Id, Name, LastLoginDate, UserRoleId from User where (Id in :userIds or UserRoleId in :roleIds) and IsActive = true and Available_for_Assignment__c = true order by Id]);
    }
    */
}