@isTest
private class ETA_ResourceTest {

    private static testmethod void InsertAffiliate()
    {
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        test.startTest();
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        ETA_Resource.InsertResourceFromAffiliate(aff.Id);
        
        test.stopTest();
        
    }
    
    static testMethod void UpdateAffiliate() 
    {
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        test.startTest();
        aff.Affiliate_Status__c = 'Inactive';
        update aff;
        
        ETA_Resource.UpdateResourceFromAffiliate(aff.Id);
        test.stopTest();
        
        //objClass.deserializeResponse(strResult);
    }
    
     static testMethod void UpdateAffiliateNegativeResponseTest() 
    {
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockNegativeResponses());
        
        test.startTest();
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        aff.Affiliate_Status__c = 'Inactive';
        update aff;
        
        ETA_Resource.UpdateResourceFromAffiliate(aff.Id);
        
        test.stopTest();
        
        //objClass.deserializeResponse(strResult);
    }
    
    static testMethod void InsertContactTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        //insert con;
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
            ETA_Resource.InsertResourceFromContact(con.Id); 
        test.stopTest();
        
    }
    
    static testMethod void UpdateContactTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        //insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        con.ETA_Status__c = 'Linked';
        con.ETA_Description__c = 'ETA Linkage Successfull';
        con.Last_ETA_Sync__c = DateTime.Now();  
        update con;
        
        Contact con1 = UtilsTest.createContact(aff);
        con1.ETA_Status__c = 'Unlinked';
        con1.ETA_Description__c = 'ETA Linkage Successfull';
        con1.Last_ETA_Sync__c = DateTime.Now();  
        update con1;
        
        Contact con2 = UtilsTest.createContact(aff);
        con2.ETA_Status__c = 'Unlinked';
        con2.ETA_Description__c = 'Empty Response';
        con2.Last_ETA_Sync__c = DateTime.Now();   
        update con2;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
            ETA_Resource.UpdateResourceFromContact(con1.Id); 
          //  ETA_Resource.InsertUserFromContact(con1.Id);
        test.stopTest();
        
    }
    static testMethod void InsertUserTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        //insert a;
        system.debug('@@@@@@@@@@@@1');
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        system.debug('@@@@@@@@@@@@2');
        Contact con = UtilsTest.createContact(aff);
        con.ETA_Status__c = 'Linked';
        con.ETA_Description__c = 'ETA Linkage Successfull';
        con.Last_ETA_Sync__c = DateTime.Now();  
        update con;
        system.debug('@@@@@@@@@@@@3');
        Contact con1 = UtilsTest.createContact(aff);
        con1.Email = 'test@test.com';
        con1.ETA_Status__c = 'Unlinked';
        con1.ETA_Description__c = 'ETA Linkage Successfull';
        con1.Last_ETA_Sync__c = DateTime.Now();  
        update con1;
        system.debug('@@@@@@@@@@@@4');
        Contact con2 = UtilsTest.createContact(aff);
        system.debug('@@@@@@@@@@@@5');
        con2.ETA_Status__c = 'Unlinked';
        con2.ETA_Description__c = 'Empty Response';
        con2.Last_ETA_Sync__c = DateTime.Now();   
        update con2;
        system.debug('@@@@@@@@@@@@6');
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        system.debug('@@@@@@@@@@@@7'+con1.Id);
        test.startTest();
            ETA_Resource.InsertUserFromContact(con1.Id);           
        system.debug('@@@@@@@@@@@@8');
        test.stopTest();
        
    }
    static testMethod void UpdateUserTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        //insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        con.Email = 'test@test.com';
        update con;
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
            ETA_Resource.UpdateUserFromContact(con.Id); 
        test.stopTest();
        
    }
    
    static testMethod void InsertRejectedBucket() 
    {
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        test.startTest();
        aff.Affiliate_Status__c = 'Inactive';
        update aff;
        
        ETA_Resource.InsertRejectedBucketForAffiliate(aff.Id);
        test.stopTest();
        
        //objClass.deserializeResponse(strResult);
    }
    static testMethod void UpdateRejectedBucket() 
    {
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        
        insert aff;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        test.startTest();
        aff.Affiliate_Status__c = 'Inactive';
        update aff;
        
        ETA_Resource.UpdateRejectedBucketForAffiliate(aff.Id);
        test.stopTest();
        
        //objClass.deserializeResponse(strResult);
    }
    
    /*
    static testMethod void InsertUserContactTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        con.ETA_Status__c = 'Linked';
        con.ETA_Description__c = 'ETA Linkage Successfull';
        con.Last_ETA_Sync__c = DateTime.Now();  
        insert con;
        
        Contact con1 = UtilsTest.createContact(aff);
        con1.ETA_Status__c = 'Unlinked';
        con1.ETA_Description__c = 'ETA Linkage Successfull';
        con1.Last_ETA_Sync__c = DateTime.Now();  
        insert con1;
        
        Contact con2 = UtilsTest.createContact(aff);
        con2.ETA_Status__c = 'Unlinked';
        con2.ETA_Description__c = 'Empty Response';
        con2.Last_ETA_Sync__c = DateTime.Now();   
        insert con2;
        
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
          //  ETA_Resource.UpdateResourceFromContact(con.Id); 
            ETA_Resource.InsertUserFromContact(con.Id);
        test.stopTest();
        
    }*/
    /*
    static testMethod void InsertUserTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        insert con;
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
            ETA_Resource.InsertUserFromContact(con.Id); 
        test.stopTest();
        
    }
    
    static testMethod void UpdateUserTest(){
        UtilsTest.CreateInstallerSettings();
        Account a = UtilsTest.createAccount();
        insert a;
        
        Affiliate__c aff = UtilsTest.CreateAffiliate();
        aff.Account__c = a.Id;
        aff.Callout__c = false;
        insert aff;
        
        Contact con = UtilsTest.createContact(aff);
        insert con;
        Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
        
        test.startTest();
            ETA_Resource.UpdateUserFromContact(con.Id); 
        test.stopTest();
        
    }*/
    
}