trigger Workforce2_CreateActivityMessageForETA_Staging_c on ETA_Staging__c (after insert, after update, before delete){
    
    if(TOA2.Workforce2_Ctrl.fromExternalSystem()) return;
    Toggle_Switch__c trgSw = Toggle_Switch__c.getInstance('Workforce2_ETA');
    //Skip trigger if it is disabled using custom setting 
    if(trgSw.isTriggerDisabled__c) return;
    //Skip the trigger if already ran 
    //if(VZ_Util.IsETAStagingTriggerExecuted) return;
    
    Map<Id,ETA_Staging__c> ETA_Staging_cMap=(Trigger.isDelete?Trigger.oldMap:Trigger.newMap);
    List<sObject> messages = new List<sObject>();
    
    for (ETA_Staging__c obj : ETA_Staging_cMap.values()){
        try{
            
            if(!VZ_Util.ETAStagingIdSet.contains(obj.Id)){
                system.debug('BeforeMessages=>');
                messages.add(new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+obj.Id,TOA2__appt_number__c=obj.Id,
                                                                     TOA2__UpdateInventory__c=true));             
            }
        }
        
        catch(Exception exc){
            obj.addError(exc.getMessage());
        }
        VZ_Util.ETAStagingIdSet.add(obj.Id);
        
    }
    
    if(messages.size()>0)
    {
        Database.SaveResult[] result=Database.insert(messages,false);
        //Setting the static variable to avoid multiple runs of this trigger
        //VZ_Util.IsETAStagingTriggerExecuted = true;
        System.assertEquals(result.size(),messages.size());
        for(Integer i=0,size=result.size();i<size;++i){
            if(!result[i].isSuccess()) 
            {
                final Id ETA_Staging_cId=Id.valueOf(((String)messages[i].get('TOA2__InternalKey__c')).substring(2));
                ETA_Staging_cMap.get(ETA_Staging_cId).addError(result[i].getErrors()[0].getMessage());
            }
        }
    }
    TOA2.Workforce2_Ctrl.analizeLinks('ETA_Staging__c', Trigger.oldMap, Trigger.newMap, messages);
}