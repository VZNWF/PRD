/****************************************************************
Created: 26 Dec 2013
Author: Krishna Tatta (CodeScience)
Purpose : a connector class for PRM's SOAP API calls
Modifications:
******************************************************************/

global with sharing class PRMAPI {
	private PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
	PRMAPIService service;
	
	//constructor
	public PRMAPI(){
		service = new PRMServiceImpl();
	}
	
	//for test code
	public PRMAPI(PRMMockServiceImpl svc) {
		service = svc; 
	}
	
	//connect method
	public HttpResponse execute(String message, String soapAction){
		system.debug('soap action inside PRMAPI is: ' + soapAction);
		return service.execute(message, soapAction);
	}	
}