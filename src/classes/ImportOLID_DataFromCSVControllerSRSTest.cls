@isTest (SeeAllData=true)
private class ImportOLID_DataFromCSVControllerSRSTest {
    
    private static testmethod void ImportOLID_DataFromCSVControllerSRSTest() {
        
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = 'SRS12340000QQQ',Account__c = Acc.Id );
        insert Orders;
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        
        List<Order_Line_Items__c> insOLIDList = new List<Order_Line_Items__c>();
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'D-5500NV-070-36-INS', Activity_Notes__c='Test 123' );
        insOLIDList.add(lineItem);
        insert insOLIDList;
        
       String blobCreator = 'Enter Order Number: (Order number is located on the upper left area of the SRS site),SRS12340000QQQ,,* REQUIRED FIELDS,,Version,v2.12.17,,,,,,,,,,,,,,,,,,,,,,,,,,Enter sensor location,,,,,,"Insert an ""x"" to all that apply",,,,,,,,,,NWF-121517 \n'+
			'INSTALL TYPE *,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE LABEL (NEW) *,VEHICLE LABEL (OLD),YEAR *,MAKE *,MODEL *,COLOR*,FUEL TYPE,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED,CONTACT NAME *,EMAIL *,PHONE *,EXT,ALTERNATE CONTACT NAME,ALTERNATE EMAIL,ALTERNATE PHONE,ALTERNATE EXT,GARAGE NICKNAME *,GARAGED ADDRESS *,CITY *,COUNTRY,STATE/ PROVINCE *,ZIP *,NOTES,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NMEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna,Driver ID,Magnet Mounts,Bluetooth Module,EOF\n'+ 
       		'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5500,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5500,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5500,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5500,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';
            
        ImportOLID_DataFromCSVControllerSRS impOrd = new ImportOLID_DataFromCSVControllerSRS();
        impOrd.csvFileBody = blob.valueOf(blobCreator);
        
        impOrd.importCSVFile();
        
        impOrd.redirectToIODS();
        impOrd.redirectToIODSCancel();
        
    }
    
    private static testmethod void ImportOLID_DataFromCSVControllerNegativeTest() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = 'SRS12340000QQQ',Account__c = Acc.Id );
        insert Orders;
        Location__c loc = new Location__c(Customer__c=Acc.Id,Garage_Address1__c = 'Shadowood',Garage_City__c='San Diego',Garage_State__c ='CA' );
        insert loc;
                
      String blobCreator = 'Enter Order Number: (Order number is located on the upper left area of the SRS site),SRS12340000QQQ,,* REQUIRED FIELDS,,Version,v2.12.17,,,,,,,,,,,,,,,,,,,,,,,,,,Enter sensor location,,,,,,"Insert an ""x"" to all that apply",,,,,,,,,,NWF-121517 \n'+
			'INSTALL TYPE *,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE LABEL (NEW) *,VEHICLE LABEL (OLD),YEAR *,MAKE *,MODEL *,COLOR*,FUEL TYPE,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED,CONTACT NAME *,EMAIL *,PHONE *,EXT,ALTERNATE CONTACT NAME,ALTERNATE EMAIL,ALTERNATE PHONE,ALTERNATE EXT,GARAGE NICKNAME *,GARAGED ADDRESS *,CITY *,COUNTRY,STATE/ PROVINCE *,ZIP *,NOTES,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NMEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna,Driver ID,Magnet Mounts,Bluetooth Module,EOF\n'+ 
       		'Dummy Install Type,3N678878111111111111111,,10258,,201,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,598681,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USAD,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@@@@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity12345678901234567890123456789012345678901234567890,Discovery12345678901234567890123456789012345678901234567890,,,,,52001,,,666-pin Heavy Duty Harness for 5500,,testemail@@@@verizon.com,,Test,Test1,,,,,,San Digeo,CANADA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';
       

        ImportOLID_DataFromCSVControllerSRS impInst = new ImportOLID_DataFromCSVControllerSRS();
        impInst.csvFileBody = blob.valueOf(blobCreator);
        impInst.isOverride = false;
        impInst.importCSVFile();
        
        
    }
    private static testmethod void TestMethod1() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = 'SRS12340000QQQ',Account__c = Acc.Id );
        insert Orders;
        Location__c loc = new Location__c(Customer__c=Acc.Id,Garage_Address1__c = 'Shadowoodss',Garage_City__c='San Diego',Garage_State__c ='CA' );
        
       String blobCreator = 'Enter Order Number: (Order number is located on the upper left area of the SRS site),SRS12340000QQQ,,* REQUIRED FIELDS,,Version,v2.12.17,,,,,,,,,,,,,,,,,,,,,,,,,,Enter sensor location,,,,,,"Insert an ""x"" to all that apply",,,,,,,,,,NWF-121517 \n'+
			'INSTALL TYPE *,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE LABEL (NEW) *,VEHICLE LABEL (OLD),YEAR *,MAKE *,MODEL *,COLOR*,FUEL TYPE,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED,CONTACT NAME *,EMAIL *,PHONE *,EXT,ALTERNATE CONTACT NAME,ALTERNATE EMAIL,ALTERNATE PHONE,ALTERNATE EXT,GARAGE NICKNAME *,GARAGED ADDRESS *,CITY *,COUNTRY,STATE/ PROVINCE *,ZIP *,NOTES,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NMEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna,Driver ID,Magnet Mounts,Bluetooth Module,EOF\n'+ 
       		'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';

        ImportOLID_DataFromCSVControllerSRS impOrd = new ImportOLID_DataFromCSVControllerSRS();
        impOrd.isOverride = true;
        impOrd.csvFileBody = blob.valueOf(blobCreator);
        impOrd.importCSVFile();
        
        impOrd.redirectToIODSCancel();
        
        
        String blobCreator1 = 'Enter Order Number: (Order number is located on the upper left area of the SRS site),SRS12340000QQQ,,* REQUIRED FIELDS,,Version,v2.12.17,,,,,,,,,,,,,,,,,,,,,,,,,,Enter sensor location,,,,,,"Insert an ""x"" to all that apply",,,,,,,,,,NWF-121517 \n'+
			'INSTALL TYPE *,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE LABEL (NEW) *,VEHICLE LABEL (OLD),YEAR *,MAKE *,MODEL *,COLOR*,FUEL TYPE,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED,CONTACT NAME *,EMAIL *,PHONE *,EXT,ALTERNATE CONTACT NAME,ALTERNATE EMAIL,ALTERNATE PHONE,ALTERNATE EXT,GARAGE NICKNAME *,GARAGED ADDRESS *,CITY *,COUNTRY,STATE/ PROVINCE *,ZIP *,NOTES,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NMEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna,Driver ID,Magnet Mounts,Bluetooth Module,EOF\n';
		String blobCreator1TempData = 'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';
        
        for(Integer i=0;i<100;i++){
        	blobCreator1 += blobCreator1TempData;
        }
        
        ImportOLID_DataFromCSVControllerSRS impOrd1 = new ImportOLID_DataFromCSVControllerSRS();
        impOrd1.isOverride = true;
        impOrd1.csvFileBody = blob.valueOf(blobCreator1);
        impOrd1.importCSVFile();
        
    }
    
    private static testmethod void TestMethod2()
    {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();

        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        List<Order_Line_Items__c> insOLIDList = new List<Order_Line_Items__c>();
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-UNIT', Activity_Notes__c='Test 123' );
        insOLIDList.add(lineItem);
        
        Order_Line_Items__c lineItem1 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-BTE', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem1);
        
        Order_Line_Items__c lineItem2 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =15.00, GP_Item_Number__c = 'I-INSTALL-UNIT');
        insOLIDList.add(lineItem2);
        
        Order_Line_Items__c lineItem3 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-DID', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem3);
        
        Order_Line_Items__c lineItem4 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-FMI', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem4);
        
        Order_Line_Items__c lineItem5 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-PEM', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem5);
        
        Order_Line_Items__c lineItem6 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-PMC', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem6);
        
        Order_Line_Items__c lineItem7 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-SSEM', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem7);
        
        Order_Line_Items__c lineItem8 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-GARMIN', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem8);
        
        Order_Line_Items__c lineItem9 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-NMEA', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem9);
        
        Order_Line_Items__c lineItem10 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, GP_Item_Number__c = 'I-INSTALL-AG', Activity_Notes__c='Test 456');
        insOLIDList.add(lineItem10);
        
        Order_Line_Items__c lineItem11 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =15.00, GP_Item_Number__c = 'I-INSTALL-AG');
        insOLIDList.add(lineItem11);
        
        insert insOLIDList;
        
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        /*list<Order_Line_Item_Details__c> vlstOLI = new list<Order_Line_Item_Details__c>();
        Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c(Device_Type__c = '5500', GP_ERP_Order_ID__c='3N6788788Y676884', Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = Orders.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'civic',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        //insert olid;
        vlstOLI.add(olid);
        Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(Device_Type__c = '5500',GP_ERP_Order_ID__c='3N6788788Y676884',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = Orders.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install Add-On Only',Year__c = '2012', Make__c = 'Honda', Model__c = 'Accord',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        
        vlstOLI.add(olid1);

        insert vlstOLI;*/
        
        ImportOLID_DataFromCSVControllerSRS.OLID_Data ioc = new ImportOLID_DataFromCSVControllerSRS.OLID_Data();
        
        List<ImportOLID_DataFromCSVControllerSRS.OLID_Data> cOLIData = createOLIData(loc.Id, orders.GP_ERP_Order_ID__c);
         
        //list<ImportOLID_DataFromCSVControllerSRS.OLID_Data> vlstIO = new list<ImportOLID_DataFromCSVControllerSRS.OLID_Data>();
        //vlstIO.add(ioc);
        //set<string> setdevices = new set<string>();
        //setdevices.add('civic');
        //setdevices.add('Accord');
        //setdevices.add('camry');
        ImportOLID_DataFromCSVControllerSRS ioccomn = new ImportOLID_DataFromCSVControllerSRS();
        ioccomn.Order_Id = Orders.Id;
        ioccomn.importCSVFile();
        ioccomn.Order_GP_ERP_Order_ID = Orders.Id;
        ioccomn.createOrderLineItemDetailsData(cOLIData);
        
        
        //ioccomn.createOrderLocationAndLocationData(vlstIO);
        //ioccomn.redirectToIODS();
        
        Test.setCurrentPageReference(new PageReference('Page.Import_OrderLineItemDetails')); 
		System.currentPageReference().getParameters().put('id', Orders.Id);
        
        //ioccomn.populateOLIdetailsMap(Orders.id);
        String csvHeader = 'Email, Gravitar URL\n';
        String csvFinalString = csvHeader;

        //ioccomn.fnGetMandatoryColumnsMap(csvFinalString);
        //ioccomn.createOLIEntryData(setdevices,olid);
    }
    
    private static List<ImportOLID_DataFromCSVControllerSRS.OLID_Data> createOLIData(Id locationId, String GPOrderId){
    	 
    	 List<ImportOLID_DataFromCSVControllerSRS.OLID_Data> olidDataList = new List<ImportOLID_DataFromCSVControllerSRS.OLID_Data>();
    	 ImportOLID_DataFromCSVControllerSRS.OLID_Data oliData = new ImportOLID_DataFromCSVControllerSRS.OLID_Data();
         oliData.INSTALLTYPE   = 'Install';
         oliData.VIN   = '12345678901234567';
         oliData.OLDVIN_REQUIREDIFTRANSFER = '';
         oliData.VEHICLEID_NEW = '';
         oliData.VEHICLEID_OLD = '';
         oliData.YEAR  = '2012';
         oliData.MAKE  = 'Test';
         oliData.MODEL = 'Test';
         oliData.COLOR = 'Red';
         oliData.FUELTYPE = 'Gasoline';
         oliData.LICPLATE  = '';
         oliData.LICSTATE  = '';
         oliData.SERIAL_NEW    = '';
         oliData.SERIAL_OLD_FORSWAP    = '';
         oliData.DEVICETYPE    = '5500';
         oliData.HARNESSTYPEORDERED    = '';
         oliData.CONTACTNAME   = '';
         oliData.EMAIL = 'test@test1.com';
         oliData.PHONE = '1234567890';
         oliData.EXT = '';
         oliData.SECONDARYCONTACT = '';
         oliData.SECONDARYEMAIL    = '';
         oliData.SECONDARYPHONE    = '';
         oliData.SECONDARYPHONEEXT    = '';
         oliData.LOCATIONNAME = 'test location';
         oliData.GARAGEDADDRESS    = '123 Test Add';
         oliData.CITY  = 'San Diego';
         oliData.STATE_PROVINCE    = 'CA';
         oliData.COUNTRY    = 'USA';
         oliData.ZIP   = '92121';
         oliData.NOTES = '';
         //oliData.TRACKINGNO    = '';
         //oliData.SHIPPEDDATE   = '';
         //oliData.ARRIVALDATE   = '';
         //oliData.RA= '';
         oliData.DEVICERETURNEDTO  = '';
         oliData.SENSOR1NAME   = 'ABC';
         oliData.SENSOR2NAME   = 'ABC';
         oliData.SENSOR3NAME   = 'ABC';
         oliData.SENSOR4NAME   = 'abc';
         oliData.SENSOR5NAME   = 'abc';
         oliData.SENSOR6NAME   = 'abc';
         oliData.PEM   = 'x';
         oliData.PelicanBox    = 'x';
         oliData.NBEACable = 'x';
         oliData.Garmin    = 'x';
         oliData.Quake = 'x';
         oliData.AlternatePowerAdapter = 'x';
         oliData.WindowMountGPSAntenna = 'x';
         oliData.DriverID  = 'x';
         oliData.MagnetMounts  = 'x';
         oliData.BluetoothModule = 'x';
         //oliData.SSEM  = '';
         //oliData.SEM= '';
         oliData.GP_ERP_Order_ID = GPOrderId;
         oliData.OrderID= '3N6788788Y676884';
         oliData.LocationID= locationId;
         olidDataList.add(oliData);
         
         ImportOLID_DataFromCSVControllerSRS.OLID_Data oliData1 = new ImportOLID_DataFromCSVControllerSRS.OLID_Data();
         oliData1.INSTALLTYPE   = 'Install';
         oliData1.VIN   = '12345678901234567';
         oliData1.OLDVIN_REQUIREDIFTRANSFER = '';
         oliData1.VEHICLEID_NEW = '';
         oliData1.VEHICLEID_OLD = '';
         oliData1.YEAR  = '2012';
         oliData1.MAKE  = 'Test';
         oliData1.MODEL = 'Test';
         oliData1.COLOR = 'Red';
         oliData1.FUELTYPE = 'Gasoline';
         oliData1.LICPLATE  = '';
         oliData1.LICSTATE  = '';
         oliData1.SERIAL_NEW    = '';
         oliData1.SERIAL_OLD_FORSWAP    = '';
         oliData1.DEVICETYPE    = 'Asset Guard PW (Hardwired)';
         oliData1.HARNESSTYPEORDERED    = '';
         oliData1.CONTACTNAME   = '';
         oliData1.EMAIL = 'test@test1.com';
         oliData1.PHONE = '1234567890';
         oliData1.EXT = '';
         oliData1.SECONDARYCONTACT = '';
         oliData1.SECONDARYEMAIL    = '';
         oliData1.SECONDARYPHONE    = '';
         oliData1.SECONDARYPHONEEXT    = '';
         oliData1.LOCATIONNAME = 'test location';
         oliData1.GARAGEDADDRESS    = '123 Test Add';
         oliData1.CITY  = 'San Diego';
         oliData1.STATE_PROVINCE    = 'CA';
         oliData1.COUNTRY    = 'USA';
         oliData1.ZIP   = '92121';
         oliData1.NOTES = '';
         //oliData1.TRACKINGNO    = '';
         //oliData1.SHIPPEDDATE   = '';
         //oliData1.ARRIVALDATE   = '';
         //oliData1.RA= '';
         oliData1.DEVICERETURNEDTO  = '';
         oliData1.SENSOR1NAME   = 'ABC';
         oliData1.SENSOR2NAME   = 'ABC';
         oliData1.SENSOR3NAME   = 'ABC';
         oliData1.SENSOR4NAME   = 'abc';
         oliData1.SENSOR5NAME   = 'abc';
         oliData1.SENSOR6NAME   = 'abc';
         oliData1.PEM   = 'x';
         oliData1.PelicanBox    = 'x';
         oliData1.NBEACable = 'x';
         oliData1.Garmin    = 'x';
         oliData1.Quake = 'x';
         oliData1.AlternatePowerAdapter = 'x';
         oliData1.WindowMountGPSAntenna = 'x';
         oliData1.DriverID  = 'x';
         oliData1.MagnetMounts  = 'x';
         oliData1.BluetoothModule = 'x';
         //oliData1.SSEM  = '';
         //oliData1.SEM= '';
         oliData1.GP_ERP_Order_ID = GPOrderId;
         oliData1.OrderID= '3N6788788Y676884';
         oliData1.LocationID= locationId;
    	 olidDataList.add(oliData1);
    	 
    	 ImportOLID_DataFromCSVControllerSRS.OLID_Data oliData2 = new ImportOLID_DataFromCSVControllerSRS.OLID_Data();
         oliData2.INSTALLTYPE   = 'Install Accessory Only';
         oliData2.VIN   = '12345678901234567';
         oliData2.OLDVIN_REQUIREDIFTRANSFER = '';
         oliData2.VEHICLEID_NEW = '';
         oliData2.VEHICLEID_OLD = '';
         oliData2.YEAR  = '2012';
         oliData2.MAKE  = 'Test';
         oliData2.MODEL = 'Test';
         oliData2.COLOR = 'Red';
         oliData2.FUELTYPE = 'Gasoline';
         oliData2.LICPLATE  = '';
         oliData2.LICSTATE  = '';
         oliData2.SERIAL_NEW    = '';
         oliData2.SERIAL_OLD_FORSWAP    = '';
         oliData2.DEVICETYPE    = 'Asset Guard PW (Hardwired)';
         oliData2.HARNESSTYPEORDERED    = '';
         oliData2.CONTACTNAME   = '';
         oliData2.EMAIL = 'test@test1.com';
         oliData2.PHONE = '1234567890';
         oliData2.EXT = '';
         oliData2.SECONDARYCONTACT = '';
         oliData2.SECONDARYEMAIL    = '';
         oliData2.SECONDARYPHONE    = '';
         oliData2.SECONDARYPHONEEXT    = '';
         oliData2.LOCATIONNAME = 'test location';
         oliData2.GARAGEDADDRESS    = '123 Test Add';
         oliData2.CITY  = 'San Diego';
         oliData2.STATE_PROVINCE    = 'CA';
         oliData2.COUNTRY    = 'USA';
         oliData2.ZIP   = '92121';
         oliData2.NOTES = '';
         //oliData2.TRACKINGNO    = '';
         //oliData2.SHIPPEDDATE   = '';
         //oliData2.ARRIVALDATE   = '';
         //oliData2.RA= '';
         oliData2.DEVICERETURNEDTO  = '';
         oliData2.SENSOR1NAME   = 'ABC';
         oliData2.SENSOR2NAME   = 'ABC';
         oliData2.SENSOR3NAME   = 'ABC';
         oliData2.SENSOR4NAME   = 'abc';
         oliData2.SENSOR5NAME   = 'abc';
         oliData2.SENSOR6NAME   = 'abc';
         oliData2.PEM   = 'x';
         oliData2.PelicanBox    = 'x';
         oliData2.NBEACable = 'x';
         oliData2.Garmin    = 'x';
         oliData2.Quake = 'x';
         oliData2.AlternatePowerAdapter = 'x';
         oliData2.WindowMountGPSAntenna = 'x';
         oliData2.DriverID  = 'x';
         oliData2.MagnetMounts  = 'x';
         oliData2.BluetoothModule = 'x';
         //oliData2.SSEM  = '';
         //oliData2.SEM= '';
         oliData2.GP_ERP_Order_ID = GPOrderId;
         oliData2.OrderID= '3N6788788Y676884';
         oliData2.LocationID= locationId;
    	 olidDataList.add(oliData2);
    	 
    	 return olidDataList;
    }
    
}