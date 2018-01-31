@isTest
private class Test_AccountTrigger {
    
    static Account a;
    static Contact c1;
    static Contact c2;
    static User u1;
    static User u2;
    
    static testMethod void testOwnershipChange() {
        list<Installation_Coordinator_Assignment_Rule__c> ICARList = UtilsTest.createInstallCoordAsstRule();
        setupTestDB();
        test.startTest();
        a.ownerId = u2.Id;
        update a;
        test.stopTest();
        Contact[] contacts = [select Id, OwnerId from Contact where Id =: c1.id or Id =:c2.Id];
        system.assertEquals(u2.id, contacts[0].ownerId);
        system.assertEquals(u2.id, contacts[1].ownerId);
    }
    
    static testMethod void testPopulatePriceBook() {
        list<Installation_Coordinator_Assignment_Rule__c> ICARList = UtilsTest.createInstallCoordAsstRule();
        PricebookSetup__c Pricebooksetup = UtilsTest.CreatePricebookSetup();
        setupTestDB();
        test.startTest();
        a.Contract_Type__c = 'standard'; 
        a.CPQ_PRICING_MODEL__c = 'MSRP';  
        a.GSA_Eligible__c = 'Eligible';
        a.Sub_Type__c = 'VAR';
        a.AccountNumber = '12345'; 
        update a;
        test.stopTest();
        Contact[] contacts = [select Id, OwnerId from Contact where Id =: c1.id or Id =:c2.Id];
     }
    
    private static void setupTestDB(){
        Profile p = [select Id from Profile where Name = 'Standard User'];
        u1 = new User(FirstName = 'TestUser15645645645', LastName = 'CodeScience', profileId = p.id,
                    Username = 'testuser1657567@codescience.com', Email = 'testuser1@danshahin.com',
                    Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
                    timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US');
        u2 = new User(FirstName = 'TestUser234546', LastName = 'CodeScience', profileId = p.id,
                    Username = 'testuser2324234234@codescience.com', Email = 'testuser2@danshahin.com',
                    Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
                    timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US');
        insert u1;
        insert u2;
        a = new Account(Name='Fake Company Inc', ownerId = u1.id);
        insert a;
        c1 = new Contact(AccountId = a.id, LastName = 'Foobar', FirstName='TestUser');
        c2 = new Contact(AccountId = a.id, LastName = 'Foobar2', FirstName='TestUser2');
        insert c1;
        insert c2;
    }
    
    

}