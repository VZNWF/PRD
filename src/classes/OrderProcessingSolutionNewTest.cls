@isTest(seealldata=true)
private class OrderProcessingSolutionNewTest {

    static testMethod void TestOrderProcessingSolutionNew() {
        OrderProcessingSolutionNew op=new OrderProcessingSolutionNew();
       
        
         Account testAccount=new Account(name='testAccount',Acct_Type__c = 'Prospect - End Customer',Sub_Type__c = 'RESELLER');
        insert testAccount;
        Account childAccount = new Account(name='childAccount',parentid=testAccount.id);
        insert childAccount;
        //Attachment Att = UtilsTest.CreateAttachment();
        //insert new CSVHeaders__c(name = 'ARRIVAL DATE');
        //op.attachment=att;
        Contact testcontact=new Contact(firstname='Test',
                                     lastname='Test',
                                     AccountId=testAccount.Id,Email='test@account.com');
        insert testcontact;
        Orders__c ord=new Orders__c(Account__c=testAccount.id,Contact__c=testcontact.id,Ship_To_Address_1__c='test address',Ship_To_City__c='test city',Ship_To_State__c='test state',Ship_To_Zip__c='123',GP_ERP_Order_ID__c='123',NavigateToCard__c=2.0 );
        insert ord;
        Test.setCurrentPageReference(new PageReference('Page.ops2')); 
        System.currentPageReference().getParameters().put('id', ord.id);
        Orders__c ord1=new Orders__c(Account__c=testAccount.id,Contact__c=testcontact.id,Ship_To_Address_1__c='test address',Ship_To_City__c='test city',Ship_To_State__c='test state',Ship_To_Zip__c='123',GP_ERP_Order_ID__c='123',NavigateToCard__c=null );
        insert ord1;
        Order_Line_Items__c lineItem=new Order_Line_Items__c(Orders__c=ord.id,GP_Quantity__c =1.00, Installation_Type__c='Install',TypeOfDevice__c='PrimaryDevice',Devices_Installed__c='');
        insert lineItem;
        Order_Line_Items__c lineItem1=new Order_Line_Items__c(Orders__c=ord.id,GP_Quantity__c =1.00,Installation_Type__c='Install',TypeOfDevice__c='AddOns',Devices_Installed__c='test addon');
        insert lineItem1;
        Location__c loc=new Location__c(name='test location',Customer__c=testAccount.id);        
        insert loc;
        List<Location__c> locList = new List<Location__c>();
        locList.add(loc);
        OrderProcessingSolutionNew.getAccount(String.valueOf(ord.id));
        OrderProcessingSolutionNew.getCount(String.valueOf(ord.id));
        Attachment att = new Attachment();  
        att.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Enter Order Number: (Order number is located on the upper right area of the upload site),123,,* REQUIRED FIELDS,,,,,,,,,,,,,,,,,,,,,,,,,,,Enter information where sensor will be connected to,,,,,,Put an x to all that applies,,,,,,,,,,, \n'+
'INSTALL TYPE *,VIN *,OLD VIN (REQUIRED IF TRANSFER),VEHICLE ID (NEW) *,VEHICLE ID (OLD),YEAR *,MAKE *,MODEL *,LIC PLATE,LIC STATE,SERIAL (NEW),SERIAL (OLD) FOR SWAP,DEVICE TYPE *,HARNESS TYPE ORDERED *,CONTACT NAME *,EMAIL *,PHONE *,SECONDARY EMAIL,SECONDARY PHONE,GARAGE NICKNAME *,GARAGED ADDRESS *,CITY *,STATE/ PROVINCE *,ZIP *,NOTES,TRACKING #,SHIPPED DATE,ARRIVAL DATE,RA?,DEVICE RETURNED TO,SENSOR 1 NAME,SENSOR 2 NAME,SENSOR 3 NAME,SENSOR 4 NAME,SENSOR 5 NAME,SENSOR 6 NAME,PEM,Pelican Box,NBEA Cable,Garmin,Quake,Alternate Power Adapter,Window Mount GPS Antenna ,Driver ID,Magnet Mounts,Bluetooth Module,SSEM,SEM \n'+
'Install,65456456464,,TESTVEH,,2012,Nis,Mvm,,,,,Asset Guard,"9-pin Heavy Duty Harness with ""D"" Mount for 5500",TEST CONT,test@T.COM,4564465564,,,tlocal,123 MAIN ST,san diego,CA,92122,,,,,,,,,,,,,,,,,,,,X,,,, \n');
        att.body=bodyBlob;
        op.attachment=att;
        
        op.upload1();
        //String locJson=OrderProcessingSolutionNew.getLocations(ord.id);
        OrderProcessingSolutionNew.WrapperOrder wo = new OrderProcessingSolutionNew.WrapperOrder();
        OrderProcessingSolutionNew.WrapperPurchasedService wp = new OrderProcessingSolutionNew.WrapperPurchasedService();
        OrderProcessingSolutionNew.WrapperVehicle wv1 = new OrderProcessingSolutionNew.WrapperVehicle();
        //wv1.LocationName = 'loc1';
        OrderProcessingSolutionNew.WraperOrderLineDevices wd = new OrderProcessingSolutionNew.WraperOrderLineDevices();
        OrderProcessingSolutionNew.getCardNumber(ord.Id);
        OrderProcessingSolutionNew.getOrder(ord.id);
        OrderProcessingSolutionNew.getPrimaryDevices(ord.id);
        OrderProcessingSolutionNew.getInstallTypes(ord.id);
        OrderProcessingSolutionNew.getHarnessCategory();
        OrderProcessingSolutionNew.getSecondaryDevices(ord.id);
        OrderProcessingSolutionNew.getLicenseState(ord.id);
        OrderProcessingSolutionNew.getPurchasedService(ord.id);
        OrderProcessingSolutionNew.getShipingInfo(ord.id);
        OrderProcessingSolutionNew.getStateCountryvalues();   
        OrderProcessingSolutionNew.getDeviceRetCategory();
        //OrderProcessingSolutionNew.saveRecord(ord.Id, 2, locJson,null, 'a@xy.com','abc@gmail.com','876578658' false);
        //OrderProcessingSolutionNew.saveRecord(ord.Id, 2, null, null,false);
       String lineItemJson='[{"service":"Install","orderQty":"5","Id1":"","device":"Harness","balance":0,"id":"PurchasedServiceModel-9"}]';
         //String lineItemJson='[{"service":"Install","orderQty":"5","Id1":"a0He0000003Qn04EAC","device":"Harness","balance":0,"id":""}]';
        OrderProcessingSolutionNew.WrapperLocation wl = new OrderProcessingSolutionNew.WrapperLocation();
        wl.LocationName = 'loc1  loc';
        wl.GarageAddress1='xxx';
        wl.GarageAddress2='xxx';
        wl.GarageCity='xxx';
        wl.GarageState='xxx';
        wl.Country='xxx';
        wl.Zip='';
        wl.vehicles.add(wv1);
        String locjson='[{"Zip":"","LocationName":"loc1  loc","vehicles":[{"Year":"2015","VIN":"sd","VehicleLabel":"","Service":"Swap","Serial":"","Sensor6":"Sensor6","Sensor5":"4","Sensor4":"3","Sensor3":"3","Sensor2":"2","Sensor1":"Sensor1","OLDVIN":"","OldVehicleLabel":"","OldSerial":"","Notes":null,"Model":"sd","Make":"sd","locId":"a1Se0000002COtjEAG","LocationName":"loc1  loc","LicenseState":"","LicensePlate":"","Id1":"","Harness":"","FuelType":"","DeviceType":"6500","Color":"","Accessories":"Pelican Box,Quake Satellite Modem","id":"Ext.TOA.VehicleModel-1"}]}]';
        
        OrderProcessingSolutionNew.saveRecord(String.valueOf(ord.Id), 2,locjson,lineItemJson, 'a@xy.com','abc@gmail.com','876578658',String.valueOf(childAccount.Id),true);
         OrderProcessingSolutionNew.saveRecord(String.valueOf(ord.Id), 2,locjson,lineItemJson, 'a@xy.com','abc@gmail.com','876578658',String.valueOf(childAccount.Id),false);
        OrderProcessingSolutionNew.getFuelType(ord.Id);
        OrderLocation__C ol = new OrderLocation__C(Orders__c = ord.Id, Location__c =loc.id);
        insert ol;
        Order_Line_Item_Details__c ld = new Order_Line_Item_Details__c(GP_ERP_Order_ID__c='111',Location__c = loc.id,SF_Orders__c = ord.Id,Old_Vehicle_Label__c = 'old label', Vehicle_Label__c= 'label',Vehicle_Harness_Category__c = '6-pin Heavy Duty Harness for 5500',Installation_Type__c = 'Install',Year__c = '2012', Make__c = 'make', Model__c = 'model',VIN__c = 'vin', Old_Vin__c = 'oldvin',License_Plate__c = 'ppp',Fuel_Type__c = 'Gasoline',Color__c='red',Device_Serial_Number__c ='sn',Device_Serial_Number_Old__c='oldnumber',Addon_Harness__c=true,Addon_Alternate_Power_Adapter__c=true,Addon_Bluetooth_module__c=true,Addon_Driver_ID__c=false,Addon_Garmin_CONNECT__c=false,Addon_Magnet_Mounts__c=false,Addon_NMEA_Cable__c=false,Addon_Pelican_Box__c=true,Addon_Pigtail__c=true,Addon_PEM__c=true,Addon_Quake_Satellite_Modem__c=true,Addon_Window_Mount_GPS_Antenna__c=true,Sensor1__c ='sensor1',Sensor2__c ='sensor2',Sensor3__c ='sensor3',Sensor4__c ='sensor4',Sensor5__c ='sensor5',Sensor6__c ='sensor6');
        insert ld;
        Set<Id> olidSet = new Set<Id>();
        olidSet.add(ld.Id);
        OrderProcessingSolutionNew.getLocationsAndVeh(ord.Id);
        OrderProcessingSolutionNew.getLocationsAndVeh(ord1.Id);
        //OrderProcessingSolutionNew.getLocations(ord.Id);
        OrderProcessingSolutionNew.WrapperVehicle wv=new OrderProcessingSolutionNew.WrapperVehicle();
        List<OrderProcessingSolutionNew.WrapperLocation> wrapperList = new List<OrderProcessingSolutionNew.WrapperLocation>();
        wrapperList.add(wl);
        OrderProcessingSolutionNew.populateETAStaging(wrapperList);
        OrderProcessingSolutionNew.submitRecord(String.valueOf(ord.id),2,locjson,lineItemJson,'a@xy.com','abc@gmail.com','876578658',String.valueOf(childAccount.Id));
    }
}