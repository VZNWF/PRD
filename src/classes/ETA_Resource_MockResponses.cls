@isTest
global class ETA_Resource_MockResponses implements WebServiceMock{

     global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) 
           
        {
        
            if(stub instanceof toatechResourcemanagement_Installer.SetResourceResponseElement){
            	toatechResourcemanagement_Installer.SetResourceResponseElement resResponseElement = new toatechResourcemanagement_Installer.SetResourceResponseElement();            
                resResponseElement.result_code = 0;
                resResponseElement.error_msg = 'Success';    
                response.put('response_x', resResponseElement);
            }
        	else if(stub instanceof toatechResourcemanagement_Installer.SetUserResponseElement){
                toatechResourcemanagement_Installer.SetUserResponseElement resUserElement = new toatechResourcemanagement_Installer.SetUserResponseElement();            
                resUserElement.result_code = 0;
                resUserElement.error_msg = 'Success';   
             	response.put('response_y', resUserElement);
            }
                       
        }
}