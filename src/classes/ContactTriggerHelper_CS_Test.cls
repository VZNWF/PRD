@isTest
private class ContactTriggerHelper_CS_Test {
	
    @isTest static void testOwnershipChange() {
		list<Account> testAccount = [Select Id, Name, OwnerId, Acct_Type__c from Account];
		list<User> testUsers = [Select Id, Username from User];
		User testUser1, testUser2;
		for(user u : testUsers) {
			if(u.Username == 'testuser1657567@codescience.com'){ testUser1 = u; }
			else if(u.Username == 'testuser2324234234@codescience.com') { testUser2 = u; }
		}
        test.startTest();
        Contact testContact = new Contact(
        	FirstName = 'NewCon', LastName = 'CodeScience', 
        	accountId = testAccount[0].id, ownerId = testUser2.id
        );
        insert testContact;
        test.stopTest();
        testContact = [select OwnerId from Contact where Id =: testContact.id];
        //verify that the owner of the new contact is u1 not u2
 		system.assertEquals(testUser1.id, testContact.ownerId);

		//Check Executing Property
		ContactTriggerHelper_CS testHandler = new ContactTriggerHelper_CS(true, 1);
		system.assert(testHandler.IsTriggerContext);

    }
    
    @testSetup static void setupTestDB(){
		Profile p = [select Id from Profile where Name = 'Standard User'];
    	List<User> testUsers = new List<User>();
    	testUsers.add(
    		new User(
    			FirstName = 'TestUser15645645645', LastName = 'CodeScience', profileId = p.id,
    			Username = 'testuser1657567@codescience.com', Email = 'testuser1@danshahin.com',
    			Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
    			timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US'
    		)
    	);
		testUsers.add(
			new User(
				FirstName = 'TestUser234546', LastName = 'CodeScience', profileId = p.id,
    			Username = 'testuser2324234234@codescience.com', Email = 'testuser2@danshahin.com',
    			Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
    			timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US'
    		)
		);
    	insert testUsers;
    	
    	Account testAccount = new Account(Name='Fake Company Inc', ownerId = testUsers[0].id);
    	insert testAccount;    	
    }
}