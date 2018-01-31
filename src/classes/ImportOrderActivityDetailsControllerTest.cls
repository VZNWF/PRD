@isTest
public class ImportOrderActivityDetailsControllerTest {
    private static testmethod void TestMethod1() {
    
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(Account__c = Acc.Id  );
        insert Orders;
        Orders__c ord1 = [select id,name,Account__c  from Orders__c where ID =:Orders.ID];
        system.debug('ordername is' + ord1.name );  
      String blobCreator = ord1.name +'\n'
                          + 'kweatherspoondraco.com,Weatherspoon,leanderDr,ab,Myrtle Beach,USA,SC,123,Kelly Weatherspoon, ,abc,100, , \n'
                          + 'Testdata1@org.com,Kelly Testdata1,1-843-283-1234,3200 Oleander Dr,Abcd Inn Express,Myrtle Beach,USA,SC,123456,,1-828-612-6789,abc,100,Testdata1@draco.com, \n';
        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        impOrderActivity.csvFileBody = blob.valueOf(blobCreator);
        impOrderActivity.importfile();  
        ImportOrderActivityDetailsController.OLID_Data OBJ = NEW ImportOrderActivityDetailsController.OLID_DATA();
    }
     private static testmethod void TestMethod2() {
    
       account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(Account__c = Acc.Id );
        insert Orders;        
        try{   
        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        //impOrderActivity.csvFileBody = blob.valueOf();
        impOrderActivity.importfile(); 
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('Choose your')); 
        }
     }
    
    private static testmethod void TestMethod3() {
    
      account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders; 
        Orders__c ord1 = [select id,name,Account__c  from Orders__c where ID =:Orders.ID];
        system.debug('ordername is' + ord1.name );
        try{ 
       String blobCreator = 'abc \n'
                 //+ 'ALTERNATEEMAIL,ALTENATENAME,ALTERNATEPHONE,GARAGEDADDRESS1,GARAGEDADDRESS2, GARAGECITY,GARAGECOUNTRY,GARAGESTATE,GARAGEZIP,NAME,PHONE,CONTACTNAME,PONUMBER,EMAIL,SHIPCOMPANY\n'
                   + 'kweatherspoon@klingspor.com,Kelly Weatherspoon,1-843-283-5608,3100 Oleander Dr,Holiday Inn Express,Myrtle Beach,USA,SC,123,Kelly Weatherspoon,1-828-612-5869,abc,100,Test1@draco.com,shipcompany\n'
                   + 'Testdata1@org.com,Kelly Testdata1,1-843-283-1234,3200 Oleander Dr,Abcd Inn Express,Myrtle Beach,USA,SC,123456,,1-828-612-6789,abc,100,Testdata1@draco.com, \n'
                        ;
            
        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        impOrderActivity.csvFileBody = blob.valueOf(blobCreator);
        impOrderActivity.importfile(); 
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('An error has occured while')); 
        }
     }
    
        private static testmethod void TestMethod4() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
    
      account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        Orders__c ord1 = [select id,name,Account__c  from Orders__c where ID =:Orders.ID];
        system.debug('ordername is' + ord1.name );
            try{ 
      String blobCreator = '1111 \n' ;

        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        impOrderActivity.csvFileBody = blob.valueOf(blobCreator);
        impOrderActivity.importfile(); 
            }catch (Exception e) {
            System.Assert(e.getMessage().contains('An error has occured while')); 
        }
      }
    
            private static testmethod void TestMethod5() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
    
      account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        Orders__c ord1 = [select id,name,Account__c  from Orders__c where ID =:Orders.ID];
        system.debug('ordername is' + ord1.name );
            try{ 
      String blobCreator = ' ' ;

        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        impOrderActivity.csvFileBody = blob.valueOf(blobCreator);
        impOrderActivity.dosubmit(); 
            
            }catch (Exception e) {
            System.Assert(e.getMessage().contains('An error has occured while')); 
        }
      }
      
        private static testmethod void TestMethod6() {
    
      account Acc = UtilsTest.createAccountforOrder();
         
      
         String blobCreator = 'O000018691\n'
                             + 'kweatherspoon@draco.com,Kelly Weatherspoon,3100 Oleander Dr,Holiday Inn Express,Myrtle Beach,USA,SC,123,Kelly Weatherspoon,1-828-612-5869,abc,100,, ';
                        

        ImportOrderActivityDetailsController impOrderActivity = new ImportOrderActivityDetailsController();
        ImpOrderActivity.csvFileBody = blob.valueOf(blobCreator);
        ImpOrderActivity.importfile();    
        ImportOrderActivityDetailsController.OLID_Data OBJ = NEW ImportOrderActivityDetailsController.OLID_DATA();
    }
    
    
    
   
   
    
   

}