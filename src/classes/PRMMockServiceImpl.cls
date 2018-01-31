/****************************************************************
Created: 5 Jan 2014
Author: Krishna Tatta (CodeScience)
Purpose : Used to test the PRMAPI class
Modifications:
******************************************************************/

public with sharing class PRMMockServiceImpl implements PRMAPIService {
	
	private static string desiredLeadOppNumber;
	private static string convertedLeadOppNumber;
	
	public static void setLeadOppNumber(string input) {
		desiredLeadOppNumber = input;
	}
	
	public static void setConvertedLeadOppNumber(string input) {
		convertedLeadOppNumber = input;
	}
	
	public static HttpResponse execute(String message, String soapAction) {
		string response = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
		response += '<soap:Body>';
    	if(soapAction.contains('LeadDateReqResp')){
    		response += '<LeadDateReqRespResponse xmlns="http://SFDC_PartnerLeadSharing.vzbi.com">';
    		response += '<LeadSharingResponse xmlns="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
    		response += '<Resp xmlns="">';
    		response += '<Transaction_ID>NWF2014-01-0803:53:44:183</Transaction_ID>';
    		response += '<Leads>';
    		response += '<Lead>';
    		response += '<LeadInfo>';
    		response += '<SFDC_Lead_ID>AZQ1025</SFDC_Lead_ID>';
    		response += '<SFDC_Lead_Long_ID>00QK00000056y5uMAA</SFDC_Lead_Long_ID>';
    		response += '<Assigned_Owner_First_Name>Kathy</Assigned_Owner_First_Name>';
    		response += '<Assigned_Owner_Last_Name>Arnold</Assigned_Owner_Last_Name>';
    		response += '<Status>Qualified</Status>';
    		response += '<Company>D&amp;Dtest</Company>';
    		response += '<Title>CTO</Title>';
    		response += '<First_Name>Mary</First_Name>';
    		response += '<Last_Name>Cilva</Last_Name>';
    		response += '<Email>mary.cilva@codescience.com</Email>';
    		response += '<Phone>111-111-1111</Phone>';
    		response += '<City>BGFD</City>';
    		response += '<State>CA</State>';
    		response += '<PostalCode>07621</PostalCode>';
    		response += '<Country>US</Country>';
    		response += '<Lead_Source>eCommerce</Lead_Source>';
    		response += '<Website>www.test.com</Website>';
    		response += '<Industry>Automotive</Industry>';
    		response += '<Lead_Region>PT</Lead_Region>';
    		response += '<Lead_Area>TestArea</Lead_Area>';
    		response += '<M2M_Expected_Close_Date>03-01-2014</M2M_Expected_Close_Date>';
    		response += '<Rep1_First_Name>Test Rep First</Rep1_First_Name>';
    		response += '<Rep1_Last_Name>Test Rep Last</Rep1_Last_Name>';
    		response += '<Rep1_Email>rep1@test.com</Rep1_Email>';
    		response += '<Rep1_Phone>222-222-2222</Rep1_Phone>';
    		response += '<Rep2_First_Name>SecondTestRepFirst</Rep2_First_Name>';
    		response += '<Rep2_Last_Name>SecondTestRepLast</Rep2_Last_Name>';
    		response += '<Rep2_Email>rep2@test.com</Rep2_Email>';
    		response += '<Rep2_Phone>333-333-3333</Rep2_Phone>';
    		response += '<Comments>New car, caviar, four star daydream, Think I\'ll buy me a football team Money get back I\'m all right Jack keep your hands off my stack.</Comments>';
    		response += '<Description>Money, get away Get a good job with more pay and your O.K. Money it\'s a gas Grab that cash with both hands and make a stash</Description>';
    		response += '<Permission_to_Contact>Yes</Permission_to_Contact>';
    		response += '<Permission_Granted_By>Testuser</Permission_Granted_By>';
    		response += '</LeadInfo>';
    		response += '</Lead>';
    		response += '<Lead>';
    		response += '<LeadInfo>';
    		response += '<SFDC_Lead_ID>AZQ1026</SFDC_Lead_ID>';
    		response += '<SFDC_Lead_Long_ID>00QK00000056y5yMBB</SFDC_Lead_Long_ID>';
    		response += '<Assigned_Owner_First_Name>Jeffrey</Assigned_Owner_First_Name>';
    		response += '<Partner_Lead_ID>' + desiredLeadOppNumber + '</Partner_Lead_ID>';
    		response += '<Assigned_Owner_Last_Name>Arnold</Assigned_Owner_Last_Name>';
    		response += '<Status>Customer Contacted</Status>';
    		response += '<Company>Bong</Company>';
    		response += '<First_Name>Krishna</First_Name>';
    		response += '<Last_Name>Tatta</Last_Name>';
    		response += '<Email>krishna.tatta@codescience.com</Email>';
    		response += '<Phone>333-333-3333</Phone>';
    		response += '<City>Irving</City>';
    		response += '<State>TX</State>';
    		response += '<PostalCode>75039</PostalCode>';
    		response += '<Country>US</Country>';
    		response += '<Lead_Source>eCommerce</Lead_Source>';
    		response += '<Rep1_First_Name>Test Rep First</Rep1_First_Name>';
    		response += '<Rep1_Last_Name>Test Rep Last</Rep1_Last_Name>';
    		response += '<Rep1_Email>rep1@test.com</Rep1_Email>';
    		response += '<Rep1_Phone>222-222-2222</Rep1_Phone>';
    		response += '<Rep2_First_Name>SecondTestRepFirst</Rep2_First_Name>';
    		response += '<Rep2_Last_Name>SecondTestRepLast</Rep2_Last_Name>';
    		response += '<Rep2_Email>rep2@test.com</Rep2_Email>';
    		response += '<Rep2_Phone>333-333-3333</Rep2_Phone>';
    		response += '<Comments>test comments</Comments>';
    		response += '<Description>test description</Description>';
    		response += '<Permission_to_Contact>No</Permission_to_Contact>';
    		response += '<Permission_Granted_By>Testuser</Permission_Granted_By>';
    		response += '</LeadInfo>';
    		response += '</Lead>';    		
    		response += '<Lead>';
    		response += '<LeadInfo>';
    		response += '<SFDC_Lead_ID>AZQ1000</SFDC_Lead_ID>';
    		response += '<SFDC_Lead_Long_ID>00QK00000078z6zNCC</SFDC_Lead_Long_ID>';
    		response += '<Assigned_Owner_First_Name>Jeffrey</Assigned_Owner_First_Name>';
    		response += '<Partner_Lead_ID>' + convertedLeadOppNumber + '</Partner_Lead_ID>';
    		response += '<Assigned_Owner_Last_Name>Arnold</Assigned_Owner_Last_Name>';
    		response += '<Status>Customer Contacted</Status>';
    		response += '<Company>Bong</Company>';
    		response += '<First_Name>Krishna</First_Name>';
    		response += '<Last_Name>Tatta</Last_Name>';
    		response += '<Email>krishna.tatta@codescience.com</Email>';
    		response += '<Phone>333-333-3333</Phone>';
    		response += '<City>Irving</City>';
    		response += '<State>TX</State>';
    		response += '<PostalCode>75039</PostalCode>';
    		response += '<Country>US</Country>';
    		response += '<Lead_Source>eCommerce</Lead_Source>';
    		response += '<Rep1_First_Name>Test Rep First</Rep1_First_Name>';
    		response += '<Rep1_Last_Name>Test Rep Last</Rep1_Last_Name>';
    		response += '<Rep1_Email>rep1@test.com</Rep1_Email>';
    		response += '<Rep1_Phone>222-222-2222</Rep1_Phone>';
    		response += '<Rep2_First_Name>SecondTestRepFirst</Rep2_First_Name>';
    		response += '<Rep2_Last_Name>SecondTestRepLast</Rep2_Last_Name>';
    		response += '<Rep2_Email>rep2@test.com</Rep2_Email>';
    		response += '<Rep2_Phone>333-333-3333</Rep2_Phone>';
            response += '<Lead_Direction>SMBC to Partner</Lead_Direction>';
            response += '<LocationCode>D239701</LocationCode>';
            response += '<Channel>Retail</Channel>';
            response += '<Fleet_Feature>Diagnostic</Fleet_Feature>';
    		response += '<Comments>test comments</Comments>';
    		response += '<Description>test description</Description>';
    		response += '<Permission_to_Contact>No</Permission_to_Contact>';
    		response += '<Permission_Granted_By>Testuser</Permission_Granted_By>';
    		response += '</LeadInfo>';
    		response += '</Lead>';
    		response += '</Leads>';
    		response += '</Resp>';
    		response += '</LeadSharingResponse>';
    		response += '</LeadDateReqRespResponse>';
    	}
    	else if(soapAction.contains('UpdateLeadsReqResp')) {
    		response += '<UpdateLeadsReqRespResponse xmlns="http://SFDC_PartnerLeadSharing.vzbi.com">';
    		response += '<UpdateLeadsResponse xmlns="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
    		response += '<Leads xmlns="">';
    		response += '<Transaction_ID />';
    		response += '<Resp>';
    		response += '<Error>';
    		response += '<Fields /><Message /><StatusCode />';
    		response += '</Error>';
    		response += '<Id>00QK00000056y5uMAA</Id>';
    		response += '<Success>true</Success>';
    		response += '</Resp>';
/*    		response += '<Resp>';
    		response += '<Error>';
    		response += '<Fields>TestID__c</Fields>';
    		response += '<Message>Test Error Message</Message>';
    		response += '<StatusCode>404</StatusCode>';
    		response += '</Error>';
    		response += '<Id>00QK00000056y5yMBB</Id>';
    		response += '<Success>false</Success>';
    		response += '</Resp>';
*/            
    		response += '</Leads>';
    		response += '</UpdateLeadsResponse>';
    		response += '</UpdateLeadsReqRespResponse>';
    	}
    	else if(soapAction.contains('LeadIDReqResp')) {
    		response += '<LeadIDReqRespResponse xmlns="http://SFDC_PartnerLeadSharing.vzbi.com">';
    		response += '<LeadSharingResponse xmlns="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
    		response += '<Resp xmlns="">';
    		response += '<Transaction_ID>NWF2014-01-0803:53:44:183</Transaction_ID>';
    		response += '<Leads>';
    		response += '<Lead>';
    		response += '<LeadInfo>';
    		response += '<SFDC_Lead_ID>AZQ1025</SFDC_Lead_ID>';
    		response += '<SFDC_Lead_Long_ID>00QK00000056y5uMAA</SFDC_Lead_Long_ID>';
    		response += '<Assigned_Owner_First_Name>Kathy</Assigned_Owner_First_Name>';
    		response += '<Assigned_Owner_Last_Name>Arnold</Assigned_Owner_Last_Name>';
    		response += '<Status>Qualified</Status>';
    		response += '<Company>D&amp;Dtest</Company>';
    		response += '<Title>CTO</Title>';
    		response += '<First_Name>Mary</First_Name>';
    		response += '<Last_Name>Cilva</Last_Name>';
    		response += '<Email>test#2@test.com</Email>';
    		response += '<Phone>111-111-1111</Phone>';
    		response += '<City>BGFD</City>';
    		response += '<State>CA</State>';
    		response += '<PostalCode>07621</PostalCode>';
    		response += '<Country>US</Country>';
    		response += '<Lead_Source>eCommerce</Lead_Source>';
    		response += '<Website>www.test.com</Website>';
    		response += '<Industry>Automotive</Industry>';
    		response += '<Lead_Region>PT</Lead_Region>';
    		response += '<Lead_Area>TestArea</Lead_Area>';
    		response += '<M2M_Expected_Close_Date>03-01-2014</M2M_Expected_Close_Date>';
    		response += '<Rep1_First_Name>Test Rep First</Rep1_First_Name>';
    		response += '<Rep1_Last_Name>Test Rep Last</Rep1_Last_Name>';
    		response += '<Rep1_Email>rep1@test.com</Rep1_Email>';
    		response += '<Rep1_Phone>222-222-2222</Rep1_Phone>';
    		response += '<Rep2_First_Name>SecondTestRepFirst</Rep2_First_Name>';
    		response += '<Rep2_Last_Name>SecondTestRepLast</Rep2_Last_Name>';
    		response += '<Rep2_Email>rep2@test.com</Rep2_Email>';
    		response += '<Rep2_Phone>333-333-3333</Rep2_Phone>';
            response += '<Lead_Direction>SMBC to Partner</Lead_Direction>';
            response += '<LocationCode>D239701</LocationCode>';
            response += '<Channel>Retail</Channel>';
            response += '<Fleet_Feature>Diagnostic</Fleet_Feature>';
    		response += '<Comments>New car, caviar, four star daydream, Think I\'ll buy me a football team Money get back I\'m all right Jack keep your hands off my stack.</Comments>';
    		response += '<Description>Money, get away Get a good job with more pay and your O.K. Money it\'s a gas Grab that cash with both hands and make a stash</Description>';
    		response += '<Permission_to_Contact>Yes</Permission_to_Contact>';
    		response += '<Permission_Granted_By>Testuser</Permission_Granted_By>';
    		response += '</LeadInfo>';
    		response += '</Lead>';
    		response += '</Leads>';
    		response += '</Resp>';
    		response += '</LeadSharingResponse>';
    		response += '</LeadIDReqRespResponse>';
    	}
    	else if(soapAction.contains('ShareLeadReqResp')) {
    		response += '<ShareLeadReqRespResponse xmlns="http://SFDC_PartnerLeadSharing.vzbi.com">';
    		response += '<ShareLeadResp xmlns="http://SFDC_PartnerLeadSharing.PartnerLeadSharingReq">';
    		response += '<Leads xmlns="">';
    		response += '<Transaction_ID />';
    		response += '<Resp>';
    		response += '<Id>00QK00000056y5uMAA</Id>';
    		response += '<Success>true</Success>';
    		response += '</Resp>';
    		response += '</Leads>';
    		response += '</ShareLeadResp>';
    		response += '</ShareLeadReqRespResponse>';
    	}
    	response += '</soap:Body>';
    	response += '</soap:Envelope>';
    	HttpResponse httpResponse = new HttpResponse();
    	httpResponse.setBody(response);
    	return httpResponse;
	}
}