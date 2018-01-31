@isTest
public class ETAStagingTriggerHandler_Test{
    
    private static Account newAccount;    
    private static Contact newContact;
    private static Orders__c newOrders;
    private static Location__c newLocation;
    private static ETA_Staging__c etaStaging = new ETA_Staging__c();
    private static ETA_Staging__c etaStaging1 = new ETA_Staging__c();
    private static ETA_Staging__c etaStaging2 = new ETA_Staging__c();
    public static List<ETA_Staging__c> etaStagingList;
    private static Order_Line_Item_Details__c newOLID;
    private static Order_Line_Item_Details__c newOLID1;
    public static list<Account> newAccountETA = new list<Account>();
    /*
    @testsetup
    public static void insertSetting(){
       Toggle_Switch__c trgSw = new Toggle_Switch__c();
       trgsW.Name = 'ETA_Staging__c';
       trgSw.isTriggerDisabled__c = false;
       upsert trgSw;
    }*/
    
    public static void createTestData(){
       
       newAccount = new Account();  
       newAccount.Name = 'TestAccount';        
       insert newAccount ;
       
       newContact = new Contact();  
       newContact.FirstName = 'TestFirst';  
       newContact.LastName = 'TestLast';   
       newContact.Email = 'Test@First.com';     
       insert newContact;
       
       OrderICuser__c  OIC = new OrderICuser__c();
       OIC = UtilsTest.createOrderICuser();
         
       newOrders = new Orders__c();       
       newOrders.Account__c = newAccount.id;   
       newOrders.Contact__c  = newContact.Id;  
       newOrders.GP_ERP_Order_ID__c  = 'TestOrderID';    
       insert newOrders;     
  
       newLocation = new Location__c();       
       newLocation.Customer__c = newAccount.id;
       newLocation.Name = 'TestLocation';      
       insert newLocation ; 
       
       
       etaStaging.ETA_Staging_Status__c = 'Pending';
       etaStaging.Account__c = newAccount.Id;
       etaStaging.Order__c = newOrders.Id;
       etaStaging.Location__c = newLocation.Id; 
       insert etaStaging; 
       
       etaStaging1.ETA_Staging_Status__c = 'Pending';
       etaStaging1.Account__c = newAccount.Id;
       etaStaging1.Order__c = newOrders.Id;
       etaStaging1.Location__c = newLocation.Id; 
       insert etaStaging1; 
        
       etaStaging2.ETA_Staging_Status__c = 'Started';
       etaStaging2.Account__c = newAccount.Id;
       etaStaging2.Order__c = newOrders.Id;
       etaStaging2.Location__c = newLocation.Id; 
       insert etaStaging2;         
       
        etaStaging2.Is_no_Show__c = true;
        update etaStaging2;
       //etaStagingList.add(etaStaging);
       //etaStagingList.add(etaStaging1);
           
       newOLID = new Order_Line_Item_Details__c();                   
       newOLID.Location__c  = newLocation.id;
       newOLID.SF_Orders__c     = newOrders.id;
       newOLID.Contact_Name__c =newContact.Name;
       newOLID.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID.ETA_Staging__c = etaStaging.Id;
       insert newOLID;
       
       newOLID1 = new Order_Line_Item_Details__c();                   
       newOLID1.Location__c  = newLocation.id;
       newOLID1.SF_Orders__c     = newOrders.id;
       newOLID1.Contact_Name__c =newContact.Name;
       newOLID1.GP_ERP_Order_ID__c  =newOrders.GP_ERP_Order_ID__c;
       newOLID1.ETA_Staging__c = etaStaging.Id;
       insert newOLID1;  
       
       
    }
    
         static testMethod void testForETAStagingInsert() { 
         //OrderICuser__c  OIC = new OrderICuser__c();
         //OIC = UtilsTest.createOrderICuser();
         UtilsTest.CreateOpportunityCPQMapping();        
        account newAccountETA1 = new Account();  
       newAccountETA1.Name = 'TestAccountETA1'; 
             
        newAccountETA1.CPQ_PRICE_TIER__c = '2';
       newAccountETA1.AccountNumber = '1215';
         
        insert newAccountETA1;
       account newAccountETA2 = new Account();  
         newAccountETA2.CPQ_PRICE_TIER__c = '2';
       newAccountETA2.Name = 'TestAccountETA2'; 
       newAccountETA2.AccountNumber = '12345';
         insert newAccountETA2;
        account newAccountETA3 = new Account();  
         newAccountETA3.CPQ_PRICE_TIER__c = '2';
       newAccountETA3.Name = 'TestAccountETA3'; 
       newAccountETA3.AccountNumber = 'STANDARD';
         insert newAccountETA3;
         
        list<AR_SalePricing__c> ARSPlist = new list<AR_SalePricing__c>();       
         AR_SalePricing__c ARSP = new AR_SalePricing__c();
         ARSP.install__c = 123456;
         ARSP.swap__c = 123457;
         ARSP.customer_number__c = '1215';
         ARSPlist.add(ARSP);
         AR_SalePricing__c ARSP2 = new AR_SalePricing__c();

         ARSP2.install__c = 1234568;
         ARSP2.swap__c = 1234579;
         ARSP2.customer_number__c = '12345';
         ARSPlist.add(ARSP2);
         AR_SalePricing__c ARSP3 = new AR_SalePricing__c();
         ARSP3.install__c = 1234555;
         ARSP3.swap__c = 123444;
         ARSP3.customer_number__c = 'STANDARD';
         ARSPlist.add(ARSP3);
         insert ARSPlist; 
         list<opportunity> Opplist =  new list<opportunity>();
         opportunity OppNonStand = new opportunity(); 
         opportunity OppStand = new opportunity();
             opportunity OppBundle = new opportunity();
         OppStand.AccountId = newAccountETA1.Id;
         OppStand.Type_of_sale__c = 'Indirect';
         OppStand.CloseDate = system.today();
         OppStand.name = 'OppStand';
         OppStand.stagename = 'pilot';   
         OppStand.Type= 'New Business'; 
         insert OppStand;
         OppNonStand.AccountId = newAccountETA2.Id;
         OppNonStand.Type_of_sale__c = 'Indirect';
         
         OppNonStand.CloseDate = system.today();
         OppNonStand.name = 'OppNonStand';
         OppNonStand.stagename = 'pilot';
         OppNonStand.Type= 'New Business';     
         insert OppNonStand;
         OppBundle.AccountId = newAccountETA2.Id;
         OppBundle.Type_of_sale__c = 'Bundled';         
         OppBundle.CloseDate = system.today();
         OppBundle.name = 'OppNonStand';
         OppBundle.stagename = 'pilot';
         OppBundle.Type= 'New Business';     
         insert OppBundle;
         
         Orders__c Ord1 = new Orders__c();
         Ord1.Account__c = newAccountETA1.Id;
         Ord1.opportunity__c = OppStand.Id;
        insert Ord1;    
         
         Orders__c Ord2 = new Orders__c();
         Ord2.Account__c = newAccountETA2.Id;
         Ord2.opportunity__c = OppNonStand.Id;
        insert Ord2;
             Orders__c Ord3 = new Orders__c();
         Ord3.Account__c = newAccountETA2.Id;
         Ord3.opportunity__c = OppBundle.Id;             
        insert Ord3;
         list<ETA_Staging__c> ETAList = new list<ETA_Staging__c>();
         ETA_Staging__c ETAStandard = new ETA_Staging__c();
         ETA_Staging__c ETANonStandard = new ETA_Staging__c();
         ETA_Staging__c ETAStandard2 = new ETA_Staging__c();
         ETA_Staging__c ETAStandard3 = new ETA_Staging__c();
         ETAStandard.Account__c = newAccountETA1.Id;
         ETAStandard.Order__c =Ord1.Id; 
         
         ETANonStandard.Account__c = newAccountETA2.Id;
         ETANonStandard.Order__c =Ord2.Id; 
         ETAStandard2.Account__c = newAccountETA3.Id; 
         ETAStandard2.Order__c =Ord2.Id;     
    ETAStandard3.Order__c =Ord3.Id;                          
         ETAList.add(ETAStandard);
         ETAList.add(ETANonStandard);
         ETAList.add(ETAStandard2);
         ETAList.add(ETAStandard3);
             test.startTest();
         insert ETAList; 
         test.stopTest();
     }

    
     
     static testMethod void testUpdateForClone() {
       createTestData(); 
       test.startTest();
       etastaging.Clone_Activity_with_Inventory__c = true;
       etastaging.Number_of_vehicles_to_add__c = 2;
       etastaging.Clone_Activity_with_Inventory__c  =false;
       etastaging.No_of_Install_Type__c = 0;
       update etastaging;
       
       etastaging.Clone_Activity_with_Inventory__c = true;
       etastaging.No_of_Install_Type__c = 1;
        update etastaging;
       
       newOLID1.ETA_Staging__c = etaStaging1.Id;
       newOLID1.ETA_INV_ID__c= '';
       newOLID1.Service_Completed__c = 'No show';
       update newOLID1; 
       
       etaStaging1.ETA_Staging_Status__c = 'Not done';
       update etaStaging1;
       test.stopTest();
       
     }
    
 }