/**
 * Test utilities for assignment support classes
 * 
 * Copyright 2015, Decisions on Demand, Inc.
 * All Rights Reserved.
 * For support, please contact support@decisionsondemand.com
 */
@isTest(SeeAllData=false)
public with sharing class AssignmentTestUtil {
    public static DecsOnD__Policy__c createTestPolicy(sObjectType mainRecType, String name) {
        return createTestPolicy(mainRecType, name, null);
    }

    public static DecsOnD__Policy__c createTestPolicy(sObjectType mainRecType, String name, DecsOnD.DecisionPointConfig dpConfig) {
        System.assertNotEquals(null, mainRecType);
        System.assert(!String.isBlank(name));
        if (dpConfig==null) dpConfig = createTestDecisionPointConfig(mainRecType);

        DecsOnD__Policy__c testPol = DecsOnD.TestUtils.createTestPolicy(mainRecType.getDescribe().getName(), name, true);

        String attachName = 'SFDC-' + testPol.DecsOnD__Applies_to__c + '-' + testPol.Name + '_DpConfig';
        String dpConfigJSON = dpConfig.toJSON(true);
        Attachment attach = new Attachment(ParentId = testPol.Id, Name = attachName, IsPrivate = true, Body = Blob.valueOf(dpConfigJSON));
//        attach.Description = 'DO NOT DELETE OR EDIT - DP config attachment for ' + testPol.Applies_to__c + '.' + testPol.Name;
        insert attach;
        System.debug('DPConfig as JSON:\n' + dpConfigJSON);
        return testPol;
    }

    public static DecsOnD.DecisionPointConfig createTestDecisionPointConfig(sObjectType mainRecType) {
        Map<String, Object> dspConfig = createTestDecisionPointConfigAsMap(mainRecType);
        return DecsOnD.DecisionPointConfig.fromJSON(JSON.serialize(dspConfig));    
    }

    public static Map<String, Object> createTestDecisionPointConfigAsMap(sObjectType mainRecType) {
        System.assertNotEquals(null, mainRecType);
        String paramName = mainRecType.getDescribe().getName();
        Map<String, Object> dspConfig = new Map<String, Object>();

        List<Object> inputParams = new List<Object>();
        
        Map<String, Object> param = createDecisionPointConfigParam(paramName, mainRecType);
        inputParams.add(param);
        dspConfig.put('input_parameters', inputParams);
        
        dspConfig.put('tables', new List<String>{'testAssignment', 'testRegion'});
        return dspConfig;
    }

    public static Map<String, Object> createSimpleValueTypeMap(sObjectType paramType) {
        System.assertNotEquals(null, paramType);
        Map<String, Object> valueType = new Map<String, Object>();
        valueType.put('typeSystem', 'SFDC.SOBJECT');        
        valueType.put('nativeTypeName', paramType.getDescribe().getName());        
        valueType.put('commonTypeName', 'Object');
        return valueType;
    }

    private static Map<String, Object> createDecisionPointConfigParam(String paramName, Map<String, Object> valueTypeMap) {
        System.assert(!String.isBlank(paramName));
        System.assertNotEquals(null, valueTypeMap);

        Map<String, Object> param = new Map<String, Object>();
        param.put('name', paramName);
        param.put('value_type', valueTypeMap);

        return param;
    }

    public static Map<String, Object> createDecisionPointConfigParam(String paramName, sObjectType paramType) {
        return createDecisionPointConfigParam(paramName, createSimpleValueTypeMap(paramType));
    }

    public static Map<String, Object> createDecisionPointConfigListParam(String paramName, sObjectType paramType) {
        Map<String, Object> itemValueType = createSimpleValueTypeMap(paramType);        

        Map<String, Object> valueType = new Map<String, Object>();
        valueType.put('commonTypeName', 'List');
        valueType.put('collectionValueType', itemValueType);
        return createDecisionPointConfigParam(paramName, valueType);
    }
    
    public static HttpCalloutMock setMockDecisionPointConfigResponse(sObjectType mainRecType) {
        return setMockJSONCalloutResponse(createTestDecisionPointConfig(mainRecType).toJSON(false), 200);
    }
    
    public static HttpCalloutMock setMockJSONCalloutResponse(String strBody, Integer statusCode) {
        HttpCalloutMock mock = new GenericCalloutMock(strBody, 'application/json', statusCode);
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }
    
    public class GenericCalloutMock implements HttpCalloutMock {
        private Object body=null;
        private String contentType;
        private Integer statusCode;
        
        private GenericCalloutMock(String contentType, Integer statusCode, Object theBody){
            this.contentType = contentType;
            this.statusCode = statusCode;       
            this.body = theBody;
        }
    
        public GenericCalloutMock(String strBody, Integer statusCode){
            this('application/json', statusCode, strBody);
        }
            
        public GenericCalloutMock(String strBody, String contentType, Integer statusCode){
            this(contentType, statusCode, strBody);
        }
            
        public GenericCalloutMock(Blob theBlob, Integer statusCode){
            this('application/octet-stream', statusCode, theBlob);
        }
            
        public GenericCalloutMock(Document theDoc, Integer statusCode){
            this('application/xml', statusCode, theDoc);
        }
            
        /**
         * Mockup response
         */ 
        public HTTPResponse respond(HTTPRequest req) {
            System.assertNotEquals(null, req);
            System.assertNotEquals(null, statusCode);
            // Create a fake response
            HttpResponse res = new HttpResponse();
            // Set response values
            res.setHeader('Content-Type',contentType);
            if (body!=null) {
                if (body instanceof Blob)
                    res.setBodyAsBlob((Blob)body);
                else if (body instanceof Dom.Document)
                    res.setBody(((Dom.Document)body).toXmlString());
                else if (body instanceof String)
                    res.setBody((String)body);
                else
                    res.setBody(JSON.serialize(body));
            }
            res.setStatusCode(statusCode);
            // return response
            return res;
        }
    }

}