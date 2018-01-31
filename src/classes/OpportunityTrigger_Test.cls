/****************************************************************
Created: 25 Feb 2013
Author: Aaron Pettitt (CodeScience)
Purpose : test class for the Opportunity trigger
Modifications:
******************************************************************/
@isTest(SeeAllData=true)
private class OpportunityTrigger_Test {
    
    static testMethod void testCreateWelcomeCallRecords() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        //ist<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
                
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.Contract_Type__c = 'custom';
        account.Price_Book__c = Test.getStandardPricebookId();
        //Add By Satish
        account.Account_Bundled_Tier__c = 'DIR-0';
        account.Account_Hardware_Accessory_Tier__c = 'DIR-0';
        account.Account_Service_Tier__c = 'DIR-0';     
        insert account;        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
               
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'New Business';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        //opportunity.Pricebook2Id = Test.
         opportunity.Shipping_Street2__c = 'Test';
        opportunity.Shipping_Street3__c = 'Test Address';
        opportunity.Multiple_PO__c = true;
        opportunity.CreateOrder__c = false;
        insert opportunity;
        
        opportunity.CreateOrder__c = true;
        update opportunity;
        
        opportunity opp = [select id,Pricebook2Id from opportunity where Id = :opportunity.id];
        
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.Role = 'Signatory';
        insert opportunityContactRole;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        //opportunityLineItem.ProductId = pricebookEntry.Product2Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
        opportunity.StageName = 'Partner Integration - Final';
        update opportunity;
        
        System.assertEquals(true, [select IsWon from Opportunity where Id = :opportunity.Id].IsWon);
        
        System.assertEquals(0, [select count() from Welcome_Call__c where Account_Name__c = :account.Id and Opportunity_Name__c = :opportunity.Id]);
    }
    
    static testMethod void testCreateWelcomeCallRecordsExistingCallForAccount() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.Completed_Account_Set_up__c = DateTime.now();
        insert account;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        
        Welcome_Call__c welcomeCall = new Welcome_Call__c();
        welcomeCall.Account_Name__c = account.Id;
        insert welcomeCall;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        insert opportunity;
        
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.Role = 'Signatory';
        insert opportunityContactRole;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
        opportunity.StageName = 'Partner Integration - Final';
        update opportunity;
        
        System.assertEquals(true, [select IsWon from Opportunity where Id = :opportunity.Id].IsWon);
        
        System.assertEquals(0, [select count() from Welcome_Call__c where Account_Name__c = :account.Id and Opportunity_Name__c = :opportunity.Id]);
    }
    
        static testMethod void testCreateWelcomeCallRecordsExistingCallForParentAccount() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        insert account;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        
        Welcome_Call__c welcomeCall = new Welcome_Call__c();
        welcomeCall.Account_Name__c = parentAccount.Id;
        insert welcomeCall;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        opportunity.Shipping_Street2__c = 'Test'; 
        opportunity.Multiple_Address__c=false;
        insert opportunity;
        
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.Role = 'Signatory';
        insert opportunityContactRole;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
        opportunity.StageName = 'Partner Integration - Final';
        update opportunity;
        
        System.assertEquals(true, [select IsWon from Opportunity where Id = :opportunity.Id].IsWon);
        
        System.assertEquals(0, [select count() from Welcome_Call__c where Account_Name__c = :account.Id and Opportunity_Name__c = :opportunity.Id]);
    }

    static testMethod void testCreateWelcomeCallRecordsExistingCallForSiblingAccount() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.PO_Required__c=true;
        insert account;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        
        Welcome_Call__c welcomeCall = new Welcome_Call__c();
        welcomeCall.Account_Name__c = siblingAccount.Id;
        insert welcomeCall;
        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        insert opportunity;
        
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.Role = 'Signatory';
        insert opportunityContactRole;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
        opportunity.StageName = 'Partner Integration - Final';
        update opportunity;
        
        System.assertEquals(true, [select IsWon from Opportunity where Id = :opportunity.Id].IsWon);
        
        System.assertEquals(0, [select count() from Welcome_Call__c where Account_Name__c = :account.Id and Opportunity_Name__c = :opportunity.Id]);
    }
    
    static testMethod void myUnitTest() {
        Account account = TestUtils.createAccount();
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        test.startTest();
        Opportunity opportunity = TestUtils.createOpportunity(account);
        opportunity.StageName = 'Closed Lost';
        update opportunity;

        //Check Executing Property
        OpportunityTriggerHelper_CS testHandler = new OpportunityTriggerHelper_CS(true, 1);
        system.assert(testHandler.IsTriggerContext);

        test.stopTest();
    }
    
    static testMethod void parentChildOppTest() {
        Account account = TestUtils.createAccount();
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        test.startTest();
        Opportunity parentOpp = TestUtils.createOpportunity(account);
        update parentOpp;
        Opportunity childOpp = TestUtils.createChildOpportunity(parentOpp,'firsttestchildopp');
        childOpp.StageName = 'Data Integration Completed';
        update childOpp;
        Opportunity childOpp2 = TestUtils.createChildOpportunity(parentOpp,'secondtestchildopp');
        childOpp2.StageName = 'Transfer Complete';
        update childOpp2;
        childOpp2.StageName = 'Verbal Commitment';
        update childOpp2;
        childOpp.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Pilot Opportunity');
        update childOpp;
        delete childOpp;
        test.stopTest();
    }
    
        static testMethod void testCPQQuoteTerms() {

        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        list<opportunity> OpportunityList = new list<opportunity>();
        list<opportunity> UpdatedOpportunityList = new list<opportunity>();
        //Standard 
        Account standardAccount = new Account();
        standardAccount.Name = 'Test';
        standardAccount.Acct_Type__c = 'End Customer';
        standardAccount.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        standardAccount.Completed_Account_Set_up__c = DateTime.now();
        standardAccount.Contract_Type__c = 'Standard';
        insert  standardAccount;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = standardAccount.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'New Business';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunity);
        
        //ADDON
        Account ADDONAccount = new Account();
        ADDONAccount.Name = 'Test';
        ADDONAccount.Acct_Type__c = 'End Customer';
        ADDONAccount.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        ADDONAccount.Completed_Account_Set_up__c = DateTime.now();
        ADDONAccount.Contract_Type__c = 'Custom';
        ADDONAccount.Sub_Type__c = 'ENTERPRISE';
        insert  ADDONAccount;
        
        Opportunity opportunityADDON = new Opportunity();
        opportunityADDON.AccountId = ADDONAccount.Id;
        opportunityADDON.Name = 'Test';
        opportunityADDON.StageName = 'Prospecting';
        opportunityADDON.Type = 'Same Tier Level Adjusted Price';
        opportunityADDON.CloseDate = Date.today().addDays(1);
        opportunityADDON.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunityADDON);
        
        //AccountInDirect
        Account pilotInDirectAccountVAR = new Account();
        pilotInDirectAccountVAR.Name = 'Test';
        pilotInDirectAccountVAR.Acct_Type__c = 'End Customer';
        pilotInDirectAccountVAR.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        pilotInDirectAccountVAR.Completed_Account_Set_up__c = DateTime.now();
        pilotInDirectAccountVAR.Contract_Type__c = 'Custom';
        pilotInDirectAccountVAR.Sub_Type__c='VAR';
        insert pilotInDirectAccountVAR;
        
        Opportunity opportunityInDirect = new Opportunity();
        opportunityInDirect.AccountId = pilotInDirectAccountVAR.Id;
        opportunityInDirect.Name = 'Test';
        opportunityInDirect.StageName = 'Prospecting';
        opportunityInDirect.Type = 'Pilot';
        opportunityInDirect.CloseDate = Date.today().addDays(1);
        opportunityInDirect.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunityInDirect);        
        
        //AccountDirect
        Account pilotDirectAccountRPP = new Account();
        pilotDirectAccountRPP.Name = 'Test';
        pilotDirectAccountRPP.Acct_Type__c = 'End Customer';
        pilotDirectAccountRPP.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        pilotDirectAccountRPP.Completed_Account_Set_up__c = DateTime.now();
        pilotDirectAccountRPP.Contract_Type__c = 'Custom';
        pilotDirectAccountRPP.Sub_Type__c='SMB';
        insert pilotDirectAccountRPP;
        
        Opportunity opportunityDirect = new Opportunity();
        opportunityDirect.AccountId = pilotDirectAccountRPP.Id;
        opportunityDirect.Name = 'Test';
        opportunityDirect.StageName = 'Prospecting';
        opportunityDirect.Type = 'Pilot';
        opportunityDirect.CloseDate = Date.today().addDays(1);
        opportunityDirect.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunityDirect);        
        
        //AccountNJPA
        Account accountNJPA = new Account();
        accountNJPA.Name = 'Test';
        accountNJPA.Acct_Type__c = 'End Customer';
        accountNJPA.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        accountNJPA.Completed_Account_Set_up__c = DateTime.now();
        accountNJPA.Contract_Type__c = 'NJPA #051613-NWF';
        accountNJPA.GSA_Eligible__c = 'Eligible';
        insert accountNJPA;
        
        Opportunity opportunityNJPA = new Opportunity();
        opportunityNJPA.AccountId = accountNJPA.Id;
        opportunityNJPA.Name = 'Test';
        opportunityNJPA.StageName = 'Prospecting';
        opportunityNJPA.Type = 'Pilot';
        opportunityNJPA.CloseDate = Date.today().addDays(1);
        opportunityNJPA.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunityNJPA);        
        
        //ACCOUNTNYOGS
        Account accountNY = new Account();
        accountNY.Name = 'Test';
        accountNY.Acct_Type__c = 'End Customer';
        accountNY.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        accountNY.Completed_Account_Set_up__c = DateTime.now();
        accountNY.Contract_Type__c = 'NY OGS #PT66910';
        accountNY.GSA_Eligible__c = 'Eligible';
        insert accountNY;
        
        Opportunity opportunityNYOGS = new Opportunity();
        opportunityNYOGS.AccountId = accountNY.Id;
        opportunityNYOGS.Name = 'Test';
        opportunityNYOGS.StageName = 'Prospecting';
        opportunityNYOGS.Type = 'Pilot';
        opportunityNYOGS.CloseDate = Date.today().addDays(1);
        opportunityNYOGS.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        OpportunityList.add(opportunityNYOGS);
        
        Test.startTest();
        DataBase.insert(OpportunityList,false);
        if(OpportunityList!=null)
        for(opportunity opp:OpportunityList){
        opp.CloseDate = Date.today().addDays(2);
        UpdatedOpportunityList.add(opp);
        DataBase.update(UpdatedOpportunityList,false);
        }

        Test.stopTest();

        
}


        static testMethod  void  test1(){
             Account account = TestUtils.createAccount();
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        test.startTest();
        Opportunity parentOpp = TestUtils.createOpportunity(account);
        update parentOpp;
        Opportunity childOpp = TestUtils.createChildOpportunity(parentOpp,'firsttestchildopp');
        childOpp.StageName = 'Data Integration Completed';
        update childOpp;
           childOpp.Account_Operational_Account_Manager__c='test@nwf.com';
           childOpp.SOS_Email__c=account.SOS_Owner__r.email;
           childOpp.DocuSign_Status__c='Completed';
           update childOpp;
           
          
           
           childOpp.StageName='Proposal Sent';
           childOpp.LeadSource='2G Migration';
           update childOpp;
           List<Opportunity> optys=new List<Opportunity>();
           optys.add(childOpp);
           OpportunityTriggerHandler o=new OpportunityTriggerHandler(true,10);
           
           o.OnAfterInsert(optys);
           childOpp.DocuSign_Status__c='Completed';
           childOpp.Contract_Pricebook_Updated__c = false;
           update childOpp;
           List<Opportunity> optys1=new List<Opportunity>();
           optys1.add(childOpp);
          
           Map<Id,Opportunity> oMap=new Map<Id,Opportunity>();
           oMap.put(childOpp.Id,childOpp);
          
           
           o.OnAfterUpdate(optys1,optys1,oMap);
           
           childOpp.Sales_Qualified_Timestamp__c=System.Today();
           childOpp.Lead_Created_Date__c=System.Today();
           childOpp.StageName='Closed Won';
           update childOpp;
        }
        
        static testMethod void testCreateOrderWithDocusign() {
        
        try{
        
        Account account = new Account();

        account.Name = 'Order Automation Bundle';
        account.Acct_Type__c = 'End Customerr';
        account.Sub_Type__c = 'RESELLER';
        account.AccountNumber = 'BUND001-S';
        account.Contract_Type__c = 'custom';
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test opportunity Create Order';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'New Business';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.Affiliate_Lead_ID__c = 'A7838873';
        opportunity.Additional_Shipping_Address_Line1__c = '123 please post';
        opportunity.Shipping_City__c = 'Canoga';
        opportunity.Shipping_Zip_Code__c = '91303';
        opportunity.Shipping_State__c = 'CA';
        opportunity.Shipping_Country__c = 'USA';
        opportunity.Shipping_Contact__c = 'Sam Killmer';
        opportunity.Shipping_email__c = 'sam@test.com';
        opportunity.Shipping_phone__c = '2347803438';
        opportunity.CreateOrder__c = false;
        opportunity.Case_Number__c='890s';
        
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        
        Welcome_Call__c welcomeCall = new Welcome_Call__c();
        welcomeCall.Account_Name__c = account.Id;
        insert welcomeCall;
        
        insert opportunity;
        
        Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
        Case theCase = new Case();
        theCase.AccountId = account.Id;
        theCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case Reason').getRecordTypeId();
        theCase.Fleet_Account__c = account.Id;
        
        insert theCase;
        
        Test.startTest();
        opportunity.CreateOrder__c = true;
        update opportunity;
        Test.stopTest();
        }
        catch(Exception e){
            System.Debug(e);
        }
        }
        /*static testMethod void Testmethod1() {
        try {
     
        Test.startTest();
        Account a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214s';
        a.Contract_Type__c='Standard';
        insert a;
        
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = a.Id;
        opportunity.Name = 'Test opportunity Create Order';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'New Business';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.Affiliate_Lead_ID__c = 'A7838873';
        opportunity.Additional_Shipping_Address_Line1__c = '123 please post';
        opportunity.Shipping_City__c = 'Canoga';
        opportunity.Shipping_Zip_Code__c = '91303';
        opportunity.Shipping_State__c = 'CA';
        opportunity.Shipping_Country__c = 'USA';
        opportunity.Shipping_Contact__c = 'Sam Killmer';
        opportunity.Shipping_email__c = 'sam@test.com';
        opportunity.Shipping_phone__c = '2347803438';
        opportunity.Additional_Shipping_Address_Line1__c = '123 post';
        opportunity.Shipping_Street2__c='345 please post';
        opportunity.Shipping_Street3__c= '567 please post';
        opportunity.CreateOrder__c = false;
         
        insert opportunity;
        
        Orders__c Ord2 = new Orders__c();
        Ord2.Account__c = A.Id;
        Ord2.opportunity__c = opportunity.Id;
        Ord2.Order_Types__c = 'BUNDLE';
        insert Ord2;
        /*
        CPQ_Opportunity_Products__c cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.SEQ__c='TestABC';      
        cpqPro.Sale_Type__c = 'BUNDLE';
        cpqPro.Opportunity_Record_ID__c = opportunity.Id;
        insert cpqPro;
        
        CPQ_Opportunity_Products__c cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.SEQ__c='TestABC1w';      
        cpqPro1.Sale_Type__c = 'PURCHASE';       
        cpqPro.Opportunity_Record_ID__c = opportunity.Id;
        insert cpqPro1;
        
        update opportunity;
        
        Test.stopTest();
        }
        catch (DmlException e)
       {
            //Assert Error Message
            //System.assert( e.getMessage().contains('Insert failed. First exception on ' +
            //   'row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION'),
             //   e.getMessage() );
              }
        }
       */
    static testMethod void testMethod2() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
                
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.Contract_Type__c = 'Standard';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.Account_Bundled_Tier__c = 'DIR-0';
        account.Account_Hardware_Accessory_Tier__c = 'DIR-0';
        account.Account_Service_Tier__c = 'DIR-0';      
        insert account;        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
               
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'Transfer (Reseller to Direct)';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        //opportunity.Pricebook2Id = Test.
        opportunity.Shipping_Street2__c = 'Test';
        opportunity.Shipping_Street3__c = 'Test Address';
        opportunity.Multiple_PO__c = true;
        opportunity.CreateOrder__c = false;
        insert opportunity;
        
    }
    
    static testMethod void testMethod3() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
                
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.Contract_Type__c = 'GSA GS07F5559R';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.GSA_Eligible__c = 'Eligible';
        account.Account_Bundled_Tier__c = 'DIR-0';
        account.Account_Hardware_Accessory_Tier__c = 'DIR-0';
        account.Account_Service_Tier__c = 'DIR-0';      
        insert account;        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
               
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.Type = 'ABC';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        //opportunity.Pricebook2Id = Test.
        opportunity.Shipping_Street2__c = 'Test';
        opportunity.Shipping_Street3__c = 'Test Address';
        opportunity.Multiple_PO__c = true;
        opportunity.CreateOrder__c = false;
        insert opportunity;
        
    }
    
    static testMethod void testMethod4() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
                
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.Sub_Type__c = 'VAR';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.GSA_Eligible__c = 'Eligible';
        account.Account_Bundled_Tier__c = 'DIR-0';
        account.Account_Hardware_Accessory_Tier__c = 'DIR-0';
        account.Account_Service_Tier__c = 'DIR-0';      
        insert account;        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
               
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Closed lost';
        opportunity.Type = 'Pilot';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        //opportunity.Pricebook2Id = Test.
        opportunity.Shipping_Street2__c = 'Test';
        opportunity.Shipping_Street3__c = 'Test Address';
        opportunity.Multiple_PO__c = true;
        opportunity.CreateOrder__c = false;
        insert opportunity;
        opportunity.LeadSource = 'Lead Gen Partner';
        opportunity.Sales_Qualified_Timestamp__c = System.now();
        opportunity.Lead_Created_Date__c = System.now();
        //opportunity.isClosed= true;
        update opportunity;
        
    }
    
     static testMethod void testMethod5() {
        Account parentAccount = new Account();
        parentAccount.Name = 'Parent';
        insert parentAccount;
        
        Account siblingAccount = new Account();
        siblingAccount.ParentId = parentAccount.Id;
        siblingAccount.Name = 'Sibling';
        insert siblingAccount;
        
        //list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='d1@andomdemodomain.com');
        insert u1;

        User u2 = new User(Alias = 'standt2',Country='United Kingdom',Email='demo2@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='d2@andomdemodomain.com');
        insert u2; 
         
        User u3 = [SELECT Id FROM User WHERE Email='demo1@randomdemodomain.com'];
                
        Account account = new Account();
        account.ParentId = parentAccount.Id;
        account.Name = 'Test';
        account.Acct_Type__c = 'End Customer';
        account.Sub_Channel__c = 'PUBLIC SECTOR SMB';
        account.Completed_Account_Set_up__c = DateTime.now();
        account.Contract_Type__c = 'GSA GS07F5559R';
        account.Price_Book__c = Test.getStandardPricebookId();
        account.GSA_Eligible__c = 'Eligible';
        account.Account_Bundled_Tier__c = 'DIR-0';
        account.Account_Hardware_Accessory_Tier__c = 'DIR-0';
        account.Account_Service_Tier__c = 'DIR-0';
        account.Type = 'Migration'; 
        account.SOS_Owner__c= u3.Id;
        insert account;        
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Test';
        insert contact;
        
               
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = account.Id;
        opportunity.Name = 'Test';
        opportunity.StageName = 'Prospecting';
        opportunity.CloseDate = Date.today().addDays(1);
        opportunity.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        opportunity.Additional_Shipping_Address_Line1__c = '';
        opportunity.Shipping_Street2__c='345 please post';
        opportunity.Shipping_Street3__c= '567 please post';
        opportunity.Multiple_PO__c = true;
        opportunity.CreateOrder__c = false;
        opportunity.Account_Operational_Account_Manager__c = U1.Email;
        insert opportunity;
        
    }

}