/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Sunil Kumar
// File Name:       VINXmlParser 
// Summary:         XML Response parser for VIN data
// Created On:      03/07/2017

// Modification Log:
====================

*******************************************************************************/
public class VINXmlParser {
    // Pass in the URL for the request
    // For the purposes of this sample,assume that the URL
    // returns the XML shown above in the response body
    public Map<String,String> parseResponseDom(String xml){
        Map<String, String> vinMap = new Map<String, String>();
        Dom.Document doc = new Dom.Document(); 
        doc.load(xml);
        //Retrieve the root element for this document.
        Dom.XMLNode decoded_vin_data = doc.getRootElement();
        
        //loop through the child elements.
        for(Dom.XMLNode child : decoded_vin_data.getChildElements()) {
            if(child.getName() == 'query_responses'){
                for(Dom.XMLNode query_responses : child.getChildElements()){
                    if(query_responses.getName() == 'query_response'){
                        for(Dom.XMLNode query_response : query_responses.getChildElements()){
                            if(query_response.getName() == 'supplemental_data' || query_response.getName() == 'us_market_data'){
                                for(Dom.XMLNode supplemental_data : query_response.getChildElements()){
                                    if(supplemental_data.getName() == 'common_supplemental_data' || supplemental_data.getName() == 'common_us_data'){
                                        for(Dom.XMLNode common_supplemental_data : supplemental_data.getChildElements()){
                                            if(common_supplemental_data.getName() == 'basic_data'){
                                                for(Dom.XMLNode basic_data : common_supplemental_data.getChildElements()){
                                                    if(basic_data.getName() == 'year')
                                                        vinMap.put('year',basic_data.getText());
                                                    if(basic_data.getName() == 'make')
                                                        vinMap.put('make',basic_data.getText());
                                                    if(basic_data.getName() == 'model')
                                                        vinMap.put('model',basic_data.getText());
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('vinMap ::'+vinMap);
        return vinMap;
    }
}