@isTest
private class Test_UserPreferenceTrigger {
	
	private static testmethod void testUserPreferenceTrigger() {
		//Create User
		User testUser = TestUtils.createTestUser(true);

		Test.startTest();
		//Test After Insert
		User_Preference__c testUP = new User_Preference__c(
			User__c = testUser.Id,
			Available_for_Assignment__c = true
		);
		insert testUP;

		//Check User value
		testUser = [Select Id, Available_for_Assignment__c from User where Id = :testUser.id Limit 1][0];
		system.assert(testUser.Available_for_Assignment__c);

		//Test After Update
		testUP.Available_for_Assignment__c = false;
		update testUP;
		//Check User value
		testUser = [Select Id, Available_for_Assignment__c from User where Id = :testUser.id Limit 1][0];
		system.assertEquals(false,testUser.Available_for_Assignment__c);

		Test.stopTest();
	}
	
	
}