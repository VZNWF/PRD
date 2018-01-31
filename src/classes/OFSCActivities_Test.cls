/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author: Sunil Kumar       
// File Name: OFSCActivities_Test
// Summary: Test Class for both Batch classes - BatchETAStagingStartedActivities,BatchETAStagingPendingActivities
// Created On:  03/28/2017    
// Jira Ticket Number: IT1638
// Modification Log:
====================
*******************************************************************************/
@isTest
public class OFSCActivities_Test{
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
    ETAStaging1.ETA_Staging_Status__c = 'Pending';
    ETAStaging1.Scheduled_Date__c = System.Today() - 1;
    
    update ETAStaging1;
    con.Certified_Installer_ID__c = 'TEST123'; //ETAStaging1.Assigned_Resource_ID__c;
    update con;
    
    Test.StartTest();
    Test.setMock(WebServiceMock.class, new OFSCCalloutMock());  
    System.schedule('ScheduleApexClass',CRON_EXP,new BatchOFSCPendingActivities());
    Test.StopTest();
  }
  
  public static TestMethod void UnitTest1(){
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
    
    Installer_Settings__c creds = new Installer_Settings__c();
    creds.name='soap user';
    creds.Login_ID__c = 'api_user';
    creds.company__c = '****';
    creds.password__c = '****';
    insert creds;
    Test.StartTest();
    Test.setMock(WebServiceMock.class, new OFSCCalloutMock());  
      OFSCDataHelper.prepareData(new List<ETA_Staging__c>{ETAStaging1});
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
    
    Installer_Settings__c creds = new Installer_Settings__c();
    creds.name='soap user';
    creds.Login_ID__c = 'api_user';
    creds.company__c = '****';
    creds.password__c = '****';
    insert creds;
    Test.StartTest();
    System.schedule('ScheduleApexClass',CRON_EXP,new BatchOFSCStartedActivities());
    Test.StopTest();
  }
}