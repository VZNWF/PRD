@isTest
private class ImportOLID_DataFromCSVControllerTest {
    
    private static testmethod void ImportOLID_DataFromCSVControllerTest() {
        
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        
        /*String blobCreator = //'INSTALL TYPE,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE ID (NEW) ,VEHICLE ID (OLD),YEAR ,MAKE ,MODEL ,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED ,CONTACT NAME ,EMAIL ,PHONE ,SECONDARY EMAIL,SECONDARY PHONE,GARAGE NICKNAME,GARAGED ADDRESS ,CITY ,STATE/ PROVINCE ,ZIP ,NOTES,TRACKING ,SHIPPED DATE,ARRIVAL DATE,RA,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NBEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna ,Driver ID,Magnet Mounts,Bluetooth Module,SSEM,SEM \n''+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676885,,10268,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676886,,10278,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,, \n';*/
       String blobCreator = 'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';
       
        ImportOLID_DataFromCSVController impOrd = new ImportOLID_DataFromCSVController();
        impOrd.csvFileBody = blob.valueOf(blobCreator);
        
        impOrd.importCSVFile();
        
    }
    
    private static testmethod void ImportOLID_DataFromCSVControllerNegativeTest() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = 'A5GS20029',Account__c = Acc.Id );
        insert Orders;
        Location__c loc = new Location__c(Customer__c=Acc.Id,Garage_Address1__c = 'Shadowood',Garage_City__c='San Diego',Garage_State__c ='CA' );
        insert loc;
        
        /*String blobCreator = //'+'Install_Type,VIN, Old_VIN,VehicleId_New,VehicleId_Old,Year,Make,Model,LIC_Plate, LIC_State, Serial_New, Serial_Old, Device_Type, Harness_Type, Contact_Name, Email, Phone, Sec_Email, Sec_Phone, Garage_Name,Garage_Street, City, State,Zip, Notes, Tracking, Shipped_Date, Arrival_Date, RA, Device_Ret, Sensor1, Sensor2, Sensor3, Sensor4, Sensor5, Sensor6, PEM,Pelican, NBEA,Garmin, Quake, APA,GPS, DriverId, Magnet, Bluetooth, SSEM,SEM,OrderId\n''
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676885,,10268,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676886,,10278,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,, \n';
        */
      String blobCreator = 'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';

        ImportOLID_DataFromCSVController impInst = new ImportOLID_DataFromCSVController();
        impInst.csvFileBody = blob.valueOf(blobCreator);
        impInst.isOverride = false;
        impInst.importCSVFile();
    }
    private static testmethod void TestMethod1() {
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        Location__c loc = new Location__c(Customer__c=Acc.Id,Garage_Address1__c = 'Shadowoodss',Garage_City__c='San Diego',Garage_State__c ='CA' );

        /*String blobCreator = //'INSTALL TYPE,VIN,OLD VIN (REQUIRED IF TRANSFER),VEHICLE ID (NEW) ,VEHICLE ID (OLD),YEAR ,MAKE ,MODEL ,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE,HARNESS TYPE ORDERED ,CONTACT NAME ,EMAIL ,PHONE ,SECONDARY EMAIL,SECONDARY PHONE,GARAGE NICKNAME,GARAGED ADDRESS ,CITY ,STATE/ PROVINCE ,ZIP ,NOTES,TRACKING ,SHIPPED DATE,ARRIVAL DATE,RA,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NBEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna ,Driver ID,Magnet Mounts,Bluetooth Module,SSEM,SEM \n''+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676885,,10268,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,,,,, \n Install,3N6788788Y676886,,10278,,2015,Infinity,Discovery,,,,,5200,6-pin Heavy Duty Harness for 5500,,test@test.com,,,,Test,Test1,,,,,,,,,,,,,,,,,,,,,,,,,,, \n';
        */
       String blobCreator = 'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n'+
            'Install,3N6788788Y676884,,10258,,2015,Infinity,Discovery,,,,,5200,,,6-pin Heavy Duty Harness for 5500,,testemail@verizon.com,,Test,Test1,,,,Shadowoodss,59868,San Digeo,USA,CA,59868,,,,,,,,,,,,,,,,,,,,, \n';

        ImportOLID_DataFromCSVController impOrd = new ImportOLID_DataFromCSVController();
        impOrd.isOverride = true;
        impOrd.csvFileBody = blob.valueOf(blobCreator);
        impOrd.importCSVFile();
    }
    
    private static testmethod void TestMethod2()
    {
        String INSTALLTYPE   = '';
         String VIN   = '';
         String OLDVIN_REQUIREDIFTRANSFER = '';
         String VEHICLEID_NEW = '';
         String VEHICLEID_OLD = '';
         String YEAR  = '';
         String MAKE  = '';
         String MODEL = '';
         String COLOR = '';
         String FUELTYPE = '';
         String LICPLATE  = '';
         String LICSTATE  = '';
         String SERIAL_NEW    = '';
         String SERIAL_OLD_FORSWAP    = '';
         String DEVICETYPE    = '';
         String HARNESSTYPEORDERED    = '';
         String CONTACTNAME   = '';
         String EMAIL = '';
         String PHONE = '';
         String EXT = '';
         String SECONDARYCONTACT = '';
         String SECONDARYEMAIL    = '';
         String SECONDARYPHONE    = '';
         String SECONDARYPHONEEXT    = '';
         String LOCATIONNAME = '';
         String GARAGEDADDRESS    = '';
         String CITY  = '';
         String STATE_PROVINCE    = '';
         String COUNTRY    = '';
         String ZIP   = '';
         String NOTES = '';
         //String TRACKINGNO    = '';
         //String SHIPPEDDATE   = '';
         //String ARRIVALDATE   = '';
         //String RA= '';
         String DEVICERETURNEDTO  = '';
         String SENSOR1NAME   = '';
         String SENSOR2NAME   = '';
         String SENSOR3NAME   = '';
         String SENSOR4NAME   = '';
         String SENSOR5NAME   = '';
         String SENSOR6NAME   = '';
         String PEM   = '';
         String PelicanBox    = '';
         String NBEACable = '';
         String Garmin    = '';
         String Quake = '';
         String AlternatePowerAdapter = '';
         String WindowMountGPSAntenna = '';
         String DriverID  = '';
         String MagnetMounts  = '';
         String BluetoothModule = '';
         //String SSEM  = '';
         //String SEM= '';
         String GP_ERP_Order_ID ='';
         String OrderID= '';
         String LocationID= '';
        OrderICuser__c ICuser = UtilsTest.createOrderICuser();
        
        account Acc = UtilsTest.createAccountforOrder();
        Orders__c Orders = new orders__c(GP_ERP_Order_ID__c = '3N6788788Y676884',Account__c = Acc.Id );
        insert Orders;
        Order_Line_Items__c lineItem = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, Service_Type__c = 'Install');
        insert lineItem;
        
        Order_Line_Items__c lineItem1 = new Order_Line_Items__c(Orders__c=Orders.id,GP_Quantity__c =5.00, Service_Type__c='Install Add-On Only');
        insert lineItem1;
        
        
        Location__c loc=new Location__c(name = 'test location',Customer__c = acc.id);        
        insert loc;
        list<Order_Line_Item_Details__c> vlstOLI = new list<Order_Line_Item_Details__c>();
        Order_Line_Item_Details__c olid = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = Orders.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'civic',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        insert olid;
        
        Order_Line_Item_Details__c olid1 = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = Orders.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Honda', Model__c = 'Accord',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        
        vlstOLI.add(olid1);
        Order_Line_Item_Details__c olid2 = new Order_Line_Item_Details__c(isSubmitted__c = true,GP_ERP_Order_ID__c='111',Order_Line_Items__c=lineItem.Id,Location__c = loc.id,SF_Orders__c = Orders.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'Toyota', Model__c = 'camry',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='123456',Device_Serial_Number_Old__c='4567890',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        vlstOLI.add(olid2);
        insert vlstOLI;
        ImportOLID_DataFromCSVController.OLID_Data ioc = new ImportOLID_DataFromCSVController.OLID_Data();
        list<ImportOLID_DataFromCSVController.OLID_Data> vlstIO = new list<ImportOLID_DataFromCSVController.OLID_Data>();
        vlstIO.add(ioc);
        set<string> setdevices = new set<string>();
        setdevices.add('civic');
        setdevices.add('Accord');
        setdevices.add('camry');
        ImportOLID_DataFromCSVController ioccomn = new ImportOLID_DataFromCSVController();
        //ioccomn.createOrderLineItemDetailsData(vlstIO);
        //ioccomn.createOrderLocationAndLocationData(vlstIO);
        ioccomn.redirectToIODS();
        ioccomn.populateOLIdetailsMap(Orders.id);
        String csvHeader = 'Email, Gravitar URL\n';
            String csvFinalString = csvHeader;

        ioccomn.fnGetMandatoryColumnsMap(csvFinalString);
        //ioccomn.createOLIEntryData(setdevices,olid);
    }
    
    
}