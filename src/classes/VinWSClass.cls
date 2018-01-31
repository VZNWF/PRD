/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          jaya srivastava
// File Name:       VinWSClass 
// Summary:         Get Make,Model & Year based on VIN Number
// Created On:      04/03/2017

// Modification Log:
====================

*******************************************************************************/
global Class VinWSClass{
    @TestVisible global static Boolean checkVal=false;
    @TestVisible  global static Map<String,String> vinMap= new Map<String,String>();

    global static void getVINData(String VINNumber){     
    
        List<Vin_Data__c> vcList=Vin_Data__c.getAll().values();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(vcList[0].EndPoint__c);
        request.setMethod(vcList[0].Method__c);
        /*String body = 'client_id='+EncodingUtil.urlEncode(vcList[0].ClientId__c, 'UTF-8')
            +'&auth_code='+EncodingUtil.urlEncode(vcList[0].AuthCode__c, 'UTF-8')
                +'&vins='+EncodingUtil.urlEncode(VINNumber, 'UTF-8');*/
        String decoderQuery = '<decoder_query> <decoder_settings> <display>full</display> <version>7.0.1</version> <styles>on</styles> <style_data_packs> <basic_data>on</basic_data> <pricing>on</pricing> <engines>on</engines> <transmissions>on</transmissions> <specifications>on</specifications> <installed_equipment>on</installed_equipment> <optional_equipment>on</optional_equipment> <colors>on</colors> <safety_equipment>on</safety_equipment> <warranties>on</warranties> <fuel_efficiency>on</fuel_efficiency> </style_data_packs> <common_data>on</common_data> <common_data_packs> <basic_data>on</basic_data> <pricing>on</pricing> <engines>on</engines> <transmissions>on</transmissions> <specifications>on</specifications> <installed_equipment>on</installed_equipment> <optional_equipment>on</optional_equipment> <colors>on</colors> <safety_equipment>on</safety_equipment> <warranties>on</warranties> <fuel_efficiency>on</fuel_efficiency> </common_data_packs> </decoder_settings> <query_requests> <query_request identifier="Request-Sample"> <vin>'+VINNumber+'</vin> <year></year> <make></make> <model></model> <trim></trim> <model_number></model_number> <package_code></package_code> <drive_type></drive_type> <vehicle_type></vehicle_type> <body_type></body_type> <body_subtype></body_subtype> <doors></doors> <bedlength></bedlength> <wheelbase></wheelbase> <msrp></msrp> <invoice_price></invoice_price> <engine description=""> <block_type></block_type> <cylinders></cylinders> <displacement></displacement> <fuel_type></fuel_type> </engine> <transmission description=""> <trans_type></trans_type> <trans_speeds></trans_speeds> </transmission> <optional_equipment_codes></optional_equipment_codes> <installed_equipment_descriptions></installed_equipment_descriptions> <interior_color description=""> <color_code></color_code> </interior_color> <exterior_color description=""> <color_code></color_code> </exterior_color> </query_request> </query_requests></decoder_query>';
        String body = 'client_id='+EncodingUtil.urlEncode(vcList[0].ClientId__c, 'UTF-8')
            +'&authorization_code='+EncodingUtil.urlEncode(vcList[0].AuthCode__c, 'UTF-8')
            +'&decoder_query='+EncodingUtil.urlEncode(decoderQuery, 'UTF-8');
        request.setBody(body); 
        System.Debug(body);
        HttpResponse response = http.send(request);
        system.debug('Test response ::'+response);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: '+response.getStatus()));
        }    
        else {
            VINXmlParser d =new VINXmlParser();
            System.Debug('response.getBody ::: '+response.getBody());
            vinMap = d.parseResponseDom(response.getBody());
            if(!vinMap.isEmpty()){
                checkVal=true;                  
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.ERROR,'Error: VIN Number does not exist or Invalid VIN Number'));
                checkVal=false;
            }                
        }        
    }
}