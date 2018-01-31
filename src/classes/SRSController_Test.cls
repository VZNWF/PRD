@isTest
private class SRSController_Test{
    
    static testMethod void testMethod1(){
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
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        Orders__c order = new Orders__c();
        order.GP_ERP_Order_ID__c = '4567891230';
        order.Account__c = acc.Id;
        
        insert order;
        
        attachment att = new attachment();
        att.ParentId = order.id;
        att.name = 'Test Attachment';
        Blob b = Blob.valueOf('Test Data');
        att.Body = b;
        insert att;
        
        //Insert Order Line Items
        List<Order_Line_Items__c> oliInsertList = new List<Order_Line_Items__c>();        
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00,  Devices_Installed__c = null, Service_Type__c = 'Install',TypeOfDevice__c = 'PrimaryDevice');
        oliInsertList.add(lineItem);
        
        Order_Line_Items__c lineItem1 = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00, Devices_Installed__c = 'Driver ID', Service_Type__c='Install Add-On Only',TypeOfDevice__c = 'Add-On Only');
        oliInsertList.add(lineItem1);
        insert oliInsertList;

        //Insert Location
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        
        //Insert Order Line Item Details
        List<Order_Line_Item_Details__c> olidInsertList = new List<Order_Line_Item_Details__c>();
        Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'civic',
        VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        olidInsertList.add(olid);
        
        Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'Accord',
        VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        olidInsertList.add(olid1);
        
        Order_Line_Item_Details__c olid2 = new Order_Line_Item_Details__c(isSubmitted__c = true,GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Toyota', Model__c = 'camry',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',
        Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=false,Addon_Bluetooth_module__c=false,Addon_Driver_ID__c=true,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        olidInsertList.add(olid2);
        insert olidInsertList;
        
        //Insert Harness Guide List
        List<Harness_Guide__c> harnessList = new List<Harness_Guide__c>();
        
        Harness_Guide__c hg = new Harness_Guide__c(Year_From__c='1985',Year_To__c='2017',Harness_Type__c='Universal',Make__c='Honda',Model__c='Civic');
        harnessList.add(hg);
        
        Harness_Guide__c hg1 = new Harness_Guide__c(Year_From__c='1985',Year_To__c='2017',Harness_Type__c='Universal',Make__c='Honda',Model__c='Accord');
        harnessList.add(hg1);
        
        insert harnessList;
        
        List<Document> documentList = new List<Document>();

        //Document d = new Document();
        //d.Name = 'Help';
        //d.FolderId='00l330000012fEXAAY';
        //d.FolderId='00l0b000001pUmEAAU';

        
        //Document d1 = new Document();
        //d1.Name = 'Vehicle_Template_SRS';
        //d1.FolderId='00l330000012fEXAAY';
        //d1.FolderId='00l0b000001pUmEAAU';
        
        //Document d2 = new Document();
        //d2.Name = 'Video';
         //d2.FolderId='00l330000012fEXAAY';
        //d2.FolderId='00l0b000001pUmEAAU';

        //documentList.add(d);
        //documentList.add(d1);
        //documentList.add(d2);
        
        //insert documentList;
        
        PageReference srsPage = Page.SRS;
        Test.setCurrentPage(srsPage);
        ApexPages.currentPage().getParameters().put('id', order.Id);

        SRSController srs = new srsController();
        //VehicleWrapper  vw = new VehicleWrapper();      
        srs.documentList = documentList;
        srs.selectedLocationVeh = loc.Id;             
        srs.fetchVehicles();
        srs.getCountries();
        srs.getStates();
        srs.getServiceType();
        srs.getDeviceType();
        
        srs.getColors();
        srs.getReturnTO();
        srs.getLicenseStates();
        srs.getFuelTypes();        
        srs.getAccountLocations();
        srs.locationWrapper.locationName = 'Sample Location'; 
        srs.locationWrapper.address1 = '#110';
        srs.locationWrapper.address2 = 'abc street';
        srs.locationWrapper.city = 'sample city';
        srs.locationWrapper.country = 'USA';
        srs.locationWrapper.state = 'CA';              
        srs.locationWrapper.zip = '12345';
        srs.locationWrapper.contactName = 'abc';
        srs.locationWrapper.email = 'test@test.com';
        srs.locationWrapper.phone = '1234567890';
        srs.locationWrapper.alternateContactName = 'abc';
        srs.locationWrapper.alternateEmail = 'test@test.com';
        srs.locationWrapper.alternatePhone = '1234567890';
        srs.savedLocation();
         srs.addlocationWrapper.locationName='Sample Location1';
        srs.addlocationWrapper.address1= '#1101';
        srs.addlocationWrapper.address2= 'abc street1';
        srs.addlocationWrapper.country= 'USA';
        srs.addlocationWrapper.city= 'sample city1';
        srs.addlocationWrapper.state= 'CA';
        srs.addlocationWrapper.zip= '32145';
        srs.addlocationWrapper.contactName= 'TestName';
        srs.addlocationWrapper.email= 'a@a.com';
        srs.addlocationWrapper.phone= '9874563214';
        srs.addlocationWrapper.phoneext= '3214';
        srs.addlocationWrapper.alternateContactName= 'TestName1';
        srs.addlocationWrapper.alternateEmail= 'test@test1.com';
        srs.addlocationWrapper.alternatePhone= '6932587412';
        srs.addlocationWrapper.alternatePhoneext= '3214';
        srs.disableEditofLocation=true;
        srs.disableEditofLocation=false;
       
        //srs.deleteSelectedVehicles();
        srs.vehicleWrapper.serviceType = 'Install';
        srs.vehicleWrapper.location = String.valueOf(loc.Id);
        srs.vehicleWrapper.VINNumber = null;
        srs.vehicleWrapper.year = '2017';
        srs.vehicleWrapper.make = 'Honda';
        srs.vehicleWrapper.model = 'Civic';
        srs.vehicleWrapper.noVINnumber = true;
        srs.vehicleWrapper.vehicleLabel = 'Label';
        srs.vehicleWrapper.licensePlate = 'licensePlate';
        srs.vehicleWrapper.licenseState = 'CA';
        srs.vehicleWrapper.deviceType = '6100 (ExpressFleet)';
        srs.vehicleWrapper.harnessType = 'Universal';
        srs.vehicleWrapper.fuelType = 'Gasoline'; 
        srs.vehicleWrapper.notAVehicle = true;
        srs.vehicleWrapper.selectedAccessories = new List<SelectOption>{new SelectOption('Driver ID','Driver ID')};
        srs.editVehicle= olid2.id;
        test.startTest();
        srs.getDeviceType();
        srs.getServiceType();
        srs.getHarnessTypes();
        srs.getModel();
        srs.getMake();
        srs.getYear();
        srs.fetchNewLocationVehicles();
        
        //Populate the SelectedVehicleWrapperList
        List<Order_Line_Item_Details__c> olidData = [Select Id,Name,SF_Orders__c,Order_Line_Items__c,location__c,location__r.Name,Installation_Type__c,Vehicle_Label__c,VIN__c,Year__c,Make__c,Model__c,Old_Vin__c,License_Plate__c,
                                                         License_State__c,Color__c,Fuel_Type__c,Device_Type__c,Device_Serial_Number__c,Device_Serial_Number_Old__c ,Sensor1__c,Sensor2__c,Sensor3__c,Sensor4__c,Sensor5__c,Sensor6__c,
                                                         Vehicle_Harness_Category__c,Device_Returned__c,Activity_Notes__c,isSubmitted__c,GP_ERP_Order_ID__c,Addon_Alternate_Power_Adapter__c,Addon_Bluetooth_module__c,Addon_Buzzer__c,
                                                         Addon_Driver_ID__c,Addon_Garmin_CONNECT__c,Addon_Magnet_Mounts__c,Addon_NMEA_Cable__c,Addon_PEM__c,Addon_Pelican_Box__c,Addon_Quake_Satellite_Modem__c,Addon_Window_Mount_GPS_Antenna__c,No_VIN_Flag__c  
                                                         from Order_Line_Item_Details__c where Id=: olid.Id];
        srs.selectedVehicleWrapperList = srs.generateVehicleWrapperData(olidData);
        srs.selectedVehicleWrapperList[0].isVehSelected = true;
        srs.selectedVehicleWrapperList[0].selectedVehicle.Not_A_Vehicle__c= true;
        srs.duplicateSelectedVehicles();
        srs.deleteSelectedVehicles();
        
        srs.redirectCustomerSRS();
        srs.savedVehicle();
        srs.getDisplayMessage();
        srs.getIsSensorCheckboxDisabled();
        srs.fetchAvailableAccessories(); 
        srsController.getAccount(Order.id);
        srs.editVehicleRecord();
        srs.preferredDateLocationsData();
        
        //srs.updateBalanceQuantity();
        //srs.childAccountName = 'Sample Account';
        srs.saveChildAccount();
        srs.importCSVFile();
        // srs.getVINDataMethod();
        srs.getHarnessTypes();
        srs.getModel();
        srs.getMake();
        srs.getYear();
        srs.setLocationState();
        srs.locationSelected();
        srs.clearVehForm();
        string str = '11/6/2014 12:00 AM';
        //string str = 'Testing';
        //srs.parsedate(str);
        //DateTime dt = DateTime.parse('11/6/2014 12:00 AM');
        // srs.parsedate(dt);
        
        // srs.deleteSelectedVehicles();
        srs.listValue = '11/6/2014 12:00 AM;11/7/2014 12:00 PM;'+loc.Id+'>>';
        srs.submitAllVehicles();
        srs.submittedFirst();
        srs.submittedLast();
        srs.submittedPrevious();
        srs.submittedNext();
        
        srs.newFirst();
        srs.newLast();
        srs.newPrevious();
        srs.newNext();
        srs.VINNumber = '2LMDJ6JK3CBL14309';
        //srs.getVINDataMethod();
        srs.searchVariableSubmittedTable = 'Honda';
        srs.searchSubmittedTableFn();
        srs.searchVariableNewTable = 'Honda';
		srs.searchNewTableFn();
		srs.vehicleWrapper.location = loc.Id;
		srs.getAllvalues();
		srs.reloadOnCancel();
		srs.clearForm();
        test.stopTest();
        
        srs.updateFlagValues();
        
        PageReference pg = Page.Import_OrderLineItemDetailsSRS;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', order.Id);
         //  srs.getAllvalues();
         //srs.vehicleWrapper.location = loc.id;
        //srs.getAllvalues();
    }  
    static  testmethod void testMethodrec1(){
        Vin_Data__c vdata= new Vin_Data__c();
        vdata.Name='test';
        vdata.ClientId__c = '3950';
        vdata.AuthCode__c =  '73c63a784d9bf7a8b623f2c013fc4d86';
        vdata.EndPoint__c='Test';
        vdata.Method__c='Test';
        insert vdata;
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
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        Orders__c order = new Orders__c();
        order.GP_ERP_Order_ID__c = '4567891230';
        order.Account__c = acc.Id;
        insert order;
        attachment att = new attachment();
        att.ParentId = order.id;
        att.name = 'Test Attachment';
        Blob b = Blob.valueOf('Test Data');
        att.Body = b;
        insert att;
        /*
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00, Service_Type__c = 'Install');
        insert lineItem;
        
        Order_Line_Items__c lineItem1 = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00, Service_Type__c='Install Add-On Only');
        insert lineItem1;
        */
        
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00, BalanceQuantity__c = 2.00, Service_Type__c = 'Install',TypeOfDevice__c = 'PrimaryDevice');
        insert lineItem;
        
        Order_Line_Items__c lineItem1 = new Order_Line_Items__c(Orders__c=order.id,GP_Quantity__c =5.00, BalanceQuantity__c = 2.00, Service_Type__c='Install Add-On Only',TypeOfDevice__c = 'Add-On Only');
        insert lineItem1;
        
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        
        Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'civic',
        VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        insert olid;
        
        Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'Accord',
        VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        insert olid1;
        
        Order_Line_Item_Details__c olid2 = new Order_Line_Item_Details__c(isSubmitted__c = true,GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = order.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Toyota', Model__c = 'camry',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,
        Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        insert olid2;
        
        List<Harness_Guide__c> harnessList = new List<Harness_Guide__c>();
        
        Harness_Guide__c hg = new Harness_Guide__c(Year_From__c='1985',Year_To__c='2017',Harness_Type__c='Universal',Make__c='Honda',Model__c='Civic');
        harnessList.add(hg);
        
        Harness_Guide__c hg1 = new Harness_Guide__c(Year_From__c='1985',Year_To__c='2017',Harness_Type__c='Universal',Make__c='Honda',Model__c='Accord');
        harnessList.add(hg1);
        
        insert harnessList;
        VehicleWrapper  vw = new VehicleWrapper();
        PageReference srsPage = Page.SRS;
        Test.setCurrentPage(srsPage);
        ApexPages.currentPage().getParameters().put('id', order.Id);
        PageReference pg = Page.Import_OrderLineItemDetailsSRS;
        Test.setCurrentPage(pg);
        ApexPages.currentPage().getParameters().put('id', order.Id);
        SRSController srs1 = new SRSController();
        /*srsController.balanceQuantity instBq = New srsController.balanceQuantity();
        instBq.installType = 'Test';
        instBq.serviceType = 'Install';
        instBq.installDevice ='PrimaryDevice';
        instBq.GPQuantity  = 10;
        instBq.GPBalance  = 10;
        instBq.isAddon = TRUE;
        instBq.isPrimaryDevice = TRUE;
        instBq.key  ='Key';*/
        
        test.startTest();
        srs1.VINNumber = '1C4RJFBG3FC733863';
        srs1.deleteSelectedVehicles();
        // srs.getVINDataMethod();
        // Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        test.stopTest();
        
    }
    
}