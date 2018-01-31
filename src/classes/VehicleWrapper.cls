/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Sunil Kumar Sirangi
// File Name:       VehicleWrapper 
// Summary:         Wrapper Class for IODS Controller
// Created On:      08-18-2017
*******************************************************************************/
public class VehicleWrapper{// Wrapper class to hold Vehicle input information
    public string serviceType {get; set;}
    public string location {get; set;}
    public string VINNumber {get; set;}
    public string year {get; set;}
    public string make {get; set;}
    public string model {get; set;}
    public string inputYear {get; set;} // When not a vehicle is selected
    public string inputMake {get; set;} // When not a vehicle is selected
    public string inputModel {get; set;} // When not a vehicle is selected
    public string otherModel {get; set;} 
    public string oldVIN {get; set;}
    public boolean noVINnumber {get; set;} // to hold NO VIN Checkbox
    public boolean notAVehicle {get; set;} // to hold Not a Vehicle Checkbox       
    public string vehicleLabel {get; set;}
    public string licensePlate {get; set;}
    public string licenseState {get; set;}
    public string deviceType {get; set;}
    public string harnessType {get; set;}
    public string fuelType {get; set;}
    public string serial {get; set;}
    public string oldSerial {get; set;}
    public list<String> accessories {get; set;}
    public list<SelectOption> availableAccessories {get; set;}
    public list<SelectOption> selectedAccessories {get; set;}
    public string returnTo {get; set;}
    public string notes {get; set;}
    public boolean sensorFlag {get; set;} // to select sensor checkbox if any of snsors present 
    public string sensor1 {get; set;}
    public string sensor2 {get; set;}      
    public string sensor3 {get; set;}      
    public string sensor4 {get; set;}      
    public string sensor5 {get; set;}      
    public string sensor6 {get; set;}  
    public string color {get; set;}
    public string otherColor {get; set;}  
    // constructor        
    public VehicleWrapper(){
        selectedAccessories = new list<SelectOption>();
        availableAccessories = new list<SelectOption>();
        /*for(Accessories__mdt accs : [Select DeveloperName,MasterLabel from Accessories__mdt]){
            availableAccessories.add(new SelectOption(accs.MasterLabel,accs.MasterLabel));                
        }*/    
    }       
}