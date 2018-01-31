public class OrderCloneWithItemsController {

    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    private Orders__c ord {get;set;}
    // set the id of the record that is created 
    public ID newRecordId {get;set;}

    public OrderCloneWithItemsController(ApexPages.StandardController controller) {
    
         //initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        ord = (Orders__c)controller.getRecord();

    }
    
    public PageReference cloneWithItems() {

         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Orders__c newOrd;

         try {

              //copy the purchase order - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             ord = [select Id, Name, Account__c, Contact__c, Customer_Email__c, GP_ERP_Order_ID__c, Installation_Coordinator__c  from Orders__c where id = :ord.id];
             newOrd = ord.clone(false);
             insert newOrd;

             // set the id of the new ord created for testing
               newRecordId = newOrd.id;

             // copy over the line items - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
             List<Order_Line_Items__c> items = new List<Order_Line_Items__c>();
             for (Order_Line_Items__c oli : [Select p.Id, p.GP_ERP_Order_Id__c, p.Installation_Type__c, p.Orders__c From Order_Line_Items__c p where Orders__c = :ord.id]) {
                  Order_Line_Items__c newOli = oli.clone(false);
                  newOli.Orders__c = newOrd.id;
                  items.add(newOli);
             }
             insert items;

         } catch (Exception e){
             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/'+newOrd.id+'/e?retURL=%2F'+newOrd.id);
    }


}