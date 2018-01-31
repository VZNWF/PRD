@isTest
private class NotifyAffiliateByEmailTest
{

    @isTest 
    static void testSendEmail()
    {

        Task task1 = new Task(Subject = 'test subject', Status = 'In Progress', Type = 'Call', Email_Affilate_Rep__c = 'Yes', Email_Affiliate_Sales_Rep__c = true
            );
        insert task1;

        List<Task> taskList = new List<Task>{task1};
        NotifyAffiliateByEmail.sendEmail(taskList);

    }

    @isTest
    static void testInnerClassForLead()
    {
        //lead with all required fields plus those to test
        Lead lead = new Lead(LastName ='Doe', Company='CodeScience', Title='Coder', Industry='Software', Phone = '3034445656', Email='test@test.com', Status='New', Main_Unqualified_Reason__c ='Bogus Lead', Sub_Unqualified_Reason_1__c ='Other', Lead_Type__c='Other', Lead_Sub_Type__c='OTHER', Total_Number_of_Vehicles__c=0, LeadSource='Event', Specific_Lead_Source__c='Adroll' , Affiliate_Sales_Name__c = 'Jane Doe', Affiliate_Sales_Name_2__c = 'Judy Doe', Affiliate_Sales_Email__c='jane.doeTester@testexample.com', Affiliate_Sales_Email_2__c='judy.doeTester@testexample.com', Affiliate_Lead_ID__c='00Qe00000047Ged', Affiliate_Lead_ID_2__c = '00Qe00000047Gkd' ); //ACCOUNT?
        insert lead;
        System.assert(lead.Id != null);

        //create a task
        Task task = new Task(Subject='test task', Priority='Normal', Type='Call' , WhoId = lead.Id, Description='My Test Description content');
        insert task;
        System.assert(task.Id != null);

    
        //pass task to NotifyAffiliateByEmail inner class ExtendedTask contstructor
        NotifyAffiliateByEmail.ExtendedTask eTask = new NotifyAffiliateByEmail.ExtendedTask(task);

        System.assertEquals(task.Id, eTask.baseTask.Id);
        //System.assertEquals(lead.Affiliate_Sales_Email__c, eTask.toEmail);
    //  System.assert(eTask.toEmail.contains(lead.Affiliate_Sales_Email__c));
        //System.assert
//      System.assertEquals(lead.Affiliate_Sales_Name__c, eTask.toName);
        System.assertEquals(lead.Company, eTask.companyName);
        System.assertEquals(lead.Affiliate_Lead_ID__c, eTask.leadId);
        System.assertEquals( UserInfo.getName(), eTask.ownerName );

        List<User> users = [SELECT Id, Phone
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()];
        if (users.size() > 0){
            System.assertEquals(users[0].Phone, eTask.ownerPhone);
        }

        System.assertEquals(UserInfo.getUserEmail(), eTask.ownerEmail);
        System.assert(eTask.isLeadOrOpp = true);

    }

    @isTest
    static void testInnerClassForOpportunity()
    {
        Account account = new Account(Name ='testAccountforOpp');
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Test Account for Opp', StageName = 'test', CloseDate = Date.today(),Affiliate_Sales_Name__c ='Affiliate Sales Person', Affiliate_Sales_Name_2__c = 'Affiliate Sales Person 2', Affiliate_Sales_Email__c = 'affiliate.salesperson@test.com', Affiliate_Sales_Email_2__c = 'affiliate.salesperson2@test.com', AccountId = account.Id , Affiliate_Lead_ID__c ='00Qe00000047Ged');
        DataBase.insert(opportunity,false );

        //create a task
        Task task = new Task(Subject='test task', Priority='Normal', Type='Call' , WhatId = opportunity.Id, Description='My Test Description content');
        DatabASE.insert(task,false );
        System.assert(task.Id != null);

    
        //pass task to NotifyAffiliateByEmail inner class ExtendedTask contstructor
        NotifyAffiliateByEmail.ExtendedTask eTask = new NotifyAffiliateByEmail.ExtendedTask(task);
        System.assertEquals(eTask.baseTask.Id, task.Id);
        
        
        
       
//      System.assertEquals(eTask.ownerName, user.Name);
//      System.assertEquals(eTask.ownerPhone, user.Phone);
//      System.assertEquals(eTask.ownerEmail, user.Email);
        

    }

    static Account createAccount(Id SOSUserId){

        Account account = new Account(Name ='testing Account', SOS_Owner__c = SOSUserId);
        //set some values
        //required fields account name, SOS owner, act type, sub type sales partner vertical, total num vehicles

        insert account;
        return account;
    }


}