/*******************************************************************************
// Modification Log:
====================

// Vanditha    - 6/16/2017 - Created Fedexlink method for Order Automation Project

*******************************************************************************/

trigger OrderLocation on OrderLocation__c (before insert, before update) {

    OrderLocationHandler handler = new OrderLocationHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.handleBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.handleBeforeUpdate(Trigger.new);    
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        handler.Fedexlink(Trigger.new);    
    }
    
}