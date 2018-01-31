trigger Task on Task (before insert, after insert, before update, after update, before delete) {

 
    List<Task> tasksToBeEmailed = new List<Task>();

    if (Trigger.isInsert){
        //if we are inserting new, this logic works
        for (Task task : Trigger.New) {
            if (task.Email_Affilate_Rep__c == 'Yes' && task.Status == 'Completed'){
                tasksToBeEmailed.add(task);
            }
        }
    }

    if (Trigger.isUpdate){
        for(Task task : Trigger.New){
            //need to check if the status changed - if it did not change  
            //may have been reparented by lead conversion
            Task oldTask = Trigger.oldMap.get(task.Id);
            if(oldTask.Status != task.Status && task.Status == 'Completed' && task.Email_Affilate_Rep__c == 'Yes'){
                tasksToBeEmailed.add(task);
            }
        }
    }
    if(tasksToBeEmailed.size() > 0){
        NotifyAffiliateByEmail.sendEmail(tasksToBeEmailed);
    }

    if(trigger.isInsert && trigger.isBefore){
        TaskTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    if(trigger.isInsert && trigger.isAfter){
        TaskTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        TaskTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isBefore){
        TaskTriggerHandler.handleBeforeDelete(Trigger.old);
    }
}