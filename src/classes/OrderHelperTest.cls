/****************************************************************
Created: 03 Feb 2017
Author: Satish
Purpose : test class for the OrderHelper
Modifications:
******************************************************************/
@isTest(SeeAllData=true)
public Class OrderHelperTest{
public static Account a;
public static Opportunity o;
public static Opportunity o1;
public static Opportunity o2;
public static Orders__c Ord2;
public static Orders__c Ord;
public static Orders__c Ord3;
public static Orders__c Ord4;
public static Location__c loc;
public static Location__c loc1;
public static Contact c;
public static OrderLocation__c oLoc;
public static OrderLocation__c oLoc1;
public static OrderLocation__c oLoc2;
public static Order_Product__c op;
public static Order_Product__c op1;
public static Order_Line_Item_Details__c olid1;
public static CPQ_SOMAST__c cpqsomast; 
public static CPQ_Opportunity_Products__c cpqPro;     
public static CPQ_Opportunity_Products__c cpqPro1;
public static CPQ_Opportunity_Products__c cpqPro2;
public static Order_Line_Items__c oli; 
public static Product2 prod;
public static Product2 prod1;
public static Product2 prod2;
public static Product2 prod3;
public static Order_Promo_Codes__c ordPromo;

static{

        a= new Account();
        a.Name = 'Test Account';
        a.ownerId = UserInfo.getUserId();
        a.CPQ_PRICE_TIER__c = '2';
        a.AccountNumber = '54214';
        a.Contract_Type__c='Standard';
        a.PO_Required__c=true;
        insert a;
        
        List<Opportunity> oppList = new List<Opportunity>();
        o = new opportunity();
        o.AccountId = a.Id;
        o.Type_of_sale__c = 'Indirect';
        O.CloseDate = system.today();
        O.name = 'Test';
        O.stagename = 'pilot'; 
        o.LeadSource='2G Migration';
        o.Existing_AVL_User__c='No';
        
        oppList.add(o);
        
        o1 = new opportunity();
        o1.AccountId = a.Id;
        o1.Type_of_sale__c = 'Indirect';
        O1.CloseDate = system.today()+50;
        O1.name = 'Test1';
        O1.stagename = 'pilot'; 
        o1.LeadSource='2G Migration';
        o1.Existing_AVL_User__c='Yes';
        
        oppList.add(o1);
        
        o2 = new opportunity();
        o2.AccountId = a.Id;
        o2.Type_of_sale__c = 'Indirect';
        o2 .CloseDate = system.today()+50;
        o2.name = 'Test1';
        o2.stagename = 'pilot'; 
        o2.LeadSource='2G Migration';
        o2.Existing_AVL_User__c='Yes';
        oppList.add(o2);
        
        insert oppList ;
        
        List<Orders__c> ordList = new List<Orders__c>();
        Ord2 = new Orders__c();
        Ord2.Order_Types__c='STDORD';
        Ord2.Account__c = A.Id;
        Ord2.opportunity__c = O.Id;
        //insert Ord2;
        ordList.add(Ord2);
                       
                       
        Ord= new Orders__c();
        Ord.Account__c = A.Id;
        Ord.Order_Types__c='STDORD';
        Ord.opportunity__c = O1.Id;
        
        //insert Ord; 
        ordList.add(Ord); 
        
        Ord3= new Orders__c();
        Ord3.Account__c = A.Id;
        Ord3.Order_Types__c='STDORD';
        Ord3.opportunity__c = O2.Id;
      
        //insert Ord3;
        ordList.add(Ord3);
        
        Ord4= new Orders__c();
        Ord4.Account__c = A.Id;
        Ord4.Order_Types__c='BUNDLE';
        Ord4.opportunity__c = O2.Id;
      
        //insert Ord4;
        ordList.add(Ord4);
        insert ordList ;
        
        /*ordPromo = new Order_Promo_Codes__c();
        ordPromo.Name = 'BUNDLE';
        ordPromo.Order_Type__c ='BUNDLE';
        ordPromo.Promo_Code__c = 'KHYEAN001';
        ordPromo.Shipping_Method__c = 'GROUND';
        
        insert ordPromo; */
        
        
        List<Contact> contactList = new List<Contact>();
        c = new Contact();
        c.Mailingcity = 'San Diego';
        c.MailingStreet='999 main st';
        c.MailingPostalCode='12345-9999';
        c.MailingState='California';
        c.MailingCountry='United States';
        c.LastName='Test Lastname';   
        c.FirstName='Test Firstname';
        contactList.add(c);
        insert contactList ;
        //insert c; 
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = o.Id, name = 'Test',primary__c = true);
        insert cpqsomast;
    
        List<Product2> prodList = new List<Product2>();
        prod = new Product2(Name = 'Laptop X200', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='SOLUTION' );
        prodList.add(prod);        //insert prod; 
        
        prod1= new Product2(Name = '5500N3AS GPS Diagnostics', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='ALL OTHER' );
        prodList.add(prod1);   //insert prod1; 
        
        prod2= new Product2(Name = 'D-1009NV-093-00-INS', Family = 'Install', CPQ_PRODUCT_CATEGORY__c='INSTALL', ProductCode = 'Parts47' );
        prodList.add(prod2);   //insert prod2;
        
        
        prod3= new Product2(Name = 'D-INSTALL-UNIT', Family = 'Install', CPQ_PRODUCT_CATEGORY__c='INSTALL', ProductCode = 'D-INSTALL-UNIT' );
        prodList.add(prod3);   //insert prod2;
        insert prodList ;
       
        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.SEQ__c='TestABC';      
        cpqPro.Sale_Type__c = 'BUNDLE';   
        cpqPro.Product_Record_Id__c = prod.id;
        cpqPro.Opportunity_Record_ID__c =o2.id;
        cpqPro.Bundle_Kit_ID__c ='398932';    
        insert cpqPro;  
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.SEQ__c='TestABC';      
        cpqPro1.Sale_Type__c = 'BUNDLE';   
        cpqPro1.Product_Record_Id__c = prod2.id;
        
        cpqPro1.Opportunity_Record_ID__c =o2.id;
        cpqPro1.Bundle_Kit_ID__c ='D-1009NV-093-00-INS';    
        insert cpqPro1;
        
        cpqPro2=new CPQ_Opportunity_Products__c();
        cpqPro2.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro2.SEQ__c='TestABC';      
        cpqPro2.Sale_Type__c = 'BUNDLE';  
        //cpqPro2.SKU__c = 'D-INSTALL-UNIT'; 
        cpqPro2.Product_Record_Id__c = prod3.id;
        cpqPro2.Opportunity_Record_ID__c =o2.id;
        cpqPro2.Bundle_Kit_ID__c ='D-INSTALL-UNIT';    
        insert cpqPro2;
        
        loc=new Location__c();
        loc.OpportunityId__c=o.Id;
        loc.Garage_Address1__c='PO';
        loc.Garage_City__c='kdkdkd';
        loc.Garage_State__c='GA';
        loc.Garage_Zip__c='9829q9q';
        loc.Phone__c='020222';
        loc.ContactName__c='C Name';    
        insert loc;
        
       
        loc1=new Location__c();
        loc1.Garage_Address1__c = 'PO BOX';
        loc1.OpportunityId__c=o1.Id;   
        insert loc1;
        
        
        op=new Order_Product__c();
        op.Order_Details__c=Ord2.Id;
        op.Location__c=loc.Id;
        op.Quantity__c=100;
        op.Sales_Price__c=43892;
        insert op;
        
        op=new Order_Product__c();
        op.Order_Details__c=Ord.Id;
        op.Location__c=loc1.Id;
        op.Quantity__c=100;
        op.Sales_Price__c=4392;
        insert op;   
        

        op=new Order_Product__c();
        op.Order_Details__c=Ord4.Id;
        op.Product_Name__c ='D-5500NV-044-36-INS';
        op.Product_Code__c='D-5500NV-044-36-INS';
        op.Location__c=loc1.Id;
        op.Quantity__c=100;
        op.Sales_Price__c=4392;
        insert op;  
                
       
        
        oli=new Order_Line_Items__c();
        oli.Orders__c=Ord.Id;
        oli.Order_Product__c=prod2.Id;
       // oli.Order_Product__c='5500N3AS GPS Diagnostics';
        insert oli;
        
        oli=new Order_Line_Items__c();
        oli.Orders__c=Ord4.Id;
        oli.Order_Product__c=prod2.Id;
       // oli.Order_Product__c='5500N3AS GPS Diagnostics';
        insert oli;
                
                
        olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c = '11111', Location__c = Loc.Id, isSubmitted__c = true);        
        insert olid1;
        
        oLoc=new OrderLocation__c();
        oLoc.Location__c=loc1.Id;
        oLoc.Orders__c=Ord2.Id;
        insert oLoc;
        
        oLoc1=new OrderLocation__c();
        oLoc1.Location__c=loc.Id;
        oLoc1.Orders__c=Ord.Id;
        insert oLoc1;
        
        oLoc2=new OrderLocation__c();
        oLoc2.Location__c=loc1.Id;
        oLoc2.Orders__c=Ord4.Id;
        insert oLoc2;

        Order_Promo_Codes__c  opc = Order_Promo_Codes__c.getInstance('BU-EXCHANG');
        
}

    static testMethod void OrderHelperTestMethod1(){
        OrderHelper.submitOrder(Ord2.Id);
        OrderHelper.cancelOrder(Ord2.Id);
        Test.startTest();
        a.Inactive_Account__c = true;
        update a;
        
        OrderHelper.submitOrder(Ord2.Id);
        
        loc.Garage_Address1__c='';
        update loc;
        
        OrderHelper.submitOrder(Ord3.Id);
        
         
              OrderHelper.submitOrder(Ord2.Id);
        Test.StopTest();
    }
    
    static testMethod void OrderHelperTestMethod2(){
    
        loc1.Garage_Address1__c = 'PO BOX';
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        loc1.Garage_Address1__c=null;
        OrderHelper.submitOrder(Ord.Id);      
        
       loc1.Garage_Address1__c='XXXX';
        loc1.ContactName__c='CCC';
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Phone__c=null;
        loc1.Garage_Zip__c=null;
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c=null;
        loc1.Garage_Zip__c='91303';
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c='73637383';
        loc1.Garage_Zip__c='91303';
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c=null;
        loc1.Garage_Zip__c=null;
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c='9388393';
        loc1.Garage_Zip__c='91030';
        loc1.ContactName__c=null;
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        Test.startTest();
         Ord.Customer_P_O__c=null;
            update Ord;
              OrderHelper.submitOrder(Ord.Id);
              
        Ord.Order_Types__c='STDORD';
        update Ord;
        OrderHelper.submitOrder(Ord.Id);
        Ord.Order_Types__c='DEMO';
        Ord.Promo_Code__c='32321';
        Ord.Shipping_Methods__c ='FREE SHIPPING';
        update Ord;
        OrderHelper.submitOrder(Ord.Id);
         
        a.Inactive_Account__c = true;
        a.GP_Account_Hold__c = true;
        a.PO_Required__c = true;
        update a;
        OrderHelper.submitOrder(Ord.Id);
        
        a.PO_Required__c = false;
        update a;
        Ord.Customer_P_O__c='8783874';
        update ord;
        OrderHelper.submitOrder(Ord.Id);
        
        Test.StopTest();
        
        
    }
    
    static TestMethod void testMethodhelper3(){
               
         
         Test.startTest();
         loc1.Garage_Address1__c='XXXX';
         loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c='9388393';
        loc1.Garage_Zip__c='91030';
        loc1.ContactName__c='testing';
         update loc1;
         ord.Order_Types__c = 'BUNDLE';
         ord.Promo_Code__c = [select Id, Promo_Code__c from Order_Promo_Codes__c where Order_Type__c = 'BUNDLE'].Promo_Code__c;
         update ord;
         a.PO_Required__c = false;
         update a;
         oLoc1.EO_Status__c = 'Submitted';
       oLoc1.Order_Activity_Status__c = 'Submitted';
       update oLoc1;

         oLoc.EO_Status__c = 'Submitted';
       oLoc.Order_Activity_Status__c = 'Submitted';
       OrderHelper.submitOrder(Ord.Id);
       update oLoc;
         Test.StopTest();
    }
    
    static TestMethod void testMethodhelper4(){
        
        a.Inactive_Account__c = true;
        a.GP_Account_Hold__c = true;
        a.PO_Required__c = true;
        update a;
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c=null;
        loc1.Garage_Zip__c=null;
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        loc1.Garage_Address1__c='XXXX';        
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c='9388393';
        loc1.Garage_Zip__c='91030';
        loc1.ContactName__c=null;
        update loc1;
        OrderHelper.submitOrder(Ord.Id);
        
        Test.startTest();
         Ord.Customer_P_O__c=null;
            update Ord;
              OrderHelper.submitOrder(Ord.Id);
              
        Ord.Order_Types__c='STDORD';
        update Ord;
        OrderHelper.submitOrder(Ord.Id);
        Ord.Order_Types__c='DEMO';
        Ord.Promo_Code__c='32321';
        Ord.Shipping_Methods__c ='FREE SHIPPING';
        update Ord;
         OrderHelper.submitOrder(Ord.Id);
        Test.StopTest();
       
         
    }
    
    static TestMethod void testMethodhelper5(){
               
         
         Test.startTest();
         loc1.Garage_Address1__c='XXXX';
         loc1.Garage_city__c='City';
        loc1.Garage_State__c='GA';
        loc1.Phone__c='9388393';
        loc1.Garage_Zip__c='91030';
        loc1.ContactName__c='testing';
         update loc1;
         ord.Order_Types__c = 'STDORD';
         ord.Promo_Code__c = o.Discount_Code__c;
         update ord;
         a.PO_Required__c = false;
         update a;
         oLoc1.EO_Status__c = 'Submitted';
       oLoc1.Order_Activity_Status__c = 'Submitted';
       update oLoc1;

         oLoc.EO_Status__c = 'Submitted';
       oLoc.Order_Activity_Status__c = 'Submitted';
       OrderHelper.submitOrder(Ord.Id);
       update oLoc;
         Test.StopTest();
    }
    
    static TestMethod void testMethodhelper6(){
               
         loc1.Garage_Address1__c = '123 post';
                
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Phone__c='73637383';
        loc1.Garage_Zip__c='91303';
        loc1.Garage_State__c='GA';
        update loc1;
        //OrderHelper.submitOrder(Ord4.Id);
        
        
        
        
        Test.startTest();
         Ord.Customer_P_O__c=null;
            
              //OrderHelper.submitOrder(Ord4.Id);
              
        Ord.Order_Types__c='STDORD';
        update Ord;
        //OrderHelper.submitOrder(Ord4.Id);
        Ord.Order_Types__c='DEMO';
        Ord.Promo_Code__c='32321';
        Ord.Shipping_Methods__c ='FREE SHIPPING';
        update Ord;
        //OrderHelper.submitOrder(Ord4.Id);
        a.Inactive_Account__c = false;
        a.GP_Account_Hold__c = false;
        a.PO_Required__c = false;
        a.AccountNumber = 'Bundle-S';
        update a;
        o2.PO_Required__c = false;
        //Ord.Customer_Number__c = 'Bundle-S';
        update o2;
        update Ord;
        update oLoc2;
        OrderHelper.submitOrder(Ord4.Id);
        
        Test.StopTest();
    }
    
    static TestMethod void testMethodhelper7(){
        loc1.Garage_Address1__c = '123 post';
                
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Phone__c='73637383';
        loc1.Garage_Zip__c='91303';
        loc1.Garage_State__c='GA';
        update loc1;
               
       Test.startTest();
        op.Order_Details__c=Ord4.Id;
        op.Product_Name__c ='D-5500NV-044-36-INS';
        op.Product_Code__c='D-5500NV-044-36-INS';
        op.Location__c=loc1.Id;
        op.Quantity__c= null;
        op.Sales_Price__c=4392;
        update op; 
        
        OrderHelper.submitOrder(Ord4.Id);
        
        Test.StopTest();
        }
        
         static TestMethod void testMethodhelper8(){
        loc1.Garage_Address1__c = '123 post';
                
        loc1.ContactName__c='CCC';
        loc1.Garage_city__c='City';
        loc1.Phone__c='73637383';
        loc1.Garage_Zip__c='91303';
        loc1.Garage_State__c='GA';
        update loc1;
               
       Test.startTest();
        op.Order_Details__c=Ord4.Id;
        op.Product_Name__c ='D-5500NV-044-36-INS';
        op.Product_Code__c='D-5500NV-044-36-INS';
        op.Location__c=loc1.Id;
        op.Quantity__c= -100;
        op.Sales_Price__c=4392;
        update op; 
        
        OrderHelper.submitOrder(Ord4.Id);
        
        Test.StopTest();
        }
}