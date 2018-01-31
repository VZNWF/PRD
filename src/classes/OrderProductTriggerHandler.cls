public class OrderProductTriggerHandler{

    public static void handleAfterInsert(Map<Id, Order_Product__c> newOrdProdMap){
    
        calcUniqProducts(newOrdProdMap.values());
    }
    
    public static void handleAfterUpdate(Map<Id, Order_Product__c> newOrdProdmap){
        calcUniqProducts(newOrdProdMap.values());
        
    }
    
    public static void handleAfterDelete(List<Order_Product__c> oldOrdProdList){
    
    calcUniqProducts(oldOrdProdList);
    
    }
    
    public static void handleAfterUndelete(List<Order_Product__c> newOrdProdList){
        calcUniqProducts(newOrdProdList);
        
    }  
      
    public static void calcUniqProducts(List<Order_Product__c> ordProdList){
        
        Set<String> ordActIds = new Set<String>();       
        List<OrderLocation__c> ordLocs = new List<OrderLocation__c>();
        
        for(Order_Product__c ordProd : ordProdList){
            if(ordProd.OrderLocationMappings__c != null){
                ordActIds.add(ordProd.OrderLocationMappings__c);
            }       
        }
        
        if(ordActIds.size() > 0){
            for(AggregateResult res : [Select Count(Id) cnt, OrderLocationMappings__c ordLoc from Order_Product__c where OrderLocationMappings__c IN : ordActIds Group By OrderLocationMappings__c]){
                Integer prodCount = Integer.valueOf(res.get('cnt'));
                String ordActId = String.valueOf(res.get('ordLoc'));
                OrderLocation__c ordLoc = new OrderLocation__c(Id = ordActId, Unique_Products__c = prodCount);
                ordLocs.add(ordLoc);
            }
        
        }
        
        if(ordLocs.size() > 0){
          Database.update(ordLocs, true);
        }
    
    }
    
}