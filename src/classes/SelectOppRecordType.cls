public with sharing class SelectOppRecordType {
    Boolean isOnGpHold {get;set;}

    public SelectOppRecordType(ApexPages.StandardController controller) {
        String accountId = ApexPages.currentPage().getParameters().get('accid');  
        isOnGpHold = false;      
        if (!String.isBlank(accountId)){
            List<Account> accountList = [SELECT GP_Account_Hold__c FROM Account WHERE id = : accountId ];
            if(accountList.size() > 0){
                if(accountList[0].GP_Account_Hold__c == true){
                    isOnGpHold = true;
                }
            }
        }

    }

    public List<RecordType> RecordTypes
    {
        get
        {
                if(RecordTypes == null)
                {
                        RecordTypes = [select id,name,description from recordtype where sobjecttype='Opportunity' and isActive = true and id IN :RecordTypeInfos.keyset() order by name];
                        
                }
                return RecordTypes;
        }
        set{}           
    }
    
    public static Map<Id,Schema.RecordTypeInfo> RecordTypeInfos
    {
        get
        {
                        if(RecordTypeInfos == null)
                 {   
                        RecordTypeInfos = new Map<Id,Schema.RecordTypeInfo>();
                        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
                        Map<Id,Schema.RecordTypeInfo> infos = d.getRecordTypeInfosById();
                        if (infos.size() >= 1) {
                                
                                for (Id i : infos.keyset()) {
                                        // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                                        // We check the Id because Name can change depending on the user's language.
                                        if (infos.get(i).isAvailable() && !String.valueOf(infos.get(i).getRecordTypeId()).endsWith('AAA'))
                                        {
                                                RecordTypeInfos.put(i,infos.get(i));
                                        }                       
                                }
                        } 
                 }
                 return RecordTypeInfos;                 
        }
        set {}    
    }
       
    
    //Selected record type for the new opportunity
    public string SelectedRecordType {get;set;}
    
    public List<selectoption> GetOppRecordTypes() {
        
        List<selectOption> OppRecordTypes = new List<SelectOption>();
        for(RecordType rt: RecordTypes) {
            if (rt.Name != 'Pilot Opportunity') {
                SelectOption opt = new SelectOption(rt.id, '<b>'+ rt.Name+ '</b>' + ' - ' + rt.description);
                opt.setEscapeItem(false);
                OppRecordTypes.add(opt);
            }
        }
        
        return OppRecordTypes;
    }
    
    public PageReference Cancel() {
        
        PageReference pageRef = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));        
        
        return pageRef;
    }
    
    public PageReference RedirectBasedonRecordType()
    {
         Boolean isValid=true;
         if(String.isEmpty(SelectedRecordType))
         {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Select a Record Type.'));
                isValid = false;
         }

        if(RecordTypeInfos.get(SelectedRecordType) != null && RecordTypeInfos.get(SelectedRecordType).getName().equalsIgnoreCase('Sales Opportunity') && isOnGpHold){
             
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The Account for this Opportunity is on Hold. You cannot create a new Opportunity at this time.'));
             isValid = false;
         } 
    
         if(isValid)
         {
                PageReference pageRef = new PageReference('/apex/CreateChildOpportunity?ent=Opportunity');
                PageRef.getParameters().put('retURL',ApexPages.currentPage().getParameters().get('retURL'));
                pageRef.getParameters().put('RecordType',SelectedRecordType);
         
                return pageRef;
         }
         return null;
    } 
     
}