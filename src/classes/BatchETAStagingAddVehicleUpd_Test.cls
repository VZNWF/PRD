@isTest
public class BatchETAStagingAddVehicleUpd_Test{
    public static TestMethod void UnitTest(){
    ETA_Staging__c ETAStaging1 = UtilsTest.CreateETAStaging();
    list<SchdClassSettings__c> SchdClassSettingsList = UtilsTest.CreateSchdClassSettings();
    Test.StartTest();    
    system.scheduleBatch(new BatchETAStagingAddVehicleUpd(),'SchdClass2', Integer.valueof(SchdClassSettings__c.getall().get('TimeInterval').value__c),Integer.valueof(SchdClassSettings__c.getall().get('Logic1BatchSize').value__c));
    Test.StopTest();
    }
}