trigger WelcomeCallTrigger on Welcome_Call__c (before insert) {
   	if (System.isFuture() || System.isBatch() || Test.isRunningTest()) return;
   	WelcomeCallAssignmentHelper helper = new WelcomeCallAssignmentHelper();
	helper.assignNewWelcomeCalls(trigger.new);
}