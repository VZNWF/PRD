/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class Test_CopyParentOppsContactRoles {

	private static Contact CreateContact(String firstName, String lastName, Id accountId) {
		
		Contact contact = new Contact();
		
		contact.FirstName = firstName;
		contact.LastName = lastName;
		contact.AccountId = accountId;
		
		return contact;
	}

	private static Opportunity CreateOpportunity(String oppName, Id accountId) {
		
		Opportunity opportunity = new Opportunity();
		
        opportunity.Name = oppName;
        opportunity.AccountId = accountId;
        opportunity.Type = 'Existing Business';
        opportunity.LeadSource = 'Other';
        opportunity.CloseDate = Date.today().addDays(5);
        opportunity.StageName = 'Initial Meeting / Demo';
		
		return opportunity;
	}
	
    static testMethod void PositiveTest() {

		List<OpportunityContactRole> childOppContactRoleList = null;
        Opportunity parentOpp = null;
        Opportunity childOpp = null;
        Account account = TestUtils.createAccount();
        Contact contact = CreateContact('John Test', 'Doe Test', account.Id);
        OpportunityContactRole parentOppContactRole = null;
        
        //Create contacts
        
        insert contact;


        //Parent
        
        CopyParentOppsContactRoles.HAS_EXECUTED = false;
        
        parentOpp = CreateOpportunity('Parent Opportunity', account.Id);
        
        parentOpp.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
        
        insert parentOpp;
        
        parentOppContactRole = new OpportunityContactRole();
        
        parentOppContactRole.OpportunityId = parentOpp.Id;
        parentOppContactRole.ContactId = contact.Id;
        parentOppContactRole.Role = 'CFO';
        parentOppContactRole.IsPrimary = true;
        
        insert parentOppContactRole;
 
        
        //Child
        
        CopyParentOppsContactRoles.HAS_EXECUTED = false;
        
        childOpp = CreateOpportunity('Child Opportunity', account.Id);
        
        childOpp.RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        childOpp.Parent_Opportunity__c = parentOpp.Id;
        
        insert childOpp;
        
        
		childOppContactRoleList = [SELECT Id FROM OpportunityContactRole
									WHERE OpportunityId = :childOpp.Id
									AND ContactId = :parentOppContactRole.ContactId
									AND Role = :parentOppContactRole.Role
									AND IsPrimary = :parentOppContactRole.IsPrimary];
		
		System.assertEquals(1, childOppContactRoleList.size());
									
    }
}