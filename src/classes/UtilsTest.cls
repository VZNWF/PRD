/**
 * This test class contains all the object creations. Use this as an Utility to create other Test Classes
 *
 */
@isTest
public with sharing class UtilsTest 
{
    public static Account a{get; set;}
    public static Opportunity o{get; set;}
    public static Contact c{get; set;}
    public static Installer_Certificate__c icert{get; set;}
         
     static testMethod void testForETAStagingInsert() {         
     account newAccountETA1 = new Account();  
     newAccountETA1.Name = 'TestAccountETA'; 
     newAccountETA1.CPQ_PRICE_TIER__c = '2';
     newAccountETA1.AccountNumber = '12345';
         
     insert newAccountETA1;
     account newAccountETA2 = new Account();  
     newAccountETA2.CPQ_PRICE_TIER__c = '2';
     newAccountETA2.Name = 'TestAccountETA'; 
     newAccountETA2.AccountNumber = '54214';
     insert newAccountETA2;
         
        list<AR_SalePricing__c> ARSPlist = new list<AR_SalePricing__c>();       
         AR_SalePricing__c ARSP = new AR_SalePricing__c();
         //ARSP.name = 'Standard';
         ARSP.install__c = 123456;
         ARSP.swap__c = 123457;
         ARSP.customer_number__c = '1215';
         ARSPlist.add(ARSP);
         AR_SalePricing__c ARSP2 = new AR_SalePricing__c();
         //ARSP2.name = '12345';
         ARSP2.install__c = 1234568;
         ARSP2.swap__c = 1234579;
         ARSP2.customer_number__c = '12345';
         ARSPlist.add(ARSP2);
         insert ARSPlist; 
         list<Opportunity_CPQ_Mapping__c> OppCPQMapping = CreateOpportunityCPQMapping();
         list<opportunity> Opplist =  new list<opportunity>();
         opportunity OppNonStand = new opportunity(); 
         opportunity OppStand = new opportunity();
         OppStand.AccountId = newAccountETA1.Id;
         OppStand.Type_of_sale__c = 'Indirect';
         OppStand.CloseDate = system.today();
         OppStand.name = 'OppStand';
         OppStand.stagename = 'pilot';    
         insert OppStand;
         OppNonStand.AccountId = newAccountETA2.Id;
         OppNonStand.Type_of_sale__c = 'Indirect';
         
         OppNonStand.CloseDate = system.today();
         OppNonStand.name = 'OppNonStand';
         OppNonStand.stagename = 'pilot';    
         insert OppNonStand;
         OrderICuser__c ICuser = new OrderICuser__c(name = 'Sophia Arroyo');
         insert ICuser;  
         Orders__c Ord1 = new Orders__c();
         Ord1.Account__c = newAccountETA1.Id;
         Ord1.opportunity__c = OppStand.Id;
         insert Ord1;             
         Orders__c Ord2 = new Orders__c();
         Ord2.Account__c = newAccountETA2.Id;
         Ord2.opportunity__c = OppNonStand.Id;
         insert Ord2;
         list<ETA_Staging__c> ETAList = new list<ETA_Staging__c>();
         ETA_Staging__c ETAStandard = new ETA_Staging__c();
         ETA_Staging__c ETANonStandard = new ETA_Staging__c();
         ETAStandard.Account__c = newAccountETA1.Id;
         ETAStandard.Order__c =Ord1.Id; 
         ETANonStandard.Account__c = newAccountETA2.Id;
         ETANonStandard.Order__c =Ord2.Id; 
         ETAList.add(ETAStandard);
         ETAList.add(ETANonStandard);
         
         test.startTest();
         insert ETAList; 
         test.stopTest();
     }
    
    
    static testMethod void UtilsTest () {
    createAccount();
    Affiliate__c aff = CreateAffiliate();
    Contact con = createContact(aff );
    createInstallerCert(con );
    //updateAffiliate(aff);
    }
    public static void setup()
    {
        createAccount();
    } 
    
    public static Attachment CreateAttachment(){
        Attachment att = new Attachment();  
        Account aa = new Account(name = 'Test');
        insert aa;
        att.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body\nTest');
        att.body=bodyBlob;
        att.parentId=aa.id;
        insert att;
        return att;
    }
    
    public static Account createAccount()
    {
        a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214';
        a.Contract_Type__c='Standard';
        return a;
    }
    
    public static Installer_Certificate__c createInstallerCert(Contact con)
    {
        icert= new Installer_Certificate__c();
        icert.Certified_Date__c=Date.today();
        icert.Installer_Contact__c = con.id;
        return icert;
    }

    public static Contact createContact(Affiliate__c aff)
    {
        
        c = new Contact();
        c.Mailingcity = 'San Diego';
        c.MailingStreet='999 main st';
        c.MailingPostalCode='12345-9999';
        c.MailingState='California';
        c.MailingCountry='United States';
        c.LastName='Test Lastname';   
        c.FirstName='Test Firstname';
        c.Affiliate_ID__c = aff.id;
        insert c;
        return c;        
        
    }
    
    /* public static opportunity CreateOpp(Account Acc){
        opportunity opp = new opportunity();
        opp.AccountId = Acc.Id;
        opp.Type_of_sale__c = 'Indirect';
        Opp.CloseDate = system.today();
        Opp.name = 'Test';
        Opp.stagename = 'pilot'; 
        insert opp;
        return opp;
    }*/
    
     public  static Account  createAccountforOrder() {         
     account newAccountETA1 = new Account();  
     User usr = [select id from user where name = :'Sophia Arroyo'];
     newAccountETA1.Name = 'TestAccountETA'; 
     newAccountETA1.CPQ_PRICE_TIER__c = '2';
     newAccountETA1.AccountNumber = '12345';
     newAccountETA1.Installation_Coordinator__c = usr.id;
     newAccountETA1.Contract_Type__c = 'custom';
     newAccountETA1.GSA_Eligible__c = 'Eligible';
     newAccountETA1.Sub_Type__c = 'FEDGOVT';
     newAccountETA1.Acct_type__c = 'End Customer';
     insert newAccountETA1;
     Account Acc = [SELECT Id,name,AccountNumber,Installation_Coordinator__c FROM Account WHERE Id = :newAccountETA1.Id];
     return newAccountETA1;
     }      
     
     public  static Account  createAccountforOrderAutomation() {         
     account newAccountETA1 = new Account();  
     User usr = [select id from user where name = :'Sophia Arroyo'];
     newAccountETA1.Name = 'TestAccountETA'; 
     newAccountETA1.CPQ_PRICE_TIER__c = '2';
     newAccountETA1.AccountNumber = '12345';
     newAccountETA1.Installation_Coordinator__c = usr.id;
     newAccountETA1.GSA_Eligible__c = 'Eligible';
     //newAccountETA1.Sub_Type__c = 'FEDGOVT';
     newAccountETA1.Acct_type__c = 'Sales Partner';
     insert newAccountETA1;
     Account Acc = [SELECT Id,name,AccountNumber,Installation_Coordinator__c FROM Account WHERE Id = :newAccountETA1.Id];
     return newAccountETA1;
     }
     
     public  static opportunity CreateOpportunity(Account Acc){
     list<Opportunity_CPQ_Mapping__c> OppCPQMapping = CreateOpportunityCPQMapping();
     opportunity OppStand = new opportunity();
     OppStand.AccountId = Acc.Id;
     OppStand.Type_of_sale__c = 'Indirect';
     OppStand.CloseDate = system.today();
     OppStand.name = 'OppStand';
     OppStand.stagename = 'pilot';    
     insert OppStand;     
     return OppStand;
     }
     
     public static orders__c CreateOrder(Account Acc,opportunity Opp){
     orders__c ord = new orders__c();
     ord.Account__c = Acc.Id;
     ord.opportunity__c = Opp.Id;
     insert ord;
     return ord;      
     }
    
     public  static orders__c  CreateOrd() {         
     account newAccountETA1 = new Account();  
     newAccountETA1.Name = 'TestAccountETA'; 
     newAccountETA1.CPQ_PRICE_TIER__c = '2';
     //newAccountETA1.AccountNumber = '12345';
     newAccountETA1.Sub_Type__c ='PUBLIC SECTOR';
         
     insert newAccountETA1;

     opportunity OppStand = new opportunity();
     OppStand.AccountId = newAccountETA1.Id;
     OppStand.Type_of_sale__c = 'Indirect';
     OppStand.CloseDate = system.today();
     OppStand.name = 'OppStand';
     OppStand.stagename = 'pilot';    
     insert OppStand;
     
     orders__c ord = new orders__c();
     ord.Account__c = newAccountETA1.Id;
     ord.opportunity__c = OppStand.Id;
     insert ord;
     return ord;       
   }    
   
    public static Attachment CreateAttachmentForOpportunity(opportunity opp){
        Attachment att = new Attachment();  
        att.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body\nTest');
        att.body=bodyBlob;
        att.parentId=opp.id;
        insert att;
        return att;
    }
  
    public static Affiliate__c CreateAffiliate()
    {
        
        Affiliate__c afl = new Affiliate__c();
        afl.Affiliate_Name__c = 'Test Affiliate';
        afl.Affiliate_Type__c = 'Active';
        return afl;
    }
    
    public static Affiliate__c CreateAffiliate2()    
    {           
        Installer_Settings__c is = new Installer_Settings__c();        
        is.Name = 'Integrate_Dev';        
        is.Password__c = 'dummyPassword';         
        insert is;        
        Affiliate__c afl = new Affiliate__c();        
        afl.Affiliate_Name__c = 'Test Affiliate2';        
        afl.Affiliate_Type__c = 'Active';        
        insert afl;        
        return afl;    
    }
    
    public static void CreateInstallerSettings()
    {
        Installer_Settings__c csInstaller_Settings = new Installer_Settings__c(Name = 'Integrate_Dev', Certificate__c = 'aa1', Company__c = 'verizon.test', Login_ID__c = 'soap_rm', Password__c = 'qwertysoap_rm');
        insert csInstaller_Settings;
    }
    
    /*public static Master_Vehicle__c createMasterVehicle(){
        Master_Vehicle__c mveh = new Master_Vehicle__c(VIN__c = '123456789', Serial_Number__c = '567894203', Color__c = 'White');
        insert mveh;
        mveh = [Select VIN__c, Serial_Number__c, Color__c from Master_Vehicle__c where Id =: mveh.Id];
        return mveh;
    }
     
    public static Master_Device__c createMasterDevice(){
        Master_Device__c mdev = new Master_Device__c(Warranty_Months__c = '12 Months', Device_ID__c = '12121');
        insert mdev;
        mdev = [Select Warranty_Months__c, Device_ID__c from Master_Device__c where Id =: mdev.Id];
        return mdev;
    }

    public static Master_Vehicle_Device__c createMasterVehicleDevice(Master_Vehicle__c mveh, Master_Device__c mdev){
        Master_Vehicle_Device__c mvd = new Master_Vehicle_Device__c(Vehicle__c = mveh.id, Device__c = mdev.id, Fleet_SellerKey__c = '123123');
        insert mvd;
        mvd = [Select isActive__c, Vehicle__c, Device__c, VIN__c, Serial_Number__c, Fleet_SellerKey__c  from Master_Vehicle_Device__c where Id =: mvd.Id];
        return mvd;
    }*/
                
    public static Case createCase(Account act, Contact cnt){ // add contact field on case (Account added to Fleet_account__c field)
        Case cas = new Case(Case_Owner__c = 'Deborah Johnson', Fleet_Account__c=act.id, Number_Of_Units__c= 1.0, Status = 'Open', Origin = 'Phone', Reason = 'RA');
        insert cas;
        cas = [Select Case_Owner__c, Status, Number_Of_Units__c, Fleet_Account__c, Origin, Reason  from Case where Id =: cas.Id];
        return cas;
    }
    
    public static Orders__c createOrderAutomatic (Account act, opportunity Opp){
        Orders__c ord = new Orders__c(Order_Types__c = 'STDORD', Contact_Person__c = 'Sam Killmer', Account__c = 'Order Automation', Opportunity__c = 'Big Money', Phone__c = '(818) 370-1213', Order_Status__c = 'NEW');
        insert ord;
        return ord;
        }
    
    public static Location__c createLocation(Account act){
        Location__c loc = new Location__c(Customer__c = act.id,name = 'California', Garage_Address1__c= '6363 Greenwich Dr', Garage_Address2__c = 'Suit 200', Garage_City__c = 'San Diego', Garage_Country__c = 'USA', Garage_State__c = 'CA', Garage_Zip__c = '92122');
        insert loc;
        //loc = [Select Customer__c, Garage_Address1__c, Garage_Address2__c, Garage_City__c, Garage_Country__c, Garage_State__c, Garage_Zip__c  from Location__c where Id =: loc.Id];
        return loc;
    }
    //As the Vehicle and case Location objects are not yet created. Commenting the code which require these Objects.
   /* public static vehicle__c createVeh(orders__c ord){           
        vehicle__c veh = new vehicle__c(SF_Orders__c = ord.Id);         
        insert veh;         
        return veh;
    }
    
    public static Case_Locations__c createCaseLocation(case cas,Location__c Loc){
        Case_Locations__c caseLoc = new Case_Locations__c(Location__c = Loc.Id,case__c = cas.Id);
        insert caseLoc;
        return caseLoc;
    }

    public static void createCaseLoc(case cas,Location__c Loc){
        Case_Locations__c caseLoc = new Case_Locations__c(Location__c = Loc.Id,case__c = cas.Id);
        insert caseLoc;
    }
    
    public static void CreateCaseVeh(case cas,Location__c Loc,vehicle__c veh){
        Case_Vehicle__c casVeh = new Case_Vehicle__c(Vehicle__c = veh.Id,Location__c = Loc.Id,case__c = cas.Id );
        insert casVeh;

    }
    
    public static Case_Vehicle__c CreateCaseVeh2(case cas,Location__c Loc,vehicle__c veh){
        Case_Vehicle__c casVeh = new Case_Vehicle__c(Vehicle__c = veh.Id,Location__c = Loc.Id,case__c = cas.Id,Eligible_for_Order__c = true );
        insert casVeh;
        return casVeh;
    }
*/    
    public static OrderICuser__c createOrderICuser(){
        OrderICuser__c ICuser = new OrderICuser__c(name = 'Sophia Arroyo');
        insert ICuser;
        return ICuser; 
    }
    
    public static OpportunityContactRole CreateOpportunityContactRoles(Opportunity opp,Contact con){
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.ContactId = con.Id;
        oppContactRole.opportunityId = opp.Id;
        oppContactRole.Role = 'Signatory';
        oppContactRole.IsPrimary = true;   
            insert oppContactRole;          
            return oppContactRole;          
        }           
                    
        public static OpportunityContactRole CreateOpportunityContactRolesPOC(Opportunity opp,Contact con){         
            OpportunityContactRole oppContactRole = new OpportunityContactRole();           
            oppContactRole.ContactId = con.Id;          
            oppContactRole.opportunityId = opp.Id;          
            oppContactRole.Role = 'Install Main POC';           
            oppContactRole.IsPrimary = true;            
            insert oppContactRole;          
            return oppContactRole;          
        }           
                    
        public static OpportunityContactRole CreateOpportunityContactRolesFleet(Opportunity opp,Contact con){           
            OpportunityContactRole oppContactRole = new OpportunityContactRole();           
            oppContactRole.ContactId = con.Id;          
            oppContactRole.opportunityId = opp.Id;          
            oppContactRole.Role = 'Fleet Manager Main User';
        oppContactRole.IsPrimary = true;
        insert oppContactRole;
        return oppContactRole;
    }

    public static list<Opportunity_CPQ_Mapping__c> CreateOpportunityCPQMapping(){
        list<Opportunity_CPQ_Mapping__c> oppCPRMappingList = new list<Opportunity_CPQ_Mapping__c>();
        Opportunity_CPQ_Mapping__c genericCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'Default',CPQ_Template_Title__c = 'Networkfleet Hardware and Services Order Form',CPQ_Account_Type__c = 'STANDARD');
        Opportunity_CPQ_Mapping__c transferCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'Transfer',CPQ_Template_Title__c = 'Networkfleet Transfer Agreement',CPQ_Account_Type__c = 'TRANSFER',Contract_Type__c='Standard',Opportunity_Type__c='Transfer (Reseller to Direct)');
        Opportunity_CPQ_Mapping__c standardCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'STANDARD',CPQ_Template_Title__c = 'Networkfleet Hardware and Services Order Form',CPQ_Account_Type__c = 'STANDARD',Contract_Type__c='Standard',Opportunity_Type3__c='Transfer (Reseller to Direct)');
        Opportunity_CPQ_Mapping__c pilotDirectCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'PILOT_DIRECT',CPQ_Template_Title__c = 'Networkfleet Direct Pilot Program',CPQ_Account_Type__c = 'PILOT_DIRECT', Account_Sub_Type__c='ENTERPRISE',Account_Sub_Type2__c='FEDGOVT',Account_Sub_Type3__c='PUBLIC SECTOR',Account_Sub_Type4__c='SMB',Opportunity_Type__c='Pilot');
        Opportunity_CPQ_Mapping__c pilotIndirectCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'PILOT_INDIRECT',CPQ_Template_Title__c = 'Networkfleet Indirect Pilot Program',CPQ_Account_Type__c = 'PILOT_INDIRECT',Account_Sub_Type__c='VAR',Account_Sub_Type2__c='RESELLER-PP',Account_Sub_Type3__c='RESELLER',Opportunity_Type__c='Pilot');
        Opportunity_CPQ_Mapping__c NJPACustomSetting = new Opportunity_CPQ_Mapping__c(name = 'NJPA',CPQ_Template_Title__c = 'Networkfleet NJPA #051613-NWF Hardware & Service Order',CPQ_Account_Type__c = 'NJPA',GSA_Eligible__c='Eligible',Contract_Type__c='NJPA #022217-NWF');
        Opportunity_CPQ_Mapping__c NJPA1CustomSetting = new Opportunity_CPQ_Mapping__c(name = 'NJPA1',CPQ_Template_Title__c = 'Networkfleet NJPA #051613-NWF Hardware & Service Order',CPQ_Account_Type__c = 'NJPA',GSA_Eligible__c='Eligible',Contract_Type__c='NJPA #051613-NWF');
        Opportunity_CPQ_Mapping__c NJPA2CustomSetting = new Opportunity_CPQ_Mapping__c(name = 'NJPA2',CPQ_Template_Title__c = 'Networkfleet NJPA #051613-NWF Hardware & Service Order',CPQ_Account_Type__c = 'NJPA',GSA_Eligible__c='Eligible',Contract_Type__c='NJPA #113011-NWF');
        Opportunity_CPQ_Mapping__c NJPA3CustomSetting = new Opportunity_CPQ_Mapping__c(name = 'NJPA3',CPQ_Template_Title__c = 'Networkfleet NJPA #051613-NWF Hardware & Service Order',CPQ_Account_Type__c = 'NJPA',GSA_Eligible__c='Eligible',Contract_Type__c='NJPA #022217-TEL');
        Opportunity_CPQ_Mapping__c STDECustomSetting = new Opportunity_CPQ_Mapping__c(name = 'STDE',CPQ_Template_Title__c = 'Networkfleet St of DE GSS11555 Hardware & Service Order',CPQ_Account_Type__c = 'STDE',GSA_Eligible__c='Eligible',Contract_Type__c='St of DE GSS11555');
        Opportunity_CPQ_Mapping__c NYOGSCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'NY-OGS',CPQ_Template_Title__c = 'Networkfleet NY OGS PT#69910 Hardware & Service Order',CPQ_Account_Type__c = 'NY-OGS',GSA_Eligible__c='Eligible',Contract_Type__c='NY OGS #PT66910');
        Opportunity_CPQ_Mapping__c ADDONCustomSetting = new Opportunity_CPQ_Mapping__c(name = 'ADD_ON',CPQ_Template_Title__c = 'Networkfleet Add On Order',Acct_Type__c = 'End Customer',CPQ_Account_Type__c = 'ADD_ON',Opportunity_Type__c='New Business',Opportunity_Type2__c='From Reseller Inventory',Opportunity_Type3__c='Transfer (Reseller to Direct)');             
        Opportunity_CPQ_Mapping__c GSACustomSetting = new Opportunity_CPQ_Mapping__c(name = 'GSA',CPQ_Template_Title__c = 'Networkfleet GSA # GS-07F-5559R Hardware & Service Order',CPQ_Account_Type__c = 'GSA');             
        oppCPRMappingList.add(genericCustomSetting);
        oppCPRMappingList.add(transferCustomSetting);
        oppCPRMappingList.add(standardCustomSetting);
        oppCPRMappingList.add(pilotDirectCustomSetting);
        oppCPRMappingList.add(pilotIndirectCustomSetting);
        oppCPRMappingList.add(NJPACustomSetting);
        oppCPRMappingList.add(NJPA1CustomSetting);
        oppCPRMappingList.add(NJPA2CustomSetting);
        oppCPRMappingList.add(NJPA3CustomSetting);
        oppCPRMappingList.add(STDECustomSetting);
        oppCPRMappingList.add(NYOGSCustomSetting);
        oppCPRMappingList.add(ADDONCustomSetting);
        oppCPRMappingList.add(GSACustomSetting);        
        insert oppCPRMappingList;
        return oppCPRMappingList;
    }   
    
    public static ETA_Staging__c CreateETAStaging(){
    ETA_Staging__c ETA1 = new ETA_Staging__c();
    ETA1.Trigger_ETA_Integration__c = 1;
    ETA1.Assigned_Resource_ID__c = 'TestAFF';
    ETA1.Number_of_vehicles_to_add__c = 5;
    ETA1.ETA_Staging_Status__c = 'Started';
    insert ETA1;
    return ETA1;
    }
    
    public static list<SchdClassSettings__c> CreateSchdClassSettings(){
    list<SchdClassSettings__c> ClassSettingList = new list<SchdClassSettings__c>();
    SchdClassSettings__c ClassSetting1 = new SchdClassSettings__c();
    ClassSetting1.name = 'Logic1BatchSize'; 
    ClassSetting1.value__c = '2';
    SchdClassSettings__c ClassSetting2 = new SchdClassSettings__c();
    ClassSetting2.name = 'TimeInterval'; 
    ClassSetting2.value__c = '5';
    ClassSettingList.add(ClassSetting1);
    ClassSettingList.add(ClassSetting2);
    insert ClassSettingList;
    return ClassSettingList;
    }
    
    public static list<Installation_Coordinator_Assignment_Rule__c> createInstallCoordAsstRule(){
    list<Installation_Coordinator_Assignment_Rule__c> ICARList = new list<Installation_Coordinator_Assignment_Rule__c>();
    Installation_Coordinator_Assignment_Rule__c ICA1 = new Installation_Coordinator_Assignment_Rule__c();
    Installation_Coordinator_Assignment_Rule__c ICA2 = new Installation_Coordinator_Assignment_Rule__c();
    Installation_Coordinator_Assignment_Rule__c ICA3 = new Installation_Coordinator_Assignment_Rule__c();
    Installation_Coordinator_Assignment_Rule__c ICA4 = new Installation_Coordinator_Assignment_Rule__c();
    ICA1.Account_Sub_Type__c = 'VAR';
    //ICA1.Account_Zone__c = '1';
    ICA1.RecordTypeId = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Specific').getRecordTypeId();
    ICARList.add(ICA1);
    ICA2.Customer_Number__c = '45';
    //ICA2.Account_Zone__c = '2';
    ICA2.Account_Sub_Type__c = 'VAR';
    ICA2.RecordTypeId = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Specific').getRecordTypeId();
    ICARList.add(ICA2);
    
    ICA3.Account_Owner_Manager__c = UserInfo.getUserId();
    //ICA3.Account_Zone__c = '3';
    //ICA3.Customer_Number__c = '45';
    ICA3.Account_Sub_Type__c = 'VAR';
    ICA3.RecordTypeId = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Specific').getRecordTypeId();
    ICARList.add(ICA3);
    
    ICA4.Account_Owner_Manager__c = UserInfo.getUserId();
    ICA4.Customer_Number__c = '45';
    //ICA4.Account_Zone__c = '4';
    ICA4.Account_Sub_Type__c = 'VAR';
    ICA4.RecordTypeId = Schema.SObjectType.Installation_Coordinator_Assignment_Rule__c.getRecordTypeInfosByName().get('Account Specific').getRecordTypeId();
    ICARList.add(ICA4);
    
    
    Insert ICARList;
    return ICARList;
        }
        
    public static PricebookSetup__c  CreatePricebookSetup(){
    PricebookSetup__c Pricebook = new PricebookSetup__c();
    Pricebook.name = 'Assetworks-MSRP2';
    Pricebook.Pricebook_Id__c = '01s33000000BtbP';
    insert Pricebook;
    return Pricebook;
    }   
    
    public static List<Order_Line_Item_Details__c> createOrderLineItemDetailRecords(location__c loc){
        Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11111', Location__c = Loc.Id, isSubmitted__c = true);
        Order_Line_Item_Details__c olid2 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11112',Location__c = Loc.Id, isSubmitted__c = true);
        Order_Line_Item_Details__c olid3 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11113',Location__c = Loc.Id, isSubmitted__c = true);
        Order_Line_Item_Details__c olid4 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11114',Location__c = Loc.Id,  isSubmitted__c = true);

        List<Order_Line_Item_Details__c> OLIDList = new List<Order_Line_Item_Details__c>();
        OLIDList.add(olid1);
        //OLIDList.add(olid2);
        OLIDList.add(olid3);
        OLIDList.add(olid4);
        insert OLIDList;
        Order_Line_Item_Details__c olid5 = [select id,name from Order_Line_Item_Details__c where GP_ERP_Order_ID__c = '11111'];        
        //olid2.Source_Vehicle_ID__c = olid5.Name;        
        insert olid2;        
        OLIDList.add(olid2);
        return OLIDList;
    }
    
    public static List<Order_Line_Item_Details__c> createOrderLineItemDetailRecords2(location__c loc){        
    //ETA_Staging__c eta = CreateETAStaging();       
    Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11111', Location__c = Loc.Id, isSubmitted__c = true, Service_Completed__c = 'Yes');        
    Order_Line_Item_Details__c olid2 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11112',Location__c = Loc.Id, isSubmitted__c = true, Service_Completed__c = 'Yes');        
    Order_Line_Item_Details__c olid3 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11113',Location__c = Loc.Id, isSubmitted__c = true, Service_Completed__c = 'Yes');        
    Order_Line_Item_Details__c olid4 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11114',Location__c = Loc.Id,  isSubmitted__c = true, Service_Completed__c = 'Yes');        
    List<Order_Line_Item_Details__c> OLIDList = new List<Order_Line_Item_Details__c>();        
    OLIDList.add(olid1);        
    OLIDList.add(olid2);        
    OLIDList.add(olid3);        
    OLIDList.add(olid4);        
    insert OLIDList;        
    return OLIDList;    
    }
    
    public static CPQ_SOMAST__c createCPQ_SOMAST(opportunity opp){
        CPQ_SOMAST__c cpqsomast = new CPQ_SOMAST__c(Opportunity__c = opp.Id, name = 'Test',primary__c = true);
        insert cpqsomast;
        return cpqsomast;
    }
    
    //public static CPQ_Opportunity_Products__c createBundleKit (Account act, opportunity Opp){
     //   CPQ_Opportunity_Products__c cpqlibun = new CPQ_Opportunity_Products__c(Product_Category__c = 'HARNESS', SKU__c = 'PARTS059', SEQ__c = '1.3', Product_Category__c = 'HARDWARE', SKU__c = '5500N3VD', SEQ__c = '1.1', Product_Category__c = 'SOLUTION', SKU__c = 'SOL-GPS AND DIAGNOSTICS-VERIZON', SEQ__c = '1');
        //insert cpqlibun;
       // return cpqlibun;
        //}
    //public static CPQ_Opportunity_Products__c cpqProducts (Account act, opportunity Opp){
        //CPQ_Opportunity_Products__c cpqli = new CPQ_Opportunity_Products__c(Sale_Type__c = 'PURCHASE', BUN_Qty__c = 5, Product_Category__c = 'HARDWARE', Product_Record_Id__r.CPQ_PRODUCT_NAME__c = '*CPQ ONLY* DO NOT USE - 5500N3VD GPS Diagnostics', Product_Record_Id__r.ProductCode = '5500N3VD', PUR_Qty__c = 1, PUR_NRC_Sale__c = 225.00);
        //insert cpqli;
        //return cpqli;
        //}
   public static OpportunityLineItem ddpProducts (Opportunity Opp){
       
       
       Product2 product = new Product2();
        product.Name = 'Test';
        product.ProductCode = 'Part 47';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
       OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookentryId = pricebookEntry.Id, Quantity = 4, UnitPrice = 170.00, Category__c = 'Hardware');
       
        insert oli;
        return oli;
       }
        
  }