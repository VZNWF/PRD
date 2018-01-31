/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the OpportunityHelper
Modifications:
******************************************************************/
@isTest(SeeAllData=true)
public Class OpportunityHelperTest{

    public static Account a;
    public static Opportunity o;
    public static Opportunity o1;
    public static Orders__c Ord2;
    public static Location__c loc;
    public static Location__c loc1;
    public static Contact c;
    public static OrderLocation__c oLoc;
    public static CPQ_SOMAST__c cpqsomast;
    public static CPQ_SOMAST__c cpqsomast1;
    public static CPQ_Opportunity_Products__c cpqPro;     
    public static CPQ_Opportunity_Products__c cpqPro1; 
    public static CPQ_Opportunity_Products__c cpqPro2; 
    public static Case ca;
    
    static{
        a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214s';
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
        o.Location_Name__c='abc';         
        insert o;
        
        Ord2 = new Orders__c();
        Ord2.Account__c = A.Id;
        Ord2.opportunity__c = O.Id;
        Ord2.Order_Types__c = 'BUNDLE';
        
        insert Ord2;         
                   
        c = new Contact();
        c.Mailingcity = 'San Diego';
        c.MailingStreet='999 main st';
        c.MailingPostalCode='12345-9999';
        c.MailingState='California';
        c.MailingCountry='United States';
        c.LastName='Test Lastname';   
        c.FirstName='Test Firstname';
        insert c;   
        
        loc=new Location__c();
        loc.OpportunityId__c=o.Id;
        loc.Garage_Address1__c='PO BOX';
        loc.Garage_City__c='kdkdkd';
        loc.Garage_State__c='GA';
        loc.Garage_Zip__c='9829q9q';
        loc.Phone__c='020222';
        loc.ContactName__c=c.Name;    
        insert loc;
        
        loc1=new Location__c();
        loc1.OpportunityId__c=o.Id;    
        insert loc1;
        
        oLoc=new OrderLocation__c();
        oLoc.Location__c=loc1.Id;
        oLoc.Orders__c=Ord2.Id;
        insert oLoc;
        
        case ca = new case();
        ca.ContactId = c.Id;
        ca.AccountId = a.Id;
        ca.Is_Fleet_same_as_Account__c = true;
        ca.Reason = 'RA';
        ca.Case_Sub_Reason__c = 'Defective Product';
        ca.RA_Type__c = 'Replace - Product (No return)';
        ca.Origin = 'Phone';
        insert ca; 
        
        o1 = new opportunity();
        o1.AccountId = a.Id;
        o1.Type_of_sale__c = 'Indirect';
        o1.CloseDate = system.today();
        o1.name = 'Test';
        o1.stagename = 'pilot'; 
        o1.LeadSource='2G Migration';
        o1.Existing_AVL_User__c='No';  
        o1.Location_Name__c='abc'; 
        o1.Type='Exchange/RA'; 
        o1.Case_Number__c = ca.CaseNumber;
        insert o1;
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = o.Id, name = 'Test',primary__c = true);
        insert cpqsomast;
        
        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.SEQ__c='TestABC';      
        cpqPro.Sale_Type__c = 'BUNDLE';
        cpqPro.Opportunity_Record_ID__c = o.Id;
        insert cpqPro;
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.SEQ__c='TestABC1w';      
        cpqPro1.Sale_Type__c = 'PURCHASE';       
        cpqPro1.Opportunity_Record_ID__c = o.Id;
        insert cpqPro1;
        
        cpqsomast1 = new CPQ_SOMAST__c(Opportunity__c = o1.Id, name = 'Test',primary__c = true);
        insert cpqsomast1;
        
        cpqPro2=new CPQ_Opportunity_Products__c();
        cpqPro2.CPQ_Quote_Record_ID__c=cpqsomast1.Id;
        cpqPro2.SEQ__c='TestABC1w';      
        cpqPro2.Sale_Type__c = 'PURCHASE';       
        cpqPro2.Opportunity_Record_ID__c = o1.Id;
        insert cpqPro2;
    }
    
    static TestMethod void OpportunityHelperTestMethod1(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c=loc.Name; 
         update o;
         cpqPro.Sale_Type__c = 'BUNDLE';       
         update cpqPro;
         OpportunityHelper.createOrder(o.Id);
    }
    static TestMethod void OpportunityHelperTestMethod2(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c= '';
         o.Additional_Shipping_Address_Line1__c = '123 please post';
         o.Shipping_Street2__c='345 please post';
         o.Shipping_Street3__c= '567 please post';
         o.Multiple_Address__c= false;
         
         update o;
         OpportunityHelper.createOrder(o.Id);
    }
    static TestMethod void OpportunityHelperTestMethod3(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c= '';
         o.Additional_Shipping_Address_Line1__c = '';
         o.Shipping_Street2__c='345 please post';
         o.Shipping_Street3__c= '567 please post';
         update o;
         OpportunityHelper.createOrder(o.Id);
    }
     static TestMethod void OpportunityHelperTestMethod4(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c= '';
         o.Additional_Shipping_Address_Line1__c = '';
         o.Shipping_Street3__c= '567 please post';
         update o;
         OpportunityHelper.createOrder(o.Id);
    }  
    static TestMethod void OpportunityHelperTestMethod5(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c= 'loc.Name';
         o.Additional_Shipping_Address_Line1__c = 'Test123';
         update o;
         OpportunityHelper.createOrder(o.Id);
    }
    static TestMethod void OpportunityHelperTestMethod6(){
         OpportunityHelper.createOrder(o.Id);
         o.Location_Name__c= 'loc.Name';
         o.Additional_Shipping_Address_Line1__c = 'Test123';
         update o;
         cpqPro1.Sale_Type__c = 'PURCHASE';       
         update cpqPro1;
         OpportunityHelper.createOrder(o.Id);
    }
    static TestMethod void OpportunityHelperTestMethod7(){
         OpportunityHelper.createOrder(o.Id);
         loc.Phone__c='020225';
         update loc;
          Product2 product = new Product2();
        product.Name = 'Test';
        insert product;

        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.IsActive = true;
        pricebookEntry.UnitPrice = 100;
        insert pricebookEntry;
        
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        opportunityLineItem.OpportunityId = o.Id;
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.Quantity = 5;
        opportunityLineItem.UnitPrice = 100;
        insert opportunityLineItem;
        
            
         OpportunityHelper.createOrder(o.Id);
    }
    
    static TestMethod void OpportunityHelperTestMethod8(){
         OpportunityHelper.createOrder(o1.Id);
         o1.Location_Name__c= 'loc.Name';
         o1.Additional_Shipping_Address_Line1__c = 'Test123';
         o1.Type = 'Exchange/RA';
         update o1;
         cpqPro1.Sale_Type__c = 'PURCHASE';       
         update cpqPro1;
         OpportunityHelper.createOrder(o1.Id);
    }
    static TestMethod void OpportunityHelperTestMethod9(){
         OpportunityHelper.createOrder(o1.Id);
         o1.Location_Name__c= 'loc.Name';
         o1.Additional_Shipping_Address_Line1__c = 'Test123';
         o1.Type = 'Exchange/RA';
         o1.Type_of_sale__c = 'Bundled';
         update o1;
         cpqPro1.Sale_Type__c = 'BUNDLE';       
         update cpqPro1;
         OpportunityHelper.createOrder(o1.Id);
    }
     
    

}