@isTest
public class Web2CaseControllerTest {

    public static testMethod void testMyController() {
        PageReference pageRef = Page.Web2Case;
        Test.setCurrentPage(pageRef);
        
        PageReference PR1;
      
        Web2CaseController controller = new Web2CaseController();

        controller = new Web2CaseController(); 
        
        controller.AcctName = 'TEST Account';
        controller.LastName = 'TEST LN';
        controller.FirstName = 'TEST FN';
        controller.FleetName = 'TEST FLEET';
        controller.UserId = 'TEST UID';
        controller.CustomerNbr = 'TEST CN';
        controller.Email = 'jgorti@gmail.com';
        controller.ConfirmEmail = 'jgorti@gmail.com';
        controller.Phone = '888-555-1212';
        controller.SellerKey = 'SELLER KEY';
            
        controller.Device  = TRUE;
        controller.Other  = 'OTHER';
        controller.WebSite = 'www.yahoo.com';
        controller.SerialNumber = 'SN0001';
        controller.VIN = 'VIN000000000111';
        controller.VehicleLabel = 'VEHICLE LABEL';
        controller.Subject  = 'SUBJECT';
        controller.CaseDesc  = 'CASE DESC';
        controller.WebSiteCB  = TRUE;
        controller.DeviceCB = TRUE;
        controller.OtherCB = TRUE;
        controller.recId  = null;
        controller.fileName   = null;
        controller.fileBody = null;
        controller.Category  = 'CATEGORY TEST';
        controller.Site1 = null;

       Account A1 = new Account();
       A1.Name = 'Web Account';
       
       insert A1;
        
       Contact C1 = new Contact();
       C1.LastName = controller.LastName;
       C1.FirstName = controller.FirstName;
       C1.AccountId = A1.id;
       //C1.Name = 'Web Account';
       insert C1;
        
       controller.SubmitWeb2Case();
       testRecord2();

    }
    
    private static testMethod void testRecord2()    {
       PageReference pageRef = Page.Web2Case;
        Test.setCurrentPage(pageRef);
        
        PageReference PR1;
      
        Web2CaseController controller = new Web2CaseController();

        controller = new Web2CaseController(); 
        
        controller.AcctName = 'TEST Account';
        controller.LastName = 'TEST LN';
        controller.FirstName = 'TEST FN';
        controller.FleetName = 'TEST FLEET';
        controller.UserId = 'TEST UID';
        controller.CustomerNbr = 'TEST CN';
        controller.Email = 'jgorti';
        controller.ConfirmEmail = 'jgorti@gmail.com';
        controller.Phone = '888-555-1212';
        controller.SellerKey = 'SELLER KEY';
            
        controller.Device  = TRUE;
        controller.Other  = 'OTHER';
        controller.WebSite = 'www.yahoo.com';
        controller.SerialNumber = 'SN0001';
        controller.VIN = 'VIN000000000111';
        controller.VehicleLabel = 'VEHICLE LABEL';
        controller.Subject  = 'SUBJECT';
        controller.CaseDesc  = 'CASE DESC';
        controller.WebSiteCB  = TRUE;
        controller.DeviceCB = TRUE;
        controller.OtherCB = TRUE;
        controller.recId  = null;
        controller.fileName   = null;
        controller.fileBody = null;
        controller.Category  = 'CATEGORY TEST';
        controller.Site1 = null;

       Account A1 = new Account();
       A1.Name = 'Web Account';
       
       insert A1;
        
       Contact C1 = new Contact();
       C1.LastName = controller.LastName;
       C1.FirstName = controller.FirstName;
       C1.AccountId = A1.id;
       //C1.Name = 'Web Account';
       insert C1;
        
       controller.SubmitWeb2Case();
    }

}