/****************************************************************
Created: 21 Feb 2013
Author: Aaron Pettitt (CodeScience)
Purpose : Lead Trigger to update CCI on opportunity updates
Modifications:
9/4/12 - Krishna Tatta - Modifying the trigger to handle 
		 updating totals on the parent opportunity when a 
		 child opp's status is changed or when a child opp
		 is deleted
10/31/14 - Bobby Tamburrino
         - Added Before Update: If Sales Opportunity is set to
           IsClosed = true with Child Opportunities that are
           still open, don't allow record to be saved.
         - Added Before Update: Do not allow Child Opportunity
           to be set to Closed/Won if the Parent Opportunity
           is already Closed/Lost
         - Added After Update: If Pilot Opportunity is Closed
           and Lost, update Parent Opportunity with the StageName
           'Lost Opportunity'
******************************************************************/
trigger Opportunity on Opportunity (before update, after insert, after update, before delete) {

	// --------------------------------------------------------------------------------------------------
	// Create Welcome Call records for Sales Opportunities.
	// --------------------------------------------------------------------------------------------------

	if (Trigger.isUpdate && Trigger.isAfter) {
		
		Id salesOpportunityRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
		
		List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
		Set<Id> accountIds = new Set<Id>();

		for (Opportunity opportunity : Trigger.new) {
			if (opportunity.RecordTypeId == salesOpportunityRecordTypeId && opportunity.IsWon == true && opportunity.Type == 'New Business') {
				opportunitiesToProcess.add(opportunity);
				accountIds.add(opportunity.AccountId);
			 }
		}

		if (opportunitiesToProcess.size() > 0) {
			Map<Id, Account> accounts =
				new Map<Id, Account>([select Id, ParentId
				                      from Account
				                      where Id in :accountIds
				                      and Acct_Type__c = 'End Customer'
				                      and (Sub_Type__c = 'SMB' or Sub_Channel__c = 'PUBLIC SECTOR SMB')
				                      and Exclude_from_Welcome_Call__c = false
				                      and Completed_Account_Set_up__c >= :Date.today().addDays(-7)]);

			if (accounts.size() > 0) {
				Map<Id, Opportunity> opportunities =
					new Map<Id, Opportunity>([select Id, (select ContactId from OpportunityContactRoles where Role = 'Signatory')
					                          from Opportunity
					                          where Id in :opportunitiesToProcess]);
	
				Set<Id> parentAccountIds = new Set<Id>();
	
				for (Account account : accounts.values()) {
					if (account.ParentId != null) {
						parentAccountIds.add(account.ParentId);
					}
				}
				
				Set<Id> siblingAccountIds = new Set<Id>();
				Map<Id, Set<Id>> parentToChildAccountIds = new Map<Id, Set<Id>>();
				
				if (parentAccountIds.size() > 0) {
					for (Account account : [select Id, ParentId from Account where ParentId in :parentAccountIds]) {
						siblingAccountIds.add(account.Id);
	
						Set<Id> childAccountIds = parentToChildAccountIds.get(account.ParentId);
						if (childAccountIds == null) {
							childAccountIds = new Set<Id>();
							parentToChildAccountIds.put(account.ParentId, childAccountIds);
						}
						
						childAccountIds.add(account.Id);
					}
				}
	
				Set<Id> welcomeCallAccountIds = new Set<Id>();
				Set<Id> welcomeCallOpportunityIds = new Set<Id>();

				List<Welcome_Call__c> existingWelcomeCalls =
					[select Account_Name__c, Opportunity_Name__c
					 from Welcome_Call__c
					 where Account_Name__c in :accountIds or
					 Account_Name__c in :parentAccountIds or
					 Account_Name__c in :siblingAccountIds or
					 Opportunity_Name__c in :opportunitiesToProcess];
				
				for (Welcome_Call__c welcomeCall : existingWelcomeCalls) {
					welcomeCallAccountIds.add(welcomeCall.Account_Name__c);
					welcomeCallOpportunityIds.add(welcomeCall.Opportunity_Name__c);
				}
	
				Id welcomeCallQueueId = [select Id from Group where Type = 'Queue' and DeveloperName = 'Welcome_Call_Queue'].Id;
				
				List<Welcome_Call__c> welcomeCalls = new List<Welcome_Call__c>();
				
				for (Opportunity opportunity : opportunitiesToProcess) {
					// If a Welcome Call record doesn't exist yet, create one.
					Account account = accounts.get(opportunity.AccountId);
					if (account != null) {
						// Check that the Opportunity and it's Account don't have a welcome call.
						if (welcomeCallOpportunityIds.contains(opportunity.Id) || welcomeCallAccountIds.contains(opportunity.AccountId)) {
							continue;
						}
						
						// Check that the Opportunity's Account's parent or sibling Accounts don't have a welcome call.
						if (account.ParentId != null) {
							if (welcomeCallAccountIds.contains(account.ParentId)) {
								continue;
							}

							if (parentToChildAccountIds.containsKey(account.ParentId)) {
								Boolean welcomeCallFound = false;

								for (Id accountId : parentToChildAccountIds.get(account.ParentId)) {
									if (welcomeCallAccountIds.contains(accountId)) {
										welcomeCallFound = true;
										break;
									}
								}
								
								if (welcomeCallFound) {
									continue;
								}
							}
						}
						
					 	Welcome_Call__c welcomeCall = new Welcome_Call__c();
					 	welcomeCall.Account_Name__c = opportunity.AccountId;
					 	welcomeCall.Opportunity_Name__c = opportunity.Id;
					 	
					 	if (opportunities.get(opportunity.Id).OpportunityContactRoles.size() > 0) {
					 		welcomeCall.Contact_Name__c = opportunities.get(opportunity.Id).OpportunityContactRoles[0].ContactId;
					 	}
					 	
					 	welcomeCall.OwnerId = welcomeCallQueueId;
					 	welcomeCalls.add(welcomeCall);
					}
				}
				
				insert welcomeCalls;
			}
		}
		
	}



    Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
    Id pilotRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Pilot Opportunity');
  	List<Opportunity> childOpps = new List<Opportunity>();
    Set<Id> childOppIdsSet = new Set<Id>();

    if (Trigger.isUpdate && Trigger.isBefore) {

        List<Opportunity> oppsToCheck = new List<Opportunity>();
        List<Id> parentsToCheck = new List<Id>();

        for (Integer i = 0;i < Trigger.new.size();i++) {

            if ((Trigger.new[i].RecordTypeId != pilotRecordTypeId) && (Trigger.new[i].IsClosed != Trigger.old[i].IsClosed) && (Trigger.new[i].IsClosed == true)) {
                oppsToCheck.add(Trigger.new[i]);
            }

            if ((Trigger.new[i].RecordTypeId == csoRecordTypeId) && (Trigger.new[i].IsClosed != Trigger.old[i].IsClosed) && (Trigger.new[i].IsClosed == true) && (Trigger.new[i].IsWon == true)) {
                parentsToCheck.add(Trigger.new[i].Parent_Opportunity__c);
            }

        }

        // If a Sales Opportunity is Closed, make sure no Pilot Opportunities are open.

        if (oppsToCheck.size() > 0) {

            List<Opportunity> pilotOpps = new List<Opportunity>();

            try {
                pilotOpps = [SELECT Id, Name, StageName, Parent_Opportunity__c, IsClosed, IsWon FROM Opportunity WHERE IsClosed = FALSE AND RecordTypeId =: pilotRecordTypeId AND Parent_Opportunity__c IN :oppsToCheck];
            } catch (Exception e) {
                // Do nothing.
            }

            if (pilotOpps.size() > 0) {

                for (Opportunity pilotOpp : pilotOpps) {

                    for (Opportunity badOpp : Trigger.new) {
                        if (badOpp.Id == pilotOpp.Parent_Opportunity__c) {
                            badOpp.StageName.addError('Cannot close this Opportunity while Pilot Opportunity ' + pilotOpp.Name + ' is still open.');
                        }
                    }

                }

            }

        }

        // Don't allow Child Opportunity to be Closed Won if Parent Opportunity is Closed Lost

        if (parentsToCheck.size() > 0) {

            List<Opportunity> parentOpps = new List<Opportunity>();

            try {
                parentOpps = [SELECT Id, Name, StageName, IsClosed, IsWon FROM Opportunity WHERE IsClosed = TRUE AND IsWon = FALSE AND Id IN :parentsToCheck];
            } catch (Exception e) {
                // Do nothing.
            }

            if (parentOpps.size() > 0) {

                for (Opportunity parentOpp : parentOpps) {

                    for (Opportunity badOpp : Trigger.new) {
                        if (badOpp.Parent_Opportunity__c == parentOpp.Id) {
                            badOpp.StageName.addError('Cannot mark this Opportunity as Won when Parent Opportunity ' + parentOpp.Name + ' is Lost.');
                        }
                    }

                }
            }
        }

    }

    else if(Trigger.isInsert && Trigger.isAfter ) {
    	for(Opportunity tmpOpp :Trigger.new) {
    		childOpps.add(tmpOpp);
    	}
    }
    
    else if(Trigger.isUpdate && Trigger.isAfter ) {    	
    	integer j=0; 
    	   	
    	while(j<trigger.new.size()) {    		
    		 if((trigger.new[j].IsWon != trigger.old[j].IsWon) && (trigger.old[j].IsWon || trigger.new[j].IsWon)) {    				
    			childOpps.add(trigger.new[j]);
    		}    		
    		j++;
    	}  	
    }
   
    else if(Trigger.isDelete && Trigger.isBefore) {  	
    	for(Opportunity oldOpp :Trigger.old ) {    		
    		childOpps.add(oldOpp);    		
    	}    	
    }
    
    if(childOpps.size() > 0) {    
    	for(opportunity opp : childOpps) {    		
    		if(opp.Parent_Opportunity__c != null && opp.RecordTypeId == csoRecordTypeId ) {    			
    			childOppIdsSet.add(opp.Id);
    		}
    	}
    	if(childOppIdsSet.size() > 0 ) {    		
    		CalculateChildOppsUnitTotal.ProcessParentOpps(childOppIdsSet);
    	}	
    }
           
    
    if(Trigger.isInsert) {
    	
    	//After
    	if(Trigger.isAfter) {
    		
    		CopyParentOppsContactRoles.Execute(trigger.new);
    	}
    }
    if(Trigger.isUpdate || Trigger.isInsert) {
    
    	//After
    	if(Trigger.isAfter) {
	    	
            // If this is a Pilot Opportunity being Closed Lost, update Parent Opportunity's Stage to Lost Opportunity.

            if (Trigger.isUpdate) {

                List<Id> closedPilotParents = new List<Id>();

                for (Integer k = 0;k < Trigger.new.size();k++) {

                    if ((Trigger.new[k].RecordTypeId == pilotRecordTypeId) &&
                        (Trigger.new[k].IsClosed != Trigger.old[k].IsClosed) && (Trigger.new[k].IsClosed == true) &&
                        (Trigger.new[k].IsWon == false) && (Trigger.new[k].Parent_Opportunity__c != null)) {
                        closedPilotParents.add(Trigger.new[k].Parent_Opportunity__c);
                    }

                }

                if (closedPilotParents.size() > 0) {

                    List<Opportunity> opportunitiesToClose = new List<Opportunity>();

                    try {
                        opportunitiesToClose = [SELECT Id, Name, StageName, IsClosed FROM Opportunity WHERE Id IN :closedPilotParents];
                    } catch (Exception e) {
                        // Do nothing
                    }

                    if (opportunitiesToClose.size() > 0) {

                        for (Opportunity opp : opportunitiesToClose) {
                            opp.StageName = 'Lost Opportunity';
                            opp.Main_Lost_Reason__c = 'Pilot Unsuccessful';
                        }

                        update opportunitiesToClose;

                    }

                }

            }

		    List<Id> opportunitiesToUpdate = new List<Id>();
		    Integer i = 0;
		    
		    while(i < trigger.new.size()){
		        if(!CSUtils.isEmpty(trigger.new[i].Affiliate_Lead_ID__c)){
		            if(trigger.IsUpdate) {
			            if((trigger.new[i].StageName != trigger.old[i].StageName || trigger.new[i].OwnerId != trigger.old[i].OwnerId || trigger.old[i].Unit_Total_of_Child_Opps__c != trigger.new[i].Unit_Total_of_Child_Opps__c) && trigger.new[i].Parent_Opportunity__c == NULL){
			                opportunitiesToUpdate.add(trigger.new[i].Id);
			            }
		            }
		            else if(Trigger.IsInsert) {
		            	if(Trigger.new[i].Parent_Opportunity__c == NULL) {
		            		opportunitiesToUpdate.add(trigger.new[i].Id);
		            	}
		            }
		        }
		        ++i;
		    }
		    
		    //update PRM
		    if(opportunitiesToUpdate.size() > 0){
                PRMLeadUpdate.updateLeads(null, new Set<Id>(opportunitiesToUpdate), test.isRunningTest());
		    	/*system.debug('calling out to batch');
		        PRMLeadUpdateBatch b = new PRMLeadUpdateBatch(null, opportunitiesToUpdate, test.isRunningTest());
		        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 99){
				   system.debug('executing batch');
				   Database.executeBatch(b,20);
				} 
				else {
				   system.debug('scheduling to be executed again in 5 minutes');
				   //schedule this same schedulable class again in 30 mins
				   PRMLeadUpdateBatchSchedule sc = new PRMLeadUpdateBatchSchedule(null,opportunitiesToUpdate,test.isRunningTest());
				   Datetime dt = Datetime.now().addMinutes(5);
				   String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
				   Id schedId = System.Schedule('Update PRM Retry'+timeForScheduler + String.ValueOf(Math.random()),timeForScheduler,sc);
				}*/
		    }
	    }
    }

}