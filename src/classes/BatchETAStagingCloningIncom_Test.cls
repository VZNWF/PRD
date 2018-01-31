@isTest
public class BatchETAStagingCloningIncom_Test{
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @testsetup
    public static void insertSetting(){
       Toggle_Switch__c trgSw = new Toggle_Switch__c();
       trgsW.Name = 'ETA_Staging__c';
       trgSw.isTriggerDisabled__c = false;
       upsert trgSw;
    }
    
    public static TestMethod void UnitTest(){
    Account Acc = UtilsTest.createAccount();
    Location__c Loc = UtilsTest.createLocation(Acc);
    Affiliate__c aff = UtilsTest.createAffiliate(); 
    Contact con = UtilsTest.createContact(aff);
    List<Order_Line_Item_Details__c> CreateOLIDList = UtilsTest.createOrderLineItemDetailRecords(Loc);
    List<Order_Line_Item_Details__c> CreateOLIDList1 = UtilsTest.createOrderLineItemDetailRecords2(Loc);
    List<Order_Line_Item_Details__c> OLIDLiistUpdation = new List<Order_Line_Item_Details__c>();
    ETA_Staging__c ETAStaging1 = UtilsTest.CreateETAStaging();
    ETAStaging1.Assigned_Resource_ID__c = 'TEST123';//aff.Name;
    update ETAStaging1;
    con.Certified_Installer_ID__c = 'TEST123'; //ETAStaging1.Assigned_Resource_ID__c;
    update con;
    for(Order_Line_Item_Details__c olid:CreateOLIDList){
    olid.ETA_Staging__c = ETAStaging1.Id;
    OLIDLiistUpdation.add(olid);
    }
    for(Order_Line_Item_Details__c olid:CreateOLIDList1){
    olid.ETA_Staging__c = ETAStaging1.Id;
    OLIDLiistUpdation.add(olid);
    }
    update OLIDLiistUpdation;
    //list<SchdClassSettings__c> SchdClassSettingsList = UtilsTest.CreateSchdClassSettings();
    Test.StartTest();
    System.schedule('ScheduleApexClass',CRON_EXP,new BatchETAStagingCloningIncompleteOrders());
    Test.StopTest();
    }
    
    public static TestMethod void UnitTest2(){
    Account Acc = UtilsTest.createAccount();
    Location__c Loc = UtilsTest.createLocation(Acc);
    Affiliate__c aff = UtilsTest.createAffiliate(); 
    Contact con = UtilsTest.createContact(aff);
    List<Order_Line_Item_Details__c> CreateOLIDList = UtilsTest.createOrderLineItemDetailRecords(Loc);
    List<Order_Line_Item_Details__c> CreateOLIDList1 = UtilsTest.createOrderLineItemDetailRecords2(Loc);
    List<Order_Line_Item_Details__c> OLIDLiistUpdation = new List<Order_Line_Item_Details__c>();
    ETA_Staging__c ETAStaging1 = UtilsTest.CreateETAStaging();
    ETAStaging1.Assigned_Resource_ID__c = 'TEST123';//aff.Name;
    ETAStaging1.ETA_Staging_Status__c = 'Started';
    ETAStaging1.Scheduled_Date__c = System.Today() - 1;
    
    update ETAStaging1;
    con.Certified_Installer_ID__c = 'TEST123'; //ETAStaging1.Assigned_Resource_ID__c;
    update con;
    for(Order_Line_Item_Details__c olid:CreateOLIDList){
    olid.ETA_Staging__c = ETAStaging1.Id;
    olid.Service_Completed__c = 'No Show';
        olid.isSubmitted__c = true;
    OLIDLiistUpdation.add(olid);
    }
    for(Order_Line_Item_Details__c olid:CreateOLIDList1){
    olid.ETA_Staging__c = ETAStaging1.Id;
    OLIDLiistUpdation.add(olid);
    }
    update OLIDLiistUpdation;
    //list<SchdClassSettings__c> SchdClassSettingsList = UtilsTest.CreateSchdClassSettings();
    Test.StartTest();
    System.schedule('ScheduleApexClass',CRON_EXP,new BatchETAStagingCloningIncompleteOrders());
    Test.StopTest();
    }
}