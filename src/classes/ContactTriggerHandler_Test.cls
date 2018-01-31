@isTest
private class ContactTriggerHandler_Test {
    
    static Account a;
    static Contact c;
    static User u1;
    static User u2;
    
    static testMethod void testOwnershipChange() {
        setupTestDB();
        test.startTest();
        c = new Contact(FirstName = 'NewCon', LastName = 'CodeScience', accountId = a.id, ownerId = u2.id);
        insert c;
        test.stopTest();
        c = [select OwnerId from Contact where Id =: c.id];
        //verify that the owner of the new contact is u1 not u2
        system.assertEquals(u1.id, c.ownerId);
    }
    
    private static void setupTestDB(){
        Profile p = [select Id from Profile where Name = 'Standard User'];
        u1 = new User(FirstName = 'TestUser13234324', LastName = 'CodeScience', profileId = p.id,
                    Username = 'testuser14534534543@codescience.com', Email = 'testuser1@danshahin.com',
                    Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
                    timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US');
        u2 = new User(FirstName = 'TestUser23242342', LastName = 'CodeScience', profileId = p.id,
                    Username = 'testuser23212312@codescience.com', Email = 'testuser2@danshahin.com',
                    Alias = 'dfsdff', emailencodingkey ='UTF-8', languagelocalekey='en_US',
                    timezonesidkey = 'America/Los_Angeles', localesidkey = 'en_US');
        insert u1;
        insert u2;
        a = new Account(Name='Fake Company Inc', ownerId = u1.id);
        insert a;
        
    }
    
    static testMethod void testContactRolesAfterInsert() {
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        UtilsTest.CreateInstallerSettings();
        Account Acc = UtilsTest.createAccount();
        //Affiliate__c Aff = UtilsTest.CreateAffiliate();
        Affiliate__c afl = new Affiliate__c();
        afl.Affiliate_Name__c = 'Test Affiliate';
        afl.Affiliate_Type__c = 'Active';
        afl.callout__c = true;
        insert afl;
        Opportunity opp = UtilsTest.CreateOpportunity(acc);
        test.startTest();
        c = new Contact(FirstName = 'NewCon2', LastName = 'CodeScience2', accountId = Acc.id, Opportunity_ID__c = opp.Id, Contact_role__c = 'Install Main POC',Affiliate_ID__c = afl.Id,contact_Type__c = 'Installer',callout__c = false,certificate__c = '11123');
        insert c;
        test.stopTest();
        
    }
    
    static testMethod void testContactRolesUpdate() {
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        UtilsTest.CreateInstallerSettings();
        Account Acc = UtilsTest.createAccount();
        Affiliate__c afl = new Affiliate__c();
        afl.Affiliate_Name__c = 'Test Affiliate';
        afl.Affiliate_Type__c = 'Active';
        afl.callout__c = true;
        insert afl;
        Opportunity opp = UtilsTest.CreateOpportunity(acc);
        Contact con = UtilsTest.CreateContact(Afl);
        Con.FirstName = 'NewCon';
        Con.callout__c = false;
        Con.Affiliate_ID__C = Afl.Id;
        Con.Affiliate_ID__c = afl.Id;
        Con.contact_Type__c = 'Installer';
        Con.callout__c = false;
        Con.certificate__c = '11123';
        test.startTest();
        Update con;
        test.stopTest();
        
    }
}