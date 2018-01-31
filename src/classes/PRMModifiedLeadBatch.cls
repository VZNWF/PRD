global class PRMModifiedLeadBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	private boolean isTestRunning = false;
	private PRMLead prmLead = new PRMLead();
	global DateTime timeStarted;
	global DateTime resetLastRunDate;
	
	public PRMModifiedLeadBatch() {
		this(false);
	}
	
	 public PRMModifiedLeadBatch(boolean isTest){
        isTestRunning = isTest;
        prmLead = new PRMLead(isTestRunning);
        timeStarted = DateTime.now();
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id from User Limit 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> theObject){
        getExistingLeads(BC);
    }
    
    global void finish(Database.BatchableContext BC){
        PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();        
        try {                 
            if(resetLastRunDate != null){
                system.debug('resetting last run date to: ' + resetLastRunDate);
                settings.Lead_Summary_Last_Updated__c = resetLastRunDate;
                update settings;
            }
            else {
            	system.debug('reset last run date value is null. timestamp is not being reset');
            }          
        }
        catch(Exception ex){
            CSUtils.sendErrorEmail(BC.getJobId(), ex, null);    
        }               
    }
    
    public void getExistingLeads(Database.BatchableContext BC) {
    	try {
    		PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
            List<Lead> invalidLeads = new List<Lead>(); 
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            system.debug('lead summary last updated date: ' + settings.Lead_Summary_Last_Updated__c);
            PRMLead.leadOppHistoryWrapper leadWrapper = prmLead.getLeadsByDateTime(settings.Lead_Summary_Last_Updated__c);
            integer totalLeadsRetrieved = 0;
            if(leadWrapper.leadsByAutoNumbers != null && leadWrapper.leadsByAutoNumbers.size() > 0) {               
                totalLeadsRetrieved += leadWrapper.existingLeads.size();
                system.debug('existing leads size in batch is: ' + leadWrapper.leadsByAutoNumbers.size());
                Set<String> manualNumbers = new Set<String>();
                //Handle the opportunities that were given manual NWFleadoppnumbers as well 
                //so that those get updated when there are any changes on the verizon side
                for(string num : leadWrapper.leadsByAutoNumbers.keyset()) {
                	system.debug('num is: ' + num);
                	if(num.startswith('M')) {
                		system.debug('adding m number: ' + num);
                		manualNumbers.add(num);
                	}
                }
                Map<Id,Opportunity> oppsWithManualNumbers = new Map<Id,Opportunity>([Select Id from Opportunity where NWF_Lead_Opp_Number__c in :manualNumbers]);
                system.debug('number of opps with manul numbers: ' + oppsWithManualNumbers.size());
                List<Lead> mappedLeads = [Select Id, Affiliate_Sales_Name__c,Affiliate_Sales_Name_2__c, IsConverted, ConvertedOpportunityId, Affiliate_Sales_Phone_2__c,Affiliate_Sales_Email_2__c, Affiliate_Sales_Email__c, Affiliate_Sales_Phone__c, Affiliate_Region__c, NWF_Lead_Opp_Number__c from Lead where NWF_Lead_Opp_Number__c in :leadWrapper.leadsByAutoNumbers.keyset() ];
                if((mappedLeads != null && mappedLeads.size() > 0) || (oppsWithManualNumbers != null && oppsWithManualNumbers.size() > 0)) {
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
                                system.debug('adding oppid: ' + l.ConvertedOpportunityId);
                            }
                        }
                    }
                    if(convertedOppIds.size() > 0 || oppsWithManualNumbers.size() > 0)  {
                    	List<Opportunity> mappedOpps = [Select Id,Affiliate_Sales_Name__c,Affiliate_Sales_Name_2__c,Affiliate_Sales_Phone_2__c,Affiliate_Sales_Email_2__c, Affiliate_Sales_Email__c, Affiliate_Sales_Phone__c, Affiliate_Region__c, NWF_Lead_Opp_Number__c from Opportunity where Id in: convertedOppIds  or Id in :oppsWithManualNumbers.keyset()];
                        for(Opportunity opp: mappedOpps) {
                            if(opp.NWF_Lead_Opp_Number__c != null) {
                                mappedOppsByAutoNumbers.put(opp.NWF_Lead_Opp_Number__c, opp);
                                system.debug('adding the opp with number to the map: ' + opp.NWF_Lead_Opp_Number__c);
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
            }
            system.debug('leads to update: ' + leadsToUpdate.size());
            if(leadsToUpdate.size() > 0) {
                system.debug('updating leads');
                update leadsToUpdate;
            }
            system.debug('opps to update: ' + oppsToUpdate.size());
            if(oppsToUpdate.size() > 0) {
                system.debug('updating opps');
                update oppsToUpdate;
            }
            if(leadWrapper.histories.size() > 0) {
                upsert leadWrapper.histories;
            }
            if(settings.Num_of_Modified_Leads_To_Import__c != null) {
                if(totalLeadsRetrieved == Integer.ValueOf(settings.Num_of_Modified_Leads_To_Import__c)) {
                    system.debug('wrappers time stamp is:' + leadWrapper.LatestLeadsTimeStamp);
                    resetLastRunDate = leadWrapper.LatestLeadsTimeStamp;
                    system.debug('resetting last run date to max timestamp: ' + resetLastRunDate);
                }
                else {
                    resetLastRunDate = timeStarted;
                    system.debug('resetting last run date to  time started: ' + timeStarted);
                }
            }
    	}
    	catch(Exception e) {
    		CSUtils.sendErrorEmail(BC.getJobId(), e, null); 
    	}
    }
	
}