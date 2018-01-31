/**
 * Assignment helpers for the Welcome_Call__c object
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
public class WelcomeCallAssignmentHelper extends AssignmentHelperBase{
    public static final String DEFAULT_WELCOME_CALL_QUEUE = 'Welcome_Call_Queue';

    public WelcomeCallAssignmentHelper() {
        super();
    }
    public WelcomeCallAssignmentHelper(LoggingLevel logLevel) {
        super(logLevel);
    }
    public WelcomeCallAssignmentHelper(boolean throwExceptionOnError) {
        super(throwExceptionOnError);
    }

    public String assignNewWelcomeCalls(Welcome_Call__c[] calls) {
        String operation = 'Assign new welcome calls';
        try {
            if (calls==null) return reportError(operation, 'no calls to assign');
            if (calls.size()==0) return reportError(operation, 'no calls to assign');
            Group queue = [select Id, Name, DeveloperName, Type from Group where Type = 'Queue' and DeveloperName = :DEFAULT_WELCOME_CALL_QUEUE];
            if (queue==null) return reportError(operation, 'queue ' + DEFAULT_WELCOME_CALL_QUEUE + ' not found');

            User[] usrs = findNextEligibleUsers(queue, calls.size());
            if ((usrs==null) || (usrs.size()==0)) return reportError(operation, 'Unable to find any eligible users in queue ' + DEFAULT_WELCOME_CALL_QUEUE);

            integer usrIndex = 0;
            for (Welcome_Call__c call : calls) {
                call.OwnerId = usrs[usrIndex].Id;
                System.debug('Assigned new call for account ' + call.Account__c + ' to user ' + usrs[usrIndex].Name);
                usrIndex++;
                usrIndex = Math.mod(usrIndex, usrs.size());
            }
            return null;
        }
        catch (Exception e) {
            return reportError(operation, e);
        }
    }

    public User[] findNextEligibleUsers(Group grp, integer numUsersRequested) {     
        System.debug('**** Looking for ' + numUsersRequested + ' eligible users for Welcome Call assignment');
        // Switch to use built-in Decisions on Demand support
//        User[] users = findNextEligibleUsers(grp, 'Welcome_Call__c', 'Assignment', numUsersRequested);
        User[] users = CustomAssignmentHelper.findNextEligibleUsers('Welcome_Call__c', 'Assignment', grp, numUsersRequested);
        System.debug('**** Found ' + ((users==null)?0:users.size()) + ' eligible users');
        return users;
    }  
}