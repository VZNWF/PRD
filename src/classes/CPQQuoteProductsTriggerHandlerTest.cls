/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the CPQ QuoteProducts Trigger Handler
Modifications:
******************************************************************/
@isTest
public Class CPQQuoteProductsTriggerHandlerTest{
    
    public static Account a;
    public static Opportunity o;
    public static CPQ_SOMAST__c cpqsomast; 
    public static CPQ_Opportunity_Products__c cpqPro;   
    public static CPQ_Opportunity_Products__c cpqPro1;   
    public static  Product2 prod;
    public static  Product2 prod1;
    static void createTestData(){
         list<Opportunity_CPQ_Mapping__c> OppCPQMapping = Utilstest.CreateOpportunityCPQMapping();
          Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        
        a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214';
        a.Contract_Type__c='Standard';
        insert a;
        
        o = new opportunity();
        o.AccountId = a.Id;
        o.Type_of_sale__c = 'Indirect';
        O.CloseDate = system.today();
        O.name = 'Test';
        O.stagename = 'pilot'; 
        o.LeadSource='2G Migration';
        o.Existing_AVL_User__c='No';
        insert o;
        
        
        prod = new Product2(Name = 'Laptop X200', Family = 'SOLUTION', CPQ_PRODUCT_CATEGORY__c='SOLUTION', ProductCode='H5200' );
        insert prod; 
        
        prod1 = new Product2(Name = 'Laptop X200', Family = 'HARNESS', CPQ_PRODUCT_CATEGORY__c='ALL OTHER', ProductCode = 'D-Install' );
        insert prod1; 
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = o.Id, name = 'Test',primary__c = true);
        insert cpqsomast;
        
        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.SEQ__c='1.1';      
        cpqPro.Sale_Type__c = 'BUNDLE'; 
        cpqPro.CPQ_Product_Inserted__c = true;
        cpqPro.Product_Record_Id__c = prod1.Id; 
        insert cpqPro;
        
        System.Debug('Product CATEGORY:'+cpqPro.Product_Category__c );
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.SEQ__c='1.2';   
        cpqPro1.Product_Record_Id__c = prod.Id; 
        cpqPro1.CPQ_Product_Inserted__c = true; 
        cpqPro1.Sale_Type__c = 'BUNDLE';   
        cpqPro1.BUN_MRC_Term__c = '36';
        insert cpqPro1;
        
        System.debug('xxx:'+[Select Id, CPQ_Quote_Record_Id__c from CPQ_Opportunity_Products__c]);
        
    }

   
    static testMethod void CPQQuoteProMethod1(){
        createTestData();
        Test.startTest();  
        update cpqPro1;  
        Test.stopTest();      
        /*List <CPQ_Opportunity_Products__c> newCPQLI=new List<CPQ_Opportunity_Products__c>();
        newCPQLI.add(cpqPro);
        Map<Id, CPQ_Opportunity_Products__c> cpqLiMap=new  Map<Id, CPQ_Opportunity_Products__c>();
        cpqLiMap.put(cpqPro.id,cpqPro);
        CPQQuoteProductsTriggerHandler.populateBundleKit(null, newCPQLI, true);
        List <CPQ_Opportunity_Products__c> new1CPQLI=new List<CPQ_Opportunity_Products__c>();
        new1CPQLI.add(cpqPro);
         new1CPQLI.add(cpqPro1);
           CPQQuoteProductsTriggerHandler.populateBundleKit(cpqLiMap,new1CPQLI, false);*/
    }
    
   /* static testMethod void CPQQuoteProMethod2(){
        createTestData();
        Test.startTest();  
        delete cpqPro1;  
        Test.stopTest();      
       
    }*/
    
    

}