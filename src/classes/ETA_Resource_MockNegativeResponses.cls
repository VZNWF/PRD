global class ETA_Resource_MockNegativeResponses implements WebServiceMock{

     global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
                
             toatechResourcemanagement_Installer.SetResourceResponseElement resResponseElement = new toatechResourcemanagement_Installer.SetResourceResponseElement();            
                resResponseElement.result_code = 28;
                resResponseElement.error_msg = 'Invalid Id';            
                
             response.put('response_x', resResponseElement);
            
           }
  }