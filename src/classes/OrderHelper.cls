global class OrderHelper{


    webservice static string submitOrder(String ordId){
      
      List<OrderLocation__c> ordLocLst = new List<OrderLocation__c>();
      String message = 'Failure';
      Map<String, decimal> productQtyMap = new Map<String, decimal>();
      Set<String> ordAddress1 = new Set<String>();  
      Set<String> locs = new Set<String>();
      decimal qty = 0;
      Boolean containsHardware = false;
      try{
          Id OrderRecType = Schema.SObjectType.Orders__c.getRecordTypeInfosByName().get('Order Read Only').getRecordTypeId();          
          
          Orders__c ord = [Select Id, RecordTypeId, Order_Status__c,Order_Types__c, Customer_P_O__c, Promo_Code__c,Customer_Number__c, Opportunity__c, Account__r.GP_Account_Inactive__c, Opportunity__r.Discount_Code__c, Account__r.GP_Account_Hold__c, Account__r.Account_Service_Tier__c, Opportunity__r.Account.PO_Required__c,
                         (Select Quantity__c, Product_Code__c, Product_Name__c, Mismatch_Install__c, Location__c From Order_Details_Mappings__r), (Select Id, PO_Number__c, EO_Status__c, Order_Activity_Status__c, EO_OrderID__c From OrderLocations__r) From Orders__c where Id =: ordId];
          
          Map<String, Order_Promo_Codes__c> promoCodeMap =  Order_Promo_Codes__c.getAll(); // [Select Shipping_Method__c, Promo_Code__c, Order_Type__c, Name, Id From Promo_Code__c];
          
          List<OpportunityLineItem> oppProds = [Select Id, Product2Id, Product2.Name,Product2.ProductCode, Quantity, Category__c, UnitPrice from OpportunityLineItem where OpportunityId =: ord.Opportunity__c ];
        
          if(ord.OrderLocations__r.size() == 0){
              message = 'Please Add the Location';
              return message;
          }
          if(ord.Order_Details_Mappings__r.size() > 0){
            for(Order_Product__c ordProd : ord.Order_Details_Mappings__r){
                locs.add(ordProd.Location__c);
            }
             for(Location__c res : [Select Garage_Address1__c, Garage_City__c, Garage_State__c, Garage_Zip__c, Phone__c, ContactName__c From Location__c where Id IN : locs]){
                String GarageAddress1 = res.Garage_Address1__c;
                String GarageCity = res.Garage_City__c;
                String GarageState = res.Garage_State__c;
                String GarageZip = res.Garage_Zip__c;
                String Phone = res.Phone__c;
                String ContactName = res.ContactName__c;
                
                if ( GarageAddress1!= null && GarageAddress1.containsignoreCase('PO BOX') || GarageAddress1.containsignoreCase('POBOX') || GarageAddress1.containsignoreCase('PO-BOX') || GarageAddress1.containsignoreCase('PO_BOX') || GarageAddress1.containsignoreCase('POB') || GarageAddress1.containsignoreCase('P O box')){
                    message = 'Products cannot be shipping to PO Box';
                    return message;
                }
                if (GarageAddress1 == null){
                    message = 'Address Line1 is blank';
                    return message;
                }
                if (GarageCity == null){
                    message = 'Ship City is blank';
                    return message;
                }
                if (GarageState == null){
                    message = 'State/Province is blank';
                    return message;
                }
                if (GarageZip == null){
                    message = 'Zip Code is blank';
                    return message;
                }
                 if (Phone == null){
                    message = 'Ship Phone is blank';
                    return message;
                }
                
                if (ContactName == null){
                    message = 'Contact Name is blank';
                    return message;
                }
             }
          }
          
          if(ord.Order_Details_Mappings__r.size() == 0){
              message = 'Please Map the Products';
              return message;
          }
         
         if(ord.Order_Details_Mappings__r.size() > 0){
            for(Order_Product__c ordProd : ord.Order_Details_Mappings__r){
                if(ordProd.Quantity__c == null){
                    message = 'Product Quantity Cannot be blank';
                    return message;
                }
                 if(ordProd.Quantity__c == 0 || ordProd.Quantity__c < 0){
                    message = 'Please Enter Valid Quantity';
                    return message;
                }
                if(!ordProd.Product_Name__c.contains('D-INSTALL-UNIT')){
                   if(ordProd.Mismatch_Install__c) {          
                     if(ordProd.Product_Code__c.contains('-INS')){
                        ordProd.Product_Code__c = ordProd.Product_Code__c.replaceAll('-INS','-000');
                        ordProd.Product_Name__c = ordProd.Product_name__c.replaceAll('-INS', '-000');
                    }     
                  }     
                    
                    if(productQtyMap.get(ordProd.Product_Code__c) != null){
                              
                        productQtyMap.put(ordProd.Product_Code__c, productQtyMap.get(ordProd.Product_Code__c) + ordProd.Quantity__c);
                      }else{
                        productQtyMap.put(ordProd.Product_Code__c, ordProd.Quantity__c);
                    }
            }
            }
          } 
        
        
         
        for(OpportunityLineItem oli : oppProds){
        System.debug('productQtyMap:::'+productQtyMap+'--prodCode--'+oli.Product2.ProductCode+'--Qty--'+oli.Quantity+'productQtyMap.get(oli.Product2.ProductCode):::' +productQtyMap.get(oli.Product2.ProductCode));
            if(productQtyMap.get(oli.Product2.ProductCode) != null){
                qty =  oli.Quantity - productQtyMap.get(oli.Product2.ProductCode);
                if(qty > 0){
                    return 'All Products must be Mapped before submitting';
                    }
                    
                }else{
                     if(oli.Category__c != 'Service' && oli.Quantity > 0){
                     return 'All Products must be Mapped before submitting';
                
                     }
            }
            
        }  
          
        List<CPQ_Opportunity_Products__c> bundKitList = [Select Product_Record_Id__r.Name,Product_Record_Id__r.ProductCode , Product_Record_Id__r.CPQ_PRODUCT_NAME__c, Product_Record_Id__c, Bundle_Kit_ID__c, Sale_Type__c,
                                                Opportunity_Id__c, BUN_Qty__c, PUR_Qty__c , Product_Category__c, Id From CPQ_Opportunity_Products__c where Opportunity_Record_ID__c =:ord.Opportunity__c AND Bundle_Kit_ID__c != null];
        
        List<CPQ_Opportunity_Products__c> cpqProds = [Select Product_Record_Id__r.Name,Product_Record_Id__r.ProductCode , Product_Record_Id__r.CPQ_PRODUCT_NAME__c,Product_Record_Id__c, Bundle_Kit_ID__c, Sale_Type__c,
                                                Opportunity_Id__c, BUN_Qty__c, PUR_Qty__c, Product_Category__c, Id From CPQ_Opportunity_Products__c where Opportunity_Record_ID__c =:ord.Opportunity__c ];
        
       
        if(cpqProds.size() > 0){
            if(bundKitList.size() > 0)
                cpqProds = bundKitList;
            for(CPQ_Opportunity_Products__c cpq : cpqProds){
            decimal cpqQty;
            if(!((cpq.Product_Category__c == 'SOLUTION' || cpq.Product_Category__c == 'SERVICE') && cpq.Sale_Type__c == 'PURCHASE')){
            if(cpq.Sale_Type__c == 'BUNDLE'){
                cpqQty = cpq.BUN_Qty__c;
            }else{
                cpqQty = cpq.PUR_Qty__c;
            }
            
            String prodName = cpq.Bundle_Kit_Id__c != null ? cpq.Bundle_Kit_Id__c : cpq.Product_Record_Id__r.Name ;
            String productCode = cpq.Bundle_Kit_Id__c != null ? cpq.Bundle_Kit_Id__c : cpq.Product_Record_Id__r.ProductCode;
            if(prodName != null && prodName.contains('*CPQ ONLY* DO NOT USE -')){
                 prodName = prodName.substring(24);
             }
            
            if(cpq.Product_Category__c == 'Hardware'){
            containsHardware = true;
            }
                         
            System.debug('productQtyMap:::'+productQtyMap+'--prodCode--'+productCode+'--cpqQty--'+cpqQty+'productQtyMap.get(productCode):::' +productQtyMap.get(productCode));
                if(productQtyMap.get(productCode) != null){
                    qty = cpqQty - productQtyMap.get(productCode);
                    if(qty > 0){
                        System.debug('Qty::'+qty);
                        return 'All Products must be Mapped before submitting';
                        }
                        
                    }else{
                        if(cpq.Product_Category__c != 'SERVICE' && cpq.Product_Category__c != 'SOLUTION' && cpqQty > 0){
                 
                        return 'All Products must be Mapped before submitting';
                   
                        }
                
                }
            
            }
           } 
            
        }
          
          
          if(ord.Account__r.GP_Account_Inactive__c == true || ord.Account__r.GP_Account_Hold__c == true){
            ord.Order_Status__c = 'Account Hold';           
            message =  'Account status is on Hold or Inactive';
            update ord;
            return message;
          }
          
          /*if(ord.Account__r.Account_Service_Tier__c == null){
           message =  'Account Setup is not completed! Account Service Tier is Blank';
           return message;
          }*/
          if(ord.Opportunity__r.Account.PO_Required__c == true){
              for(OrderLocation__c ordLoc : ord.OrderLocations__r){
            if(ordLoc.PO_Number__c == null){
                message = 'Please Enter PO number';
                return message;
             }
            }
          }
          
          if(ord.Order_Types__c != null && promoCodeMap.get(ord.Order_Types__c) != null){
            ord.Promo_Code__c = promoCodeMap.get(ord.Order_Types__c).Promo_Code__c; // 'AHYAAN005';
            ord.Shipping_Methods__c = promoCodeMap.get(ord.Order_Types__c).Shipping_Method__c; // 'FREE SHIPPING';
          }
         /* if(ord.Order_Types__c != null && ord.Order_Types__c.equalsignoreCase('MIGRATE')){
            ord.Promo_Code__c = 'KHYEAN001';
          }
          if(ord.Order_Types__c != null && (ord.Order_Types__c.equalsignoreCase('BUNDLE') || ord.Order_Types__c.equalsignoreCase('BU-EXCHANG')|| ord.Order_Types__c.equalsignoreCase('BU-UPGRADE'))){
            ord.Promo_Code__c = 'KHYEAN001';
          }
          if(ord.Order_Types__c != null && ord.Order_Types__c.equalsignoreCase('PILOT')){
            ord.Promo_Code__c = '';
            ord.Shipping_Methods__c = 'FREE SHIPPING';
          }
          if(ord.Order_Types__c != null && ord.Order_Types__c.equalsignoreCase('RA-WTY-ACC')){
            ord.Promo_Code__c = 'AHYAAN002';
           ord.Shipping_Methods__c = 'FREE SHIPPING';
          }*/
          
          if(ord.Order_Types__c != null && ord.Order_Types__c.equalsignoreCase('STDORD')){
             if(ord.Opportunity__r.Discount_Code__c != null){
                ord.Promo_Code__c = ord.Opportunity__r.Discount_Code__c;
              }
              if(ord.Customer_Number__c != null && ord.Customer_Number__c.endsWith('S') && containshardware){
                message = 'Please correct the Customer Number';
                return message;
            }
          }
          if(ord.Order_Types__c != null && ord.Order_Types__c.equalsignoreCase('Bundle')){
            if(ord.Customer_Number__c != null && !ord.Customer_Number__c.endsWith('S')){
                message = 'Please correct the Customer Number';
                return message;
            }
          }
         
          ord.Order_Status__c  = 'Submitted';
          ord.RecordTypeId = OrderRecType;
          if(ord.OrderLocations__r.size() > 0){
              for(OrderLocation__c ordLoc : ord.OrderLocations__r){
                  ordLoc.EO_Status__c = 'Submitted';
                  ordLoc.Order_Activity_Status__c = 'Submitted';
                  ordLocLst.add(ordloc);
              }
              
              if(ordLocLst.size() > 0){
              Database.update(ordLocLst, false);
              }
              
          }
          
          update ord;
          
          message = 'Success';
          
          return message;
      
      }catch(Exception ex){
          return message;
      }
      
    }
     webservice static string cancelOrder(String ordId){
      
      List<OrderLocation__c> ordLocLst = new List<OrderLocation__c>();
      try{  
         Id OrderRecType = Schema.SObjectType.Orders__c.getRecordTypeInfosByName().get('Order Read Only').getRecordTypeId();
          
          Orders__c ord = [Select Id, Order_Status__c, RecordTypeId, (Select Id, EO_Status__c From OrderLocations__r) From Orders__c where Id =: ordId];
          
          ord.RecordTypeId = OrderRecType;
          ord.Order_Status__c  = 'Cancelled';
          
          if(ord.OrderLocations__r.size() > 0){
              for(OrderLocation__c ordLoc : ord.OrderLocations__r){
                  ordLoc.EO_Status__c = 'Cancelled';
                   ordLoc.Order_Activity_Status__c = 'Cancelled';
                  ordLocLst.add(ordloc);
              }
              
              if(ordLocLst.size() > 0){
              Database.update(ordLocLst, false);
              }
              
          }
          
          update ord;
          
          return 'Success';
      
      }catch(Exception ex){
          return 'Failure';
      }
      
    }
  
 }