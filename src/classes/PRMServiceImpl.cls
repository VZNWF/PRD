/****************************************************************
Created: 26 Dec 2013
Author: Krishna Tatta (CodeScience)
Purpose : PRM API communications
Modifications:
******************************************************************/
public with sharing class PRMServiceImpl implements PRMAPIService {
	public static HttpResponse execute(String message, String soapAction) {
		PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
		
		Integer attempt = 1;
        Boolean success = false;
        Boolean IsSandbox = URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
		HttpResponse response;
		
		string username, password, endpoint;
		if(IsSandbox) {
        	endpoint = settings.Sandbox_URL__c;
            username = settings.Sandbox_Username__c;
            password = settings.Sandbox_Password__c;
        }
        else {
        	endpoint = settings.URL__c;
        	username = settings.ITWUsername__c;
        	password = settings.ITWPassword__c;
      	}    
		
		while(success==false && attempt<=1) {
            try {
            	Http h = new Http();
     			String request = makeRequest(message, soapAction);
     			system.debug('request is: ' + request);
     			if (request.indexOf('\n')!=-1) System.debug('request contains backslash n');
        		if (request.indexOf('\r')!=-1) System.debug('request contains backslash r');
        		
        		HttpRequest req = buildHttpRequest(request,username,password,endpoint,soapAction);
        		response = h.send(req);
	            system.debug('response '+response);
	            system.debug('res-------'+response.getBody());
            }
            catch (Exception e) {
               System.debug('An API Exception occured:  ' + e.getMessage());
            } 
            finally {
                success=true;
                attempt++;
            }
		}
		return response;
	}
	
	public static String makeRequest(string message, string soapAction) {
     	 //If any padding needs to be added to XML body message
     	string soapbody = message;
     	 //Creating the SOAP Request Body.
     	string req='';     	
     	req = req + '<soapenv:Body xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" Id="Body">';
     	
     	if(soapAction.contains('LeadDateReqResp')) {
     		req = req + '<sfdc:LeadDateReqResp xmlns:sfdc="http://SFDC_PartnerLeadSharing.vzbi.com" xmlns:sfdc1="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
	     	req = req + '<sfdc1:QueryLeadsByLastUpdatedDateReq>';
	     	req = req + soapbody;
	     	req = req + '</sfdc1:QueryLeadsByLastUpdatedDateReq>';
	     	req = req + '</sfdc:LeadDateReqResp>';
     	}
     	else if(soapAction.contains('LeadIDReqResp')) {
     		req += '<sfdc:LeadIDReqResp xmlns:sfdc="http://SFDC_PartnerLeadSharing.vzbi.com" xmlns:sfdc1="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
     		req += '<sfdc1:QueryLeadsByPartnerLeadIdReq>';
     		req += soapbody;
     		req += '</sfdc1:QueryLeadsByPartnerLeadIdReq>';
     		req += '</sfdc:LeadIDReqResp>';
     	}
     	else if(soapAction.contains('LeadStatusReqResp')) {
     		req += '<sfdc:LeadStatusReqResp xmlns:sfdc="http://SFDC_PartnerLeadSharing.vzbi.com" xmlns:sfdc1="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
     		req += '<sfdc1:QueryLeadsByStatusReq>';
     		req += soapbody;
     		req += '</sfdc1:QueryLeadsByStatusReq>';
     		req += '</sfdc:LeadStatusReqResp>';
     	}
     	else if(soapAction.contains('UpdateLeadsReqResp')) {
     		req += '<sfdc:UpdateLeadsReqResp xmlns:sfdc="http://SFDC_PartnerLeadSharing.vzbi.com" xmlns:sfdc1="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
     		req += '<sfdc1:UpdateLeadsRequest>';
     		req += soapbody;
     		req += '</sfdc1:UpdateLeadsRequest>';
     		req += '</sfdc:UpdateLeadsReqResp>';
     	}
     	else if(soapAction.contains('ShareLeadReqResp')) {
     		req += '<sfdc:ShareLeadReqResp xmlns:sfdc="http://SFDC_PartnerLeadSharing.vzbi.com" xmlns:sfdc1="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
     		req += '<sfdc1:ShareLeadReq>';
     		req += soapbody;
     		req += '</sfdc1:ShareLeadReq>';
     		req += '</sfdc:ShareLeadReqResp>';
     	}
     	
     	req = req + '</soapenv:Body>';
        system.debug('reqqqq'+req);
        return req;     	
     }
     
     public static HttpRequest buildHttpRequest(string req, string username, string password,String epURL,string soapAction){
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        String openEnvString = '';
        String headerString = '';
        String bodyString = req;
        String closingEnvString = '';        
        
        openEnvString = '<?xml version="1.0" encoding="UTF-8"?>';
        openEnvString += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">';
        
        //Creating the SOAP Header in WSSE- Format with Singature.
        //headerString  = generateSoapHeader(req,username,password);
        headerString =  GlobalHeaderGenerator.generateSoapHeader(req,username,password);
        closingEnvString += '</soapenv:Envelope>';
        
        //Concatenating SOAP Header, Body and assigning in a String
        String docString = openEnvString + headerString + bodyString + closingEnvString;        
        
        Http h = new Http();
        HttpRequest SFAreq = new HttpRequest();
        String pwd = '';
        SFAreq.setEndpoint(epURL);
        SFAreq.setMethod('POST');
        SFAreq.setTimeout(120000);
        SFAreq.setHeader('Content-Type', 'application/soap+xml');
        SFAreq.setHeader('Content-Length', '100000');
        if(soapAction.contains('LeadDateReqResp')) {
        	SFAreq.setHeader('SOAPAction', 'http://SFDC_PartnerLeadSharing.vzbi.com/SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/LeadDateReqResp');
        }
        else if(soapAction.contains('LeadIDReqResp')) {
        	SFAreq.setHeader('SOAPAction','http://SFDC_PartnerLeadSharing.vzbi.com/SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/LeadIDReqResp');
        } 
        else if(soapAction.contains('LeadStatusReqResp')) {
        	SFAreq.setHeader('SOAPAction','http://SFDC_PartnerLeadSharing.vzbi.com/SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/LeadStatusReqResp');
        }
        else if(soapAction.contains('UpdateLeadsReqResp')) {
        	SFAreq.setHeader('SOAPAction','http://SFDC_PartnerLeadSharing.vzbi.com/SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/UpdateLeadsReqResp');
        }
        else if(soapAction.contains('ShareLeadReqResp')) {
        	SFAReq.setHeader('SOAPAction','http://SFDC_PartnerLeadSharing.vzbi.com/SFDC_PartnerLeadSharing_PartnerLeadSharingOrch_PartnerLeadSharingReqRespPort/ShareLeadReqResp');
        }
        
        System.debug('--------------'+docString);
        SFAreq.setBody(docString);
        
        return SFAreq;
    }
     
     public static string createFullToGetLeadsByID(string username, string pw, integer NumOfLeadsToImport) {
     	XmlStreamWriter w = new XmlStreamWriter();
    	w.writeStartElement('', 'Req', '');
    	//Write Username
    	if(!String.IsBlank(username)) {
	    	w.writeStartElement('', 'ITW_Username', '');
	    	w.writeCharacters(username);
	    	w.writeEndElement();
    	}
    	//Write Password
    	if(!string.IsBlank(pw)) {
	    	w.writeStartElement('', 'ITW_Password', '');
	    	w.writeCharacters(pw);
	    	w.writeEndElement();
    	}
    	//Write Transaction ID
    	w.writeStartElement('', 'Transaction_ID', '');
    	w.writeCharacters(GetTransactionId());
    	w.writeEndElement();
    	
    	//Write Max Response Records
    	if(NumOfLeadsToImport != null) {
	    	w.writeStartElement('', 'Max_Response_Records', '');
	    	w.writeCharacters(String.Valueof(NumOfLeadsToImport));
	    	w.writeEndElement();
    	}
    	w.writeEndDocument();
        
        String XMLUpdateMsg = w.getXmlString();         
        w.close();
        
        XMLUpdateMsg = XMLUpdateMsg.replace('\r\n','');
        System.debug('XML main message...>>>>'+XMLUpdateMsg );
        return XMLUpdateMsg; 
     }
     
     public static string createFullXMLToGetLeadsByDate(string username, string pw, DateTime lastRunDate, integer NumOfLeadsToImport) {
    	    	
    	XmlStreamWriter w = new XmlStreamWriter();
    	w.writeStartElement('', 'Req', '');
    	//Write Username
    	if(!String.IsBlank(username)) {
	    	w.writeStartElement('', 'ITW_Username', '');
	    	w.writeCharacters(username);
	    	w.writeEndElement();
    	}
    	//Write Password
    	if(!string.IsBlank(pw)) {
	    	w.writeStartElement('', 'ITW_Password', '');
	    	w.writeCharacters(pw);
	    	w.writeEndElement();
    	}
    	//Write Transaction ID
    	w.writeStartElement('', 'Transaction_ID', '');
    	w.writeCharacters(GetTransactionId());
    	w.writeEndElement();
    	//Write LastUpdated timestamp
    	if(lastRunDate != null) {
	    	w.writeStartElement('', 'LastUpdatedDate', '');
	    	if(lastrundate != null){
            	system.debug('last run date value is: ' + lastRunDate);
            	//w.writeCharacters(lastRunDate.format('yyyy-MM-dd\'T\'HH:mm:ss'));
            	w.writeCharacters(lastRunDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
	        }
	        else{
	            w.writeCharacters('2013-01-01T11:00:00');
	        }	    	
	    	w.writeEndElement();
    	}
    	//Write Max Response Records
    	if(NumOfLeadsToImport != null) {
	    	w.writeStartElement('', 'Max_Response_Records', '');
	    	w.writeCharacters(String.Valueof(NumOfLeadsToImport));
	    	w.writeEndElement();
    	}
    	w.writeStartElement('', 'OnlyExistingLeads', '');
    	w.writeCharacters('true');
    	w.writeEndElement();
    	
    	w.writeEndDocument();
        
        String XMLUpdateMsg = w.getXmlString();         
        w.close();
        
        XMLUpdateMsg = XMLUpdateMsg.replace('\r\n','');
        System.debug('XML main message...>>>>'+XMLUpdateMsg );
        return XMLUpdateMsg; 
    }
    
    public static string createFullXMLToUpdateLeads(List<Lead> leads, List<Opportunity> opps, string username, string pw) {
    	XmlStreamWriter w = new XmlStreamWriter();
    	w.writeStartElement('','Req','');
    	
    	//Write Transaction ID
    	w.writeStartElement('', 'Transaction_ID', '');
    	w.writeCharacters(GetTransactionId());
    	w.writeEndElement();    	
    	//Write Username
    	if(!String.IsBlank(username)) {
	    	w.writeStartElement('', 'ITW_Username', '');
	    	w.writeCharacters(username);
	    	w.writeEndElement();
    	}
    	//Write Password
    	if(!string.IsBlank(pw)) {
	    	w.writeStartElement('', 'ITW_Password', '');
	    	w.writeCharacters(pw);
	    	w.writeEndElement();
    	}
    	if(leads != null && leads.size() > 0) {
    		for(Lead ld: leads) {
    			w.writeStartElement('', 'Lead', '');
    			w.writeStartElement('', 'LeadInfo', '');
    			if(ld.Partner_ID__c != null) {
    				w.writeStartElement('','SFDC_Lead_Long_ID','');
    				w.writeCharacters(ld.Partner_ID__c);
    				w.writeEndElement();
    			}

                //Added code to send additional values to VZW Interface

                if(ld.Status != null) {
                    w.writeStartElement('','Partner_Sales_Stage','');
                    w.writeCharacters(ld.Status);
                    w.writeEndElement();
                }

                if(ld.Status_Last_Change__c != null) {
                    w.writeStartElement('','Partner_Sales_Stage_Updated','');
                    w.writeCharacters(string.valueof(ld.Status_Last_Change__c));
                    w.writeEndElement();
                }

    			if(ld.NWF_Lead_Opp_Number__c != null) {
    				w.writeStartElement('', 'Partner_Lead_ID', '');
    				w.writeCharacters(ld.NWF_Lead_Opp_Number__c);
    				w.writeEndElement();
    			}
    			if(ld.Status != null) {
    				w.writeStartElement('', 'Status', '');
    				w.writeCharacters(PRMLead.convertLeadStatus(ld.Status));
    				w.writeEndElement();
    				if(ld.Status == 'Non-Responsive' || ld.Status == 'Closed Duplicate' || ld.Status == 'Unqualified') {
    					string invalidReason = PRMLead.getInvalidReason(ld.Status, ld.Main_Unqualified_Reason__c);
    					if(invalidReason != null) {
    						w.writeStartElement('','Invalid_Reason', '');
	    					w.writeCharacters(invalidReason);
	    					w.writeEndElement();
    					}    					
    				}
    			}
    			/*if(ld.Total_Number_of_Vehicles__c != null) {
    				w.writeStartElement('','M2M_Connection_Est','');
    				w.writeCharacters(string.ValueOf(ld.Total_Number_of_Vehicles__c));
    				w.writeEndElement();
    			}*/
    			if(ld.OwnerId != null) {
    				if(ld.Owner.FirstName != null) {
    					w.writeStartElement('', 'Assigned_Owner_First_Name', '');
    					w.writeCharacters(ld.Owner.FirstName);
    					w.writeEndElement();
    				}
    				if(ld.Owner.LastName != null) {
    					w.writeStartElement('', 'Assigned_Owner_Last_Name', '');
    					w.writeCharacters(ld.Owner.LastName);
    					w.writeEndElement();
    				}
    				if(ld.Owner.Email != null) {
    					w.writeStartElement('','Assigned_Owner_Email','');
    					w.writeCharacters(ld.Owner.Email);
    					w.writeEndElement();
    				}
    				if(ld.Owner.Phone != null) {
    					w.writeStartElement('', 'Assigned_Owner_Phone', '');
    					string phoneformatted=removeFormatting(ld.Owner.phone).trim();
    					w.writeCharacters(phoneFormatted);
    					w.writeEndElement();
    				}
    			}    			
    			w.writeEndElement();
    			w.writeEndElement();
    		}
    	}
    	if(opps != null && opps.size() > 0) {
    		for(Opportunity opp: opps) {
    			w.writeStartElement('', 'Lead', '');
    			w.writeStartElement('', 'LeadInfo', '');
    			if(opp.Affiliate_Lead_ID__c != null) {
    				w.writeStartElement('','SFDC_Lead_Long_ID','');
    				w.writeCharacters(opp.Partner_ID__c);
    				w.writeEndElement();
    			}
    			if(opp.NWF_Lead_Opp_Number__c != null) {
    				w.writeStartElement('', 'Partner_Lead_ID', '');
    				w.writeCharacters(opp.NWF_Lead_Opp_Number__c);
    				w.writeEndElement();
    			}

                //Change field mappings for opportunity

                if(opp.StageName != null) {
                    w.writeStartElement('','Partner_Sales_Stage','');
                    w.writeCharacters(opp.StageName);
                    w.writeEndElement();
                }

                if(opp.Stage_Last_Change__c != null) {
                    w.writeStartElement('','Partner_Sales_Stage_Updated','');
                    w.writeCharacters(string.valueof(opp.Stage_Last_Change__c));
                    w.writeEndElement();
                }

    			if(opp.StageName != null) {
    				w.writeStartElement('', 'Status', '');
    				w.writeCharacters(PRMLead.convertLeadStatus(opp.StageName));
    				w.writeEndElement();
    				if(opp.StageName == 'Closed Lost') {
    					string invalidReason = PRMLead.getInvalidReason(opp.StageName, opp.Main_Lost_Reason__c);
    					if(invalidReason != null) {
    						w.writeStartElement('', 'Invalid_Reason', '');
	    					w.writeCharacters(invalidReason);
	    					w.writeEndElement();
    					}    					
    				}
    				else if(opp.StageName == 'Closed Won') {
    					if(opp.CloseDate != null) {
    						w.writeStartElement('', 'Close_Date', '');
	    					w.writeCharacters(String.ValueOf(opp.CloseDate));
	    					w.writeEndElement();
    					}
    				}
    			}
    			if(opp.Unit_Total_All_Opps__c != null) {
    				w.writeStartElement('','M2M_Connection_Actual','');
    				system.debug('unit total of opps is: ' + opp.Unit_Total_All_Opps__c);
    				if(Integer.valueOf(opp.Unit_Total_All_Opps__c) > 0){
		            	 w.writeCharacters(String.ValueOf(opp.Unit_Total_All_Opps__c));
		           	}
		            else{
		            	w.writeCharacters('1');
		            }
    				w.writeEndElement();
    			}
    			if(opp.OwnerId != null) {
    				if(opp.Owner.FirstName != null) {
    					w.writeStartElement('', 'Assigned_Owner_First_Name', '');
    					w.writeCharacters(opp.Owner.FirstName);
    					w.writeEndElement();
    				}
    				if(opp.Owner.LastName != null) {
    					w.writeStartElement('', 'Assigned_Owner_Last_Name', '');
    					w.writeCharacters(opp.Owner.LastName);
    					w.writeEndElement();
    				}
    				if(opp.Owner.Email != null) {
    					w.writeStartElement('','Assigned_Owner_Email','');
    					w.writeCharacters(opp.Owner.Email);
    					w.writeEndElement();
    				}
    				if(opp.Owner.Phone != null) {
    					w.writeStartElement('', 'Assigned_Owner_Phone', '');
    					string phoneformatted=removeFormatting(opp.Owner.phone).trim();
    					w.writeCharacters(phoneFormatted);
    					w.writeEndElement();
    				}
    			}
    			w.writeEndElement();
    			w.writeEndElement();
    		}
    	}
    	w.writeEndDocument();
    	
    	String XMLUpdateMsg = w.getXmlString();         
        w.close();
        
        XMLUpdateMsg = XMLUpdateMsg.replace('\r\n','');
        System.debug('XML main message...>>>>'+XMLUpdateMsg );
        return XMLUpdateMsg; 
    }
    
    public static string createFullXMLToShareLeads(List<Lead> leads, List<Opportunity> opps, string username, string pw) {
    	XmlStreamWriter w = new XmlStreamWriter();
    	w.writeStartElement('','Req','');
    	
    	//Write Transaction ID
    	w.writeStartElement('', 'Transaction_ID', '');
    	w.writeCharacters(GetTransactionId());
    	w.writeEndElement();    	
    	//Write Username
    	if(!String.IsBlank(username)) {
	    	w.writeStartElement('', 'ITW_Username', '');
	    	w.writeCharacters(username);
	    	w.writeEndElement();
    	}
    	//Write Password
    	if(!string.IsBlank(pw)) {
	    	w.writeStartElement('', 'ITW_Password', '');
	    	w.writeCharacters(pw);
	    	w.writeEndElement();
    	}
    	if(leads != null && leads.size() > 0) {
    		w.writeStartElement('', 'Lead', '');
    		for(Lead ld: leads) {
    			
    			w.writeStartElement('', 'LeadInfo', '');
    			if(ld.Partner_ID__c != null) {
    				w.writeStartElement('','SFDC_Lead_Long_ID','');
    				w.writeCharacters(ld.Partner_ID__c);
    				w.writeEndElement();
    			}
    			w.writeEndElement();
    			
    		}
    		w.writeEndElement();
    	}
    	if(opps != null && opps.size() > 0) {
    		for(Opportunity opp: opps) {
    			w.writeStartElement('', 'Lead', '');
    			w.writeStartElement('', 'LeadInfo', '');
    			if(opp.Affiliate_Lead_ID__c != null) {
    				w.writeStartElement('','SFDC_Lead_Long_ID','');
    				w.writeCharacters(opp.Partner_ID__c);
    				w.writeEndElement();
    			}
    			w.writeEndElement();
    			w.writeEndElement();
    		}
    	}
    	w.writeEndDocument();
    	
    	String XMLUpdateMsg = w.getXmlString();         
        w.close();
        
        XMLUpdateMsg = XMLUpdateMsg.replace('\r\n','');
        System.debug('XML main message...>>>>'+XMLUpdateMsg );
        return XMLUpdateMsg; 
    }
    
    public static String removeFormatting(String phoneFaxZip) {
        list<string> alphaList=new list<string>{'a','b','c','d','e','f','g','h','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
        if (phoneFaxZip == null) return phoneFaxZip;
        phoneFaxZip = phoneFaxZip.replace('.','');
        phoneFaxZip = phoneFaxZip.replace('-','');
        phoneFaxZip = phoneFaxZip.replace(' ','');
        phoneFaxZip = phoneFaxZip.replace('(','');
        phoneFaxZip = phoneFaxZip.replace(')','');
        phoneFaxZip = phoneFaxZip.replace('/','');
        phoneFaxZip = phoneFaxZip.replace('?','');
        for(string alp:alphaList){
            if(phoneFaxZip.contains(alp)){
        phoneFaxZip=phoneFaxZip.replace(alp,'');
            }
        }
        return phoneFaxZip;
    }
	
	public static String GetTransactionId() {
        return 'NWF'+system.now().format('YYYY-MM-DDhh:mm:ss:SS');
    }  
	
}