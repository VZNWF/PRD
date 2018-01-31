public with sharing class PRMLead {
    private PRMAPI api = new PRMAPI();
    private PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
    //private PRM_API_History__c history = new PRM_API_History__c();
    
    public PRMLead(){
        this(false);
    }
    
    public PRMLead(boolean isTest){
        if(isTest){
            PRMMockServiceImpl mocksvc = new PRMMockServiceImpl();    
            api = new PRMAPI(mocksvc);
        }
    }
    
    public boolean IsSandBox {
    	get {
    		return URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
    	}
    } 
        
    private Map<String, Lead> leadsByAutoNumbers = new Map<String,Lead>();
    private List<Lead> newLeads = new List<Lead>();
    private List<Lead> existingLeads = new List<Lead>();
    DateTime LatestModifiedLeadTime;
    
    public LeadOppHistoryWrapper getLeadsByIds() {
        PRM_API_History__c history = new PRM_API_History__c();
    	leadOppHistoryWrapper wrapper = new leadOppHistoryWrapper();
    	history.Operation__c = 'Retrieve Leads';
    	String message = '';
    	
    	Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.useDefaultRule = true;
		dmlOpts.EmailHeader.triggerUserEmail = true;
		dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
        
        string UserName, password;
        if(IsSandbox) {
        	UserName = settings.Sandbox_Username__c;
        	password = settings.Sandbox_Password__c;
        }
        else {
        	UserName = settings.ITWUsername__c;
        	password = settings.ITWPassword__c;
        }
        
    	message = PRMServiceImpl.createFullToGetLeadsByID(UserName, password, Integer.ValueOf(settings.Num_Of_Leads_To_Import__c));
        
    	history.Request_Data__c = message;
    	system.debug('Message built in prm lead before calling execute: ' + message);
    	HttpResponse htResponse  = api.execute(message,'SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/LeadIDReqResp');
    	string response = htResponse.getBody();
    	system.debug('response recieved in prm lead is: ' + response);
    	if(response.length() > 131000){
        	history.Response_Data__c = response.substring(0, 131000);
        	history.Response_Data__c += '\r\n\r\n' + 'response truncated due to length...';
        }
        else{
        	history.Response_Data__c = response;
        }
    	system.debug('before replacing: ' + response);
    	response = response.replace('&amp;', 'amp;').replace('\r\n','newlinefeed');
    	system.debug('after replacing: ' + response);
    	
    	XmlStreamReader res = new XmlStreamReader(response);
         	
    	while(res.HasNext()) {
    		if(res.getEventType() == XmlTag.START_ELEMENT) {
    			if(res.getLocalName() == 'LeadInfo') {
    				//res.next();
    				//system.debug('is reader end element' + (res.getEventType() == XmlTag.END_ELEMENT));
    				Lead parsedLead = parseLead(res);
    			}
    		}
    		//used for the history record
            else if(res.getLocalName() == 'ProcessKey'){
            	res.next();
             	if(res.getEventType() != XmlTag.END_ELEMENT){
                	history.Name = res.getText();
                    history.Status__c = 'Success';
                } 
                else {
                	history.Status__c = 'Error';
                }
            }
            else if(res.getLocalName() == 'ReplyErrorCode' && res.getEventType() == XmlTag.START_ELEMENT){
            	res.next();
                if(res.getEventType() != XmlTag.END_ELEMENT){
                	history.Error_Code__c = truncatecharacters(res.getText());
                }
           	}
    		res.next();
    		//system.debug('next element at the end of the loop is: ' + res.getLocalName());
    	} 
    	
    	List<PRM_API_History__c> histories = new List<PRM_API_History__c>();
        histories.add(history);
        wrapper.histories = histories;
        //set DML options so that assignment rules are executed
        if(newLeads != null) {
        	for(Lead l: newLeads) {
        		if(dmlOpts != null) {
        			l.setOptions(dmlOpts);
        		}
        	}
        }
        wrapper.newLeads = newLeads;
       // wrapper.existingLeads = existingLeads;
       // wrapper.leadsByAutoNumbers = leadsByAutoNumbers; 
        return wrapper;
    }
    
    public LeadOppHistoryWrapper getLeadsByDateTime(DateTime lastRunDate) {
    	PRM_API_History__c history = new PRM_API_History__c();
    	leadOppHistoryWrapper wrapper = new leadOppHistoryWrapper();
    	history.Operation__c = 'Retrieve existing Leads';
    	String message = '';
    	
    	Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.useDefaultRule = true;
		dmlOpts.EmailHeader.triggerUserEmail = true;
		dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
        
        string UserName, password;
        if(IsSandbox) {
        	UserName = settings.Sandbox_Username__c;
        	password = settings.Sandbox_Password__c;
        }
        else {
        	UserName = settings.ITWUsername__c;
        	password = settings.ITWPassword__c;
        }
        
        message = PRMServiceImpl.createFullXMLToGetLeadsByDate(UserName, password,lastRunDate, Integer.ValueOf(settings.Num_of_Modified_Leads_To_Import__c));
        
    	history.Request_Data__c = message;
    	system.debug('Message built in prm lead before calling execute: ' + message);
    	HttpResponse htResponse  = api.execute(message,'SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/LeadDateReqResp');
    	string response = htResponse.getBody();
    	system.debug('response recieved in prm lead is: ' + response);
    	if(response.length() > 131000){
        	history.Response_Data__c = response.substring(0, 131000);
        	history.Response_Data__c += '\r\n\r\n' + 'response truncated due to length...';
        }
        else{
        	history.Response_Data__c = response;
        }
    	system.debug('before replacing: ' + response);
    	response = response.replace('&amp;', 'amp;').replace('\r\n','newlinefeed');
    	system.debug('after replacing: ' + response);
    	
    	XmlStreamReader res = new XmlStreamReader(response);
         	
    	while(res.HasNext()) {
    		if(res.getEventType() == XmlTag.START_ELEMENT) {
    			if(res.getLocalName() == 'LeadInfo') {
    				//res.next();
    				//system.debug('is reader end element' + (res.getEventType() == XmlTag.END_ELEMENT));
    				Lead parsedLead = parseLead(res);
    			}
    		}
    		//used for the history record
            else if(res.getLocalName() == 'ProcessKey'){
            	res.next();
             	if(res.getEventType() != XmlTag.END_ELEMENT){
                	history.Name = res.getText();
                    history.Status__c = 'Success';
                } 
                else {
                	history.Status__c = 'Error';
                }
            }
            else if(res.getLocalName() == 'ReplyErrorCode' && res.getEventType() == XmlTag.START_ELEMENT){
            	res.next();
                if(res.getEventType() != XmlTag.END_ELEMENT){
                	history.Error_Code__c = truncatecharacters(res.getText());
                }
           	}
    		res.next();
    		//system.debug('next element at the end of the loop is: ' + res.getLocalName());
    	} 
    	
    	List<PRM_API_History__c> histories = new List<PRM_API_History__c>();
        histories.add(history);
        wrapper.histories = histories;
        //set DML options so that assignment rules are executed
        if(newLeads != null) {
        	for(Lead l: newLeads) {
        		if(dmlOpts != null) {
        			l.setOptions(dmlOpts);
        		}
        	}
        }
        //wrapper.newLeads = newLeads;
        wrapper.existingLeads = existingLeads;
        wrapper.leadsByAutoNumbers = leadsByAutoNumbers; 
        wrapper.LatestLeadsTimeStamp = LatestModifiedLeadTime;
        system.debug('end of get leads call setting wrappers timestamp to: ' + LatestModifiedLeadTime);
        return wrapper;
    }
    
    public LeadOppHistoryWrapper shareLeads(List<Lead> leads, List<Opportunity> opps) {
        PRM_API_History__c history = new PRM_API_History__c();
    	LeadOppHistoryWrapper wrapper = new LeadOppHistoryWrapper();
    	history.Operation__c = 'Share Leads';
    	String message = '';
        
        string UserName, password;
        if(IsSandbox) {
        	UserName = settings.Sandbox_Username__c;
        	password = settings.Sandbox_Password__c;
        }
        else {
        	UserName = settings.ITWUsername__c;
        	password = settings.ITWPassword__c;
        }
        
        message = PRMServiceImpl.createFullXMLToShareLeads(leads, opps, UserName, password);
        history.Request_Data__c = message;
    	system.debug('Message built in prm lead before calling sharing: ' + message);
    	HttpResponse htResponse  = api.execute(message,'SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/ShareLeadReqResp');
    	string response = htResponse.getBody();
    	system.debug('response received in prm lead after sharing is: ' + response);
    	if(response.length() > 131000){
        	history.Response_Data__c = response.substring(0, 131000);
        	history.Response_Data__c += '\r\n\r\n' + 'response truncated due to length...';
        }
        else{
        	history.Response_Data__c = response;
        }
    	
    	XmlStreamReader res = new XmlStreamReader(response);
    	while(res.HasNext()) {
    		if(res.getEventType() == XmlTag.START_ELEMENT) {
	    		if(res.getLocalName() == 'ShareLeadResp'){
	            	history = parseUpdateResponse(res, history);
	          	}
	            else if(res.getLocalName() == 'fault'){
	            	history = parseUpdateError(res, history);
	            }
    		}
    		res.next();
    	}
    	List<PRM_API_History__c> histories = new List<PRM_API_History__c>();
        histories.add(history);
        wrapper.histories = histories;
        return wrapper;
    }
    
    public LeadOppHistoryWrapper UpdateLeads(List<Lead> leads, List<Opportunity> opps) {
        PRM_API_History__c history = new PRM_API_History__c();
    	//leadOppHistoryWrapper wrapper = new leadOppHistoryWrapper();
        leadOppHistoryWrapper wrapper;
    	history.Operation__c = 'Update Leads';
    	String message = '';
        
        string UserName, password;
        if(IsSandbox) {
        	UserName = settings.Sandbox_Username__c;
        	password = settings.Sandbox_Password__c;
        }
        else {
        	UserName = settings.ITWUsername__c;
        	password = settings.ITWPassword__c;
        }
        
        message = PRMServiceImpl.createFullXMLToUpdateLeads(leads, opps, UserName, password);
        
        history.Request_Data__c = message;
    	system.debug('Message built in prm lead before calling updating: ' + message);
    	HttpResponse htResponse  = api.execute(message,'SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/UpdateLeadsReqResp');
        //Check for success
        if(htResponse != null){
            wrapper = new leadOppHistoryWrapper();
        	string response = htResponse.getBody();
        	system.debug('response recieved in prm lead after updating is: ' + response);
        	if(response.length() > 131000){
            	history.Response_Data__c = response.substring(0, 131000);
            	history.Response_Data__c += '\r\n\r\n' + 'response truncated due to length...';
            }
            else{
            	history.Response_Data__c = response;
            }
        	
        	XmlStreamReader res = new XmlStreamReader(response);
        	
        	while(res.HasNext()) {
        		if(res.getEventType() == XmlTag.START_ELEMENT) {
    	    		if(res.getLocalName() == 'UpdateLeadsResponse'){
    	            	history = parseUpdateResponse(res, history);
    	          	}
    	            else if(res.getLocalName() == 'fault'){
    	            	history = parseUpdateError(res, history);
    	            }
        		}
        		res.next();
        	}
    	    List<PRM_API_History__c> histories = new List<PRM_API_History__c>();
            histories.add(history);
            wrapper.histories = histories;
        }
        return wrapper;
    }
    
    public PRM_API_History__c parseUpdateResponse(XMLStreamReader res, PRM_API_History__c history) {
    	String failureMessage = '';
    	while(res.hasNext()) {
    		if (res.getEventType() == XmlTag.END_ELEMENT && (res.getLocalName() == 'UpdateLeadsResponse' || res.getLocalName() == 'ShareLeadResp')) {
                break;
            } 
    		else if(res.getLocalName() == 'Resp' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			string errorMsg = parseSFUpdateResponse(res);
    			if(!String.IsBlank(errorMsg)) {
    				failureMessage += '\n ' + errorMsg;
    			}
    		}
    		else if(res.getLocalName() == 'ErrorCode' && res.getEventType() == XmlTag.START_ELEMENT){
            	res.next();
                if(res.getEventType() != XmlTag.END_ELEMENT){
                	if(!String.IsBlank(res.getText())) {
                		history.Error_Code__c = truncatecharacters(res.getText());
                	}                	
                	system.debug('error code in update call is: ' + res.getText());
                }
           	}
           	else if(res.getLocalName() == 'ErrorStatus' && res.getEventType() == XmlTag.START_ELEMENT){
            	res.next();
                if(res.getEventType() != XmlTag.END_ELEMENT){
                	if(!String.ISBlank(res.getText())) {
                		history.Status__c = res.getText();
                	}
                	system.debug('error status in update call is: ' + res.getText());
                }
           	}
    		res.next();
    	}
    	if(!String.IsBlank(failureMessage)) {
    		failureMessage = 'Errors while updating a few records. ' + failureMessage;
    		history.Error_Message__c = failureMessage;
    		history.Status__c = 'Partial Success';
    	}
    	return history;
    }
    
    //parses the xml lead update error response
    public PRM_API_History__c parseUpdateError(XMLStreamReader res, PRM_API_History__c history){
        history.Status__c = 'Error';
        while(res.hasNext()) {
            if (res.getEventType() == XmlTag.END_ELEMENT && res.getLocalName() == 'Fault') {
                break;
            }
            else if(res.getLocalName() == 'faultstring' && res.getEventType() == XmlTag.START_ELEMENT){
                res.next();
                if(res.getEventType() != XmlTag.END_ELEMENT){
                    history.Error_Code__c = truncatecharacters(res.getText());
                }
            }
            res.next(); 
        }
        return history;
    }
    
    public String parseSFUpdateResponse(XmlStreamReader res) {
    	system.debug('inside parsesfupdateresponse');
    	String message;
    	String Id;
    	boolean IsSuccess = false;
    	while(res.hasNext()) {
    		if(res.getEventType() == XmlTag.END_ELEMENT && res.getLocalName() == 'Resp') {
    			break;
    		}
    		else if(res.getLocalName() == 'Success' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			if(res.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(res.getText())){
    				if(res.getText() == 'true') {
    					system.debug('setting is success to true');
    					IsSuccess = true;
    					break;
    				}
    			}
    		}
    		else if(res.getLocalName() == 'Id' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			if(res.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(res.getText())){
    				Id = res.getText();
    			}
    		}
    		else if(res.getLocalName() == 'Error' && res.getEventType() == XmlTag.START_ELEMENT) {
    			system.debug('inside error element');
    			res.next();
    			message = parseRecordUpdateError(res);
    		}    		
    		res.next();
    	}
    	if(IsSuccess == false) {
    		system.debug('is success is false');
    		return 'Update to the record with Id ' + Id + ' failed. Error Details: ' + message;
    	}
    	else {
    		system.debug('identified as success');
    		return null;
    	}
    }
    
    public String parseRecordUpdateError(XmlStreamReader res) {
    	system.debug('inside parseRecordUpdateError');
    	string message='';
    	while(res.hasNext()) {
    		if(res.getEventType() == XmlTag.END_ELEMENT && res.getLocalName() == 'Error') {
    			break;
    		}
    		else if(res.getLocalName() == 'Fields' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			if(res.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(res.getText())){
    				message += 'Error Fields - ' + res.getText();
    			}
    		}
    		else if(res.getLocalName() == 'StatusCode' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			if(res.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(res.getText())) {
    				message += ' Status Code - ' + res.getText();
    			}
    		}
    		else if(res.getLocalName() == 'Message' && res.getEventType() == XmlTag.START_ELEMENT) {
    			res.next();
    			if(res.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(res.getText())) {
    				message += ' Message - ' + res.getText();
    			}
    		}
    		res.next();
    	}
    	system.debug('return value from parse record update error: ' + message);
    	return message;
    }
       
    public Lead parseLead(XMLStreamReader reader){
        Lead lead = new Lead();
        lead.Description = '';
        lead.LeadSource = 'Verizon';
        lead.Specific_Lead_Source__c = 'Verizon';
        string partnerID;
        string referringRepName='';
	    string secondReferringRepName=''; 
	    string permissionToContact = '';
	    string permissionGrantedBy = '';
	    string expectedCloseDate='';
	    string description = '';
	    string comments =''; 
        string callReferrerFirst = '';
	    DateTime LatestLeadsTimeStamp;     
        while(reader.hasNext()) {        	
            if (reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'LeadInfo') {
                lead.Description += 'Call Referrer First? ' + callReferrerFirst + '\r\n';
                lead.Description += 'Permission to Contact Lead? ' + permissionToContact + '\r\n';
		        lead.Description += 'Permission Granted By? ' + permissionGrantedBy + '\r\n';
		        lead.Description += 'Expected Close Date: ' + expectedCloseDate + '\r\n';
		        lead.Description += 'Additional Information: ' + '\r\n';
		        lead.Description += description + '\r\n';
		        lead.Description += comments;
                if(!string.isblank(lead.Partner_ID__c)) {
                	if(!string.IsBlank(partnerID)) {
			        	system.debug('adding to existing leads');
			        	existingLeads.add(lead);
			    		leadsByAutoNumbers.put(partnerID, lead);
			        }
			        else {
			        	lead.Status = 'New';
			        	system.debug('adding to new leads');
			        	system.debug('leads status is: ' + lead.Status);
			        	newLeads.add(lead);
			        }
                }
                system.debug('Latest leads time stamp at the end of lead parsing is:' + LatestLeadstimeStamp );
                if(LatestLeadsTimeStamp != null) {
                	LatestModifiedLeadTime = LatestLeadsTimeStamp;
                	system.debug('last modified is:' + LatestModifiedLeadTime);
                }
                return lead;
            } 
            else if(reader.getLocalName() == 'Call_Referrer_First' && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(reader.getText())) {
                    callReferrerFirst = reader.getText();
                }
             }
            else if(reader.getLocalName() == 'Status' && reader.getEventType() == XmlTag.START_ELEMENT){
             	reader.next();
             	if(reader.getEventType() != XmlTag.END_ELEMENT && !String.IsBlank(reader.getText())) {
             		lead.Status = reader.getText();
             	}
             }
            else if(reader.getLocalName() == 'Company' && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){                    
                    if(reader.getText() != null && reader.getText().contains('amp;')) {
                    	lead.Company = reader.getText().replace('amp;','&');
                    }
                    else {
                    	lead.Company = reader.getText();
                    }
                    //system.debug('company name: ' + lead.Company);
                }
            }
            else if (reader.getLocalName() == 'First_Name'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.FirstName = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Last_Name'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.LastName = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Email'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Email = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Phone'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Phone = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Street'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                   lead.Street = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'City'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.City = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'State'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    if(reader.getText() != null) {
                    	lead.State = reader.getText();
                    }                  
                }
            }
            else if (reader.getLocalName() == 'PostalCode'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              lead.PostalCode = reader.getText();
                }
            }          
            else if (reader.getLocalName() == 'Country'  && reader.getEventType() == XmlTag.START_ELEMENT && reader.getEventType() != XmlTag.END_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                   lead.Country = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Website'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              if(reader.getText() != null && reader.getText().contains('amp;')) {
  	              	lead.Website = reader.getText().replace('amp;','&');
  	              }
  	              else {
  	              	lead.Website = reader.getText();
  	              }
                }
            }  
            else if (reader.getLocalName() == 'Lead_Source'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                        lead.Lead_Source_Detail__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Permission_to_Contact'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    permissionToContact  = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Permission_Granted_By'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    permissionGrantedBy = reader.getText();
                    system.debug('permission granted by: ' + permissionGrantedBy);
                }
            }
            else if (reader.getLocalName() == 'M2M_Expected_Close_Date'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT ){
                    expectedCloseDate = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Description'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT && reader.getText() != null){
                    description = reader.getText().replace('amp;','&');
                   // system.debug('description inside: ' + description);
                }
            }
            else if (reader.getLocalName() == 'Comments'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT && reader.getText() != null){
                    comments = reader.getText().replace('amp;','&').replace('newlinefeed', ' ');
                   // system.debug('comments retrieved: ' + comments);
                }
            }
            else if (reader.getLocalName() == 'SFDC_Lead_ID'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Affiliate_Lead_ID__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'SFDC_Lead_Long_ID'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Partner_ID__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'M2M_Connection_Est'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Total_Number_Of_Vehicles__c = Decimal.ValueOf(reader.getText());
                }
            }
            else if (reader.getLocalName() == 'Title'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                    lead.Title = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Industry'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              lead.Industry = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Lead_Region'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              lead.Affiliate_Region__c = reader.getText();
                }
            }  
            else if (reader.getLocalName() == 'Lead_Area'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              lead.Affiliate_Area__c = reader.getText();
                }
            } 
            else if (reader.getLocalName() == 'Rep1_First_Name'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
	                 if(!String.IsBlank(reader.getText())) {
	  	              	referringRepName += reader.getText();
	  	             }  	              
                }
            }
            else if(reader.getLocalName() == 'Rep1_Last_Name'  && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	referringRepName += ' ' + reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Rep1_Email'  && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	lead.Affiliate_Sales_Email__c = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Rep1_Phone'  && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	lead.Affiliate_Sales_Phone__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Rep2_First_Name'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	              secondReferringRepName += reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Rep2_Last_Name'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	secondReferringRepName += ' ' + reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Rep2_Email'  && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	lead.Affiliate_Sales_Email_2__c = reader.getText();
                }
            }
            else if(reader.getLocalName() == 'Rep2_Phone'  && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT){
  	            	lead.Affiliate_Sales_Phone_2__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Lead_Direction'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  lead.Lead_Direction__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'LocationCode'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  lead.Location_Code__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Channel'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  lead.Channel__c = reader.getText();
                }
            }
            else if (reader.getLocalName() == 'Fleet_Feature'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  lead.VZ_Lead_Fleet_Feature__c = reader.getText();
                }
            }
              else if (reader.getLocalName() == 'D_U_N_S'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  lead.CompanyDunsNumber = reader.getText();
                }
            }

            else if(reader.getLocalName() == 'LastUpdatedDateTime' && reader.getEventType() == XmlTag.START_ELEMENT) {
            	reader.next();
            	if(reader.getEventType() != XmlTag.END_ELEMENT) {
            		string str = '"' + reader.getText() + '"' ;
            		system.debug('str is: ' + str);
            		DateTime lastModifiedTS = DateTime.ValueOf(json.deserialize(str ,datetime.class));
            		system.debug('last modified ts: ' + lastModifiedTS);
            		system.debug('latest leads time stamp:' + LatestLeadsTimeStamp);
            		if(LatestLeadsTimeStamp == null || lastModifiedTS > LatestLeadsTimeStamp ) {
            			LatestLeadsTimeStamp = lastModifiedTS;
            			system.debug('looks like its greater');
            		}
            	}
            }
            if (reader.getLocalName() == 'Partner_Lead_ID'  && reader.getEventType() == XmlTag.START_ELEMENT){
                reader.next();
                if(reader.getEventType() != XmlTag.END_ELEMENT){
                  // system.debug('partner id value: ' + reader.getText());
                   partnerID = reader.getText();
                }
            }  
            if(!string.isBlank(referringRepName)) {
	            lead.Affiliate_Sales_Name__c = referringRepName;
	      	}
	        if(!string.isblank(secondReferringRepName)) {
	        	lead.Affiliate_Sales_Name_2__c = secondReferringRepName;
	      	}
	      	                     
            reader.next();
            //system.debug('***lead ' + lead);
        }    

       // system.debug('leads description is: ' + lead.Description);
        if(!string.IsBlank(partnerID)) {
        	system.debug('adding to existing leads');
        	existingLeads.add(lead);
    		leadsByAutoNumbers.put(partnerID, lead);
        }
        else {
        	lead.Status = 'New';
        	system.debug('adding to new leads');
        	newLeads.add(lead);
        }
        system.debug('***lead ' + lead);
        return lead;
    }
    
    private String GetTransactionId() {
        return 'NWF'+system.now().format('YYYY-MM-DDhh:mm:ss:SS');
    } 
    
    //converts the Saleforce Lead Status to valid CCI Lead Status
    public static String convertLeadStatus(string status){
        if(status == 'New' || status == 'Won Maintenance'){
            return Status;
        }
        else if(status == 'Contacted Affiliate') {
        	return 'Referrer Contacted';
        }
        else if(status == 'Contacted Lead' || status == 'Nurture' || status == 'Pre-Qualified'){
            return 'Customer Contacted';
        }
        else if(status == 'Unqualified'){
            return 'Unqualified';
        }
        //For Legacy statuses
        else if(status == 'Initial Meeting / Demo' || status == 'Proposal Sent' || status == 'Pilot' || status == 'Verbal Commitment'){
            return 'Qualified';
        }
        else if(status == 'Qualified' || status == 'Qualified Opportunity' || status == 'Solution Presentation' || status == 'In Negotiations' || status == 'Contract Pending' || status == 'Promo Code Pending'){
        	return 'Qualified';
        }
        else if(status == 'Non-Responsive'){
            return 'Unqualified';
        }
        //else if(status =='Opportunity Won / Order Placed'){
        else if(status =='Closed Won' || status =='Opportunity Won / Order Placed'){
        	return 'Closed - Won (Maint)';
        }
        //else if(status == 'Lost Opportunity'){
        else if(status == 'Closed Lost' || status == 'Lost Opportunity'){
            return 'Closed - Lost';
        }
        else if(status == 'Closed Duplicate'){
            return 'Unqualified';
        }
        return null;
    }
    
    public static String getInvalidReason(string status, string reason) {
    	if(status == 'Non-Responsive') {
    		return 'Customer Unresponsive';
    	}
    	else if(status == 'Closed Duplicate' ) {
    		return 'Duplicate Lead';
    	}
    	else if(status == 'Unqualified') {
    		if(reason == 'Existing Customer') {
    			return 'Existing Customer';
    		}
    		else if(reason == 'Feature Function') {
    			return 'Feature Function';
    		}
    		else if(reason == 'No interest from the start') {
    			return 'Customer Not Interested';
    		}
    	}
    	else if(status == 'Closed Lost') {
    		if(reason == 'Feature Function') {
    			return 'Feature Function';
    		}
    		else if(reason == 'Pilot Unsuccessful') {
    			return 'Pilot Unsuccessful';
    		}
    	}
    	return null;
    }
    
    public static boolean IsLeadValid(Lead lead) {
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

    private static string truncatecharacters(String str){
        string substr='';
        if(str!=null){
            if(str.length()>254){
             subStr = str.subString(0,254);
            }else{
               subStr =str; 
            }
        }
        return substr;
    }
     
    public class leadOppHistoryWrapper{
    	public List<Lead> NewLeads = new List<Lead>();
    	public List<Lead> existingLeads = new List<Lead>();
    	public Map<String,Lead> leadsByAutoNumbers = new Map<String,Lead>();
    	public List<PRM_API_History__c> histories = new List<PRM_API_History__c>();
    	public DateTime LatestLeadsTimeStamp;
    }    
}