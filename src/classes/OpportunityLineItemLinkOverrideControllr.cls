public with sharing class OpportunityLineItemLinkOverrideControllr {

    private OpportunityLineItem opportunityLineItem;
    private Opportunity opp;
    
    public OpportunityLineItemLinkOverrideControllr(ApexPages.StandardController controller) {
        opportunityLineItem = (OpportunityLineItem) controller.getRecord();

        if (opportunityLineItem.Id != null) {
            opportunityLineItem = [select Id, OpportunityId from OpportunityLineItem where Id = :opportunityLineItem.Id];
            opp = [select Id, Is_in_Approval_Process__c from Opportunity where Id = :opportunityLineItem.OpportunityId];
        }
    }

    public PageReference initPage() {
        if(opp != null && opp.Is_in_Approval_Process__c == true) {
            PageReference oppDetailPage = new PageReference('/'+opp.Id);
            return oppDetailPage;
        }
        else {        
            PageReference managePage = Page.ProductManager;
            managePage.getParameters().put('id', opportunityLineItem.OpportunityId);
            managePage.setRedirect(true);
            return managePage;
        }
    }

}