public with sharing class OpportunityLinkOverrideController {

    private Opportunity opportunity;   

    public OpportunityLinkOverrideController(ApexPages.StandardController controller) {
        opportunity = (Opportunity) controller.getRecord();
        Opportunity opp = [select Id, Is_in_Approval_Process__c from Opportunity where Id = :opportunity.Id];
        if(opp != null) {
            opportunity.Is_in_Approval_Process__c = opp.Is_in_Approval_Process__c;
        }
    }

    public PageReference initPage() {
    
        if(opportunity.Is_in_Approval_Process__c == true) {
            PageReference oppDetailPage = new PageReference('/'+opportunity.Id);
            return oppDetailPage;
        }
        else {
            PageReference managePage = Page.ProductManager;
            managePage.getParameters().put('id', opportunity.Id);
            managePage.setRedirect(true);
            return managePage;
        }
    }

}