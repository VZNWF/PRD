trigger Workforce2_CreateInventoryMessageForOrder_Line_Item_Details_c on Order_Line_Item_Details__c (after insert, after update, before delete){

     if(TOA2.Workforce2_Ctrl.fromExternalSystem()) return;
     Toggle_Switch__c trgSw = Toggle_Switch__c.getInstance('Workforce2_OLID');
     //Skip trigger if it is disabled using custom setting 
     if(trgSw.isTriggerDisabled__c) return;

     List<Order_Line_Item_Details__c> Order_Line_Item_Details_cList=(Trigger.isDelete?Trigger.old:Trigger.new);
     Map<Id,sObject> messages = new Map<Id,sObject>();

     final String keyField=TOA2.Workforce2_Ctrl.getActivityIdField('Order_Line_Item_Details__c','inventory');

     if(Trigger.old!=null)
        for (sObject obj : Trigger.old){
            try{
                    final Object id=obj.get(keyField);
                    if(id!=null)
                         messages.put(obj.Id,new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+(String)id,
                                                                                                    TOA2__appt_number__c=(String)id,
                                                                                                    TOA2__UpdateInventory__c=true));
                                                                                                   
                }catch(Exception exc){
                    obj.addError(exc.getMessage());
               }
        }
     if(Trigger.new!=null)
        for (sObject obj : Trigger.new){
            try{
                    if(messages.containsKey(obj.Id)) continue;
                    final Object id=obj.get(keyField);
                    if(id!=null)
                         messages.put(obj.Id,new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+(String)id,
                                                                                                    TOA2__appt_number__c=(String)id,
                                                                                                    TOA2__UpdateInventory__c=true));
                                                                                                   
                }catch(Exception exc){
                    obj.addError(exc.getMessage());
               }
        }       
        
     if(messages.size()>0)
        insert messages.values();
 }