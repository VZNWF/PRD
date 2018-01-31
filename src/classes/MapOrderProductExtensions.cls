/*******************************************************************************
// Copyright (c) 2017 All Right Reserved
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY 
// KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
// NON-DISTRIBUTABLE: WITHOUT PRIOR WRITTEN PERMISSION FROM AUTHER THIS CODE
// ITS LOGIC OR ANY PART OF IT IS NOT REPRODUCABLE. 
// -----------------------------------------------------------------------------
// Author:          Satish Prasad
// File Name:       MapOrderProductExtensions 
// Summary:         Trigger Handler class for CPQ Line Item
// Created On:      FEB-21-2017

// Modification Log:
====================
//Satish    - 02/21/2017 - Created a base version of MapOrderProductExtensions class 
*******************************************************************************/

public with sharing class MapOrderProductExtensions {
 
    public String ordId;
    public List<OrderHelper> ordList{get; set;}
    public List<OrderHelper> ordListToDisp {get; set;}
    Map<Id, OrderLocation__c> ordLocsMap;
    @TestVisible
    List<SelectOption> locOptions;
    @TestVisible
    List<SelectOption> prodOptions;
    Map<String, AvailProdLog> uniqueProdNamesMap = new Map<String, AvailProdLog>();
    public List<AvailProdLog> avlProdLst{get; set;}
    Map<String, String> mapProdCode = new Map<String, String>();
    Map<String, decimal> mapProdPrice = new Map<String, decimal>();
    Map<String, decimal> productQtyMap = new Map<String, decimal>();
    public List<Order_Product__c > ordMapsToSave{get; set;}
    public boolean showInstQty {get; set;}
    public decimal totInstQty {get; set;}
    Map<String, CPQ_Opportunity_Products__c> prodWithCPQprods = new Map<String, CPQ_Opportunity_Products__c>();
    
    private Map<String, decimal> mapInstQty = new Map<String, decimal>();
    
    public MapOrderProductExtensions(ApexPages.StandardController controller) {
          ordListToDisp = new List<OrderHelper>();
          loadOrderLocations(); 
    }
    
    
    public void loadOrderLocations(){
        ordList = new List<OrderHelper>();
        locOptions = new List<SelectOption>();
        prodOptions = new List<SelectOption>();
        uniqueProdNamesMap = new Map<String, AvailProdLog>();
        prodOptions.add(new SelectOption('', '--None--'));
        locOptions.add(new SelectOption('', '--None--'));
        avlProdLst = new List<AvailProdLog>();
        AvailProdLog avlLog; 
        mapProdCode = new Map<String, String>();
        mapProdPrice = new Map<String, decimal>();
        productQtyMap = new Map<String, decimal>();        
        ordMapsToSave = new List<Order_Product__c >();
        totInstQty = 0;
        
        if(ApexPages.currentPage().getParameters().get('OrdId') != null){
            ordId = ApexPages.currentPage().getParameters().get('OrdId');
            
        Orders__c ord = [Select Id, Opportunity__c, Opportunity__r.HasCPQProducts__c, (Select Quantity__c, Product_Code__c, Product_Name__c, Mismatch_Install__c From Order_Details_Mappings__r) from Orders__c where Id =: ordId];    
        
        if(ord.Order_Details_Mappings__r.size() > 0){
            for(Order_Product__c ordProd : ord.Order_Details_Mappings__r){
                
                if(ordProd.Mismatch_Install__c) {
                    totInstQty += ordProd.Quantity__c; 
                    
                    if(ordProd.Product_Code__c.contains('-INS')){
                        ordProd.Product_Code__c = ordProd.Product_Code__c.replaceAll('-INS','-000');
                        ordProd.Product_Name__c = ordProd.Product_name__c.replaceAll('-INS', '-000');
                    }                 
                }
                
                if(!(ordProd.Product_Code__c.contains('true') && ordProd.Product_Code__c.contains('false')) && ord.Opportunity__r.HasCPQProducts__c){
                    ordProd.Product_Code__c += ordProd.Mismatch_Install__c;
                }
                                
                if(productQtyMap.get(ordProd.Product_Code__c) != null){
                    productQtyMap.put(ordProd.Product_Code__c, productQtyMap.get(ordProd.Product_Code__c) + ordProd.Quantity__c);
                }else{
                    productQtyMap.put(ordProd.Product_Code__c, ordProd.Quantity__c);
                }
            }
        } 
        
        System.debug('productQtyMap:::'+productQtyMap); 
        ordLocsMap = new Map<Id, OrderLocation__c>([Select Id, Location__c, Location__r.Name from OrderLocation__c where Orders__c =: ordId ORDER BY Location__r.Name]) ;
        for(OrderLocation__c ol : ordLocsMap.values()){        
        locOptions.add(new SelectOption(ol.Id, ol.Location__r.Name));        
        } 
        
        List<OpportunityLineItem> oppProds = [Select Id, Product2Id, Product2.Name,Product2.ProductCode, Quantity, UnitPrice, Category__c from OpportunityLineItem where OpportunityId =: ord.Opportunity__c ];
        
        
        if(oppProds.size() > 0){
        for(OpportunityLineItem oli : oppProds ){
        if(!(oli.Category__c == 'Service')){
             decimal qty = 0;
            
               
            mapProdCode.put(oli.Product2.Name, oli.Product2.ProductCode);  
            mapProdPrice.put(oli.Product2.Name, oli.UnitPrice); 
            System.debug('prodName:::'+oli.Product2.Name+'---productQtyMap::'+productQtyMap+'---productQtyMap.get(oli.Product2.Name):::'+productQtyMap.get(oli.Product2.Name));
            if(productQtyMap.get(oli.Product2.ProductCode) != null){
                qty =  (oli.Quantity - productQtyMap.get(oli.Product2.ProductCode));
                productQtyMap.put(oli.Product2.ProductCode, qty);
            } else{
            qty = oli.Quantity;
            productQtyMap.put(oli.Product2.ProductCode, oli.Quantity);
            }
            
            System.debug('prodQtyMap::'+productQtyMap);
            
            System.debug('productCode::'+oli.Product2.ProductCode+'---Avl Qty--'+qty);
            if(!uniqueProdNamesMap.containsKey(oli.Product2.ProductCode)){
            prodOptions.add(new SelectOption(oli.Product2.ProductCode, oli.Product2.ProductCode)); 
            avlLog = new AvailProdLog(oli.Product2.Name, oli.Product2.ProductCode, oli.Quantity, qty, false);
            uniqueProdNamesMap.put(oli.Product2.ProductCode, avlLog);
            }else{
                        
            avlLog = uniqueProdNamesMap.get(oli.Product2.ProductCode);
            avlLog.qty += oli.Quantity;
            avlLog.avlQty += oli.Quantity;
            uniqueProdNamesMap.put(oli.Product2.ProductCode, avlLog);
            }
            }
        } 
            if(uniqueProdNamesMap.size() > 0){
            avlProdLst = uniqueProdNamesMap.values();
            }
        System.debug('avlProdLst:::'+avlProdLst);
        }
        
        List<CPQ_Opportunity_Products__c> bundKitList = [Select Product_Record_Id__r.Name,Product_Record_Id__r.ProductCode , Product_Record_Id__c, Product_Category__c, Bundle_Kit_ID__c, Sale_Type__c,
                                                Opportunity_Id__c, BUN_Qty__c, BUN_MRC_List__c, PUR_Qty__c, Primary__c, PUR_MRC_List__c,Mismatch_Install__c, Id From CPQ_Opportunity_Products__c where Opportunity_Record_ID__c =:ord.Opportunity__c AND (Bundle_Kit_ID__c != null OR (Product_Category__c = 'INSTALL' AND Mismatch_Install__c = true))];
        
        List<CPQ_Opportunity_Products__c> cpqProds = [Select Product_Record_Id__r.Name,Product_Record_Id__r.CPQ_PRODUCT_NAME__c,Product_Record_Id__r.ProductCode , Product_Category__c, Product_Record_Id__c, Bundle_Kit_ID__c, Sale_Type__c,
                                                Opportunity_Id__c, BUN_Qty__c, BUN_MRC_List__c, PUR_MRC_List__c, PUR_Qty__c, Primary__c, Mismatch_Install__c, Id From CPQ_Opportunity_Products__c where Opportunity_Record_ID__c =:ord.Opportunity__c OR (Opportunity_Record_ID__c =:ord.Opportunity__c AND Product_Category__c = 'INSTALL' AND Mismatch_Install__c = true) ];
        
        if(cpqProds.size() > 0){
            if(bundKitList.size() > 0)
                cpqProds = bundKitList;
            for(CPQ_Opportunity_Products__c cpq : cpqProds){
            decimal qty;
            decimal cpqQty;
            decimal price;
            if(cpq.Primary__c == true){
            if(!((cpq.Product_Category__c == 'SOLUTION' || cpq.Product_Category__c == 'SERVICE') && cpq.Sale_Type__c == 'PURCHASE')){
            if(cpq.Sale_Type__c == 'BUNDLE'){
                cpqQty = cpq.BUN_Qty__c;
                price = cpq.BUN_MRC_List__c;
            }else{
                cpqQty = cpq.PUR_Qty__c;
                price = cpq.PUR_MRC_List__c;
            }
             String prodName = cpq.Bundle_Kit_Id__c != null ? cpq.Bundle_Kit_Id__c : cpq.Product_Record_Id__r.Name ;
             String productCode = cpq.Bundle_Kit_Id__c != null ? cpq.Bundle_Kit_Id__c + cpq.Mismatch_Install__c: cpq.Product_Record_Id__r.ProductCode + cpq.Mismatch_Install__c;
             
             
             
             
             if(prodName != null && prodName.contains('*CPQ ONLY* DO NOT USE -')){
                 prodName = prodName.substring(24);
             }
             
             String nameProd = productCode.replaceALL('true','').replaceAll('false','').trim(); 
             prodWithCPQprods.put(nameProd, cpq);
             
             System.debug('productCode:::'+productCode+'---productQtyMap::'+productQtyMap+'---cpqQty::::'+cpqQty+'---------productQtyMap.get(productCode):::'+productQtyMap.get(productCode));
             mapProdCode.put(prodName, productCode); 
             mapProdPrice.put(prodName, price);
             
              if(productQtyMap.get(productCode) != null ){
                qty = cpqQty - productQtyMap.get(productCode);
                productQtyMap.put(productCode, qty);
              } else{  
              qty = cpqQty;           
              productQtyMap.put(productCode, cpqQty);
              }
              
              if(cpq.Product_Record_Id__r.ProductCode == 'D-INSTALL-UNIT'){
                qty = cpqQty - totInstQty;
                if(qty < 0){
                qty = 0;
                }
                mapInstQty.put('D-INSTALL-UNIT', qty);
             }
                
                         
               if(uniqueProdNamesMap.containsKey(productCode) && uniqueProdNamesMap.get(productCode).mismatch == cpq.Mismatch_Install__c){
               avlLog = uniqueProdNamesMap.get(productCode);
                avlLog.qty += cpqQty;
                avlLog.avlQty += cpqQty;
                avlLog.mismatch = cpq.Mismatch_Install__c;
                uniqueProdNamesMap.put(productCode, avlLog);
               }else{
                prodOptions.add(new SelectOption(nameProd, nameProd));
                
                avlLog = new AvailProdLog(prodName, nameProd, cpqQty, qty, cpq.Mismatch_Install__c);
                if(cpq.Mismatch_Install__c){
                showInstQty = true;
                avlLog.mismatch = true;
                }
                uniqueProdNamesMap.put(productCode, avlLog);
                
              }
            }
            }
            }
              if(uniqueProdNamesMap.size() > 0)
              avlProdLst =  uniqueProdNamesMap.values(); 
              
              
        }        
        
        }
        System.debug('mapProdCode::'+mapProdCode);
     }
    
    public void AddProduct(){
        prodOptions.clear();
        prodOptions.add(new SelectOption('', '--None--'));
        for(AvailProdLog avl : avlProdLst){
           if(avl.avlQty > 0 && !(avl.mismatch && avl.prodCode.contains('D-INSTALL-UNIT'))){
           prodOptions.add(new SelectOption(avl.prodName, avl.prodName));
           }
        } 
           
        //locOptions = sortSelectOptionList(locOptions);
        
        ordList.add(new OrderHelper(new Order_Product__c(Order_Details__c = ordId), locOptions, prodOptions, ordList.size() ));
    }
    
    public Pagereference deleteRow(){
        System.debug('Value--->' +ApexPages.CurrentPage().getParameters().get('rowid'));
        Integer SelectedRowId= Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowid'));
        System.debug('ordList.size()--->' +ordList.size());
        System.debug(SelectedRowId);
        
        for(Integer intVar=0; intVar < ordList.size(); intVar++){
            if(intVar>=SelectedRowId){
                Integer intCurrentCount = ordList.get(intVar).locationNumber - 1;
                ordList.get(intVar).locationNumber = intCurrentCount;
            }
        }
        
        ordList.remove(SelectedRowId);
        return null;
        /*
        for (Integer i = 0; i < ordList.size(); i++) {
            Order_Product__c a = ordList[i];
            //ordListToDisp a = rownum[i];
            if (a.Id == SelectedRowId) {
                //delete a;
                ordListToDisp.remove(i);
                break;
            }
        }*/
    }
    
    public Pagereference deleteOrderProductRow(){
        System.debug('Value--->' +ApexPages.CurrentPage().getParameters().get('rowid'));
        Integer SelectedRowId= Integer.valueOf(ApexPages.CurrentPage().getParameters().get('rowid'));
        System.debug('ordListToDisp.size()--->' +ordListToDisp.size());
                
        List<Order_Product__c> lstOP =[Select Id from Order_Product__c where Product_Code__c =:ordListToDisp.get(SelectedRowId).ord.Product_Code__c AND 
                                    Location__c =:ordListToDisp.get(SelectedRowId).ord.Location__c AND
                                    Sales_Price__c =:ordListToDisp.get(SelectedRowId).ord.Sales_Price__c AND
                                    Quantity__c =:ordListToDisp.get(SelectedRowId).ord.Quantity__c AND 
                                    Product_Name__c =:ordListToDisp.get(SelectedRowId).ord.Product_Name__c AND 
                                    OrderLocationMappings__c =:ordListToDisp.get(SelectedRowId).ord.OrderLocationMappings__c Order by createddate desc Limit 1];
        delete lstOP;
        
        for(Integer intVar=0; intVar < ordListToDisp.size(); intVar++){
            if(intVar>SelectedRowId){
                Integer intCurrentCount = ordListToDisp.get(intVar).locationNumber - 1;
                ordListToDisp.get(intVar).locationNumber = intCurrentCount <= 0 ? 0 :intCurrentCount;
                System.debug('intCurrentCount--->' +intCurrentCount +':::'+ intVar);
            }
        }
        
        ordListToDisp.remove(SelectedRowId);
        loadOrderLocations();
        return null;
        
    }
    
  
    
    public PageReference saveMappings(){
        
        PageReference pg;
        
        boolean isRedirect = saveRecords();
        
        if(isRedirect){
            pg = new PageReference('/'+ordId);
            pg.setRedirect(true);        
        }
            
        return pg;
    }
    
    public boolean saveRecords(){ 
        
        Boolean isRedirect = true;
        
        //ordMapsToSave = new List<Order_Product__c >();
        Map<String, decimal> prodQty = new Map<String, decimal>();
        decimal currentQty;
            if(ordList.size() > 0){
                for(OrderHelper o : ordList){
                    
                     o.Ord.Product_Code__c =  mapProdCode.get(o.ord.Product_Name__c) != null ? mapProdCode.get(o.ord.Product_Name__c) : o.Ord.Product_Name__c;
                     
                     
                     if(prodWithCPQprods.get(o.ord.Product_Code__c) != null){
                        if(prodWithCPQprods.get(o.ord.Product_Code__c).Mismatch_Install__c){
                            o.ord.Product_Code__c += 'true';
                        }else{
                            o.ord.Product_Code__c +='false';
                        }
                    }
                    
                   /*  if(o.ord.Product_Name__c != null && o.ord.Product_Name__c.startswith('D-')){
                        if(o.InstQty > 0)
                        o.ord.Product_Name__c += 'true';
                        else{
                        o.ord.Product_Name__c += 'false';
                        }
                    }*/
                    currentQty = o.Ord.Quantity__c != null ? o.ord.Quantity__c : 0;
                    if(prodQty.size() > 0 && prodQty.get(o.ord.Product_Code__c) != null){
                        currentQty += prodQty.get(o.ord.Product_Code__c);
                    }
                   
                    
                    if(o.InstQty > mapInstQty.get('D-INSTALL-UNIT')){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Install Quantity cannot be greater than available Installation Quantity.'));
                        isRedirect = false;
                    }
                                        
                    if(mapInstQty.get('D-INSTALL-UNIT') >0 && o.ord.Quantity__c >0 && o.InstQty < 1){
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Kits with Installations MUST be entered first. Installation Qty must be completely allocated'));
                        isRedirect = false; 
                    }
                    
                    if(o.InstQty != null && o.InstQty > 0 && o.ord.Quantity__c != o.InstQty){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Install Quantity should be same as Product Quantity'));
                        isRedirect = false; 
                     }
                    
                    System.debug('uniqueProdNamesMap::'+uniqueProdNamesMap);  
                    System.debug('uniqueProdNamesMap.get(o.Ord.Product_Code__c)::'+uniqueProdNamesMap.get(o.Ord.Product_Code__c) +'::o.ord.Quantity__c:'+o.ord.Quantity__c);
                    if(uniqueProdNamesMap.get(o.Ord.Product_Code__c) != null && uniqueProdNamesMap.get(o.Ord.Product_Code__c).avlQty < currentQty){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected Quantity cannot be greater than the Balance quantity'));
                        isRedirect = false;                        
                    }
                    if(o.ord.Quantity__c == null || o.ord.Quantity__c < 1){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Quantity'));
                          isRedirect = false; 
                    }
                    if(o.ord.OrderLocationMappings__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select the Location'));
                         isRedirect = false; 
                    }
                    if(o.ord.Product_Code__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select the Product'));
                          isRedirect = false; 
                    }
                    if(currentQty <= 0){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter Quantity Correctly'));
                          isRedirect = false; 
                    }
                    
                    if(isRedirect){
                    prodQty.put(o.ord.Product_Code__c, currentQty);
                    System.debug('mapProdCode::'+mapProdCode);
                   
                    o.Ord.Location__c = ordLocsMap.get(o.ord.OrderLocationMappings__c) != null ? ordLocsMap.get(o.ord.OrderLocationMappings__c).Location__c : null;
                    o.Ord.Sales_Price__c = mapProdPrice.get(o.ord.Product_Name__c) != null ? mapProdPrice.get(o.ord.Product_Name__c) : null;
                    o.Ord.Mismatch_Install__c = uniqueProdNamesMap.get(o.Ord.Product_Code__c) != null ? uniqueProdNamesMap.get(o.Ord.Product_Code__c).mismatch : false;
                    o.ord.Product_Code__c = o.ord.Product_Code__c.replaceALL('true','').replaceALL('false','').trim();                    
                    
                    System.debug('Mismatch::'+o.Ord.Mismatch_Install__c+'--ProductCode::'+o.ord.Product_Code__c+'--mapInstQty--'+mapInstQty);
                   if(o.Ord.Mismatch_Install__c && o.ord.Product_Code__c.endswith('-000') && mapInstQty.get('D-INSTALL-UNIT') > 0 ){
                        o.ord.Product_Code__c = o.ord.Product_Code__c.reverse().replaceFirst('000-','SNI-').reverse();
                        o.ord.Product_Name__c = o.ord.Product_Name__c.reverse().replaceFirst('000-', 'SNI-').reverse();
                    }
                    System.debug('o.ord.Product_Code__c::'+o.ord.Product_Code__c);
                   
                    ordMapsToSave.add(o.Ord);  
                     //IT-1965 - Changes for Delete link issue
                    OrderHelper otemp = o;
                    otemp.locationNumber = ordListToDisp.size();
                    ordListToDisp.add(otemp);
                    }else{
                    ordListToDisp.clear();
                    ordMapsToSave.clear();
                    }
                                  
                }
                
                if(ordMapsToSave.size() > 0){
                 // try{  
                  insert ordMapsToSave;                  
                  isRedirect = true;
                /*  }catch(Exception ex){
                  ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                   isRedirect = false;
                   ordListToDisp.clear();
                  }*/
               }
         }else{
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please add products to save.'));
             isRedirect = false;
          } 
         
         return isRedirect;          
    }
    
    public class OrderHelper{
        
        public Order_Product__c ord{get; set;}        
        public List<SelectOption> locLst{get; set;}
        public String locationId {get; set;}
        public String prodcode {get; set;}
        public Integer instQty {get;set;}
        public List<SelectOption> prodLst{get; set;}
        public Integer locationNumber {get; set;}
        
        public OrderHelper(Order_Product__c ordM, List<SelectOption> locs, List<SelectOption> pLst, Integer orderCount){
            ord = ordM;    
            locLst = locs;
            prodLst = pLst;
            locationNumber = orderCount;
        }
        
    }
    
    public class AvailProdLog{
    
        public String prodName {get; set;}
        public String prodCode {get; set;}
        public decimal qty {get; set;} 
        public decimal avlQty {get; set;}
        public boolean mismatch {get;set;}
        
        public AvailProdLog(String name, String pCode, decimal quant, decimal aQty, boolean nomatch){
            prodName = name;
            qty = quant;
            avlQty = aQty;
            prodCode = pCode;
            mismatch = nomatch;
        }      
        
    }
    
    public PageReference quickSave(){
        boolean isRedirect = saveRecords();
        
        if(isRedirect){
        loadOrderLocations();
        }
        return null;
        
    }
    
    public PageReference cancel(){
        PageReference pgRef = new PageReference('/'+ordId);
        return pgRef;
    }
    
   /* public List<SelectOption> sortSelectOptionList(List<SelectOption> source)
    {
        List<string> sortable = new  LIst<string>();
        for(SelectOption so: source)
        {
            // replace blank with '_!' so we know the final split will have two components
            sortable.Add((string.isblank(so.getLabel())?'_!':so.getLabel()) + '@!@' + (string.isblank(so.getValue())?'_!':so.getValue()));
        }
        // sort the list
        sortable.sort();
        List<SelectOption> targetList = new  List<SelectOption>();
        //targetList.add(new SelectOption('', '--None--'));

        // split the value/name components and re create the list
        for(string s: sortable)
        {
                targetList.Add(new  SelectOption(s.split('@!@')[1].replace('_!',''), s.split('@!@')[0].replace('_!','')));
         
        }
        return targetList;
    } */
}