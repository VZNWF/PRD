public with sharing class OrdersLocationsController {
    
    String OrdLocId;
    public String ordId{get; set;}
    public OrderLocation__c ordLoc {get;set;}
    
    public OrdersLocationsController(ApexPages.StandardController controller) {
        
        if(((OrderLocation__c)controller.getRecord()).Id != null){
        ordLocId = ((Orders__c)controller.getRecord()).Id;
        ordLoc = [Select Id, Name, Orders__c from OrderLocation__c where Id =: ordLocId Limit 1];
        ordId = ordLoc.Orders__c;
        }else{
        ordLoc = new OrderLocation__c();
        }
        
        if(System.currentPageReference().getParameters().get('ordId') != null){
            ordId = System.currentPageReference().getParameters().get('ordId');
            ordLoc.Orders__c = ordId;
        }
    }
    
    public PageReference save(){
        try{
        upsert ordLoc;
        PageReference pgRef = new PageReference('/'+ordId); 
        return pgRef;
        
        }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
            
        return null;
    }
    
     public PageReference cancel(){
        
        PageReference pgRef = new PageReference('/'+ordId);     
    
        return pgRef;
    }

}