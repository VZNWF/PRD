/*******************************************************************************
// Copyright (c) 2015 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Aravind Rajamanickam
// File Name:       ETA_Resource
// Summary:         class for ETA Resource object data structure
// Created On:      March-27-2015

// Modification Log:
====================

// Aravind    - 3/27/2015 - Create a base version of ETA_Resource class 
// Vasanth    - 4/14/2015 - Added Insert_Resource Method
// Vasanth    - 4/15/2015 - Added Update_Resource Method
// Siteja     - 6/13/2016 - Added a condition on createAffiliateProperties for resource type value.

*******************************************************************************/
 

public class ETA_Resource{

    
    // Insert_resource callout for insertic Contact Record into ETA Direct
     @future(callout=true)
     public static void InsertResourceFromContact(String contactId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Contact cont = [Select Id, Name, ETA_Status__c, ETA_Insert__c, Contact_Affiliate__c,Last_ETA_Sync__c, Callout__c,Installer_Status__c,Affiliate_ID__c,Contact_Type__c,FirstName,LastName,Email,Phone,
                               Certificate__c,MailingStreet,MailingCity,Affiliate_Name__c,MailingState,MailingPostalCode, Contact_Secondary_Affiliate__c,Master_Certified_Installer__c, Advanced_Certified_Installer__c
                        from Contact where Id =:contactId limit 1];
         
                
        String Id = cont.Certificate__c;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createContactProperties(props, cont);
            
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;
       /* if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.contactInsertResourceMockResponse();
        }else{*/
            resp = inputrequest.insert_resource(user_x, Id, properties, users, workskills );
       // }
        
        System.debug('resp::'+resp); 
        if(resp != null){
            
            if(resp.result_code != null && resp.result_code == 0){
                if(cont != null){
                    cont.ETA_Status__c = 'Linked';
                    cont.ETA_Description__c = 'ETA Linkage Successfull';
                    cont.Last_ETA_Sync__c = DateTime.Now();                      
                }
            }else{
                if(cont != null){
                    cont.ETA_Status__c = 'Unlinked';
                    cont.ETA_Description__c = resp.error_msg;
                    cont.Last_ETA_Sync__c = DateTime.Now();  
                }
            }
                
        }else{
            if(cont != null){
                cont.ETA_Status__c = 'Unlinked';
                cont.ETA_Description__c = 'Empty Response';
                cont.Last_ETA_Sync__c = DateTime.Now();                  
            }
        }
        
        cont.ETA_Insert__c = false;
        cont.Callout__c = true;
        update cont;
        
    } 
   
    
     // Update_resource callout to update contact record
     @future(callout=true)
     public static void UpdateResourceFromContact(String contactId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Contact cont = [Select Id, Name, ETA_Status__c,Callout__c,Installer_Status__c,Contact_Affiliate__c,Last_ETA_Sync__c, Affiliate_ID__c,Contact_Type__c,FirstName,LastName,Email,Phone,
                            Certificate__c,MailingStreet,MailingCity,Affiliate_Name__c,MailingState,MailingPostalCode, Contact_Secondary_Affiliate__c, Master_Certified_Installer__c, Advanced_Certified_Installer__c
                            from Contact where Id =:contactId limit 1];
        
                
        String Id = cont.Certificate__c;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createContactProperties(props, cont);
        
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;// inputrequest.update_resource(user_x, Id, properties, users, workskills );
        
       /* if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.contactUpdateResourceMockResponse();
        }else{*/
            resp = inputrequest.update_resource(user_x, Id, properties, users, workskills );
        //}
        
        System.debug('resp::'+resp); 
        
           if(resp != null){
                
                if(resp.result_code != null && resp.result_code == 0){
                    if(cont != null){
                        cont.ETA_Status__c = 'Linked';
                        cont.ETA_Description__c = 'ETA Linkage Successfull';
                        cont.Last_ETA_Sync__c = DateTime.Now();                          
                    }
                }else{
                    if(cont != null){
                        cont.ETA_Status__c = 'Unlinked';
                        cont.ETA_Description__c = resp.error_msg;
                        cont.Last_ETA_Sync__c = DateTime.Now();                          
                    }
                }
                    
            }else{
                if(cont != null){
                    cont.ETA_Status__c = 'Unlinked';
                    cont.ETA_Description__c = 'Empty Response';
                    cont.Last_ETA_Sync__c = DateTime.Now();                    
                }
            }
         
         cont.Callout__c = true;
         update cont;       
        
    }
 
    // Insert_User callout for insert Contact Record as User into ETA Direct
     @future(callout=true)
     public static void InsertUserFromContact(String contactId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Contact cont = [Select Id, Name, ETA_Status__c, ETA_Insert__c, ETA_Insert_User__c, Contact_Affiliate__c,Last_ETA_Sync__c, Callout__c,Installer_Status__c,Affiliate_ID__c,Contact_Type__c,FirstName,LastName,Email,Phone,
                               Certificate__c,MailingStreet,MailingCity,Affiliate_Name__c,MailingState,MailingPostalCode, Contact_Secondary_Affiliate__c,Master_Certified_Installer__c, Advanced_Certified_Installer__c
                        from Contact where Id =:contactId limit 1];
         
                
        String login = cont.Email;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createUserProperties(props, cont);
            
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        
        toatechResourcemanagement_Installer.ResourceIdListElement resources = new toatechResourcemanagement_Installer.ResourceIdListElement ();
       // String resources = cont.name;
        
        toatechResourcemanagement_Installer.ProfileListElement  profiles = new toatechResourcemanagement_Installer.ProfileListElement();
        //String profiles = 'Mobile Worker';
        
        toatechResourcemanagement_Installer.ProfileListElement managed_profiles = new toatechResourcemanagement_Installer.ProfileListElement();
      //  toatechResourcemanagement_Installer.ResourceIdListElement  res1 = new toatechResourcemanagement_Installer.ResourceIdListElement();
       String idVal;
       String[] namVal = new String[]{};
        /*
        if(cont.Contact_Secondary_Affiliate__c != null){
            idVal = cont.Contact_Secondary_Affiliate__c; 
        }else if(Cont.Contact_Affiliate__c != null){
             idVal = Cont.Contact_Affiliate__c;
        }
        else{
            idVal = 'verizon_nwf';
        } */
        idVal = cont.Certificate__c;
        namVal.add(idVal);
        resources.id= namVal;
        //resources.a(res1);
  
          toatechResourcemanagement_Installer.ProfileListElement prof1 = new toatechResourcemanagement_Installer.ProfileListElement ();
          String[] profVal = new String[]{'Mobile Worker'};      // prof1.Name = 'profile';
           //     prof1.Value = 'Manager';
                profiles.profile = profVal ;
            
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetUserResponseElement  resp;
       /* if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.contactInsertResourceMockResponse();
        }else{*/
            resp = inputrequest.insert_user(user_x, login, properties, resources, profiles, managed_profiles);
       // }
        
        System.debug('resp::'+resp); 
        if(resp != null){
            
            if(resp.result_code != null && resp.result_code == 0){
                if(cont != null){
                    cont.ETA_Status__c = 'Linked';
                    cont.ETA_Description__c = 'ETA Linkage Successfull';
                    cont.Last_ETA_Sync__c = DateTime.Now();                      
                }
            }else{
                if(cont != null){
                    cont.ETA_Status__c = 'Unlinked';
                    cont.ETA_Description__c = resp.error_msg;
                    cont.Last_ETA_Sync__c = DateTime.Now();  
                }
            }
                
        }else{
            if(cont != null){
                cont.ETA_Status__c = 'Unlinked';
                cont.ETA_Description__c = 'Empty Response';
                cont.Last_ETA_Sync__c = DateTime.Now();                  
            }
        }
        
        cont.ETA_Insert__c = false;
        cont.ETA_Insert_User__c = false;
        cont.Callout__c = true;
        update cont;
        
    } 
    
        // Update_user callout to update contact user record in ETA
     @future(callout=true)
     public static void UpdateUserFromContact(String contactId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Contact cont = [Select Id, Name, ETA_Status__c,Callout__c,Installer_Status__c,Contact_Affiliate__c,Last_ETA_Sync__c, Affiliate_ID__c,Contact_Type__c,FirstName,LastName,Email,Phone,
                            Certificate__c,MailingStreet,MailingCity,Affiliate_Name__c,MailingState,MailingPostalCode, Contact_Secondary_Affiliate__c, Master_Certified_Installer__c, Advanced_Certified_Installer__c
                            from Contact where Id =:contactId limit 1];
        
                
        String login = cont.Email;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createUserProperties(props, cont);
        
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        toatechResourcemanagement_Installer.ResourceIdListElement  resources = new toatechResourcemanagement_Installer.ResourceIdListElement();
        
        toatechResourcemanagement_Installer.ProfileListElement  profiles = new toatechResourcemanagement_Installer.ProfileListElement();
        
        toatechResourcemanagement_Installer.ProfileListElement managed_profiles = new toatechResourcemanagement_Installer.ProfileListElement();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
             toatechResourcemanagement_Installer.ResourceIdListElement  res1 = new toatechResourcemanagement_Installer.ResourceIdListElement();
           String idVal;
       String[] namVal = new String[]{};
        
        if(cont.Contact_Secondary_Affiliate__c != null){
            idVal = cont.Contact_Secondary_Affiliate__c; 
        }else if(Cont.Contact_Affiliate__c != null){
             idVal = Cont.Contact_Affiliate__c;
        }
        else{
            idVal = 'verizon_nwf';
        }
       
        namVal.add(idVal);
        resources.id= namVal;
        //resources.a(res1);
  
          toatechResourcemanagement_Installer.ProfileListElement prof1 = new toatechResourcemanagement_Installer.ProfileListElement ();
          String[] profVal = new String[]{'Manager'};      // prof1.Name = 'profile';
           //     prof1.Value = 'Manager';
                profiles.profile = profVal ;
         
        toatechResourcemanagement_Installer.SetUserResponseElement resp;// inputrequest.update_resource(user_x, Id, properties, users, workskills );
        
       /* if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.contactUpdateResourceMockResponse();
        }else{*/
            resp = inputrequest.update_user(user_x, login, properties, resources , profiles, managed_profiles );
        //}
        
        System.debug('resp::'+resp); 
        
           if(resp != null){
                
                if(resp.result_code != null && resp.result_code == 0){
                    if(cont != null){
                        cont.ETA_Status__c = 'Linked';
                        cont.ETA_Description__c = 'ETA Linkage Successfull';
                        cont.Last_ETA_Sync__c = DateTime.Now();                          
                    }
                }else{
                    if(cont != null){
                        cont.ETA_Status__c = 'Unlinked';
                        cont.ETA_Description__c = resp.error_msg;
                        cont.Last_ETA_Sync__c = DateTime.Now();                          
                    }
                }
                    
            }else{
                if(cont != null){
                    cont.ETA_Status__c = 'Unlinked';
                    cont.ETA_Description__c = 'Empty Response';
                    cont.Last_ETA_Sync__c = DateTime.Now();                    
                }
            }
         
         cont.Callout__c = true;
         update cont;       
        
    } 
    
    
     // Insert_resource callout for Affiliate record insert
     @future(callout=true)
     public static void InsertResourceFromAffiliate(String affiliateId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Affiliate__c affil = [Select Id, Name, ETA_Status__c, ETA_Insert__c, Callout__c,Affiliate_Status__c,Parent_Affiliate_ID__c,Last_ETA_Sync__c, Affiliate_Type__c,Affiliate_Name__c,
                                Email__c,Phone__c,Address_Line_1__c,City__c,Parent_Affiliate__c,State__c,Postal_Code__c, GP_Vendor_ID__c
                                 from Affiliate__c where Id =:affiliateId limit 1];
                
        String Id = affil.Name;
       
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};        
              
        createAffiliateProperties(props, affil); 
               
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;// = inputrequest.insert_resource(user_x, Id, properties, users, workskills );
        
        /*if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.affiliateInsertResourceMockResponse();
        }else{*/
            resp = inputrequest.insert_resource(user_x, Id, properties, users, workskills );
        //}
        System.debug('resp::'+resp); 
        
       
       if(resp != null){
            
            if(resp.result_code != null && resp.result_code == 0){
                if(affil != null){
                    affil.ETA_Status__c = 'Linked';
                    affil.ETA_Description__c = 'ETA Linkage Successfull';
                    affil.Last_ETA_Sync__c = DateTime.Now();
                }
            }else{
                if(affil != null){
                    affil.ETA_Status__c = 'Unlinked';
                    affil.ETA_Description__c = resp.error_msg;
                    affil.Last_ETA_Sync__c = DateTime.Now();
                }
            }
                
        }else{
            if(affil != null){
                affil.ETA_Status__c = 'TimeOut';
                affil.ETA_Description__c = 'Empty Response';
                affil.Last_ETA_Sync__c = DateTime.Now();
            }
        }
        affil.Callout__c = true;
        affil.ETA_Insert__c = false;
        update affil;
        
    } 
   
        // Update_resource callout for Affiliate Record update
     @future(callout=true)
     public static void UpdateResourceFromAffiliate(String affiliateId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c; 
        user_x.auth_string = AuthString ;
        
        Affiliate__c affil = [Select Id, Name, ETA_Status__c, Callout__c,Affiliate_Status__c,Parent_Affiliate_ID__c,Last_ETA_Sync__c, Affiliate_Type__c,Affiliate_Name__c,
                                Email__c,Phone__c,Address_Line_1__c,City__c,Parent_Affiliate__c,State__c,Postal_Code__c, GP_Vendor_ID__c
                                 from Affiliate__c where Id =:affiliateId limit 1];
                
        String Id = affil.Name;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createAffiliateProperties(props, affil);
        
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;// = inputrequest.update_resource(user_x, Id, properties, users, workskills );
        
        /*if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.affiliateUpdateResourceMockResponse();
        }else{*/
            resp = inputrequest.update_resource(user_x, Id, properties, users, workskills );
        //}
        System.debug('resp::'+resp); 
       
       if(resp != null){
            
            if(resp.result_code != null && resp.result_code == 0){
                if(affil != null){
                    affil.ETA_Status__c = 'Linked';
                    affil.ETA_Description__c = 'ETA Linkage Successfull';
                    affil.Last_ETA_Sync__c = DateTime.Now();
                }
            }else{
                if(affil != null){
                    affil.ETA_Status__c = 'Unlinked';
                    affil.ETA_Description__c = resp.error_msg;
                    affil.Last_ETA_Sync__c = DateTime.Now();
                    
                }
            }
                
        }else{
            if(affil != null){
                affil.ETA_Status__c = 'TimeOut';
                affil.ETA_Description__c = 'Empty Response';
                affil.Last_ETA_Sync__c = DateTime.Now();
            }
        }
        
        affil.Callout__c = true;
        update affil;
        
    }
    
     // Insert_resource callout for Rejected Bucket record insert
     @future(callout=true)
     public static void InsertRejectedBucketForAffiliate(String affiliateId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c;
        user_x.auth_string = AuthString ;
        
        Affiliate__c affil = [Select Id, Name, ETA_Status__c, ETA_Insert__c, Callout__c,Affiliate_Status__c,Parent_Affiliate_ID__c,Last_ETA_Sync__c, Affiliate_Type__c,Affiliate_Name__c,
                                Email__c,Phone__c,Address_Line_1__c,City__c,Parent_Affiliate__c,State__c,Postal_Code__c,Rejected_Bucket__c, GP_Vendor_ID__c
                                 from Affiliate__c where Id =:affiliateId limit 1];
                
        String Id = affil.Rejected_Bucket__c;
       
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};        
        
        createAffiliatePropertiesRejected(props, affil); 
               
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;// = inputrequest.insert_resource(user_x, Id, properties, users, workskills );
        
        /*if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.affiliateInsertResourceMockResponse();
        }else{*/
            resp = inputrequest.insert_resource(user_x, Id, properties, users, workskills );
        //}
        System.debug('resp::'+resp); 
        
        //affil.CreateRejectedBucket__c= false;
        //update affil;
   
        
    } 
   
        // Update_resource callout for Rejected Bucket Record update
     @future(callout=true)
     public static void UpdateRejectedBucketForAffiliate(String affiliateId){
        
        Installer_Settings__c csInstaller_Settings = Installer_Settings__c.getInstance('Integrate_Dev'); 
    
        String Password = csInstaller_Settings.Password__c; 
        String ISODATE = VZ_Util.GetCurrentDateTimeInISO8601Format();
        String AuthString = VZ_Util.GetAuthString(Password , ISODATE);  
        
        toatechResourcemanagement_Installer.GetResourceResponseElement respResource = new toatechResourcemanagement_Installer.GetResourceResponseElement();        
        toatechResourcemanagement_Installer toaResource = new toatechResourcemanagement_Installer();        
        toatechResourcemanagement_Installer.AuthNodeElement user_x = new  toatechResourcemanagement_Installer.AuthNodeElement();
        
        user_x.now = ISODATE;
        user_x.login = csInstaller_Settings.Login_ID__c;
        user_x.company = csInstaller_Settings.Company__c; 
        user_x.auth_string = AuthString ;
        
        Affiliate__c affil = [Select Id, Name, ETA_Status__c, Callout__c,Affiliate_Status__c,Parent_Affiliate_ID__c,Last_ETA_Sync__c, Affiliate_Type__c,Affiliate_Name__c,
                                Email__c,Phone__c,Address_Line_1__c,City__c,Parent_Affiliate__c,State__c,Postal_Code__c,Rejected_Bucket__c, GP_Vendor_ID__c
                                 from Affiliate__c where Id =:affiliateId limit 1];
                
        String Id = affil.Name;
        
        toatechResourcemanagement_Installer.PropertyElement[] props = new toatechResourcemanagement_Installer.PropertyElement[]{};
        createAffiliatePropertiesRejected(props, affil); 
        
        toatechResourcemanagement_Installer.PropertiesElement properties = new toatechResourcemanagement_Installer.PropertiesElement();
        properties.property = props;
        toatechResourcemanagement_Installer.UsersLoginList users = new toatechResourcemanagement_Installer.UsersLoginList();
        
        toatechResourcemanagement_Installer.WorkSkillList workskills = new toatechResourcemanagement_Installer.WorkSkillList();
        
        toatechResourcemanagement_Installer.ResourceManagementPort  inputrequest = new toatechResourcemanagement_Installer.ResourceManagementPort();
        toatechResourcemanagement_Installer.SetResourceResponseElement resp;// = inputrequest.update_resource(user_x, Id, properties, users, workskills );
        
        /*if(Test.isRunningTest()){
            resp = ETA_Resource_MockResponses.affiliateUpdateResourceMockResponse();
        }else{*/
            resp = inputrequest.update_resource(user_x, Id, properties, users, workskills );
        //}
        System.debug('resp::'+resp); 
       
             
    }
    
    public static void createContactProperties(toatechResourcemanagement_Installer.PropertyElement[] props, Contact cont){
        
        toatechResourcemanagement_Installer.PropertyElement prop1 = new toatechResourcemanagement_Installer.PropertyElement();
        prop1.Name = 'id';
        prop1.Value = cont.Certificate__c; //contact.Certificate__c != null ? String.valueOf(contact.Certificate__c) : null;        
        props.add(prop1);
        
        toatechResourcemanagement_Installer.PropertyElement prop2 = new toatechResourcemanagement_Installer.PropertyElement();
        prop2.Name = 'status';
        prop2.Value = cont.Installer_Status__c !=null ? cont.Installer_Status__c.toLowerCase()  : 'inactive';
        props.add(prop2);
               
        toatechResourcemanagement_Installer.PropertyElement prop3 = new toatechResourcemanagement_Installer.PropertyElement();
        prop3.Name = 'parent_id';
        if(cont.Contact_Secondary_Affiliate__c != null){
            prop3.Value = cont.Contact_Secondary_Affiliate__c; 
        }else if(Cont.Contact_Affiliate__c != null){
             prop3.Value = Cont.Contact_Affiliate__c;
        }
        else{
            prop3.Value = 'usa_live';
        }
        props.add(prop3);
       
        toatechResourcemanagement_Installer.PropertyElement prop4 = new toatechResourcemanagement_Installer.PropertyElement();
        prop4.Name = 'type';
        prop4.Value = 'MW';
        props.add(prop4);
                  
        toatechResourcemanagement_Installer.PropertyElement prop5 = new toatechResourcemanagement_Installer.PropertyElement();
        prop5.Name = 'name';
        prop5.Value = cont.LastName+', '+cont.FirstName;
        props.add(prop5);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop6 = new toatechResourcemanagement_Installer.PropertyElement();
        prop6.Name = 'email';
        prop6.Value = cont.Email;
        props.add(prop6);  
        
        toatechResourcemanagement_Installer.PropertyElement prop7 = new toatechResourcemanagement_Installer.PropertyElement();
        prop7.Name = 'phone';
        prop7.Value = cont.Phone;
        props.add(prop7);  

        toatechResourcemanagement_Installer.PropertyElement prop8 = new toatechResourcemanagement_Installer.PropertyElement();
        prop8.Name = 'language';
        prop8.Value = 'en';
        props.add(prop8);  
 
        toatechResourcemanagement_Installer.PropertyElement prop9 = new toatechResourcemanagement_Installer.PropertyElement();
        prop9.Name = 'time_zone_diff';
        prop9.Value = '-420';
        props.add(prop9);
                 
        toatechResourcemanagement_Installer.PropertyElement prop10 = new toatechResourcemanagement_Installer.PropertyElement();
        prop10.Name = 'time_zone';
        prop10.Value = 'Pacific';
        props.add(prop10); 
        
        toatechResourcemanagement_Installer.PropertyElement prop11 = new toatechResourcemanagement_Installer.PropertyElement();
        prop11.Name = 'date_format';
        prop11.Value = 'mm/dd/yy';
        props.add(prop11);  
          
        toatechResourcemanagement_Installer.PropertyElement prop12 = new toatechResourcemanagement_Installer.PropertyElement();
        prop12.Name = 'time_format';
        prop12.Value = '24-hour';
        props.add(prop12);  
          
        toatechResourcemanagement_Installer.PropertyElement prop13 = new toatechResourcemanagement_Installer.PropertyElement();
        prop13.Name = 'certification_number';
        prop13.Value = cont.Certificate__c;
        props.add(prop13);  
      
        toatechResourcemanagement_Installer.PropertyElement prop14 = new toatechResourcemanagement_Installer.PropertyElement();
        prop14.Name = 'installer_address';
        prop14.Value = cont.MailingStreet;
        props.add(prop14);  
        
        toatechResourcemanagement_Installer.PropertyElement prop15 = new toatechResourcemanagement_Installer.PropertyElement();
        prop15.Name = 'installer_city';
        prop15.Value = cont.MailingCity;
        props.add(prop15);  
      
        toatechResourcemanagement_Installer.PropertyElement prop16 = new toatechResourcemanagement_Installer.PropertyElement();
        prop16.Name = 'parent_company';
        prop16.Value = cont.Affiliate_Name__c;
        props.add(prop16);  
      
        toatechResourcemanagement_Installer.PropertyElement prop17 = new toatechResourcemanagement_Installer.PropertyElement();
        prop17.Name = 'installer_state';
        prop17.Value = cont.MailingState;
        props.add(prop17);  
       
        toatechResourcemanagement_Installer.PropertyElement prop18 = new toatechResourcemanagement_Installer.PropertyElement();
        prop18.Name = 'installer_zip';
        prop18.Value = cont.MailingPostalCode;
        props.add(prop18);  
        
        toatechResourcemanagement_Installer.PropertyElement prop19 = new toatechResourcemanagement_Installer.PropertyElement();
        prop19.Name = 'personnel_type';
        prop19.Value = '';
        props.add(prop19); 
        
        toatechResourcemanagement_Installer.PropertyElement prop20 = new toatechResourcemanagement_Installer.PropertyElement();
        prop20.Name = 'certificate_level';
        if(cont.Master_Certified_Installer__c){
            prop20.Value = 'Master'; 
        }else if(Cont.Advanced_Certified_Installer__c){
             prop20.Value = 'Advanced';
        }
        else{
            prop20.Value = 'Basic';
        }
        props.add(prop20);
        
        toatechResourcemanagement_Installer.PropertyElement prop21 = new toatechResourcemanagement_Installer.PropertyElement();
        prop21.Name = 'vendor_id';
        if(cont.Contact_Secondary_Affiliate__c != null){
            prop21.Value = cont.Contact_Secondary_Affiliate__c; 
        }else if(Cont.Contact_Affiliate__c != null){
             prop21.Value = Cont.Contact_Affiliate__c;
        }
        else{
            prop21.Value = 'usa_live';
        }
               
 
    } 
     
 
    
    public static void createAffiliateProperties(toatechResourcemanagement_Installer.PropertyElement[] props, Affiliate__c affil){
        string NTSSId = system.label.Affiliate_Name;
        toatechResourcemanagement_Installer.PropertyElement prop1 = new toatechResourcemanagement_Installer.PropertyElement();
        prop1.Name = 'id';
        prop1.Value = affil.Name; //contact.Certificate__c != null ? String.valueOf(contact.Certificate__c) : null;        
        props.add(prop1);
        
        toatechResourcemanagement_Installer.PropertyElement prop2 = new toatechResourcemanagement_Installer.PropertyElement();
        prop2.Name = 'status';
        prop2.Value = affil.Affiliate_Status__c != null ? affil.Affiliate_Status__c.toLowerCase() : 'inactive';
        props.add(prop2); 
               
        toatechResourcemanagement_Installer.PropertyElement prop3 = new toatechResourcemanagement_Installer.PropertyElement();
        prop3.Name = 'parent_id';
        prop3.Value = affil.Parent_Affiliate_ID__c!= null ? String.valueOf(affil.Parent_Affiliate_ID__c) : 'usa_live';
        props.add(prop3);
        
        toatechResourcemanagement_Installer.PropertyElement prop4 = new toatechResourcemanagement_Installer.PropertyElement();
        prop4.Name = 'type';
        if(affil.Parent_Affiliate_ID__c == NTSSId){
        prop4.Value = 'MW'; 
        } else {
        prop4.Value = 'BK'; 
        }
        props.add(prop4);
                  
        toatechResourcemanagement_Installer.PropertyElement prop5 = new toatechResourcemanagement_Installer.PropertyElement();
        prop5.Name = 'name';
        prop5.Value = affil.Affiliate_Name__c;
        props.add(prop5);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop6 = new toatechResourcemanagement_Installer.PropertyElement();
        prop6.Name = 'email';
        prop6.Value = affil.Email__c;
        props.add(prop6);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop7 = new toatechResourcemanagement_Installer.PropertyElement();
        prop7.Name = 'phone';
        prop7.Value = affil.Phone__c;
        props.add(prop7);  

        toatechResourcemanagement_Installer.PropertyElement prop8 = new toatechResourcemanagement_Installer.PropertyElement();
        prop8.Name = 'language';
        prop8.Value = 'en';
        props.add(prop8);  
 
        toatechResourcemanagement_Installer.PropertyElement prop9 = new toatechResourcemanagement_Installer.PropertyElement();
        prop9.Name = 'time_zone_diff';
        prop9.Value = '-420';
        props.add(prop9);
                 
        toatechResourcemanagement_Installer.PropertyElement prop10 = new toatechResourcemanagement_Installer.PropertyElement();
        prop10.Name = 'time_zone';
        prop10.Value = 'Pacific';
        props.add(prop10); 
        
        toatechResourcemanagement_Installer.PropertyElement prop11 = new toatechResourcemanagement_Installer.PropertyElement();
        prop11.Name = 'date_format';
        prop11.Value = 'mm/dd/yy';
        props.add(prop11);  
                    
        toatechResourcemanagement_Installer.PropertyElement prop12 = new toatechResourcemanagement_Installer.PropertyElement();
        prop12.Name = 'time_format';
        prop12.Value = '24-hour';
        props.add(prop12);  
                
        toatechResourcemanagement_Installer.PropertyElement prop13 = new toatechResourcemanagement_Installer.PropertyElement();
        prop13.Name = 'certification_number';
        prop13.Value = '';
        props.add(prop13);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop14 = new toatechResourcemanagement_Installer.PropertyElement();
        prop14.Name = 'installer_address';
        prop14.Value = affil.Address_Line_1__c;
        props.add(prop14);  
           
        toatechResourcemanagement_Installer.PropertyElement prop15 = new toatechResourcemanagement_Installer.PropertyElement();
        prop15.Name = 'installer_city';
        prop15.Value = affil.City__c;
        props.add(prop15);  
            
        toatechResourcemanagement_Installer.PropertyElement prop16 = new toatechResourcemanagement_Installer.PropertyElement();
        prop16.Name = 'parent_company';
        prop16.Value = affil.Parent_Affiliate_ID__c;
        props.add(prop16);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop17 = new toatechResourcemanagement_Installer.PropertyElement();
        prop17.Name = 'installer_state';
        prop17.Value = affil.State__c;
        props.add(prop17);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop18 = new toatechResourcemanagement_Installer.PropertyElement();
        prop18.Name = 'installer_zip';
        prop18.Value = affil.Postal_Code__c;
        props.add(prop18);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop19 = new toatechResourcemanagement_Installer.PropertyElement();
        prop19.Name = 'personnel_type';
        prop19.Value = '2';
        props.add(prop19);
        
                  
        toatechResourcemanagement_Installer.PropertyElement prop20 = new toatechResourcemanagement_Installer.PropertyElement();
        prop20.Name = 'affiliate_type';
        prop20.Value = affil.Affiliate_Type__c;
        props.add(prop20);
        
        toatechResourcemanagement_Installer.PropertyElement prop21 = new toatechResourcemanagement_Installer.PropertyElement();
        prop21.Name = 'vendor_id';
        prop21.Value = affil.GP_Vendor_ID__c;
        props.add(prop21);
        
             
    }
    
    
    public static void createAffiliatePropertiesRejected(toatechResourcemanagement_Installer.PropertyElement[] props, Affiliate__c affil){
        toatechResourcemanagement_Installer.PropertyElement prop1 = new toatechResourcemanagement_Installer.PropertyElement();
        prop1.Name = 'id';
        prop1.Value = affil.Rejected_Bucket__c; //contact.Certificate__c != null ? String.valueOf(contact.Certificate__c) : null;        
        props.add(prop1);
        
        toatechResourcemanagement_Installer.PropertyElement prop2 = new toatechResourcemanagement_Installer.PropertyElement();
        prop2.Name = 'status';
        prop2.Value = affil.Affiliate_Status__c != null ? affil.Affiliate_Status__c.toLowerCase() : 'inactive';
        props.add(prop2); 
               
        toatechResourcemanagement_Installer.PropertyElement prop3 = new toatechResourcemanagement_Installer.PropertyElement();
        prop3.Name = 'parent_id';
        prop3.Value = affil.Name; //affil.Parent_Affiliate_ID__c!= null ? String.valueOf(affil.Parent_Affiliate_ID__c) : 'usa_live';
        props.add(prop3);
       
        toatechResourcemanagement_Installer.PropertyElement prop4 = new toatechResourcemanagement_Installer.PropertyElement();
        prop4.Name = 'type';
        prop4.Value = 'BK';
        props.add(prop4);
                  
        toatechResourcemanagement_Installer.PropertyElement prop5 = new toatechResourcemanagement_Installer.PropertyElement();
        prop5.Name = 'name';
        prop5.Value = 'Rejected Bucket';//affil.Affiliate_Name__c;
        props.add(prop5);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop6 = new toatechResourcemanagement_Installer.PropertyElement();
        prop6.Name = 'email';
        prop6.Value = affil.Email__c;
        props.add(prop6);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop7 = new toatechResourcemanagement_Installer.PropertyElement();
        prop7.Name = 'phone';
        prop7.Value = affil.Phone__c;
        props.add(prop7);  

        toatechResourcemanagement_Installer.PropertyElement prop8 = new toatechResourcemanagement_Installer.PropertyElement();
        prop8.Name = 'language';
        prop8.Value = 'en';
        props.add(prop8);  
 
        toatechResourcemanagement_Installer.PropertyElement prop9 = new toatechResourcemanagement_Installer.PropertyElement();
        prop9.Name = 'time_zone_diff';
        prop9.Value = '-420';
        props.add(prop9);
                 
        toatechResourcemanagement_Installer.PropertyElement prop10 = new toatechResourcemanagement_Installer.PropertyElement();
        prop10.Name = 'time_zone';
        prop10.Value = 'Pacific';
        props.add(prop10); 
        
        toatechResourcemanagement_Installer.PropertyElement prop11 = new toatechResourcemanagement_Installer.PropertyElement();
        prop11.Name = 'date_format';
        prop11.Value = 'mm/dd/yy';
        props.add(prop11);  
                    
        toatechResourcemanagement_Installer.PropertyElement prop12 = new toatechResourcemanagement_Installer.PropertyElement();
        prop12.Name = 'time_format';
        prop12.Value = '24-hour';
        props.add(prop12);  
                
        toatechResourcemanagement_Installer.PropertyElement prop13 = new toatechResourcemanagement_Installer.PropertyElement();
        prop13.Name = 'certification_number';
        prop13.Value = '';
        props.add(prop13);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop14 = new toatechResourcemanagement_Installer.PropertyElement();
        prop14.Name = 'installer_address';
        prop14.Value = affil.Address_Line_1__c;
        props.add(prop14);  
           
        toatechResourcemanagement_Installer.PropertyElement prop15 = new toatechResourcemanagement_Installer.PropertyElement();
        prop15.Name = 'installer_city';
        prop15.Value = affil.City__c;
        props.add(prop15);  
            
        toatechResourcemanagement_Installer.PropertyElement prop16 = new toatechResourcemanagement_Installer.PropertyElement();
        prop16.Name = 'parent_company';
        prop16.Value = affil.Affiliate_Name__c; //affil.Parent_Affiliate_ID__c;
        props.add(prop16);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop17 = new toatechResourcemanagement_Installer.PropertyElement();
        prop17.Name = 'installer_state';
        prop17.Value = affil.State__c;
        props.add(prop17);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop18 = new toatechResourcemanagement_Installer.PropertyElement();
        prop18.Name = 'installer_zip';
        prop18.Value = affil.Postal_Code__c;
        props.add(prop18);  
                 
        toatechResourcemanagement_Installer.PropertyElement prop19 = new toatechResourcemanagement_Installer.PropertyElement();
        prop19.Name = 'personnel_type';
        prop19.Value = '2';
        props.add(prop19);
        
        toatechResourcemanagement_Installer.PropertyElement prop20 = new toatechResourcemanagement_Installer.PropertyElement();
        prop20.Name = 'affiliate_type';
        prop20.Value = affil.Affiliate_Type__c;
        props.add(prop20);
        
        toatechResourcemanagement_Installer.PropertyElement prop21 = new toatechResourcemanagement_Installer.PropertyElement();
        prop21.Name = 'vendor_id';
        prop21.Value = affil.GP_Vendor_ID__c;
        props.add(prop21);
    
    }
    
  
     public static void createUserProperties(toatechResourcemanagement_Installer.PropertyElement[] props, Contact cont){
        
        toatechResourcemanagement_Installer.PropertyElement prop1 = new toatechResourcemanagement_Installer.PropertyElement();
        prop1.Name = 'login';
        prop1.Value = cont.Email;        
        props.add(prop1);
        
        toatechResourcemanagement_Installer.PropertyElement prop2 = new toatechResourcemanagement_Installer.PropertyElement();
        prop2.Name = 'status';
        prop2.Value = 'active';
        props.add(prop2);
               
        toatechResourcemanagement_Installer.PropertyElement prop3 = new toatechResourcemanagement_Installer.PropertyElement();
        prop3.Name = 'password';
        prop3.Value = 'VZ8003508';
        props.add(prop3);
       
        toatechResourcemanagement_Installer.PropertyElement prop4 = new toatechResourcemanagement_Installer.PropertyElement();
        prop4.Name = 'name';
        prop4.Value = cont.LastName+', '+cont.FirstName;
        props.add(prop4);
                  
        toatechResourcemanagement_Installer.PropertyElement prop5 = new toatechResourcemanagement_Installer.PropertyElement();
        prop5.Name = 'language';
        prop5.Value = 'en';
        props.add(prop5);  
                   
        toatechResourcemanagement_Installer.PropertyElement prop6 = new toatechResourcemanagement_Installer.PropertyElement();
        prop6.Name = 'time_zone';
        prop6.Value = 'Pacific';
        props.add(prop6);  
        
        toatechResourcemanagement_Installer.PropertyElement prop7 = new toatechResourcemanagement_Installer.PropertyElement();
        prop7.Name = 'display_profile';
        prop7.Value = 'Mobile Worker';
        props.add(prop7);  
       
        toatechResourcemanagement_Installer.PropertyElement prop9 = new toatechResourcemanagement_Installer.PropertyElement();
        prop9.Name = 'password_temporary';
        prop9.Value = 'yes';
        props.add(prop9); 
    /*    
         toatechResourcemanagement_Installer.PropertyElement prop8 = new toatechResourcemanagement_Installer.PropertyElement();
        prop8.Name = 'main_resource_id';
        prop8.Value = cont.name;
        props.add(prop8); 
        
        toatechResourcemanagement_Installer.PropertyElement prop9 = new toatechResourcemanagement_Installer.PropertyElement();
        prop9.Name = 'profile';
        prop9.Value = 'Mobile Worker';
        props.add(prop9);        
  */
     }
    
        
     
}