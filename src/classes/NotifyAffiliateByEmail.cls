public with sharing class NotifyAffiliateByEmail {

	public static void sendEmail(List<Task> theTasks){
	//loop through the submitted list to make extended task objects
	//use the size of toEmail array to determine capacity required (could be 0, 1, or 2)
		List<ExtendedTask> extendedTaskList = new List<ExtendedTask>();
		Integer capacityCounter = 0;
		for(Task aBaseTask : theTasks){
			ExtendedTask extendedTask = new ExtendedTask(aBaseTask);			
			extendedTaskList.add(extendedTask);
			capacityCounter += extendedTask.toEmail.size();
		}

		System.debug('$$$ capacityCounter is ' + capacityCounter);
		if(capacityCounter > 0){
			Messaging.reserveSingleEmailCapacity(capacityCounter);
		}

		for(ExtendedTask anExtendedTask : extendedTaskList){
			if (anExtendedTask.isLeadOrOpp == true && anExtendedTask.toEmail.size() > 0){
			//anExtendedTask.hasRecipients == true){
				NotifyAffiliateByEmail.sendTaskEmail(anExtendedTask);
			}
		}
	}

	public static void sendTaskEmail(ExtendedTask theTaskToSend){
		VerizonLogoUrl__c mc = VerizonLogoUrl__c.getValues('Verizon');
		String imgURL = mc.URL__c;

		//allows for 2 emails per task if Affiliate_Sales_Email_2__c is filled in
		for (Integer i = 0; i < theTaskToSend.toEmail.size(); i++){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('Activity Notification to VZ Sales');
			String dateString;
			if(theTaskToSend.baseTask.ActivityDate == null){
				dateString = '';
			}
			else {
				dateString = theTaskToSend.baseTask.ActivityDate.format();	
			}	
			String nextStepString = '';	
			if(theTaskToSend.nextStep != null){
				nextStepString = '<br/>Next Step: ' + theTaskToSend.nextStep;
			}	
			String comments = theTaskToSend.baseTask.Description != null ? theTaskToSend.baseTask.Description : '';
			String phone = theTaskToSend.ownerPhone != null ? '<br/>'+theTaskToSend.ownerPhone : '';
			String htmlMessage = '<img src="'+ imgURL + '" /><br/>'  
			+ '<table height="400" width="550" cellpadding="5" border="0" cellspacing="5" ><tr height="400" valign="top" ><td style=" color:#000000; font-size:12pt; background-color:#FFFFFF; font-family:arial;">'
			+ '<p>Dear ' + theTaskToSend.toName[i] 
			+ ',</p><p>The following activity has been completed for ' + theTaskToSend.companyName 
			+ ':<br/><br/>Subject: ' + theTaskToSend.baseTask.Subject 
			+ '<br/>Lead ID: ' + theTaskToSend.leadId 
			+ '<br/>Type: ' + theTaskToSend.baseTask.Type 
			+ '<br/>Date: ' + dateString 
			+ nextStepString 
	 		+ '<br/>Comments:' + comments
			+ '<p>Please let me know if you have any questions.</p>'
			+ '<p>Thank you!</p>'
			+ '<p>' + theTaskToSend.ownerName 
			+ phone
			+ '<br/>' + 	theTaskToSend.ownerEmail 
			+ '</p></tr></table><hr color="red" >';

			System.debug('$$$ htmlMessage is ' + htmlMessage);

			mail.setHtmlBody(htmlMessage);
			mail.setToAddresses(new String[] {theTaskToSend.toEmail[i]});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
		}		
		
	}

//inner wrapper class to allow for opportunity and lead to be represented by one object
	public class ExtendedTask {
		public Task baseTask {get; set;}
		public String[] toEmail {get; set;}
		public String[] toName {get; set;}
		public String companyName {get; set;}
		public String leadId {get; set;}
		public String ownerName {get; set;}
		public String ownerPhone {get; set;}
		public String ownerEmail {get; set;}
		public Boolean isLeadOrOpp {get; set;}
		public String nextStep {get; set;}

		public ExtendedTask(Task task){
			this.baseTask = task;
			this.toName = new String[]{};
			this.toEmail = new String[]{};
			if(task.WhatId != null){
				//query for opportunity with this id
				List<Opportunity> oppList = [SELECT Affiliate_Sales_Name__c, Affiliate_Sales_Name_2__c, Affiliate_Sales_Email__c, Affiliate_Sales_Email_2__c, AccountId, Affiliate_Lead_ID__c, OwnerId
												FROM Opportunity
												WHERE Id = :task.whatId]; //or task.Id if change input
				if (oppList.size() > 0){
					//set values for companyName, leadId, ownerName, ownerPhone, ownerEmail
					Opportunity opportunity = oppList[0];

					//do not allow blanks or nulls in toEmail, because its size is used to reserveSingleEmailCapacity
					if(!String.isBlank(opportunity.Affiliate_Sales_Email__c)){
						this.toEmail.add(opportunity.Affiliate_Sales_Email__c);
					}
					//allows for blank name
					this.toName.add( !String.isBlank(opportunity.Affiliate_Sales_Name__c) ? opportunity.Affiliate_Sales_Name__c : '');
					if (!String.isBlank(opportunity.Affiliate_Sales_Email_2__c)){
						this.toEmail.add(opportunity.Affiliate_Sales_Email_2__c);
						// allows for blank name
						this.toName.add( !String.isBlank(opportunity.Affiliate_Sales_Name_2__c) ? opportunity.Affiliate_Sales_Name_2__c : '');
					}
					this.leadId = !String.isBlank(opportunity.Affiliate_Lead_ID__c) ? opportunity.Affiliate_Lead_ID__c : '';

					List<Account> accountList = [SELECT Name, Id
													FROM Account
													WHERE Id = :opportunity.accountId];
					if (accountList.size() > 0){
						this.companyName = accountList[0].Name;

					}
					List<User> userList = [SELECT Id, FirstName, LastName,  Phone, Email
											FROM User
											WHERE Id =:opportunity.OwnerId];
					if (userList.size() > 0){	
						User ownerUser = userList[0];					
						this.ownerName = ownerUser.FirstName + ' ' + ownerUser.LastName;
						this.ownerPhone = ownerUser.Phone;
						this.ownerEmail = ownerUser.Email;
					}

					isLeadOrOpp = true;
				}
				//if none, do nothing
			}
			//look at who id if what id was null
			else if(task.WhoId != null){
				//query Lead for this task's whoId
				List<Lead> leadList = [SELECT Affiliate_Sales_Name__c, Affiliate_Sales_Name_2__c,Affiliate_Sales_Email__c, Affiliate_Sales_Email_2__c, Company, Affiliate_Lead_ID__c, OwnerId, Next_Step__c
										FROM Lead
										WHERE Id = :task.WhoId];
				if (leadList.size() > 0){
					Lead lead = leadList[0];
					//set values for toname, toemail, companyName, leadId, 
					//do not allow blanks or nulls in toEmail, because its size is used to reserveSingleEmailCapacity
					if(!String.isBlank(lead.Affiliate_Sales_Email__c)){
						this.toEmail.add(lead.Affiliate_Sales_Email__c);

					}
					//allows for blank name
					this.toName.add(!String.isBlank(lead.Affiliate_Sales_Name__c) ? lead.Affiliate_Sales_Name__c : '');


					if (!String.isBlank(lead.Affiliate_Sales_Email_2__c)){
						this.toEmail.add(lead.Affiliate_Sales_Email_2__c);
						//allows for blank name
						this.toName.add( !String.isBlank(lead.Affiliate_Sales_Name_2__c) ? lead.Affiliate_Sales_Name_2__c : '');
					}
					this.companyName = lead.Company;
					this.leadId = !String.isBlank(lead.Affiliate_Lead_ID__c) ? lead.Affiliate_Lead_ID__c : '';

					List<User> userList = [SELECT Id, FirstName, LastName, Phone, Email
											FROM User
											WHERE Id =:lead.OwnerId];
					if (userList.size() > 0){	
						//set ownerName, ownerPhone, ownerEmail
						User ownerUser = userList[0];					
						this.ownerName = ownerUser.FirstName + ' ' + ownerUser.LastName;
						this.ownerPhone = ownerUser.Phone;
						this.ownerEmail = ownerUser.Email;
					}
					this.nextStep = lead.Next_Step__c;
				isLeadOrOpp = true;

				} 
				//if none, do nothing 
			
			}//end else if
			else {
				//no lead or opportunity connected to this task
				isLeadOrOpp = false;

			}//end else
		}//end constructor
	}// end inner class
}//end class