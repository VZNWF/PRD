/****************************************************************
Created: 1 Jan 2014
Author: Krishna Tatta (CodeScience)
Purpose : Batch class to get new and updated PRM Leads
Modifications:
******************************************************************/
global class PRMLeadBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful { 

    private boolean isTestRunning = false;
    private PRMLead prmLead = new PRMLead();
    global DateTime timeStarted;
    global List<Id> newLeadsInserted = new List<Id>();
    //global boolean resetLastRunDate;
     
    //constructors
    public PRMLeadBatch(){ 
        this(false);
    }

    public PRMLeadBatch(boolean isTest){
        isTestRunning = isTest;
        prmLead = new PRMLead(isTestRunning);
        timeStarted = DateTime.now();
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id from User Limit 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> theObject){
        List<Lead> insertedLeads = importLeads(BC);
        system.debug('inserted leads size in first batch execute: ' + insertedLeads.size());
        if(insertedLeads != null) {
            system.debug('inserted leads is not null in execute of first batch');
            for(Lead l : insertedLeads) {
                system.debug('leads Id in execute of first batch: ' + l.Id);
                newLeadsInserted.add(l.Id);
            }
        }
        system.debug('new leads size at the end of execute of first batch: ' + newLeadsInserted.size());
    }
    
    global void finish(Database.BatchableContext BC){
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
        system.debug('size of newleadsinserted in finish of first batch: ' + newLeadsInserted.size());
        try {
            if(newLeadsInserted.size() > 0) {
                //Update Assignments Batch
                LeadAssignmentBatch lab = new LeadAssignmentBatch(newLeadsInserted);
                if(Test.isRunningTest()) {
                    Database.executeBatch(lab,1);
                }
                else {
                    Database.executeBatch(lab);
                }

                system.debug('next batch job is being daisy chained');
                //daisy chain to a new batch job for updating the leads
                Integer sleepMinutes = (Integer)settings.Test_Delay__c;

                PRMLeadUpdateBatch b = new PRMLeadUpdateBatch(newLeadsInserted,null,isTestRunning);
                
                if(settings.Test_Delay__c == null || settings.Test_Delay__c == 0){

                    Database.executeBatch(b,10);
                
                } else {

                    system.scheduleBatch( b, 'PRMLeadUpdateBatch Delay', sleepMinutes);
                
                }
            }       
            /*if(resetLastRunDate == true){
                system.debug('resetting last run date');
                settings.Lead_Summary_Last_Updated__c = timeStarted;
                update settings;
            }  */         
        }
        catch(Exception ex){
            CSUtils.sendErrorEmail(BC.getJobId(), ex, null);    
        }               
    }
    
    public List<Lead> importLeads(Database.BatchableContext BC){
        List<Lead> insertedLeads = new List<Lead>();
        try {
            PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
            List<Lead> invalidLeads = new List<Lead>(); 
            List<Lead> leadsToInsert = new List<Lead>();
            //List<Lead> leadsToUpdate = new List<Lead>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            // fetch new leads since last run
            //****************************uncomment this line and coment the next one to revert it back to get leads by date time*******************************/
            //PRMLead.leadOppHistoryWrapper leadWrapper = prmLead.getLeadsByDateTime(settings.Lead_Summary_Last_Updated__c);
            PRMLead.leadOppHistoryWrapper leadWrapper = prmLead.getLeadsByIDs();
            integer totalLeadsRetrieved = 0;
            system.debug('new leads size in batch is: ' + leadWrapper.newLeads.size());
            if(leadWrapper.newLeads != null && leadWrapper.newLeads.size() > 0) {
                totalLeadsRetrieved += leadWrapper.newLeads.size();
                Integer i = 0;              
                while(i < leadWrapper.newLeads.size()){ 
                    if(!isLeadValid(leadWrapper.newLeads[i])) {
                        system.debug('lead is invalid');
                        invalidLeads.add(leadWrapper.newLeads[i]);
                        leadWrapper.newLeads.remove(i);
                    }
                    else {
                        system.debug('lead is valid');
                        leadsToInsert.add(leadWrapper.newLeads[i]);
                        ++i;
                    }
                }
            }
            /*if(leadWrapper.leadsByAutoNumbers != null && leadWrapper.leadsByAutoNumbers.size() > 0) {               
                totalLeadsRetrieved += leadWrapper.existingLeads.size();
                system.debug('existing leads size in batch is: ' + leadWrapper.leadsByAutoNumbers.size());
                List<Lead> mappedLeads = [Select Id, Affiliate_Sales_Name__c,Affiliate_Sales_Name_2__c, IsConverted, ConvertedOpportunityId, Affiliate_Sales_Phone_2__c,Affiliate_Sales_Email_2__c, Affiliate_Sales_Email__c, Affiliate_Sales_Phone__c, Affiliate_Region__c, NWF_Lead_Opp_Number__c from Lead where NWF_Lead_Opp_Number__c in :leadWrapper.leadsByAutoNumbers.keyset() ];
                if(mappedLeads != null && mappedLeads.size() > 0) {
                    Map<String,Lead> mappedLeadsByAutoNumbers = new Map<String,Lead>();
                    Map<String, Opportunity> mappedOppsByAutoNumbers = new Map<String,Opportunity>();
                    Set<Id> convertedOppIds = new Set<Id>();
                    for(Lead l : mappedLeads) {
                        if(l.NWF_Lead_Opp_Number__c != null) {
                            if(l.IsConverted == false) {
                                mappedLeadsByAutoNumbers.put(l.NWF_Lead_Opp_Number__c, l);
                            }
                            else {
                                convertedOppIds.add(l.ConvertedOpportunityId);
                            }
                        }
                    }
                    if(convertedOppIds.size() > 0) {
                    List<Opportunity> mappedOpps = [Select Id,Affiliate_Sales_Name__c,Affiliate_Sales_Name_2__c,Affiliate_Sales_Phone_2__c,Affiliate_Sales_Email_2__c, Affiliate_Sales_Email__c, Affiliate_Sales_Phone__c, Affiliate_Region__c, NWF_Lead_Opp_Number__c from Opportunity where Id in: convertedOppIds];
                        for(Opportunity opp: mappedOpps) {
                            if(opp.NWF_Lead_Opp_Number__c != null) {
                                mappedOppsByAutoNumbers.put(opp.NWF_Lead_Opp_Number__c, opp);
                            }
                        }
                    }
                    for(String autoNumber : leadWrapper.leadsByAutoNumbers.keyset()) {
                        Lead existingLead;
                        Opportunity existingOpp;
                        if(mappedLeadsByAutoNumbers.containsKey(autoNumber)) {
                            existingLead = mappedLeadsByAutoNumbers.get(autoNumber);
                        }
                        else if(mappedOppsByAutoNumbers.containsKey(autoNumber)) {
                            existingOpp = mappedOppsByAutoNumbers.get(autoNumber);
                        }
                        Lead recievedLead = leadWrapper.leadsByAutoNumbers.get(autoNumber);
                        if(existingLead != null && recievedLead != null) {
                            Lead updatedLead = new Lead();
                            boolean isChangeValid = false;
                            if(existingLead.Affiliate_Region__c != recievedLead.Affiliate_Region__c) {
                                updatedLead.Affiliate_Region__c = recievedLead.Affiliate_Region__c;
                                isChangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Name__c != recievedLead.Affiliate_Sales_Name__c) {
                                updatedLead.Affiliate_Sales_Name__c = recievedLead.Affiliate_Sales_Name__c;
                                isChangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Name_2__c != recievedLead.Affiliate_Sales_Name_2__c) {
                                updatedLead.Affiliate_Sales_Name_2__c = recievedLead.Affiliate_Sales_Name_2__c;
                                ischangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Email__c != recievedLead.Affiliate_Sales_Email__c) {
                                updatedLead.Affiliate_Sales_Email__c = recievedLead.Affiliate_Sales_Email__c;
                                isChangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Email_2__c != recievedLead.Affiliate_Sales_Email_2__c) {
                                updatedLead.Affiliate_Sales_Email_2__c = recievedLead.Affiliate_Sales_Email_2__c;
                                isChangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Phone__c != recievedLead.Affiliate_Sales_Phone__c) {
                                updatedLead.Affiliate_Sales_Phone__c = recievedLead.Affiliate_Sales_Phone__c;
                                isChangeValid = true;
                            }
                            if(existingLead.Affiliate_Sales_Phone_2__c != recievedLead.Affiliate_Sales_Phone_2__c) {
                                updatedLead.Affiliate_Sales_Phone_2__c = recievedLead.Affiliate_Sales_Phone_2__c;
                                isChangeValid = true;
                            }
                            if(isChangeValid == true) {
                                system.debug('lead will be updated');
                                updatedLead.Id = existingLead.Id;
                                leadsToUpdate.add(updatedLead);
                            }
                        }
                        else if(existingOpp != null && recievedLead != null) {
                            Opportunity updatedOpp = new Opportunity();
                            boolean isChangeValid = false;
                            if(existingOpp.Affiliate_Region__c != recievedLead.Affiliate_Region__c) {
                                updatedOpp.Affiliate_Region__c = recievedLead.Affiliate_Region__c;
                                isChangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Name__c != recievedLead.Affiliate_Sales_Name__c) {
                                updatedOpp.Affiliate_Sales_Name__c = recievedLead.Affiliate_Sales_Name__c;
                                isChangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Name_2__c != recievedLead.Affiliate_Sales_Name_2__c) {
                                updatedOpp.Affiliate_Sales_Name_2__c = recievedLead.Affiliate_Sales_Name_2__c;
                                ischangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Email__c != recievedLead.Affiliate_Sales_Email__c) {
                                updatedOpp.Affiliate_Sales_Email__c = recievedLead.Affiliate_Sales_Email__c;
                                isChangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Email_2__c != recievedLead.Affiliate_Sales_Email_2__c) {
                                updatedOpp.Affiliate_Sales_Email_2__c = recievedLead.Affiliate_Sales_Email_2__c;
                                isChangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Phone__c != recievedLead.Affiliate_Sales_Phone__c) {
                                updatedOpp.Affiliate_Sales_Phone__c = recievedLead.Affiliate_Sales_Phone__c;
                                isChangeValid = true;
                            }
                            if(existingOpp.Affiliate_Sales_Phone_2__c != recievedLead.Affiliate_Sales_Phone_2__c) {
                                updatedOpp.Affiliate_Sales_Phone_2__c = recievedLead.Affiliate_Sales_Phone_2__c;
                                isChangeValid = true;
                            }
                            if(isChangeValid == true) {
                                system.debug('opp will be updated');
                                updatedOpp.Id = existingOpp.Id;
                                oppsToUpdate.add(updatedOpp);
                            }
                        }
                    }
                }
            } */
            if(leadsToInsert.size() > 0) {
                system.debug('leads being inserted: ' + leadsToInsert.size());
                for(Lead l : leadsToInsert) {
                    system.debug('partnerid' + l.Partner_ID__c);
                    system.debug('state' + l.State);
                    system.debug('country' + l.country);
                    system.debug('name' + l.FirstName + l.LastName);
                }
                Database.Dmloptions options=new Database.Dmloptions();
                options.optAllOrNone=true;
                Database.Saveresult[] insertResults=Database.insert(leadsToInsert, options);
                
                integer counter=0;
                integer errorsCount=0;
                String message = '';
                for(Database.Saveresult r:insertResults)
                {
                    message = 'The following leads creation failed: ';
                    message += '<table border="1">';
                    message += '<tr>';
                    message += '<th>PRM Lead Id</th>';
                    message += '<th>Name</th>';
                    message += '<th>Email</th>';
                    message += '<th>Error</th>';
                    message += '</tr>';
                    if(!r.isSuccess() || Test.isRunningTest())
                    {
                        ++errorsCount;
                        Database.Error[] errors=r.getErrors();
                        string errStr='';
                        for(Database.Error e: errors)
                        {
                            errStr+=e.getMessage()+' :: ';
                        }
                    
                        message += '<tr>';
                        message += '<td>' + leadsToInsert[counter].Partner_ID__c + '</td>';
                        message += '<td>' + leadsToInsert[counter].FirstName + ' ' + leadsToInsert[counter].LastName + '</td>';
                        message += '<td>' + leadsToInsert[counter].Email + '</td>';
                        message += '<td>' + errStr + '</td>';
                        message += '</tr>';
                    }
                    message += '</table>';
                    ++counter;
                }
                if(errorsCount>0)
                    CSUtils.sendErrorEmail(BC.getJobId(), null, message);
            
                insertedLeads.addall(leadsToInsert);
            }
            
            
            
            /*system.debug('leads to update size is: ' + leadsToUpdate.size());
            if(leadsToUpdate.size() > 0) {
                system.debug('updating leads');
                update leadsToUpdate;
            }
            if(oppsToUpdate.size() > 0) {
                system.debug('updating opps');
                update oppsToUpdate;
            }*/
            if(leadWrapper.histories.size() > 0) {
                upsert leadWrapper.histories;
            }
            system.debug('total leads retrieved: ' + totalLeadsRetrieved);
            /*if(settings.Num_Of_Leads_To_Import__c != null) {
                if(totalLeadsRetrieved == Integer.ValueOf(settings.Num_Of_Leads_To_Import__c)) {
                    resetLastRunDate = false;
                    system.debug('setting last run date flag to false');
                }
                else {
                    resetLastRunDate = true;
                    system.debug('setting last run date flag to true');
                }
            }*/
            if(invalidLeads.size() > 0 || Test.isRunningTest()){
                String message = 'The following leads did not get imported: ';
                message += '<table border="1">';
                message += '<tr>';
                message += '<th>PRM Lead Id</th>';
                message += '<th>Name</th>';
                message += '<th>Email</th>';
                message += '</tr>';
                for(Lead lead : invalidLeads){
                    message += '<tr>';
                    message += '<td>' + lead.Partner_ID__c + '</td>';
                    message += '<td>' + lead.FirstName + ' ' + lead.LastName + '</td>';
                    message += '<td>' + lead.Email + '</td>';
                    message += '</tr>';
                }
                message += '</table>';
                CSUtils.sendErrorEmail(BC.getJobId(), null, message);
            }
        }
        catch(Exception ex){
            CSUtils.sendErrorEmail(BC.getJobId(), ex, null);    
        }
        return insertedLeads;
    }
    
    public boolean IsLeadValid(Lead lead) {
        if(lead != null) {  
            if(!Pattern.matches('[a-zA-Z0-9\\.\\!\\#\\$\\%\\&\\*\\/\\=\\?\\^\\_\\+\\-\\`\\{\\|\\}\\~\'._%+-]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}[.]?[0-9a-zA-Z]{0,6}$', lead.email)) {
            
                return false;
            }
            else{
                return true;
            }
        }
        return false;
    }
}