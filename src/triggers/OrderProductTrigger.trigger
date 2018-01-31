trigger OrderProductTrigger on Order_Product__c (after insert, after update, after delete, after undelete) {
if(Trigger.isAfter && Trigger.isInsert){
        OrderProductTriggerHandler.handleAfterInsert(Trigger.newMap);
    }
    
    if(Trigger.isafter && Trigger.isUpdate){
        OrderProductTriggerHandler.handleAfterUpdate(Trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
        OrderProductTriggerHandler.handleAfterDelete(Trigger.old);
    }
    
    if(Trigger.isAfter && Trigger.isUndelete){
        OrderProductTriggerHandler.handleAfterUndelete(Trigger.new);
    
    }
}