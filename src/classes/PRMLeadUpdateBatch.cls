/****************************************************************************
Created: 15 Jan 2014
Author: Krishna Tatta (CodeScience)
Purpose : Batch class to update PRM with partner IDs of newly inserted Leads
Modifications:
*****************************************************************************/
global class PRMLeadUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	private boolean isTestRunning = false;
	private PRMLead prmLead;
	global DateTime timeStarted;
	global List<Id> insertedLeadIds = new List<Id>();
	global List<Id> updatedOppIds = new List<Id>();
	private Integer attempt;
	
	//constructors
	public PRMLeadUpdateBatch(List<Id> leadIds, List<Id> oppIds){ 
		this(leadIds, oppIds, false, 1);
	}


	public PRMLeadUpdateBatch(List<Id> leadIds, List<Id> oppIds, boolean isTest){
		/*isTestRunning = isTest;
		prmLead = new PRMLead(isTestRunning);
		if(leadIds != null) {
			insertedLeadIds.addAll(leadIds);
		}
		if(oppIds != null) {
			updatedOppIds.addAll(oppIds);
		}*/
		this(leadIds, oppIds, isTest, 1);
	}

	public PRMLeadUpdateBatch(List<Id> leadIds, List<Id> oppIds, boolean isTest, Integer attempt){
		isTestRunning = isTest;
		this.attempt = attempt;
		prmLead = new PRMLead(isTestRunning);
		if(leadIds != null) {
			insertedLeadIds.addAll(leadIds);
		}
		if(oppIds != null) {
			updatedOppIds.addAll(oppIds);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'Select Id from User Limit 10';
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Lead> leads;
		if(insertedLeadIds != null && insertedLeadIds.size() > 0) {
			leads = [Select Id, Status_Last_Change__c,Affiliate_Lead_ID__c,Partner_ID__c, NWF_Lead_Opp_Number__c, Status, Main_Unqualified_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone, Total_Number_of_Vehicles__c from Lead where Id in : insertedLeadIds];
		}
		List<Opportunity> opps;
		if(updatedOppIds != null && updatedOppIds.size() > 0) {
			opps = [Select Id, Stage_Last_Change__c,Unit_Total__c, Affiliate_Lead_ID__c,Partner_ID__c, NWF_Lead_Opp_Number__c, CloseDate, StageName,Unit_Total_All_Opps__c, Number_of_units__c,Main_Lost_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone from Opportunity where Id IN : updatedOppIds];
		}
		
		updateLeads(leads, opps);
	}
	
	global void finish(Database.BatchableContext BC){
		for(CronTrigger cron : [SELECT Id FROM CronTrigger WHERE State = 'DELETED' and CronJobDetail.Name LIKE 'Update PRM Retry%']){
			system.abortJob(cron.Id);
		}
	}
	
	global void updateLeads(List<Lead> leads, List<Opportunity> opps) {
		PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
		if(settings.Number_of_Leads_To_Update__c != null) {
			Integer maxLeadsToUpdate = Integer.ValueOf(settings.Number_of_Leads_To_Update__c);
			if(maxLeadsToUpdate != null && maxLeadsToUpdate > 0) {
				List<PRM_API_History__c> historiesToUpsert = new List<PRM_API_History__c>();
				if(leads != null) {
					List<List<Lead>> chunkedLeads = new List<List<Lead>>();
					system.debug('leads received in update call in batch: ' + leads.size());
					for(integer i=0; i< leads.size();) {
						List<Lead> subLeads = new List<Lead>();
						integer maxNumber;
						if((i + maxLeadsToUpdate) > leads.size()) {
							maxNumber = leads.size();
						}
						else {
							maxNumber = i + maxLeadsToUpdate;
						}						
						for(integer j=i; j< maxNumber; j++ ) {
							subLeads.add(leads[j]);
						}
						chunkedLeads.add(subLeads);
						i = i+ maxLeadsToUpdate;
					}
					system.debug('size of chunked leads list is: ' + chunkedLeads.size());
					if(chunkedLeads.size() > 0) {
						for(List<Lead> subLeads : chunkedLeads) {
							if(subLeads != null && subLeads.size() > 0) {
								PRMLead.leadOppHistoryWrapper wrapper = prmLead.UpdateLeads(subLeads, null);
								if(wrapper != null && wrapper.histories != null && wrapper.histories.size() > 0) {
									if(wrapper.histories[0].Status__c != 'Partial Success' && wrapper.histories[0].Status__c != 'Error') {
										PRMLead.leadOppHistoryWrapper shareLeadsWrapper = prmLead.shareLeads(subLeads, null);
										if(shareLeadsWrapper != null && shareLeadsWrapper.histories != null && shareLeadsWrapper.histories.size() > 0) {
											for(PRM_API_History__c hist: shareLeadswrapper.histories) {
												PRM_API_History__c newHist = hist.clone();
												historiesToUpsert.add(newHist);
											}
										}
									}
									for(PRM_API_History__c hist: wrapper.histories) {
										PRM_API_History__c newHist = hist.clone();
										newHist.Operation__c = 'Update Leads';
										historiesToUpsert.add(newHist);
									}
								//Something went wrong with the connection, reschedule the batch to run later.
								} else if(wrapper == null){
   									//Email admin?
   									Integer sleepMinutes = (PRM_API_Settings__c.getOrgDefaults().Retry_Delay_Minutes__c != null ? (Integer)PRM_API_Settings__c.getOrgDefaults().Retry_Delay_Minutes__c : 10);
   									Integer maxRetries = (PRM_API_Settings__c.getOrgDefaults().Max_Retries__c != null ? (Integer)PRM_API_Settings__c.getOrgDefaults().Max_Retries__c : 1);

   									if(attempt < maxRetries) {
   										PRMLeadUpdateBatch lub = new PRMLeadUpdateBatch(insertedLeadIds, updatedOppIds, false, attempt + 1);
   										system.scheduleBatch(lub, 'PRMLeadUpdateBatch Retry' + attempt, sleepMinutes);
   									}
								}
							}
						}
					}					
				}
				if(opps != null) {
					List<List<Opportunity>> chunkedOpps = new List<List<Opportunity>>();
					system.debug('opportunities received in update call in batch: ' + opps.size());
					for(integer i=0; i< opps.size(); ) {
						List<Opportunity> subOpps = new List<Opportunity>();
						integer maxNumber;
						if((i + maxLeadsToUpdate) > opps.size()) {
							maxNumber = opps.size();
						}
						else {
							maxNumber = i + maxLeadsToUpdate;
						}						
						for(integer j=i; j< maxNumber; j++ ) {
							subOpps.add(opps[j]);
						}
						chunkedOpps.add(subOpps);
						i=i+maxLeadsToUpdate;
					}
					system.debug('list of chunked opps size is: ' + chunkedOpps.size());
					if(chunkedOpps.size() > 0) {
						for(List<Opportunity> subOpps : chunkedOpps) {
							if(subOpps != null && subOpps.size() > 0) {
								PRMLead.leadOppHistoryWrapper wrapper = prmLead.UpdateLeads(null, subOpps);
								if(wrapper != null && wrapper.histories != null && wrapper.histories.size() > 0) {
									if(wrapper.histories[0].Status__c != 'Partial Success' && wrapper.histories[0].Status__c != 'Error') {
										PRMLead.leadOppHistoryWrapper shareOppsWrapper = prmLead.shareLeads(null, subOpps);
										if(shareOppsWrapper != null && shareOppsWrapper.histories != null && shareOppsWrapper.histories.size() > 0) {
											for(PRM_API_History__c hist: shareOppswrapper.histories) {
												PRM_API_History__c newHist = hist.clone();
												historiesToUpsert.add(newHist);
											}
										}
									}									
									for(PRM_API_History__c hist: wrapper.histories) {
										PRM_API_History__c newHist = hist.clone();
										newHist.Operation__c = 'Update Leads';
										historiesToUpsert.add(newHist);
									}
								}
							}
						}
					}	
				}
				if(historiesToUpsert.size() > 0) {
					upsert historiesToUpsert;
				}
				/*PRMLead.leadOppHistoryWrapper wrapper = prmLead.UpdateLeads(leads,opps);
				if(wrapper != null && wrapper.histories != null && wrapper.histories.size() > 0) {
					upsert wrapper.histories;
				}*/
			}
		}		
	}
}