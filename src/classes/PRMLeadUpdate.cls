global with sharing class PRMLeadUpdate {

	private static PRMLead prmLead;
	
	public PRMLeadUpdate() {
		
	}

	//method to update Opportunity Description after lead conversion

	public static void updateOppDescription(map<id,Lead> newleadmap,map<id,lead> oldleadmap){
		map<id,Lead> mapOppIdByLead=new map<id,Lead>();
		list<Opportunity> lstOpptoUpdate=new list<Opportunity>();
		for(Lead l:newleadmap.values()){
			if(l.isConverted && !oldleadmap.get(l.id).isConverted){
				if(l.ConvertedOpportunityId!=null){
					mapOppIdByLead.put(l.ConvertedOpportunityId,l);
				}
			}
		}

		//Update Opportunity

		for(Opportunity opp:[Select Description,Id from Opportunity where ID IN:mapOppIdByLead.keyset()]){
			if(mapOppIdByLead.get(opp.Id).Description!=null){
				opp.Description=mapOppIdByLead.get(opp.Id).Description;
				lstOpptoUpdate.add(opp);
			}	
		}

		if(lstOpptoUpdate.size()>0){
			update lstOpptoUpdate;
		}

	}



	@future(callout=true)
	public static void updateLeads(Set<Id> insertedLeadIds, Set<Id> updatedOppIds, Boolean isTest) {
		prmLead = new PRMLead(isTest);

		Boolean isTestRunning = isTest;
		List<Lead> leads;
		if(insertedLeadIds != null && insertedLeadIds.size() > 0) {
			leads = [Select Id, Affiliate_Lead_ID__c,Partner_ID__c,Status_Last_Change__c, NWF_Lead_Opp_Number__c, Status, Main_Unqualified_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone, Total_Number_of_Vehicles__c from Lead where Id in : insertedLeadIds];
		}
		List<Opportunity> opps;
		if(updatedOppIds != null && updatedOppIds.size() > 0) {
			opps = [Select Id, Unit_Total__c,Stage_Last_Change__c,Affiliate_Lead_ID__c,Partner_ID__c, NWF_Lead_Opp_Number__c, CloseDate, StageName,Unit_Total_All_Opps__c, Number_of_units__c,Main_Lost_Reason__c, Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone from Opportunity where Id IN : updatedOppIds];
		}

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
									historiesToUpsert.addAll(wrapper.histories);
									if(wrapper.histories[0].Status__c != 'Partial Success' && wrapper.histories[0].Status__c != 'Error') {
										PRMLead.leadOppHistoryWrapper shareLeadsWrapper = prmLead.shareLeads(subLeads, null);
										if(shareLeadsWrapper != null && shareLeadsWrapper.histories != null && shareLeadsWrapper.histories.size() > 0) {
											historiesToUpsert.addAll(shareLeadsWrapper.histories);
										}
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
									historiesToUpsert.addAll(wrapper.histories);
									if(wrapper.histories[0].Status__c != 'Partial Success' && wrapper.histories[0].Status__c != 'Error') {
										PRMLead.leadOppHistoryWrapper shareOppsWrapper = prmLead.shareLeads(null, subOpps);
										if(shareOppsWrapper != null && shareOppsWrapper.histories != null && shareOppsWrapper.histories.size() > 0) {
											historiesToUpsert.addAll(shareOppsWrapper.histories);
										}
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