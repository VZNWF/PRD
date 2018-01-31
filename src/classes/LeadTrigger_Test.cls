/****************************************************************
Created: 25 Feb 2013
Author: Aaron Pettitt (CodeScience)
Purpose : test class for the Lead trigger
Modifications:
******************************************************************/
@isTest
private class LeadTrigger_Test {

    static testMethod void myUnitTest() {
        test.startTest();
        Lead lead = TestUtils.createLead();        
        lead.Update_PRM__c = true;
        lead.status = 'Unqualified';
        
        update lead;
        
        User u = [Select Id from User where Profile.name = 'System Administrator' and isActive = true and Id<>:Userinfo.getUserId() LIMIT 1];
        lead.OwnerId = u.Id;
        
        update lead;
        
        system.assertequals('Unqualified', lead.status);
        test.stopTest();
    }

    static testMethod  void testOwnerProfileNew(){
        Profile p = [select id from profile where name='Sales Call Center User'];
        //need to assign ROLE to user
        UserRole r = new UserRole(name = 'Concentrix Sales Rep');
            Database.insert(r);         
            User u = new User(alias = 'clCtrUsr', email='callcenteruser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', Username='callcenteruser@testorg.com',  UserRoleId = r.id);
        insert u;
        u = [select Id, UserRoleId, Username from User where id=: u.Id];
          System.runAs(u) {
            System.assertEquals(u.Username,UserInfo.getUserName());
            System.assertEquals(r.Id, UserInfo.getUserRoleId());
            System.assertEquals(p.id, UserInfo.getProfileId()); 
            Lead lead = new Lead(LastName = 'Test123432', Company='Test Company', Phone = '555-789-5947', 
            Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', 
            Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', 
            Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '111111111111111', 
            Main_Unqualified_Reason__c = 'Feature Function');
            insert lead;
            lead = [Select Id, OwnerId, SCC_Sub_Channel__c, LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, 
            Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, 
            Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead.Id];
            //now query lead
            System.assert(lead.id != null);    
            System.assert(lead.OwnerId != null);
            System.assert(u.Id != null);
            System.assertEquals(lead.ownerId, u.Id);
            System.assertEquals(u.userroleid, r.id);        
            //trigger should run and set SCC_Sub_Channel__c = true
            System.assertEquals(true, lead.SCC_Sub_Channel__c);
            
        }
    }

    static testMethod void testOwnerRoleUpdate(){
        Profile p = [select id from profile where name='Sales Call Center User'];
        //don't assign the correct role
        UserRole r = new UserRole(name = 'Concentrix Sales Rep');
            Database.insert(r);         
            User u = new User(alias = 'clCtrUsr', email='callcenteruser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='callcenteruser@testorg.com'); //, userroleid = r.id);
        insert u;
        u = [select Id, userroleid, username from User where id=: u.Id];
        System.runAs(u) {
            System.assertEquals(u.userName,UserInfo.getUserName());
            System.assertEquals(p.id, UserInfo.getProfileId()); 
            Lead lead = new Lead(LastName = 'Test123432', Company='Test Company', Phone = '555-789-5947', 
            Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', 
            Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', 
            Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '111111111111111', 
            Main_Unqualified_Reason__c = 'Feature Function');
            insert lead;
            lead = [Select Id, OwnerId, SCC_Sub_Channel__c, LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, 
            Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, 
            Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead.Id];
            //now query lead
            System.assert(lead.id != null);    
            System.assert(lead.OwnerId != null);
            System.assert(u.Id != null);
            System.assertEquals(lead.ownerId, u.Id);
            System.assert(u.userroleid != r.id);    
            //trigger should run but won't set SCC_Sub_Channel__c = true
            //because role is not right
            System.assertEquals(false, lead.SCC_Sub_Channel__c);            
        }
        //assign correct role
        u.userRoleId = r.id;
        update u;
        System.runAs(u){
            System.assertEquals(r.Id, UserInfo.getUserRoleId());

            Lead lead2 = new Lead(LastName = 'Test909090xxx', Company='another Test Company', Phone = '5675758787', 
            Email='testlead90@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', 
            Total_Number_of_Vehicles__c = 100, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', 
            Affiliate_Lead_ID__c = '41702979', Partner_ID__c = '1111111111111113', 
            Main_Unqualified_Reason__c = 'Feature Function');
            insert lead2;
            lead2 = [Select Id, OwnerId, SCC_Sub_Channel__c, LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, 
            Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, 
            Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead2.Id];
            //now query lead
            System.assert(lead2.id != null);    
            System.assert(lead2.OwnerId != null);
            System.assert(u.Id != null);
            System.assertEquals(lead2.ownerId, u.Id);
            System.assertEquals(u.userroleid, r.id);    
            System.assertEquals(true, lead2.SCC_Sub_Channel__c);            

        }
    }

   static testMethod void testOwnerProfileUpdate(){
        Profile correctProfile = [select id from profile where name='Sales Call Center User'];
        Profile wrongProfile = [SELECT id FROM Profile WHERE name = 'System Administrator'];
        //don't assign the correct profile
        UserRole r = new UserRole(name = 'Concentrix Sales Rep');
            Database.insert(r);         
            User u = new User(alias = 'clCtrUsr', email='callcenteruser@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = wrongProfile.Id,
            timezonesidkey='America/Los_Angeles', username='callcenteruser@testorg.com', userroleid = r.id);
        insert u;
        u = [select Id, userroleid, username, ProfileId  from User where id=: u.Id];
        System.runAs(u) {
            System.assertEquals(u.userName,UserInfo.getUserName());
            System.assertEquals(wrongProfile.id, UserInfo.getProfileId()); 
            Lead lead = new Lead(LastName = 'Test123432', Company='Test Company', Phone = '555-789-5947', 
            Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', 
            Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', 
            Affiliate_Lead_ID__c = '41702978', Partner_ID__c = '1111111111111116', 
            Main_Unqualified_Reason__c = 'Feature Function');
            insert lead;
            lead = [Select Id, OwnerId, SCC_Sub_Channel__c, LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, 
            Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, 
            Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead.Id];
            //now query lead
            System.assert(lead.id != null);    
            System.assert(lead.OwnerId != null);
            System.assert(u.Id != null);
            System.assertEquals(lead.ownerId, u.Id);
            System.assert(u.ProfileId == wrongProfile.id);  
            //trigger should run but won't set SCC_Sub_Channel__c = true
            //because role is not right
            System.assertEquals(false, lead.SCC_Sub_Channel__c);            
        }
        //assign correct profile
        u.ProfileId = correctProfile.id;
        update u;
        System.runAs(u){
            System.assertEquals(correctProfile.Id, UserInfo.getProfileId());

            Lead lead2 = new Lead(LastName = 'Test909090', Company='Test Company', Phone = '555-789-5947', 
            Email='testlead@mailuser.com', Status = 'New', Lead_Type__c = 'Other', Lead_Sub_Type__c = 'Other', 
            Total_Number_of_Vehicles__c = 10, LeadSource = 'Other', Specific_Lead_Source__c = 'Other', 
            Affiliate_Lead_ID__c = '4170297', Partner_ID__c = '111111111111111', 
            Main_Unqualified_Reason__c = 'Feature Function');
            insert lead2;
            lead2 = [Select Id, OwnerId, SCC_Sub_Channel__c, LastName, Company, Phone, Email, Owner.Email, Status, Lead_Type__c, Lead_Sub_Type__c, 
            Total_Number_of_Vehicles__c, Lead_Opp_Number__c, LeadSource, Specific_Lead_Source__c, Affiliate_Lead_ID__c, 
            Partner_ID__c, Main_Unqualified_Reason__c, NWF_Lead_Opp_Number__c from Lead where Id =: lead2.Id];
            //now query lead
            System.assert(lead2.id != null);    
            System.assert(lead2.OwnerId != null);
            System.assert(u.Id != null);
            System.assertEquals(lead2.ownerId, u.Id);
            System.assertEquals(u.userroleid, r.id);    
            System.assertEquals(true, lead2.SCC_Sub_Channel__c);            

        }
    }
}