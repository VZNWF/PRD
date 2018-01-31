@isTest
public class OrderLineItemsTriggerHandlerTesting{
public static testmethod void testing(){

OrderLineItemsTriggerHandler classins = new OrderLineItemsTriggerHandler(true,4);

       User user = new User();
        user.ProfileId = UserInfo.getProfileId();
        user.Username = 'test' + System.currentTimeMillis() + '@test.com';
        user.LastName = 'Test';
        user.Email = 'test@test.com';
        user.Alias = 'Test';
        user.CommunityNickname = 'UserWithRoleTest';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        insert user;
        
       OrderICuser__c OrderCS = new OrderICuser__c();
       OrderCS.Name = 'Test';
       OrderCS.Email__c = 'test@test.com';
       insert OrderCS;
      
      account acc = new account(name = 'Qlick');
      insert acc;

      Orders__c orderIns = new Orders__c(account__c = acc.Id);
     insert orderIns;

//insert custom setting
GP_Item_Number_Mapping__c csIns = new GP_Item_Number_Mapping__c();
csIns.Name = 'I-DEINSTALL001';
csIns.Item_Number__c = 'I-DEINSTALL001';
csIns.Item_Description__c = 'D-1000EV-000-36-INS Kit';
insert csIns;


Order_Line_Items__c orderLI = new Order_Line_Items__c (Orders__c = orderIns.id,GP_Item_Number__c = 'I-DEINSTALL001',GP_Item_Description__c = 'D-1000EV-000-36-INS Kit');
insert orderLI ;


Order_Line_Items__c orderLI2 = new Order_Line_Items__c (Orders__c = orderIns.id,GP_Item_Number__c = 'I-DEINSTAL',GP_Item_Description__c = 'D-1000EV-000-36-INS Kit');
insert orderLI2 ;

orderLI.GP_Item_Number__c = '1234';
orderLI.GP_Item_Description__c = 'Test';

update orderLI;

}


}