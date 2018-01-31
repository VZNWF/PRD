/*
    Name: ContactCaseCountBatchUpdate
    Test Class : CustomerProfileSettingsControllerTest
    Description:  Batch script to count the number of cases, for the contact based on the Case Reason Criteria set on the Customer Profile Settings Page
    Modification History:
    Author      Jira                Date        Description

        
*/

global class ContactCaseCountBatchUpdate implements Database.Batchable<sObject>{
	//global variables
    global final String Query;
    global final String Operation;
    global final Id schConTriggerId;
    private Customer_Profile_Settings__c cPSettings = new Customer_Profile_Settings__c();
    private Map<Decimal, List<CustomerProfileSettingsController.ReasonWrapperClass>> timeFrameMap = new Map<Decimal, List<CustomerProfileSettingsController.ReasonWrapperClass>>();
    
    //Constructor
    global ContactCaseCountBatchUpdate(String o){
        //get Customer Profile Settings
        getCustomerProfileSettings();
        
        //Create the Query string
        String whereCon = ' WHERE Id = null';
        if(cPSettings != null){
            whereCon = cPSettings.Contacts_Filter_Criteria__c != null?' WHERE '+cPSettings.Contacts_Filter_Criteria__c:'';
        }
        Query= 'SELECT Id from Contact'+whereCon;
        Operation = o;
    }
    
    //Overloaded Constructor with Operation and CronTrigger Id
    global ContactCaseCountBatchUpdate(String o, Id scId){
        this(o);
        schConTriggerId = scId;
    }

    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug(Query);
        return Database.getQueryLocator(Query);
    }

    //Execute Method
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(cPSettings != null && (Operation!=null && Operation.equalsIgnoreCase('UPDATE'))){
            Map<Id, ContactBucketWrapper> contactBucketCountObj = new Map<Id, ContactBucketWrapper>();
            Set<Id> conIdSet = new Set<Id>();
            //Create the Contact Id Set
            for(sobject s : scope){
                conIdSet.add(s.Id); 
            }

            List<Contact> updContList = new List<Contact>();
            Map<Id, Decimal> caseTotalCountMap365 = new Map<Id, Decimal>();
            Map<Id, Decimal> caseTotalCountMap183 = new Map<Id, Decimal>();
            
            //Iterate over the Number of Days
            for(Decimal noOfDays: timeFrameMap.keySet()){
                Set<String> caseReasonSet = new Set<String>();
                Set<String> caseSubReasonSet = new Set<String>();
                String seperator = '@$#';
                List<CustomerProfileSettingsController.ReasonWrapperClass> rwcList = timeFrameMap.get(noOfDays);
                Map<String, Set<String>> caseReasonSettingsMap = new Map<String, Set<String>>();
                Map<String, String> caseReasonsCategoryMap = new Map<String, String>();
                for(CustomerProfileSettingsController.ReasonWrapperClass rWCTemp: rwcList){
                    //Populate Case Reason - SubReason Set map
                    if(caseReasonSettingsMap.containsKey(rWCTemp.caseReason)){
                        //if the map already contains the case-reason key, read the existing values and append the new ones
                        Set<String> tmpSubReasSet = caseReasonSettingsMap.get(rWCTemp.caseReason);
                        tmpSubReasSet.addAll(rWCTemp.selectedSubReasonSet);
                        caseReasonSettingsMap.put(rWCTemp.caseReason, tmpSubReasSet);
                    }else{
                        //if the map does not contain the case-reason key, create a new key-value
                        caseReasonSettingsMap.put(rWCTemp.caseReason, rWCTemp.selectedSubReasonSet);
                    }                   
                    
                    //Populate the Case Reason set
                    caseReasonSet.add(rWCTemp.caseReason);
                    
                    //Populate the Case Sub-Reason set
                    caseSubReasonSet.addAll(rWCTemp.selectedSubReasonSet);
                    
                    //Populate the map with Case Reason and Sub-Reason combo for the appropriate Bucket.  If the same case reason fall into different categories with different sub-reasons
                    for(String subReason: rWCTemp.selectedSubReasonSet){
                        caseReasonsCategoryMap.put(rWCTemp.caseReason+seperator+subReason, rWCTemp.categoryBucket);
                    }
                }
                
                //Where Condition from the Settings
                String whereConditonCase = (cPSettings.Case_Filter_Criteria__c!= null)?(' AND '+cPSettings.Case_Filter_Criteria__c):' ';
                //Case Query String
                String caseQuery = 'SELECT ContactId, Reason, Case_Sub_Reason__c FROM Case WHERE ContactId IN:conIdSet AND Reason IN: caseReasonSet AND Case_Sub_Reason__c IN: caseSubReasonSet AND createddate = LAST_N_DAYS:'+noOfDays+' '+whereConditonCase;
                //Query and loop through the results
                for(List<Case> caseList: Database.query(caseQuery)){
                    for(Case cas: caseList){
                        ContactBucketWrapper cBWTemp = new ContactBucketWrapper();
                        //if the Map already contains the Contact Id key, get it.  If not, create a new key value.
                        if(contactBucketCountObj.containsKey(cas.ContactId)){
                            cBWTemp = contactBucketCountObj.get(cas.ContactId);
                        }else{
                            cBWTemp.contactId = cas.ContactId;
                            cBWTemp.product = 0;
                            cBWTemp.billingAndFinance = 0;
                            cBWTemp.serviceAndSupport = 0;
                        }

                        if(caseReasonSettingsMap.containsKey(cas.Reason)){
                            Set<String> tempCaseSubReasonSet = caseReasonSettingsMap.get(cas.Reason);
                            if(tempCaseSubReasonSet.contains(cas.Case_Sub_Reason__c)){
                                //Get the appropriate category based on Case Reason and Sub Reason
                                String tempBucket = caseReasonsCategoryMap.get(cas.Reason+seperator+cas.Case_Sub_Reason__c);
                                
                                if(tempBucket == 'Product'){
                                    cBWTemp.product += 1;
                                }else if(tempBucket == 'Billing & Finance'){
                                    cBWTemp.billingAndFinance += 1;
                                }else if(tempBucket == 'Service & Support'){
                                    cBWTemp.serviceAndSupport += 1;
                                }
                                contactBucketCountObj.put(cas.ContactId,cBWTemp);
                            }
                        }
                    }
                }
                //To calculate the total number of cases
                
                String caseQuery1 = 'SELECT ContactId, Count(Id) FROM Case WHERE ContactId IN:conIdSet AND createddate = LAST_N_DAYS:'+noOfDays+' '+whereConditonCase;
                caseQuery1 += ' GROUP BY ContactId';
                //Query and loop through the results
                for(List<AggregateResult> agList: Database.query(caseQuery1)){
                    for(AggregateResult ag: agList){
                        String contactId = String.valueOf(ag.get('ContactId'));
                        String caseCount = String.valueOf(ag.get('expr0'));
                        if(noOfDays == 365){
                            caseTotalCountMap365.put(contactId, Decimal.valueOf(caseCount));
                        }else if(noOfDays == 183){
                            caseTotalCountMap183.put(contactId, Decimal.valueOf(caseCount));
                        }
                    }
                }
            }
            
            //Update the Bucket/Category values on the contact records
            for(sObject con:scope){
                ContactBucketWrapper cBW = contactBucketCountObj.get(con.Id);
                Contact c = new Contact();
                c.Id = cBW!=null?cBW.contactId:con.Id;
                c.Product__c = cBW!=null?cBW.product:0;
                c.Billing_Finance__c = cBW!=null?cBW.billingAndFinance:0;
                c.Service_Support__c = cBW!=null?cBW.serviceAndSupport:0;
                c.Case_Count_in_last_365_days__c = caseTotalCountMap365.containsKey(c.Id)?caseTotalCountMap365.get(c.Id):null;
                c.Case_Count_in_last_183_days__c = caseTotalCountMap183.containsKey(c.Id)?caseTotalCountMap183.get(c.Id):null;
                updContList.add(c);
            }
            //if the update list size is greater than zero, there are records to be updated.
            if(updContList.size()>0){
                Database.SaveResult[] srList = Database.update(updContList,false);
                sendErrorEmailNotifications(srList);
                System.debug('Update record count: '+updContList.size());
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        //if the next job is scheduled successfully
        String jobId = scheduleNextJob();
        if(jobId != null){
            List<CronTrigger> ctList = new List<CronTrigger>([SELECT TimesTriggered, NextFireTime, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId]);
            cPSettings.Next_Job_Schedule_Timestamp__c = ctList.size()>0?ctList[0].NextFireTime:null;
        }
        
        //Update Customer Profile Settings object
        cPSettings.Last_Job_Run_Timestamp__c = System.now();
        try{
            update cPSettings;
        }catch(Exception e){
            string body = 'Update operation failed with the following error: '+e;
            sendEmailMethod('ContactCaseCountBatchUpdate: Timestamp Update Operation Failed', body, ((cPSettings != null && cPSettings.Email_receipients__c != '') ? cPSettings.Email_receipients__c : Userinfo.getUserEmail()));
        }
        
        // Is the Notify Job Completion is checked?
        if(cPSettings.Notify_Job_Completion__c){
            //Send the Batch Job complete notification email
            string body = 'The batch job has been successfully completed <br/><br/> Query executed: '+query;
            sendEmailMethod('ContactCaseCountBatchUpdate: Completed', body, ((cPSettings != null && cPSettings.Email_receipients__c != '') ? cPSettings.Email_receipients__c : Userinfo.getUserEmail()));
        }
    }
    
    //Method to send the emails in case of errors
    private void sendErrorEmailNotifications(List<Database.SaveResult> srList){
        // Iterate through each returned result

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful
                System.debug('Successfully Updated');
            }
            else{
                String body;
                
                for(Database.Error err : sr.getErrors()) {
                    body+='The following error has occurred.  ';                   
                    body+=err.getStatusCode() + ': ' + err.getMessage();
                    body+='<br/><br/>Fields that affected this error: ' + err.getFields()+'<br\\>';
                }
                sendEmailMethod('ContactCaseCountBatchUpdate Error Notification', body, ((cPSettings != null && cPSettings.Email_receipients__c != '') ? cPSettings.Email_receipients__c : Userinfo.getUserEmail()));
                 
            }
        }
    }
    
    //Method to send the emails
    private void sendEmailMethod(String subject, String body, String toAddresses){
        Messaging.SingleEmailMessage sm = new Messaging.SingleEmailMessage();
        sm.setSubject(subject);
        string[] toAddrs = toAddresses.split(',');
        sm.setToAddresses(toAddrs);
        sm.setHtmlBody(body);
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sm});
        }
        catch(Exception e){
            system.debug(e);
        }
    }
    
    //Method to schedule the next job run
    private String scheduleNextJob(){
        //abortCurrentJob
        abortCurrentJob();
        
        ContactCaseCountBatchScheduler casConBat = new ContactCaseCountBatchScheduler();
        String sch = (cPSettings != null && cPSettings.Apex_Scheduler_Cron_Expression__c!='')?cPSettings.Apex_Scheduler_Cron_Expression__c:'';
        try{
            if(sch!=''){
                String jobId = system.schedule('ContactCaseCountBatchUpdate', sch, casConBat);
                return jobId;
            }
        }
        catch(Exception e){
            system.debug(e);
            string body = '\"ContactCaseCountBatchScheduler\" automated job scheduler failed with the following error: '+e;
            sendEmailMethod('ContactCaseCountBatchUpdate: Next Job Schedule Failed', body, ((cPSettings != null && cPSettings.Email_receipients__c != '') ? cPSettings.Email_receipients__c : Userinfo.getUserEmail()));
        }
        return null;
    }
    
    //Method to Abort the current scheduled job
    public void abortCurrentJob(){
        try{
            if(schConTriggerId!=null){
                system.abortJob(schConTriggerId);
            }else{
                List<CronTrigger> ctList = new List<CronTrigger>([SELECT Id, CronJobDetailId, TimesTriggered, NextFireTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'ContactCaseCountBatchUpdate' and NextFireTime>:system.now()]);
                for(CronTrigger ct: ctList){
                    system.abortJob(ct.Id);
                }
            }
        }catch(Exception e){
            string body = '\"ContactCaseCountBatchScheduler\" automated job scheduler failed with the following error: '+e;
            sendEmailMethod('ContactCaseCountBatchUpdate: Abort Job Operation Failed', body, ((cPSettings != null && cPSettings.Email_receipients__c != '') ? cPSettings.Email_receipients__c : Userinfo.getUserEmail()));
        
        }
        
    }
    
    //Method to get the selected customer profile settings
    private void getCustomerProfileSettings(){
		//Fetch the Customer Profile Settings  
        CustomerProfileSettingsController.CustomerProfileConfig cPC = new CustomerProfileSettingsController.CustomerProfileConfig();
        cPSettings = cPC.cPSettings;
        
        List<CustomerProfileSettingsController.ReasonWrapperClass> rWCListBatch = new List<CustomerProfileSettingsController.ReasonWrapperClass>();
        //Assign the Case-Reason Criteria from the Customer Profile Settings configuration to the Wrapper class object
        rWCListBatch = cPC.rWCList;
        //Populate the Map with Timeframe as the Key and the corresponding Case-Criteria as the value
        for(CustomerProfileSettingsController.ReasonWrapperClass rwcTemp: rWCListBatch){
            List<CustomerProfileSettingsController.ReasonWrapperClass> tempRWCList = new List<CustomerProfileSettingsController.ReasonWrapperClass>();
            if(timeFrameMap.containsKey(rwcTemp.timeFrame)){
                tempRWCList = timeFrameMap.get(rwcTemp.timeFrame);
            }
            tempRWCList.add(rwcTemp);
            timeFrameMap.put(rwcTemp.timeFrame, tempRWCList);
        } 
        
        system.debug(timeFrameMap.size());
        
    }
    
    //Wrapper Class
    private class ContactBucketWrapper{
        private Id contactId;
        private Decimal product;
        private Decimal billingAndFinance;
        private Decimal serviceAndSupport;
    }
}