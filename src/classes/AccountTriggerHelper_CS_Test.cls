@isTest
private class AccountTriggerHelper_CS_Test {
    
    @isTest static void testOwnershipChange() {
        list<Account> testAccount = [Select Id, Name, OwnerId, Acct_Type__c from Account];
        list<User> testUser = [Select Id, Username from User where Username = 'testuser2324234234@codescience.com'];
        test.startTest();
        testAccount[0].ownerId = testUser[0].Id;
        testAccount[0].Acct_Type__c = 'End Customer';
        update testAccount[0];
        test.stopTest();
        Contact[] contacts = [select Id, OwnerId from Contact where AccountId =: testAccount[0].Id];
        system.assertEquals(testUser[0].id, contacts[0].ownerId); // un comment back
        system.assertEquals(testUser[0].id, contacts[1].ownerId); // un comment back

        //Check Executing Property
        AccountTriggerHelper_CS testHandler = new AccountTriggerHelper_CS(true, 1);
        system.assert(testHandler.IsTriggerContext); 
    }

    // SCS - Removing per Sprint.ly #119 - See comments in AccountTriggerHelper_CS
/*    @isTest static void testChildToParentUpdates() {
        Id accRecTypeId = CSUtils.getRecordTypeId('Account','Sales Account');
        list<Account> testParentAccount1 = [Select Id, Name, OwnerId, Acct_Type__c from Account];
        Account testParentAccount2 = new Account(Name='Fake Parent Company 1');
        insert testParentAccount2;
        Account testChildAccount = new Account(Name='Fake Child Company', ParentId = testParentAccount1[0].Id,
                        Account_Hardware_Accessory_Tier__c  = 'Test Hardware Tier',
                        Account_Service_Tier__c = 'Test Service Tier',
                        Account_Bundled_Tier__c = 'Test Bundled Tier',
                        Acct_Type__c = 'End Customer',
                        Bundled__c = true,
                        RecordTypeId = accRecTypeId);
        Test.startTest();
        insert testChildAccount;
        testChildAccount.ParentId = testParentAccount2.Id;
        testChildAccount.Account_Hardware_Accessory_Tier__c = 'Test Accessory Tier';
        update testChildAccount;
        Test.stopTest();
        testParentAccount1 = [Select    Id, Name, OwnerId, Acct_Type__c, Account_Hardware_Accessory_Tier__c, 
                                        Account_Service_Tier__c, Account_Bundled_Tier__c
                              from      Account
                              where     Id = : testParentAccount1[0].Id];
        testParentAccount2 = [Select    Id, Name, OwnerId, Acct_Type__c, Account_Hardware_Accessory_Tier__c, 
                                        Account_Service_Tier__c, Account_Bundled_Tier__c
                              from      Account
                              where     Id = : testParentAccount2.Id];
        system.assertEquals('Test Hardware Tier', testParentAccount1[0].Account_Hardware_Accessory_Tier__c);
        system.assertEquals('Test Bundled Tier', testParentAccount1[0].Account_Bundled_Tier__c);
        system.assertEquals('Test Accessory Tier', testParentAccount2.Account_Hardware_Accessory_Tier__c);
        system.assertEquals('Test Bundled Tier', testParentAccount2.Account_Bundled_Tier__c);
    }
*/
    
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

        List<Contact> testContacts = new List<Contact>();
        testContacts.add(
            new Contact(
                AccountId = testAccount.id, LastName = 'Foobar', FirstName='TestUser'
            )
        );
        testContacts.add(
            new Contact(
                AccountId = testAccount.id, LastName = 'Foobar2', FirstName='TestUser2'
            )
        );
        insert testContacts;
    }
}