@isTest
private class Test_CaseTrigger {

    static testMethod void testCopyFleetAccountOwnerEmail() {
        User user = new User();
        user.ProfileId = UserInfo.getProfileId();
        user.Username = 'test' + System.currentTimeMillis() + '@test.com';
        user.LastName = 'Test';
        user.Email = 'test@test.com';
        user.Alias = 'Test';
        user.CommunityNickname = 'UserWithRoleTest';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        insert user;

        Account account = new Account();
        account.Name = 'Test';
        account.OwnerId = user.Id;
        insert account;
        
        Case theCase = new Case();
        theCase.AccountId = account.Id;
        theCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        theCase.Fleet_Account__c = account.Id;
        insert theCase;
        
        System.assertEquals(user.Email, [select Fleet_Account_Owner_Email__c from Case where Id = :theCase.Id].Fleet_Account_Owner_Email__c);
    }
    
    static testMethod void testEscalationChange() {

        Account account = new Account();
        account.Name = 'Test';
        insert account;
        
        Case theCase = new Case();
        theCase.AccountId = account.Id;
        theCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        theCase.Fleet_Account__c = account.Id;
        insert theCase;
        System.assertEquals(false, [select Notify__c from Case where Id = :theCase.Id].Notify__c);
        
        Test.startTest();
        
        theCase.IsEscalated = true;
        update theCase;
        
        Test.stopTest();
        
        System.assertEquals(true, [select Notify__c from Case where Id = :theCase.Id].Notify__c);
    }

}