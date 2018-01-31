@isTest
private class ImportInstallerDataFromCSVControllerTest {

    private static testmethod void ImportInstallerDataFromCSVControllerTest() {
    
      UtilsTest.CreateInstallerSettings();  
      Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
      Account acc = UtilsTest.createAccount();
      acc.Name = 'Default Certified Installer Vendor';
      insert acc;   
      String blobCreator = 'exam_date,exam_length,exam_id,exam_name,pass_score,user_score,total_questions,right_answers,pass_result,lname,fname,email,company,phone,city,state,zip,session_number,user_id,question_1,answer_1,question_2,answer_2,question_3,answer_3,question_4,answer_4,question_5,answer_5,question_6,answer_6,question_7,answer_7,question_8,answer_8\n'
                        +   '4/21/2015 17:20,0 min,464,Verizon Networkfleet Installer Certification Basic,90,0.966666667,30,29,TRUE,Import1,Test,kevin.hall@wirelessusa.com,,,,,,1.43E+12,49805,Address,1621 Towne Drive,City,Columbia,State,MO,Zip Code (5 digits only),65201,Phone Number (Please use this format XXX-XXX-XXXX),5738142220,Parent Installation Company (Must match what was chosen on profile page),Verizon NetworkFleet Vwr,Child - Subcontracted Company (Optional,Wireless USA,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,8079\n'
                        +   '4/17/2015 14:44,5 min,464,Verizon Networkfleet Installer Certification Basic,90,0.933333333,30,28,TRUE,Import1,Test,eli@firstcomm.net,,,,,,1.43E+12,21675,Address,108 Commerce Park Dr,City,Thomasville,State,Georgia,Zip Code (5 digits only),31757,Phone Number (Please use this format XXX-XXX-XXXX),229-228-0610,Parent Installation Company (Must match what was chosen on profile page),USMSS,Child - Subcontracted Company (Optional,First Communications,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,6462\n'
                        +   '4/21/2015 10:48,9 min,464,Verizon Networkfleet Installer Certification Basic,90,0.933333333,30,28,TRUE,Import1,Test,gary.laforce@wirelessusa.com,,,,,,1.43E+12,14361,Address,1621 Towne Drive,City,Columbia,State,MISSOURI,Zip Code (5 digits only),65202,Phone Number (Please use this format XXX-XXX-XXXX),5738142220,Parent Installation Company (Must match what was chosen on profile page),Wireless USA,Child - Subcontracted Company (Optional,Wireless USA,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,6627\n';
       
    
        ImportInstallerDataFromCSVController impInst = new ImportInstallerDataFromCSVController();
        impInst.csvFileBody = blob.valueOf(blobCreator);
        
        impInst.importCSVFile();
        
    }
    
     private static testmethod void ImportInstallerDataFromCSVControllerNegativeTest() {
    
      UtilsTest.CreateInstallerSettings();  
      Test.setMock(WebServiceMock.class, new ETA_Resource_MockResponses());
      Account acc = UtilsTest.createAccount();
      acc.Name = 'Default Certified Installer Vendor';
      insert acc;   
      String blobCreator = 'exam_date,exam_length,exam_id,exam_name,pass_score,user_score,total_questions,right_answers,pass_result,lname,fname,email,company,phone,city,state,zip,session_number,user_id,question_1,answer_1,question_2,answer_2,question_3,answer_3,question_4,answer_4,question_5,answer_5,question_6,answer_6,question_7,answer_7,question_8,answer_8\n'
                        +   '4/21/2015 17:20,0 min,464,Verizon Networkfleet Installer Certification Basic,90,0.966666667,30,29,TRUE,Import1,Test,kevin.hall@wirelessusa.com,,,,,,1.43E+12,49805,Address,1621 Towne Drive,City,Columbia,State,MO,Zip Code (5 digits only),65201,Phone Number (Please use this format XXX-XXX-XXXX),5738142220,Parent Installation Company (Must match what was chosen on profile page),Verizon NetworkFleet Vwr,Child - Subcontracted Company (Optional,Wireless USA,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,8079\n'
                        +   '4/17/2015 14:44,5 min,464,Verizon Networkfleet Installer Certification Basic,90,0.933333333,30,28,TRUE,Import1,Test,eli@firstcomm.net,,,,,,1.43E+12,21675,Address,108 Commerce Park Dr,City,Thomasville,State,Georgia,Zip Code (5 digits only),31757,Phone Number (Please use this format XXX-XXX-XXXX),229-228-0610,Parent Installation Company (Must match what was chosen on profile page),USMSS,Child - Subcontracted Company (Optional,First Communications,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,6462\n'
                        +   '4/21/2015 10:48,9 min,464,Verizon Networkfleet Installer Certification Basic,90,0.933333333,30,28,TRUE,Import1,Test,gary.laforce@wirelessusa.com,,,,,,1.43E+12,14361,Address,1621 Towne Drive,City,Columbia,State,MISSOURI,Zip Code (5 digits only),65202,Phone Number (Please use this format XXX-XXX-XXXX),5738142220,Parent Installation Company (Must match what was chosen on profile page),Wireless USA,Child - Subcontracted Company (Optional,Wireless USA,Last 4 digits of your Social Security Number OR alternative 4 digit number given to NWF,6627\n';
       
    
        ImportInstallerDataFromCSVController impInst = new ImportInstallerDataFromCSVController();
        impInst.csvFileBody = blob.valueOf(blobCreator);
        
        //impInst.importCSVFile();
        
        List<ImportInstallerDataFromCSVController.InstallerData> instData = new List<ImportInstallerDataFromCSVController.InstallerData>();     
        
        impInst.getInstallersWithContactIdList(instData);
        
    }




}