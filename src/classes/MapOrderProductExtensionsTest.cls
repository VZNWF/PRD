/****************************************************************
Created: 20 Feb 2017
Author: Satish
Purpose : test class for the MapOrderProductExtensions
Modifications:
******************************************************************/
@isTest()
private class MapOrderProductExtensionsTest {
    public static CPQ_Opportunity_Products__c cpqPro;   
    public static CPQ_Opportunity_Products__c cpqPro1; 
    public static CPQ_SOMAST__c cpqsomast; 
	static testMethod void testloadOrderLocations() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        
        
        Test.startTest();
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
       ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        System.assert(addProdVar.avlProdLst.size() > 0);
       
        Test.stopTest();
    
        }
        
        static testMethod void testcpqloadOrderLocations() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        opp.HasCPQProducts__c = true;
        update opp;
        Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        CPQ_SOMAST__c cpqli= UtilsTest.createCPQ_SOMAST(opp);
        
        Product2 prod = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X200true', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='SOLUTION', ProductCode='H5200' );
        insert prod; 
        
        Product2 prod1 = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X200false', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='ALL OTHER', ProductCode = 'D-Install' );
        insert prod1; 
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = opp.Id, name = 'Test',primary__c = true);
        insert cpqsomast;

        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.Opportunity_Record_ID__c = opp.Id;
        cpqPro.SEQ__c='1.1';      
        cpqPro.Sale_Type__c = 'BUNDLE'; 
        cpqPro.CPQ_Product_Inserted__c = true;
        cpqPro.Product_Record_Id__c = prod.Id; 
        insert cpqPro;
        
        System.Debug('Product CATEGORY:'+cpqPro.Product_Category__c );
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.Opportunity_Record_ID__c=opp.Id;
        cpqPro1.SEQ__c='1.2';   
        cpqPro1.Product_Record_Id__c = prod1.Id; 
        cpqPro1.CPQ_Product_Inserted__c = true; 
        cpqPro1.Sale_Type__c = 'BUNDLE';   
        insert cpqPro1;

        Test.startTest();
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer', Customer__c = acc.Id);
        insert loc;
        OrderLocation__c ordloc = new OrderLocation__c(Location__c = loc.Id, Orders__c = ord.id);
        insert ordloc;
        Order_Product__c ordprod = new Order_Product__c(Location__c = loc.id, Order_Details__c = ord.id, OrderLocationMappings__c = ordloc.Id, Mismatch_Install__c= true, Product_Name__c = '5600 D type', Product_Code__c = 'D-Install-INS', Quantity__c = 2.0, Sales_Price__c = 450.0);
        insert ordprod;
       ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        System.assert(addProdVar.avlProdLst.size() > 0);
       
        Test.stopTest();
    
        }
    
    
		static testMethod void testAddProduct() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
       ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        Test.startTest();
        addProdVar.AddProduct();
        
        System.assert(addProdVar.ordList.size() > 0);
       
        Test.stopTest();
    
        }
        
        static testMethod void testcpqAddProduct() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        opp.HasCPQProducts__c = true;
        update opp;
        Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        CPQ_SOMAST__c cpqli= UtilsTest.createCPQ_SOMAST(opp);
        
        Product2 prod = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X200true', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='SOLUTION', ProductCode='H5200' );
        insert prod; 
        
        Product2 prod1 = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X200false', Family = 'Hardware', CPQ_PRODUCT_CATEGORY__c='ALL OTHER', ProductCode = 'D-Install' );
        insert prod1; 
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = opp.Id, name = 'Test',primary__c = true);
        insert cpqsomast;

        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.Opportunity_Record_ID__c = opp.Id;
        cpqPro.SEQ__c='1.1';      
        cpqPro.Sale_Type__c = 'BUNDLE'; 
        cpqPro.CPQ_Product_Inserted__c = true;
        cpqPro.Product_Record_Id__c = prod.Id; 
        insert cpqPro;
        
        System.Debug('Product CATEGORY:'+cpqPro.Product_Category__c );
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.Opportunity_Record_ID__c=opp.Id;
        cpqPro1.SEQ__c='1.2';   
        cpqPro1.Product_Record_Id__c = prod1.Id; 
        cpqPro1.CPQ_Product_Inserted__c = true; 
        cpqPro1.Sale_Type__c = 'BUNDLE';   
        insert cpqPro1;

        Test.startTest();
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer', Customer__c = acc.Id);
        insert loc;
        OrderLocation__c ordloc = new OrderLocation__c(Location__c = loc.Id, Orders__c = ord.id);
        insert ordloc;
        Order_Product__c ordprod = new Order_Product__c(Location__c = loc.id, Order_Details__c = ord.id, OrderLocationMappings__c = ordloc.Id, Mismatch_Install__c= true, Product_Name__c = '5600 D type', Product_Code__c = 'D-Install-INS', Quantity__c = 2.0, Sales_Price__c = 450.0);
        insert ordprod;
       ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
         addProdVar.AddProduct();
         addProdVar.saveRecords();        
        System.assert(addProdVar.ordList.size() > 0);
       
        Test.stopTest();
    
        }
    
        
		static testMethod void testsaveMappings() {
        
                Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
       ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
       ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        Test.startTest();
        addProdVar.saveMappings();
        
       
        Test.stopTest();    
        }
        
		static testMethod void testsaveRecords() {
        
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        Location__c loc = UtilsTest.createLocation(acc);
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        Test.startTest();
         addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = 'test';
         addProdVar.saveRecords();
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         addProdVar.saveRecords();
         addProdVar.saveMappings();
         addProdVar.quickSave();
         addProdVar.cancel();
         addProdVar.loadOrderLocations();
        Test.stopTest();
    
        }
        
        static testMethod void testsaveCpqRecords() {
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        
        Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        CPQ_SOMAST__c cpqli= UtilsTest.createCPQ_SOMAST(opp);
        Location__c loc = UtilsTest.createLocation(acc);
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        Test.startTest();
         addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = 'test';
         addProdVar.saveRecords();
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         addProdVar.saveRecords();
         addProdVar.saveMappings();
         addProdVar.quickSave();
         addProdVar.cancel();
         addProdVar.loadOrderLocations();
        Test.stopTest();
    
    
        }
        
        static testMethod void testdelsaverecordswithnoprod() {
        
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        Location__c loc = UtilsTest.createLocation(acc);
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        Test.startTest();
        try{
         addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = null;
         addProdVar.saveRecords();
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         addProdVar.saveRecords();
         addProdVar.deleteOrderProductRow();
         } catch(Exception e)
                {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please Select the') ? true : false;
                }
        Test.stopTest();
    
        } 
        
        static testMethod void testdelerecordswithnoprod() {
        
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        Location__c loc = UtilsTest.createLocation(acc);
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.CurrentPage().getParameters().put('rowid','0');
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        Test.startTest();
        try{
         addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = null;
         addProdVar.saveRecords();
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         addProdVar.deleteRow();
         addProdVar.deleteOrderProductRow();
         } catch(Exception e)
                {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please Select the') ? true : false;
                }
        Test.stopTest();
    
        } 
        
        static testMethod void testdelerecordswithcpqprod() {
        
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        //OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        //Location__c loc = UtilsTest.createLocation(acc);
        
        opp.HasCPQProducts__c = true;
        update opp;
        Toggle_Switch__c trgSw = new Toggle_Switch__c();
        trgSw.name= 'CPQ_SOMAST__c';
        trgSw.isTriggerDisabled__c = false;
        insert trgSw;
        CPQ_SOMAST__c cpqli= UtilsTest.createCPQ_SOMAST(opp);
        
        Product2 prod = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X200', Family = 'Harness', CPQ_PRODUCT_CATEGORY__c='HARNESS', ProductCode='H5200' );
        insert prod; 
        
        Product2 prod1 = new Product2(Name = '*CPQ ONLY* DO NOT USE -Laptop X400', Family = 'Install', CPQ_PRODUCT_CATEGORY__c='INSTALL',ProductCode = 'D-INSTALL-UNI');
        insert prod1; 
        
        cpqsomast = new CPQ_SOMAST__c(Opportunity__c = opp.Id, name = 'Test',primary__c = true);
        insert cpqsomast;

        cpqPro=new CPQ_Opportunity_Products__c();
        cpqPro.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro.Opportunity_Record_ID__c = opp.Id;
        cpqPro.SEQ__c='1.1';      
        cpqPro.Sale_Type__c = 'BUNDLE'; 
        //cpqPro.CPQ_Product_Category__c = 'HARNESS';
        cpqPro.BUN_Qty__c = 2;
        cpqPro.Bundle_Kit_Id__c = 'D-5200-098-36-INS';
        cpqPro.CPQ_Product_Inserted__c = true;
        cpqPro.Product_Record_Id__c = prod.Id; 
        insert cpqPro;
        
        System.Debug('Product CATEGORY:'+cpqPro.Product_Category__c );
        
        cpqPro1=new CPQ_Opportunity_Products__c();
        cpqPro1.CPQ_Quote_Record_ID__c=cpqsomast.Id;
        cpqPro1.Opportunity_Record_ID__c=opp.Id;
        cpqPro1.SEQ__c='1.2';  
        //cpqPro1.CPQ_Product_Category__c = 'INSTALL';
        //cpqPro.Bundle_Kit_Id__c = 'D-INSTALL-UNIT'; 
        cpqPro1.Product_Record_Id__c = prod1.Id; 
        
        cpqPro1.CPQ_Product_Inserted__c = true; 
        cpqPro1.Sale_Type__c = 'BUNDLE';   
        insert cpqPro1;

        Test.startTest();
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        Location__c loc = new Location__c(ContactName__c = 'Sam killmer', Customer__c = acc.Id);
        insert loc;
        OrderLocation__c ordloc = new OrderLocation__c(Location__c = loc.Id, Orders__c = ord.id);
        insert ordloc;
        Order_Product__c ordprod = new Order_Product__c(Location__c = loc.Id, Order_Details__c = ord.id, OrderLocationMappings__c = ordloc.Id, Mismatch_Install__c= true, Product_Name__c = '5600 D type', Product_Code__c = 'D-Install-INS', Quantity__c = 2.0, Sales_Price__c = 450.0);
        insert ordprod;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.CurrentPage().getParameters().put('rowid','2');
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        
        try{
         addProdVar.ordList.add(new MapOrderProductExtensions.OrderHelper(new Order_Product__c(Order_Details__c = ord.Id), addProdVar.locOptions, addProdVar.prodOptions, 1));
         //addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = '*CPQ ONLY* DO NOT USE -Laptop X200';
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         system.debug('ordList::'+addProdVar.ordList.size()+'+++List---'+addProdVar.ordList);
		 addProdVar.ordList.clear();
		 MapOrderProductExtensions.OrderHelper obj = new MapOrderProductExtensions.OrderHelper(new Order_Product__c(Order_Details__c = ord.Id), addProdVar.locOptions, addProdVar.prodOptions, 1);
		 obj.ord.Quantity__c =1;
		 obj.ord.Product_Name__c ='*CPQ ONLY* DO NOT USE -';
		 obj.ord.OrderLocationMappings__c =ordloc.id;
		 addProdVar.ordList.add(obj );		 
         addProdVar.saveRecords();
         //addProdVar.deleteOrderProductRow();
                  
         //addProdVar.saveRecords();
		 addProdVar.ordList[0].ord = ordprod;
		 addProdVar.ordList[0].locationNumber = 1;		 
		 addProdVar.ordListToDisp.add(addProdVar.ordList[0]);
         addProdVar.deleteOrderProductRow();
         } catch(Exception e)
                {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please Select the') ? true : false;
                }
        Test.stopTest();
    
        } 
        
        static testMethod void testdelerecords1(){
       
        
        Account acc = UtilsTest.createAccountforOrder();
        Opportunity opp = UtilsTest.createOpportunity(acc);
        OpportunityLineItem oli = UtilsTest.ddpProducts(opp);
        Location__c loc = UtilsTest.createLocation(acc);
        
       //create order  record
        Orders__c ord = new Orders__c(Contact_Person__c = 'Sam killmer', Account__c = acc.Id, Opportunity__c = opp.Id);
        insert ord;
        ApexPages.currentPage().getParameters().put('OrdId', ord.Id);
        ApexPages.currentPage().getParameters().put('rowid', '0');
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        MapOrderProductExtensions addProdVar = new MapOrderProductExtensions(sc);
        
        
        Test.startTest();
        try{
         addProdVar.saveRecords();
         addProdVar.AddProduct();
         addProdVar.ordList[0].ord.Product_Name__c = null;
         addProdVar.saveRecords();
         addProdVar.ordList[0].ord.Quantity__c = 1;
         addProdVar.ordList[0].ord.Location__c = loc.id;
         addProdVar.deleteRow();
         } catch(Exception e)
                {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Please Select the') ? true : false;
                }
        Test.stopTest();
    
        } 
        
        
       
        
       
     
     }