/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Sunil Kumar
// File Name:       OFSCDataHelper 
// Summary:         data preparation class for toatechInboundinterface SOAP class
// Created On:      03/13/2017
// Jira Ticket Number: IT1638
// Modification Log:
====================

*******************************************************************************/
public class OFSCDataHelper{
    
    public static void prepareData(List<ETA_Staging__c> OFSCList){
        
      try{
        for(ETA_Staging__c  etaRecord : OFSCList){
            toatechInboundinterface.UserElement userData = new toatechInboundinterface.UserElement(); // instantiate the user element class
            userData.now = VZ_Util.GetCurrentDateTimeInISO8601Format();
            Installer_Settings__c credentials = Installer_Settings__c.getInstance('soap user');
            userData.login = credentials.Login_ID__c;
            userData.company = credentials.Company__c;
            userData.auth_string = generateAuthString();
            
            toatechInboundinterface.HeadElement headElement = new toatechInboundinterface.HeadElement(); // instantiate the head element class
            headElement.upload_type = 'incremental'; 
            
            toatechInboundinterface.KeysArray activityKey = new toatechInboundinterface.KeysArray(); // to hold the activity key fields information in head node.
            List<String> keyActivity = new List<String>{'appt_number','customer_number'};
            activityKey.field = keyActivity;
            
            toatechInboundinterface.KeysArray inventoryKey = new toatechInboundinterface.KeysArray(); // to hold the inventory key fields information in head node.
            List<String> keyInventory = new List<String>{'invsn'};
            inventoryKey.field = keyInventory;
            
            toatechInboundinterface.AppointmentSettings appointmentSettings = new toatechInboundinterface.AppointmentSettings();
            appointmentSettings.keys = activityKey; 
            
            toatechInboundinterface.InventorySettings  inventorySettings = new toatechInboundinterface.InventorySettings();
            inventorySettings.keys = inventoryKey;
            
            headElement.appointment = appointmentSettings;
            headElement.inventory = inventorySettings;
            
            
            toatechInboundinterface.DataElement dataElement = new toatechInboundinterface.DataElement(); // instantiate the data element class
            
            toatechInboundinterface.AppointmentElement appointmentElement = new toatechInboundinterface.AppointmentElement();
            appointmentElement.appt_number = etaRecord.id;
            appointmentElement.customer_number = etaRecord.Order__r.Customer_Number__c;
            appointmentElement.action_if_completed = 'update';
            
            List<toatechInboundinterface.PropertyElement> propertyElementList = new List<toatechInboundinterface.PropertyElement>();
            
            toatechInboundinterface.PropertyElement propertyElement = new toatechInboundinterface.PropertyElement();
            propertyElement.label = 'astatus';
            propertyElement.value = 'Suspended';
            propertyElementList.add(propertyElement);
            
            toatechInboundinterface.PropertiesArray propertiesArray = new toatechInboundinterface.PropertiesArray();
            propertiesArray.property = propertyElementList;
            
            
            appointmentElement.properties = propertiesArray;
            
            List<toatechInboundinterface.CommandElement> commandElementList = new List<toatechInboundinterface.CommandElement>();
            
            toatechInboundinterface.CommandElement commandElement = new toatechInboundinterface.CommandElement();
            Date dToday = etaRecord.Scheduled_Date__c;
            Datetime dt = datetime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String formattedDate = dt.format('yyyy-MM-dd'); // accpted date format is yyyy-mm-dd
            commandElement.date_x = formattedDate;
            commandElement.type_x = 'suspend_activity';
            commandElement.appointment = appointmentElement;
            commandElementList.add(commandElement);
            
            toatechInboundinterface.CommandsArray commandsArray = new toatechInboundinterface.CommandsArray();
            commandsArray.command = commandElementList;            
            dataElement.commands = commandsArray;
            
            toatechInboundinterface.InboundInterfacePort inboundInterfacePort = new toatechInboundinterface.InboundInterfacePort();
            toatechInboundinterface.InboundInterfaceResponseElement inboundInterfaceResponseElement = inboundInterfacePort.inbound_interface(userData,headElement,dataElement);
            system.debug('***inboundInterfaceResponseElement:'+inboundInterfaceResponseElement);
            
            toatechInboundinterface.DataResponseElement dataResponseElement = new toatechInboundinterface.DataResponseElement();
            dataResponseElement.commands = inboundInterfaceResponseElement.data.commands;
            
            toatechInboundinterface.CommandsResponseArray commandsResponseArray = new toatechInboundinterface.CommandsResponseArray();
            commandsResponseArray = dataResponseElement.commands;
          
            toatechInboundinterface.CommandResponseElement responseCommandElement = new toatechInboundinterface.CommandResponseElement();
            responseCommandElement = commandsResponseArray.command[0];
            
            
            toatechInboundinterface.AppointmentResponseElement appointmentResponseElement = new toatechInboundinterface.AppointmentResponseElement();
            appointmentResponseElement = responseCommandElement.appointment;
            
            
             
            toatechInboundinterface.ReportElement reportElement = new toatechInboundinterface.ReportElement();
            reportElement = appointmentResponseElement.report;
            
            List<OFSC_Log__c> ofscLogs = new List<OFSC_Log__c>();
            
            if(reportElement.message.size() > 0){
                for(toatechInboundinterface.ReportMessageElement rem : reportElement.message){
                     OFSC_Log__c dataLog = new OFSC_Log__c();
                     dataLog.ETA_Activitiy__c = etaRecord.id;                 
                     dataLog.result__c = rem.result;                     
                     dataLog.code__c = rem.code;
                     dataLog.description__c = rem.description;
                     datalog.Response__c = String.valueOf(inboundInterfaceResponseElement);
                     ofscLogs.add(dataLog);
                }
            }
            
            if(ofscLogs.size() > 0){
               insert ofscLogs; 
            }
         }
       }
       Catch(Exception e){
                System.debug(logginglevel.Error, '@@@@@@@Failed here'+e.getMessage()+'stack trace'+ e.getStackTraceString());
       }
    }
    // this method uses crypto class to generate auth_string for OFSC authentication purpose.
    public static String generateAuthString(){
        Installer_Settings__c credentials = Installer_Settings__c.getInstance('soap user');        
        String auth_string = VZ_Util.GetAuthString(credentials.Password__c);
        return auth_string;
    }
}