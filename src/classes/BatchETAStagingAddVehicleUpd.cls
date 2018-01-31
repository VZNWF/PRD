global class BatchETAStagingAddVehicleUpd implements Database.Batchable<SObject>{
    /*
     Sunil Kumar - 07/03/2017 - Updated the class to fix multiple jobs issue in scheduler - IT1203
     */
    public string query; 
    public integer SchdClassBatchSize; 
    
    global Database.queryLocator start(Database.BatchableContext BC){
        //Fetch the ETASTaging records to update
        //Removing the limit 100, As this Batch would consider only the top 100 and ignore the remaining records.
        query = 'Select id,Number_of_vehicles_to_add__c,Trigger_ETA_Integration__c  from ETA_Staging__c where Trigger_ETA_Integration__c = 1';
        return Database.getQueryLocator(query);    
    }
    //Update the ETASTaging records
    global void execute(Database.BatchableContext BC, List<ETA_Staging__c> scope){
        //Check for current Logic.
            for(ETA_Staging__c  a : scope)
             {
                 a.Number_of_vehicles_to_add__c = 0; 
                 a.Trigger_ETA_Integration__c = 0;          
             }
         update scope;
     }

     global void finish(Database.BatchableContext BC){
        //Schedule the job every five minutes. Get the Time Interval from Custom Setting 
        BatchETAStagingAddVehicleUpd apextoSchd = new BatchETAStagingAddVehicleUpd();
            SchdClassBatchSize = Integer.valueof(SchdClassSettings__c.getall().get('Logic1BatchSize').value__c);
            if(!Test.isRunningTest())
            system.scheduleBatch(apextoSchd,'OFSC_Trigger_Integration', Integer.valueof(SchdClassSettings__c.getall().get('TimeInterval').value__c),SchdClassBatchSize);
        }   

}