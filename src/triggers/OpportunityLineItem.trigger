/********************************************************************************
Modifications:
9/4/13 - Krishna Tatta - Updated the trigger to handle updating the unit total of 
         		child opps on the parent opportunity when an opportunityLineItem  
         		on a child opp is deleted
9/10/2015 - Steve Swiger (Code|Science) - updated delete query ignore null parent
                Id values.
*********************************************************************************/


trigger OpportunityLineItem on OpportunityLineItem (before delete, after insert, after update) {

	if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
		
		CalculateChildOppsUnitTotal.Execute(Trigger.new);
	}
    else if(Trigger.isDelete && Trigger.isBefore) {

	     CalculateChildOppsUnitTotal.Execute(Trigger.Old);
	    
	    // -------------------------------------------------------------------------------
	    // Cascade deletes to child product line items.
	    // -------------------------------------------------------------------------------
           
        Set<String> parentIds = new Set<String>();
        for (OpportunityLineItem opportunityLineItem : Trigger.old) {            
            parentIds.add(opportunityLineItem.Id);
        }

        // Delete children.
        delete [select  Id 
                from    OpportunityLineItem 
                where   Parent_OpportunityLineItem_Id__c != null and 
                        Parent_OpportunityLineItem_Id__c in :parentIds];

    }    	
}