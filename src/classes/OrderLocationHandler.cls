/*******************************************************************************
// Modification Log:
====================

// Vanditha    - 6/9/2017 - Created Fedexlink method for Order Automation Project
//Satish       - 09/25/2017 - Cancel button issue fix
*******************************************************************************/

public class OrderLocationHandler{

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public OrderLocationHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void handleBeforeInsert(List<OrderLocation__c> newOrderLocs){
        Set<String> orderIds = new Set<String>();
        
        for(OrderLocation__c ordLoc : newOrderLocs){
            if(ordLoc.Orders__c != null)
            orderIds.add(ordLoc.Orders__c);
            
            if(ordLoc.Scribe_Status__c != null && ordLoc.Scribe_Status__c.equalsIgnoreCase('Failed')){
                ordLoc.Order_Activity_Status__c = 'Failed';
            }
        }
        
       if(orderIds.size() > 0){
        Map<String, Orders__c> ordsMap = new Map<String, Orders__c>([Select Id, Shipping_Methods__c from Orders__c where Id IN : orderIds]);
        
        for(OrderLocation__c ordLoc : newOrderLocs){
           if(ordsMap != null && ordsMap.get(ordLoc.Orders__c) != null && (ordLoc.Shipping_Method__c == null || ordLoc.Shipping_Method__c == '')) {
               System.debug('Inside OL trigger');
               ordLoc.Shipping_Method__c = ordsMap.get(ordLoc.Orders__c).Shipping_Methods__c;
           }
        }
        }
    }
    
    public void handleBeforeUpdate(List<OrderLocation__c> newOrderLocs){
        
        Map<Id, Orders__c> orders = new Map<Id, Orders__c>();
        for(OrderLocation__c ordLoc :  newOrderLocs){
            
            if(ordLoc.Scribe_Status__c != null && ordLoc.Scribe_Status__c.equalsIgnoreCase('Failed')){
                ordLoc.Order_Activity_Status__c = 'Failed';
            }
            
            if(ordLoc.Order_Activity_Status__c == 'Completed' || ordLoc.Order_Activity_Status__c == 'Cancelled' || ordLoc.Order_Activity_Status__c == 'Shipped' || ordLoc.Order_Activity_Status__c == 'Inventory HOLD' || ordLoc.Order_Activity_Status__c == 'Failed' || ordLoc.Order_Activity_Status__c == 'Processing' || ordLoc.Order_Activity_Status__c == 'CR Hold' || ordLoc.Order_Activity_Status__c == 'Pending' || ordLoc.Order_Activity_Status__c == 'Committed' || ordLoc.Order_Activity_Status__c == 'Hold'){
                
                if(ordLoc.Orders__c != null){
                orders.put(ordLoc.Orders__c, new Orders__c(Id = ordLoc.Orders__c, Order_Status__c = ordLoc.Order_Activity_Status__c));
                }
            }
        
        }
        
        if(orders.size() > 0){
            Database.update(orders.values(), false);
        }
    
    }
    
    public void Fedexlink(List<OrderLocation__c> newOrderTrack){
       
         String Srt1 = 'https://www.fedex.com/apps/fedextrack/?tracknumbers=' ;
         String Str2 = '&locale=en_US&cntry_code=us' ;
            for(OrderLocation__c Track :  newOrderTrack){
                   if( Track.Tracking_Numbers__c != null ){
                   
                    String strTrackNum = Track.Tracking_Numbers__c;
                    List<string> lststrTrackNum =strTrackNum.split(',');
                    Track.Tracking_Number_URL__c='';
                        for(string strtrack: lststrTrackNum) {
                            Track.Tracking_Number_URL__c  = Track.Tracking_Number_URL__c +( '<a href=' + Srt1 + strtrack + Str2 +'>' + strtrack + '</a>' +  '\n');
                        } 
                }       
            }       
        } 

        
}