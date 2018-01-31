@isTest (SeeAllData=true)
public class VZ_Util_Test{
    static testMethod void initiateVZ_Util() {
       
        List<Account> listOfAccounts = new List<Account>();
        List<string> listOfStrings = new List<string>();
        
        
        Map<string, Account> mapAccounts = new Map<string, Account>();
        Map<integer, Account> mapIntAccounts = new Map<integer, Account>();
        Map<ID, String> mapIntStr = new Map<ID, String>();//jvl
        Map<string, List<Account>> mapListAccounts = new Map<string, List<Account>>();
        Datetime dt = Datetime.Now();
        
        String Test1 = 'Test1';//jvl
        String Test2 = 'Test2';//jvl
        String Test3 = 'Test3';//jvl
        listOfStrings.add(Test1);//jvl
        listOfStrings.add(Test2);//jvl
        listOfStrings.add(Test3);//jvl
        
        VZ_Util.GetAuthString('test');
        VZ_Util.GetAuthString('test','2015-12-12'); //jvl
        VZ_Util.IsNullOrEmpty('test');
       
        VZ_Util.IsNullOrEmpty('test test', true);
        
        VZ_Util.MakeNullEmpty('test');
           
        VZ_Util.IsNullOrEmpty(listOfStrings);
       
        VZ_Util.IsNullOrEmpty(listOfAccounts);
          
        VZ_Util.IsNullOrEmpty(mapAccounts);
           
        VZ_Util.IsNullOrEmpty(mapListAccounts);
           
        VZ_Util.IsNullOrEmpty(mapIntAccounts );
        
        VZ_Util.IsNullOrEmpty(mapIntStr);//jvl
      
        VZ_Util.IsValidEmail('test');
       
        VZ_Util.IsValidNumber('34', 3); 
       
        VZ_Util.ConvertNewLineToBreaks('test test');
       
        VZ_Util.ConvertBreaksToNewLine('test test');
        
        VZ_Util.IsListContains(listOfStrings, 'test');//jvl
      
        VZ_Util.ConvertToLocalTimezone(dt);
        
        VZ_Util.GetPicklistValues('Account', 'AccountSource');
        
        VZ_Util.setStringToDateFormat('01/01/2020');//jvl
        VZ_Util.parseDate('01/01/2020');//jvl
        VZ_Util.parseDate('');//
        
        testParseCSV();
        
        createAccount();
        
        createICRule();
        
    }
    
    static testMethod void initiateVZ_UtilNegative() {
       
        List<Account> listOfAccounts = new List<Account>();
        List<string> listOfStrings = new List<string>();
        
        
        Map<string, Account> mapAccounts = new Map<string, Account>();
        Map<integer, Account> mapIntAccounts = new Map<integer, Account>();
        Map<ID, String> mapIntStr = new Map<ID, String>();//jvl
        Map<string, List<Account>> mapListAccounts = new Map<string, List<Account>>();
        Datetime dt = Datetime.Now();
        
        String Test1 = 'Test1';//jvl
        String Test2 = 'Test2';//jvl
        String Test3 = 'Test3';//jvl
        listOfStrings.add(Test1);//jvl
        listOfStrings.add(Test2);//jvl
        listOfStrings.add(Test3);//jvl
        
        VZ_Util.GetAuthString('');
        VZ_Util.GetAuthString('',''); //jvl
        VZ_Util.IsNullOrEmpty('');
       
        VZ_Util.IsNullOrEmpty('',false);
        
        VZ_Util.MakeNullEmpty('');
           
        VZ_Util.IsNullOrEmpty('');
       
        VZ_Util.IsNullOrEmpty('');
          
        VZ_Util.IsNullOrEmpty(mapAccounts);
           
        VZ_Util.IsNullOrEmpty(mapListAccounts);
           
        VZ_Util.IsNullOrEmpty(mapIntAccounts );
        
        VZ_Util.IsNullOrEmpty(mapIntStr);//jvl
      
        VZ_Util.IsValidEmail('');
       
        VZ_Util.IsValidNumber('', 0);
       
        VZ_Util.ConvertNewLineToBreaks('');
       
        VZ_Util.ConvertBreaksToNewLine('');
        VZ_Util.IsListContains(null, '');//jvlVZ_Util.IsListContains('', '');//jvl
      
        VZ_Util.ConvertToLocalTimezone(dt);
        
        VZ_Util.GetPicklistValues('Account', 'AccountSource');
        
        VZ_Util.setStringToDateFormat('01/01/2020');//jvl
        
        testParseCSV();
        
        createAccount();
        
        createICRule();
        
    }
    

    private static void testParseDate() {
        System.assertEquals(Date.newInstance(2020,1,1),     VZ_Util.parseDate('2020-01-01'));
        System.assertEquals(Date.newInstance(2020,1,1),     VZ_Util.parseDate('2020-01-01T01:09:00Z'));
        System.assertEquals(Date.newInstance(2020,1,1),     VZ_Util.parseDate('01/01/2020'));
        System.assertEquals(Date.newInstance(2020,1,1),     VZ_Util.parseDate('1/1/2020'));
        System.assertEquals(Date.newInstance(2020,1,1),     VZ_Util.parseDate('01/01/2020 05:08:00.000-0800'));
        System.assertEquals(null,                           VZ_Util.parseDate(null));
        System.assertEquals(null,                           VZ_Util.parseDate(''));
        System.assertEquals(null,                           VZ_Util.parseDate('ab/de/1201'));
        System.assertEquals(null,                           VZ_Util.parseDate('13/01/2020'));
        System.assertEquals(null,                           VZ_Util.parseDate('2020-13-01'));
                
    }
           private static void testParseCSV(){
            string contents='Field1,Field2,Field3\n1,,Smith\n2,Fred,O\'Connor\n3,Destiny,"Awaits, DDS"\n\n';
            list<list<string>> parsedCSV=VZ_Util.parseCSV(contents,true,false);
            //line 1
            system.assertEquals('1',parsedCSV[0][0]);
            system.assertEquals('',parsedCSV[0][1]);
            system.assertEquals('Smith',parsedCSV[0][2]);
            //line 2
            system.assertEquals('2',parsedCSV[1][0]);
            system.assertEquals('Fred',parsedCSV[1][1]);
            system.assertEquals('O\'Connor',parsedCSV[1][2]);
            //line 3
            system.assertEquals('3',parsedCSV[2][0]);
            system.assertEquals('Destiny',parsedCSV[2][1]);
            system.assertEquals('Awaits, DDS',parsedCSV[2][2]);
        }
  
   public static void createICRule(){
    RecordType OpportunityRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Opportunity_Specific' limit 1];
    RecordType AccountRecType = [Select Id From RecordType  Where SobjectType = 'Installation_Coordinator_Assignment_Rule__c' and DeveloperName = 'Account_Specific' limit 1];
    
   
    User user = [SELECT Id FROM User ORDER BY ProfileId DESC NULLS LAST  LIMIT 1];
    User user2 = [SELECT Id FROM User ORDER BY ProfileId LIMIT 1];
    
  
   
    
    
    Installation_Coordinator_Assignment_Rule__c accRule = new Installation_Coordinator_Assignment_Rule__c(RecordTypeId = AccountRecType.Id, Account_Sub_Type__c = 'ENTERPRISE', Account_Owner_Manager__c = user.Id, Install_Coordinator__c = user.Id);
    
    Installation_Coordinator_Assignment_Rule__c opty = new Installation_Coordinator_Assignment_Rule__c(RecordTypeId = OpportunityRecType.Id, Opportunity_Type__c = 'Migration', Opportunity_Owner_Manager__c = user.Id, Install_Coordinator__c = user.Id);
    
    insert accRule ;
    
    Account account = new Account(Name = 'Test Account 234234',Installation_Coordinator__c  = user.id,  SOS_Owner__c = user.Id, Acct_Type__c = 'Other', Sub_Type__c = 'Other', Sales_Partner_Vertical__c = 'Other', Total_Number_of_Vehicles__c = 10);
    insert account;
    
    
    accRule .Install_Coordinator__c = user2.Id;
    update accRule ;
    
    insert opty;
    opty.Install_Coordinator__c = user2.Id;
    update opty;
  }  

  public static Lead createLead(){
    Lead lead = new Lead(LastName = 'Test123432', Company='Test Company', Phone = '555-789-5947', Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '111111111111111', Main_Unqualified_Reason__c = 'Feature Function');
    insert lead;
    lead = [Select LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead.Id];
    return lead;
  }
  
  public static Account createAccount(){
    RecordType acctRecordType = [Select Id from RecordType where Name = 'Sales Account' and SobjectType = 'Account'];
    User user = [Select Id from User Limit 1];
    Account account = new Account(Name = 'Test Account 234234', SOS_Owner__c = user.Id, Acct_Type__c = 'Other', Sub_Type__c = 'Other', Sales_Partner_Vertical__c = 'Other', Total_Number_of_Vehicles__c = 10);
    insert account;
    account.Sub_Type__c = 'VAR';
    update account;
    
    Opportunity  opportunity =  createOpportunity(account);
    opportunity.Force_Trigger_Update__c = true;
    update opportunity;
    return account;
  }
  
  public static Opportunity createOpportunity(Account account){
    RecordType opRecordType = [Select Id from RecordType where Name = 'Sales Opportunity' and SobjectType = 'Opportunity'];
    Opportunity opportunity = new Opportunity(RecordTypeId = opRecordType.Id, Name = 'Test Opportunity', Lead_Opp_Number__c  = 'test number', AccountId = account.Id, Type = 'Existing Business', LeadSource = 'Other', Specific_Lead_Source__c = 'Other', CloseDate = Date.today().addDays(30), StageName = 'Initial Meeting / Demo', Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '00QK00000056y5yMBB', Main_Lost_Reason__c='Feature Function');
    insert opportunity;
    opportunity = [Select RecordTypeId,Name,Lead_Opp_Number__c, NWF_Lead_Opp_Number__c,Unit_Total_All_Opps__c, AccountId, Type,LeadSource,Specific_Lead_Source__c,CloseDate, StageName, Affiliate_Lead_ID__c, Partner_ID__c, Main_Lost_Reason__c, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone from Opportunity where Id=: opportunity.Id ];
    return opportunity;
  }
  
  public static Opportunity createChildOpportunity(Opportunity parentOpp,string childOppName) {
    RecordType opRecordType = [Select Id from RecordType where Name='Child Sales Opportunity' and SobjectType = 'Opportunity'];
    Opportunity childOpp  = new Opportunity(RecordTypeId = opRecordType.Id, Name= childOppName, Lead_Opp_Number__c = 'test number', AccountId = parentOpp.AccountId, Type='Existing Business',LeadSource='Other', Specific_Lead_Source__c=  'Other', CloseDate = Date.today().addDays(30), StageName = 'Pilot' );
    insert childOpp;
    return childOpp;
  }

}