@isTest
global class ETA_Resource_Conct_MockResponses implements WebServiceMock{

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
             
          toatechResourcemanagement_Installer.SetUserResponseElement resResponseElement = new toatechResourcemanagement_Installer.SetUserResponseElement();            
                resResponseElement.result_code = 0;
                resResponseElement.error_msg = 'Success';      
                  
                
             response.put('response_x', resResponseElement);
            
        }
   
  

}