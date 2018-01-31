/**
 * Helper class for Decisions on Demand assignment actions.
 * Implements a custom round-robin schedule that returns only users available for assignment.
 * 160225 Added support for stacked round robin for selected groups. 
 * To enable the custom algorith create a custom settings under 'Decisions on Demand Cponfiguration' with the following values:
 * - Name and External ID: any unique value (name must be max 38 chars)
 * - Type: RoundRobinCustomAlgorithm
 * - Value: Stacked
 * 
 * Copyright 2015-2016, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
global without sharing class CustomAssignmentHelper extends DecsOnD.AssignmentHelper {
    public static final String CUSTOM_ALGORITHM_SETTING = 'RoundRobinCustomAlgorithm';
    public static final String MIN_AGENT_RATING_SETTING = 'StackedRoundRobin_MinimumAgentRating';
    public static final String ASSIGNMENTS_IN_ROUND_SETTING = 'StackedRoundRobin_AssignmentsInRound';

    public static final String CUSTOM_ALGORITHM_NAME = 'Stacked';
    public static final String BLANK_RATING = '__None__';
    @TestVisible
    private static CustomAssignmentHelper lastHelper = null;

    // List of agent ratings in descending order of preference
    List<String> agentRatings = null;
    // Reverse map of rating to ranking
    Map<String, Integer> agentRatingRankings = null;
/*
    // Rankings are inverted -- first item in picklist has highest ranking
    transient List<Schema.PicklistEntry> agentRatingValuesAttr = null;
    List<Schema.PicklistEntry>agentRatingValues{get{
            if (agentRatingValuesAttr==null) {
                agentRatingValuesAttr = getAgentRatingValues();
            }
            return agentRatingValuesAttr;
        }
    }
    Map<String, Integer> agentRatingRankings{get{
            Map<String, Integer> rankings = null;
            if (this.agentRatingRankingsAttr==null) {
                if (this.agentRatingValues==null) return null;
                this.agentRatingRankingsAttr = new Map<String, Integer>();
                integer ranking = this.agentRatingValues.size();
                for (Schema.PicklistEntry rating : this.agentRatingValues) {                    
                    this.agentRatingRankingsAttr.put(rating.getValue(), ranking);
                    ranking--;
                }
                this.agentRatingRankingsAttr.put(BLANK_RATING, ranking);
            }
            return this.agentRatingRankingsAttr;
        }
    }
    */
    @TestVisible
    DecsOnD.PolicyInvocationContext policyInvocationContext = null;
    @TestVisible
    Map<Id, Map<String, DecsOnD__ConfigurationSetting__c>> customSettingsByGroup = null;
    Map<Id, List<User>> groupToUsersMap = null;
    DecsOnD.PolicyActionBatch batch = null;
    DecsOnD.PolicyActionRecord actionRec = null;

    global CustomAssignmentHelper() {
        super();
        System.debug(LoggingLevel.info, 'CustomAssignmentHelper instance created');
        initializeAgentRatings();
        lastHelper = this;
    }

    // --------------------
    // Override base class methods
    // --------------------
    global override void initialize(DecsOnD.PolicyInvocationContext context, boolean allowQueueAsOwner, boolean allowQueueAsGroup) {
        super.initialize(context, allowQueueAsOwner, allowQueueAsGroup);
        this.policyInvocationContext = context;
        System.debug(LoggingLevel.info, 'CustomAssignmentHelper instance initialized');
    }

    global override void addScopeToBatch(DecsOnD.PolicyActionRecord actionRec, boolean addMainRecordAsTarget) {
        super.addScopeToBatch(actionRec, addMainRecordAsTarget);
        this.actionRec = actionRec;
    }

    global override void loadScope(DecsOnD.PolicyActionBatch batch) {
        super.loadScope(batch);
        this.batch = batch;
    }

    // --------------------
    global override User getAssignedOwner(Group grp, Map<String, Object> parameters) {
        if ((grp==null) || (this.agentRatings==null) || (this.groupToUsersMap==null)) {
            return super.getAssignedOwner(grp, parameters);   
        }
        boolean useStandardAssignment = false;
        DecsOnD__ConfigurationSetting__c numAssignmentsInRoundSetting = getGroupSetting(grp.Id, ASSIGNMENTS_IN_ROUND_SETTING);
        DecsOnD__ConfigurationSetting__c minimumRatingSetting = null;
        // If no setting then custom algorithm is not enabled for this group
        if (numAssignmentsInRoundSetting==null) {
            useStandardAssignment = true;
        } else {
            minimumRatingSetting = getGroupSetting(grp.Id, MIN_AGENT_RATING_SETTING);
            // If no minimum rating then we have an error
            if (minimumRatingSetting==null) {
                System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + '] Missing custom setting: ' + MIN_AGENT_RATING_SETTING);
                useStandardAssignment = true;
            }
        }
        List<User> allUsers = groupToUsersMap.get(grp.Id);
        if ((allUsers==null) || (allUsers.size()==0)) useStandardAssignment = true;
        if (useStandardAssignment) return super.getAssignedOwner(grp, parameters);   
        try {
            DecsOnD__ConfigurationSetting__c[] settingsToUpsert = new DecsOnD__ConfigurationSetting__c[]{};
            String currentRating = minimumRatingSetting.DecsOnD__Value__c;
            List<User> eligibleUsers = getAllEligibleUsers(allUsers, currentRating);
            integer numUsersInCurrentRound = eligibleUsers.size();

            integer numAssignmentsRemainingInRound = Integer.valueOf(numAssignmentsInRoundSetting.DecsOnD__Value__c);
            // Handle case where users may have been deleted since last assignment
            if (numAssignmentsRemainingInRound>numUsersInCurrentRound) numAssignmentsRemainingInRound = numUsersInCurrentRound;
            // When counter hits 0 it is time to move to the next round
            if (numAssignmentsRemainingInRound<=0) {
                String newRating = null;
                // Check for additional eligible users by incrementally lowering the eligible rating
                integer currentRoundRanking = this.agentRatingRankings.get(currentRating);
                for (integer rank=currentRoundRanking-1;rank>=0;rank--) {
                    newRating = this.agentRatings[this.agentRatingRankings.size() - rank - 1];
                    eligibleUsers = getAllEligibleUsers(allUsers, newRating);
                    if (eligibleUsers.size()>numUsersInCurrentRound) {
                        break;
                    }
                    // If there are no users with a lower rating, then continue
                    newRating = null;
                }
                // If we hit the end without finding more users -- go back to first level
                if (newRating==null) {
                    newRating = findHighestRatingWithEligibleUsers(allUsers);
                    if (String.isBlank(newRating)) {
                        System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + 
                                '] Unable to find eligible users with a valid rating for stacked round robin - reverting to standard round robin assignment');
                        delete numAssignmentsInRoundSetting;
                        return super.getAssignedOwner(grp, parameters);
                    } else {
                        eligibleUsers = getAllEligibleUsers(allUsers, newRating);
                    }
                }
                numUsersInCurrentRound = eligibleUsers.size();
                System.debug(LoggingLevel.INFO, '[Group: ' + grp.Name + 
                        '] Completed all round robin assignments for rating level ' + currentRating + 
                        '. Next round has minimum rating of ' + newRating + ' (' + numUsersInCurrentRound + ' users)');
                currentRating = newRating;
                numAssignmentsRemainingInRound = numUsersInCurrentRound;
                minimumRatingSetting.DecsOnD__Value__c = newRating;
                settingsToUpsert.add(minimumRatingSetting);
            }
            User usr = eligibleUsers[numUsersInCurrentRound - numAssignmentsRemainingInRound];
            numAssignmentsRemainingInRound--;
            numAssignmentsInRoundSetting.DecsOnD__Value__c = String.valueOf(numAssignmentsRemainingInRound);
            System.debug(LoggingLevel.INFO, '[Group: ' + grp.Name + 
                    '] Assigning record to user ' + usr.Name + ' with rating ' + usr.Agent_Rating__c + 
                    ' (minimum level allowed: ' + currentRating + '). ' + 
                    numAssignmentsRemainingInRound + ' assignment(s) left in round');

            // TODO Batchify
            settingsToUpsert.add(numAssignmentsInRoundSetting);
            if (this.actionRec!=null) {
                for (DecsOnD__ConfigurationSetting__c setting : settingsToUpsert) {
                    this.actionRec.addTargetRecord(setting);
                }
            } else {
                upsert settingsToUpsert;
            }
            return usr;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + '] Error while applying custom round robin algorithm: ' + e.getMessage());            
            System.debug(e.getStackTraceString());
            return super.getAssignedOwner(grp, parameters);
        }
/*        if ((grp==null) || this.policyInvocationContext==null) return usr;
        String policyMainRecordType = this.policyInvocationContext.getMainRecordTypeName();
        String policyName = this.policyInvocationContext.getPolicyName();

        DecsOnD__ConfigurationSetting__c[] settings = [Select DecsOnD__ElementName__c, DecsOnD__SettingType__c, DecsOnD__Value__c From DecsOnD__ConfigurationSetting__c 
                          Where DecsOnD__Object__c =:policyMainRecordType And DecsOnD__PolicyName__c =:policyName and DecsOnD__SettingType__c = 'WeightedRoundRobinLastRating' And DecsOnD__ElementName__c = :grp.Id];
        Map<Id, Map<String, String>> settingsByGroup = new Map<Id, Map<String, String>>();
        for (DecsOnD__ConfigurationSetting__c setting : settings) {
            if (String.isBlank(setting.DecsOnD__ElementName__c)) continue;
            Map<String, String> groupSettings = settingsByGroup.get(setting.DecsOnD__ElementName__c);
            if (groupSettings==null) {
                groupSettings = new Map<String, String>();
                settingsByGroup.put(setting.DecsOnD__ElementName__c, groupSettings);
            }
            groupSettings.put(setting.DecsOnD__SettingType__c, setting.DecsOnD__Value__c);
        }
*/
    }

    // --------------------
    global override Map<Id, List<User>> loadGroupMembers(Map<Id, Group> groups) {
        this.groupToUsersMap = super.loadGroupMembers(groups);
        // If no rating packlist values, we cannot apply the stacked round robin
        if (this.agentRatings==null) return groupToUsersMap;
        // Load all custom settings
        loadCustomSettingsByGroup(groups);
        // Initialize basic settings when necessary
        List<DecsOnD__ConfigurationSetting__c> settingsToUpsert = new List<DecsOnD__ConfigurationSetting__c>();
        for (Id groupId : groups.keySet()) {
            Map<String, DecsOnD__ConfigurationSetting__c> groupSettings = this.customSettingsByGroup.get(groupId);
            if ((groupSettings==null) || (groupSettings.size()==0)) continue;
            String algorithm = getSettingValue(groupSettings, CUSTOM_ALGORITHM_SETTING);
            if (String.isBlank(algorithm)) continue;
            Group grp = groups.get(groupId);
            if (CUSTOM_ALGORITHM_NAME!=algorithm.trim()) {
                System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + 
                        '] Unexpected value for RoundRobinCustomAlgorithm custom setting: ' + algorithm);
                continue;
            }
            List<User> users = groupToUsersMap.get(groupId);
            if ((users==null) || (users.size()==0)) continue;
            // Minimum rating stores the lowest agent rating eligible in the current round
            String minimumRating = getSettingValue(groupSettings, MIN_AGENT_RATING_SETTING);
            // The count of the number of agents to process in this round
            // will be decremented for every assignment
            if (String.isBlank(minimumRating)) {
                minimumRating = findHighestRatingWithEligibleUsers(users);
                if (String.isBlank(minimumRating)) {
                    System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + 
                            '] None of the eligible users have a valid rating for stacked round robin - defaulting to standard round robin assignment');
                } else {
                    List<User> selectedUsers = getAllEligibleUsers(users, minimumRating);
                    DecsOnD__ConfigurationSetting__c setting = createNewSetting(groupId, MIN_AGENT_RATING_SETTING, minimumRating);
                    settingsToUpsert.add(setting);
                    groupSettings.put(MIN_AGENT_RATING_SETTING, setting);
                    setting = createNewSetting(groupId, ASSIGNMENTS_IN_ROUND_SETTING, String.valueOf(selectedUsers.size()));
                    groupSettings.put(ASSIGNMENTS_IN_ROUND_SETTING, setting);
                    settingsToUpsert.add(setting);
                    System.debug(LoggingLevel.INFO, '[Group: ' + grp.Name + 
                            '] Initialized stacked round robin settings - starting at rating level ' + minimumRating + 
                            ' with ' + selectedUsers.size() + ' eligible user(s)');
                }
            }
        }
        if (settingsToUpsert.size()>0) upsert settingsToUpsert;
        return this.groupToUsersMap;
/*        if (groupToUsersMap==null) return null;
        if (this.policyInvocationContext==null) return groupToUsersMap;
        if (this.agentRatingValues==null) return groupToUsersMap;

        // Filter out certain users for certain groups and policies, if weighted distribution is in place
        List<DecsOnD__ConfigurationSetting__c> settingsToUpsert = new List<DecsOnD__ConfigurationSetting__c>();
        for (Id groupId : groups.keySet()) {
            Map<String, DecsOnD__ConfigurationSetting__c> groupSettings = this.customSettingsByGroup.get(groupId);
            if ((groupSettings==null) || (groupSettings.size()==0)) continue;
            Group grp = groups.get(groupId);
            String algorithm = getSettingValue(groupSettings, CUSTOM_ALGORITHM_SETTING);
            if (String.isBlank(algorithm)) continue;
            if (CUSTOM_ALGORITHM_NAME!=algorithm.trim()) {
                System.debug(LoggingLevel.WARN, '[Group: ' + grp.Name + 
                        '] Unexpected value for RoundRobinCustomAlgorithm custom setting: ' + algorithm);
                continue;
            }

            List<User> users = groupToUsersMap.get(groupId);
            if ((users==null) || (users.size()==0)) continue;
            // Minimum rating stores the lowest agent rating eligible in the current round
            String minimumRating = getSettingValue(groupSettings, MIN_AGENT_RATING_SETTING);
            // The count of the number of agents to process in this round
            // will be decremented for every assignment
            DecsOnD__ConfigurationSetting__c numAssignmentsInRoundSetting = getSetting(groupSettings, ASSIGNMENTS_IN_ROUND_SETTING);
            if (String.isBlank(minimumRating)) {
                minimumRating = this.agentRatingValues[0].getValue();
                DecsOnD__ConfigurationSetting__c minimumRatingSetting = 
                    createNewSetting(groupId, MIN_AGENT_RATING_SETTING, minimumRating);
                settingsToUpsert.add(minimumRatingSetting);
            } else if ((numAssignmentsInRoundSetting!=null) && (numAssignmentsInRoundSetting.DecsOnD__Value__c=='0')) {
                // When counter hits 0 it is time to move to the next round
                String newRating = null;
                // Check up to the last value but one
                // if we're at the end we need to loop back to the beginning
                for (integer i=0;i<(this.agentRatingValues.size()-1);i++) {
                    if (this.agentRatingValues[i].getValue()==minimumRating) {
                        newRating = this.agentRatingValues[i+1].getValue();
                        integer numUsersInCurrentRound = getEligibleUsersByRating(users, minimumRating).size();
                        integer numUsersInNextRound = getEligibleUsersByRating(users, newRating).size();
                        // If there are no users with a lower rating, then start over
                        if (numUsersInNextRound==numUsersInCurrentRound) newRating = null;
                        break;
                    }
                }
                // If we hit the end (or if the rating values are adjusted while algorithm is running) -- go back to first
                if (newRating==null) {
                    newRating = this.agentRatingValues[0].getValue();
                }
                System.debug(LoggingLevel.INFO, '[Group: ' + grp.Name + 
                        '] Completed all round robin assignments for rating level ' + minimumRating + 
                        '. Next round has minimum rating of ' + newRating);
                minimumRating = newRating;
            }
            List<User> selectedUsers = getEligibleUsersByRating(users, minimumRating);
            if (selectedUsers.size()==0) {
                System.debug(LoggingLevel.WARN, '[Group: ' + groups.get(groupId).Name + 
                        '] No users with rating ' + minimumRating + ' or better. Ignoring rating and proceeding with regular round robin');
                selectedUsers = users;
            } else if (numAssignmentsInRoundSetting==null) {
                numAssignmentsInRoundSetting = 
                    createNewSetting(groupId, ASSIGNMENTS_IN_ROUND_SETTING, String.valueOf(selectedUsers.size()));
                settingsToUpsert.add(numAssignmentsInRoundSetting);
            } 
            if (selectedUsers.size()==0) {
                numAssignmentsInRoundSetting.DecsOnD__Value__c = String.valueOf(selectedUsers.size());
                settingsToUpsert.add(numAssignmentsInRoundSetting);
            }

        }
        if (settingsToUpsert.size()>0) upsert settingsToUpsert;
        return groupToUsersMap;
        */
    }

    // --------------------
    // --------------------
    global override Map<Id, User> queryEligibleUsers(Set<Id> userIds, Set<Id> roleIds) {   
        if (userIds==null) {
            if (roleIds==null) {
                return null;                
            } else {
                userIds = new Set<Id>();
            }
        } else if (roleIds==null) {
            roleIds = new Set<Id>();
        }
        return new Map<Id, User>([select Id, Name, FirstName, LastName, LastLoginDate, UserRoleId, Available_for_Assignment__c, Agent_Rating__c from User where (Id in :userIds or UserRoleId in :roleIds) and IsActive = true and Available_for_Assignment__c = true order by Agent_Rating__c asc nulls last, Id asc nulls last]);
    }

    // --------------------
    // --------------------
    void initializeAgentRatings() {
        DescribeFieldResult ratingPicklistDesc = User.Agent_Rating__c.getDescribe();
        if (ratingPicklistDesc.getType()!=DisplayType.Picklist) {
            System.debug(LoggingLevel.WARN, 'User.Agent_Rating__c is not a picklist field. Unable to apply stacked round robin algorithm');            
            return;
        } else {
            List<Schema.PicklistEntry> ratingValues = ratingPicklistDesc.getPicklistValues();
            List<String> activeRatings = new List<String>();
            for (Schema.PicklistEntry entry : ratingValues) {
                if (entry.isActive()) activeRatings.add(entry.getValue());
            }
            if (activeRatings.size()==0) {
                System.debug(LoggingLevel.WARN, 'User.Agent_Rating__c does not have any active values. Unable to apply stacked round robin algorithm');            
                return;
            } else {
                System.debug(LoggingLevel.INFO, 'Found ' + activeRatings.size() + ' active agent rating values for the stacked round robin algorithm');            
                activeRatings.add(BLANK_RATING);
                this.agentRatings = activeRatings;
                this.agentRatingRankings = new Map<String, Integer>();
                for (integer i=0;i<activeRatings.size();i++) {
                    // Blank rating gets ranking of 0
                    this.agentRatingRankings.put(activeRatings.get(i), activeRatings.size()-i-1);
                }
            }
        }
    }

    @TestVisible
    void loadCustomSettingsByGroup(Map<Id, Group> groups) {
        if (this.customSettingsByGroup!=null) return;
        this.customSettingsByGroup = new Map<Id, Map<String, DecsOnD__ConfigurationSetting__c>>();
        if (this.policyInvocationContext==null) return;
        if ((groups==null) || (groups.size()==0)) return;
        String policyMainRecordType = policyInvocationContext.getMainRecordTypeName();
        String policyName = policyInvocationContext.getPolicyName();

        Set<String> groupIdsAndNames = new Set<String>();
        Map<String, Id> groupNameToIdMap = new Map<String, Id>();
        for (Group grp : groups.values()) {
            groupIdsAndNames.add(grp.Id);
            groupIdsAndNames.add(grp.DeveloperName);
            groupNameToIdMap.put(grp.DeveloperName, grp.Id);
        }
        DecsOnD__ConfigurationSetting__c[] settings = [Select Name, DecsOnD__ElementName__c, DecsOnD__SettingType__c, DecsOnD__Value__c From DecsOnD__ConfigurationSetting__c 
                      Where (DecsOnD__Object__c =:policyMainRecordType OR DecsOnD__Object__c = null) 
                            And (DecsOnD__PolicyName__c =:policyName OR DecsOnD__PolicyName__c = null) 
                            And DecsOnD__ElementName__c in :groupIdsAndNames];
        if (settings.size()==0) return;
        for (DecsOnD__ConfigurationSetting__c setting : settings) {            
            if (String.isBlank(setting.DecsOnD__ElementName__c)) continue;
            Id groupId = groupNameToIdMap.get(setting.DecsOnD__ElementName__c);
            if (groupId==null) {
                // Guaranteed to be a valid ID at this point
                groupId = Id.valueOf(setting.DecsOnD__ElementName__c);
            }
            Map<String, DecsOnD__ConfigurationSetting__c> groupSettings = this.customSettingsByGroup.get(groupId);
            if (groupSettings==null) {
                groupSettings = new Map<String, DecsOnD__ConfigurationSetting__c>();
                this.customSettingsByGroup.put(groupId, groupSettings);
            }
            groupSettings.put(setting.DecsOnD__SettingType__c, setting);
        }
    }

    // --------------------
    @TestVisible
    DecsOnD__ConfigurationSetting__c getGroupSetting(Id groupId, String settingName) {
        if (groupId==null) return null;
        if (this.customSettingsByGroup==null) return null;
        Map<String, DecsOnD__ConfigurationSetting__c> groupSettings = this.customSettingsByGroup.get(groupId);
        return getSetting(groupSettings, settingName);
    }

    // --------------------
    static DecsOnD__ConfigurationSetting__c getSetting(Map<String, DecsOnD__ConfigurationSetting__c> settings, String settingName) {
        if (settings==null) return null;
        return settings.get(settingName);
    }

    // --------------------
    static String getSettingValue(Map<String, DecsOnD__ConfigurationSetting__c> settings, String settingName) {
        DecsOnD__ConfigurationSetting__c setting = getSetting(settings, settingName);
        if (setting==null) return null;
        return setting.DecsOnD__Value__c;
    }

    // --------------------
    @TestVisible
    DecsOnD__ConfigurationSetting__c createNewSetting(Id groupId, String settingType, String value) {
        DecsOnD__ConfigurationSetting__c setting = new DecsOnD__ConfigurationSetting__c();
        if (this.policyInvocationContext!=null) {
            setting.DecsOnD__Object__c = policyInvocationContext.getMainRecordTypeName();
            setting.DecsOnD__PolicyName__c = policyInvocationContext.getPolicyName();
        }
        setting.DecsOnD__ElementName__c = groupId;
        setting.DecsOnD__SettingType__c = settingType;
        setting.DecsOnD__Value__c = value;
        String settingFullName = groupId + '_' + settingType;
        setting.DecsOnD__External_ID__c = settingFullName;
        integer maxLength = 38;
        if (settingFullName.length()>maxLength) {
            String origName = settingFullName;
            settingFullName = settingFullName + '_' + Math.roundToLong(1000000 * Math.random());
            settingFullName = '_' + settingFullName.right(maxLength-1);
        }
        setting.Name = settingFullName;
        return setting;
    }

    // --------------------
    // --------------------
    @TestVisible
    String findHighestRatingWithEligibleUsers(List<User> allUsers) {
        if (allUsers==null) return null;
        if (this.agentRatings==null) return null;
        Map<String, List<User>> allUsersByRating = getEligibleUsersByRating(allUsers, null);
        // Find max rating that has at least one eligible user
        for (String rating : this.agentRatings) {                    
            if (allUsersByRating.containsKey(rating)) return rating;
        } 
        return null;
    }

    List<User> getAllEligibleUsers(List<User> allUsers, String lowestRatingAllowed) {
        if (allUsers==null) return null;
        Map<String, List<User>> allUsersByRating = getEligibleUsersByRating(allUsers, lowestRatingAllowed);
        List<User> allEligibleUsers = new List<User>();
        for (String rating : this.agentRatings) {                    
            List<User> usersWithRating = allUsersByRating.get(rating);
            if (usersWithRating!=null) allEligibleUsers.addAll(usersWithRating);
        } 
        return allEligibleUsers;
    }

    Map<String, List<User>> getEligibleUsersByRating(List<User> allUsers, String lowestRatingAllowed) {
        if (allUsers==null) return null;
        integer lowestRatingAllowedRank =0;
        if (String.isBlank(lowestRatingAllowed)) lowestRatingAllowed = BLANK_RATING;
        if (this.agentRatingRankings.containsKey(lowestRatingAllowed)) {
            lowestRatingAllowedRank = this.agentRatingRankings.get(lowestRatingAllowed);
        }
        
        Map<String, List<User>> selectedUsers = new Map<String, List<User>>();
        for (User usr : allUsers) {
            String rating = usr.Agent_Rating__c;
            integer ratingRank = 0;
            // Blank ratings are considered equal to the lowest available
            if (String.isBlank(rating)) rating = BLANK_RATING;
            if (this.agentRatingRankings.containsKey(rating)) {
                ratingRank = this.agentRatingRankings.get(rating);
            }
            if (ratingRank>=lowestRatingAllowedRank) {
                List<User> usrList = selectedUsers.get(rating);
                if (usrList==null) {
                    usrList = new List<User>();
                    selectedUsers.put(String.isBlank(rating)?BLANK_RATING:rating, usrList);
                }
                usrList.add(usr);
            }
        }
        return selectedUsers;
    }

    /**
      * Helper method used to find round-robin users for cases where there is no business policy (such as the Welcome Call)
      */
    public static User[] findNextEligibleUsers(String objectTypeName, String policyName, Group grp, integer numUsersRequested) {       
        if (grp==null) return null;
        if (numUsersRequested<=0) return null;
        
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('AssignmentMode', DecsOnD.AssignmentHelper.MODE_ROUND_ROBIN);
        parameters.put('PolicyName', policyName);
        parameters.put('ObjectType', objectTypeName);
        parameters.put('SkipLastAssignedUserSettingsUpdate', true);
        
        CustomAssignmentHelper helper = new CustomAssignmentHelper();
        List<User> users = new List<User>();
        for (integer i=0;i<numUsersRequested;i++) {
            if (i==(numUsersRequested-1)) parameters.remove('SkipLastAssignedUserSettingsUpdate');
            users.add(helper.getAssignedOwner(grp, parameters));
        }
        return users;
    }
}