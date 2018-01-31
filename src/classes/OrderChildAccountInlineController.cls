Public Class OrderChildAccountInlineController{
    Public String StrOrderid{get;set;}
    public Id accountId {get;set;}
    public Id accId;
    Public Orders__c ord{get;set;}
    Public Boolean showvalues{get;set;}
   
    Public OrderChildAccountInlineController(Apexpages.StandardController Ctrl){
    
        StrOrderid = apexpages.currentpage().getparameters().get('id');                                   
        ord = new Orders__c();
        ord = [SELECT Id,Child_Account__c,Child_Account__r.Seller_Key__c,Account_Sub_type__c,Account__r.Seller_Key__c,Account__c FROM Orders__c WHERE Id=:StrOrderid];               
        accountId = ord.Child_Account__c;    
        accId = ord.Account__c;
        
        // ord.Child_Seller_Key__c = ord.Child_Account__r.Seller_Key__c;       
      //  ord.Seller_Key__c = ord.Account__r.Seller_Key__c;
        List<Account> ListParentAccount  = new List<Account>();
        ListParentAccount = [ SELECT Id,parentId,Name FROM Account WHERE (Sub_Type__c='VAR' OR Sub_Type__c ='RESELLER' OR Sub_Type__c ='RESELLER-PP') AND Id=:accId ];   
        if(ListParentAccount.size()>0){
            if(ord.Account__r.Seller_Key__c!=null){
                       // ord.Seller_Key__c = ord.Account__r.Seller_Key__c;           
            }
            List<Account> ListChildAccount  = new List<Account>(); 
            ListChildAccount = [SELECT Id,parentId,Name FROM Account WHERE ParentId=:ListParentAccount[0].Id];       
             if(ListChildAccount.size()>0){
                 showvalues = True;                                                    
               if(ord.Account__r.Seller_Key__c!=null && ord.Child_Account__r.Seller_Key__c!=null ) {
                    
                   // ord.Seller_Key__c = ord.Child_Account__r.Seller_Key__c;                        
             } 
             else{
                
             }                                                                                                              
        }
        else{
           // ord.Seller_Key__c = ord.Account__r.Seller_Key__c;     
        }                                                             
    }
  }
    
    Public List<SelectOption> getchildAccounts(){
 
         List<Account> LstParentAccount = new List<Account>();
         LstParentAccount =[SELECT Id,parentId,Name FROM Account WHERE (Sub_Type__c='VAR' OR Sub_Type__c ='RESELLER' OR Sub_Type__c ='RESELLER-PP') AND Id=:accId];
         List<SelectOption> options;
         if(LstParentAccount.size()>0){ 
          options = new List<SelectOption>();
             options.add(new SelectOption('noaccount', '--None--')); 
             System.debug('@@@@@LstParentAccount---'+LstParentAccount);
                     
                 for(Account acc: [SELECT Id,parentId,Name FROM Account WHERE ParentId=:LstParentAccount[0].Id]) {
                     options.add(new SelectOption(acc.Id, acc.Name));                            
                 }
                 
                 if(!options.IsEmpty() & LstParentAccount.size()>0 ){
                     showvalues = True;
                 
                 } 
                 else{
                     showvalues = False;
                 }                         
         }                                                                                                                        
       return options;   
    }
    
    Public Pagereference UpdateChildaccount(){
                     
        List<Orders__c> OrderLst = new List<Orders__c>(); 
        List<Orders__c> UpdateOrderLst = new List<Orders__c>();
        if(accountId!=null){
              
            OrderLst = [SELECT Id,Account__c,Child_Account__r.Seller_Key__c FROM Orders__c WHERE Id =:StrOrderid];         
        }
        
        Account selectedaccount =  [SELECT Id,Seller_Key__c FROM Account WHERE Id =:accountId];
                       
        if(OrderLst.size()>0){
            OrderLst[0].Child_Account__c = selectedaccount.Id; 
                       
           // OrderLst[0].Seller_Key__c= selectedaccount.Seller_Key__c;
                                       
            UpdateOrderLst.add(OrderLst[0]);                                    
        }
        if(UpdateOrderLst.size()>0){
            Update UpdateOrderLst;
        
        }   
        Pagereference pg = new Pagereference('/apex/OrderChildAccountInline?Id='+UpdateOrderLst[0].Id);
        pg.setredirect(True);    
        return pg;
        }   
}