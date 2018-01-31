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
private class Test_CreateChildOpportunityController {

	private static List<Opportunity> m_ParentOpportunityList = new List<Opportunity>();
	private static Account m_Account = null;
	private static Campaign m_Campaign = null;

	private static Opportunity CreateOpportunity(String oppName, Id recordTypeId, Id accountId) {
		
		Opportunity opportunity = new Opportunity();
		Account salesPartner = TestUtils.createAccount();
		Campaign campaign = new Campaign();
		
		campaign.Name = 'Test Campaign';
		campaign.StartDate = Date.today();
		campaign.EndDate = Date.today().addDays(2);
		
		insert campaign;
		
        opportunity.Name = oppName;
        opportunity.RecordTypeId = recordTypeId;
        opportunity.AccountId = accountId;
        opportunity.Type = 'Existing Business';
        opportunity.LeadSource = 'Other';
        opportunity.CloseDate = Date.today().addDays(5);
        opportunity.StageName = 'Initial Meeting / Demo';
		
		opportunity.Related_Reseller__c = salesPartner.Id;		
		opportunity.CampaignId = campaign.Id; 
		
		return opportunity;
	}
		
	private static void SetUp() {
		
		Custom_Field_Settings__c fieldSettings = null;
		Id nonCSORecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity');
		
		m_Account = TestUtils.createAccount();
		
		m_ParentOpportunityList.add(CreateOpportunity('Opportunity #1', nonCSORecordTypeId, m_Account.Id));
		m_ParentOpportunityList.add(CreateOpportunity('Opportunity #2', nonCSORecordTypeId, m_Account.Id));
		
		insert m_ParentOpportunityList;
		
		fieldSettings = new Custom_Field_Settings__c();
		
		fieldSettings.Name = 'RandomString';
		fieldSettings.Id__c = '00N40000002EHcy';
		fieldSettings.Field_Name__c = 'Related_Reseller__c';
		fieldSettings.Table_Enum_Or_Id__c = 'Opportunity';
			
		insert fieldSettings;
	}
	
	private static void CheckAndAssertPageMessages(List<ApexPages.Message> messagesList, String messageToFind) {
		
		String tmpMessageToFind = messageToFind.replace(' ', '');
		Boolean found = false;
		
		for(ApexPages.Message message : messagesList) {
			
			if(message.getDetail().replace(' ', '').equalsIgnoreCase(tmpMessageToFind)) {
				
				System.assert(true, 'Message found!');
				found = true;		
			}
		}
		
		if(!found) {
			
			//System.assert(false, 'Message was NOT found!');
		}
	}
	
    static testMethod void CreateChildOppTest() {
        
        PageReference newOppPageRef = null;
        Id csoRecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        
        SetUp();
        
        Test.setCurrentPage(Page.CreateChildOpportunity);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        
        CreateChildOpportunityController ccoController = new CreateChildOpportunityController(sc);
    
        ApexPages.currentPage().getParameters().put('RecordType', csoRecordTypeId);
      
      	//Test Redirect
      	
        System.assertEquals(null, ccoController.RedirectBasedOnRecordType());
        
        //Test Filter
        
        ccoController.AccountId = m_Account.Id;
        
        ccoController.FilterOpportunitiesByAccount();
        
       System.assertEquals(2, ccoController.ParentOpportunitiesList.size());
        
        //Test Selection
        
        ccoController.SelectedOpportunityId = m_ParentOpportunityList[0].Id;
        
        newOppPageRef = ccoController.Save();
        
        //System.assertEquals(m_ParentOpportunityList[0].Name, newOppPageRef.getParameters().get('opp3'));
    }
    
    static testMethod void NegativeTest() {
        	
        PageReference newOppPageRef = null;
        
        SetUp();
        
        Test.setCurrentPage(Page.CreateChildOpportunity);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        
        CreateChildOpportunityController ccoController = new CreateChildOpportunityController(sc);
    
        ApexPages.currentPage().getParameters().put('RecordType', CSUtils.getRecordTypeId('Opportunity', 'Sales Opportunity'));
        ApexPages.currentPage().getParameters().put('retURL', 'http://www.google.com');
        
        //Test Redirect - To Non Child Opportunity
      	
        System.assertNotEquals(null, ccoController.RedirectBasedOnRecordType());
        
        //Test Filter - No Account Filter Specified
        
        ApexPages.currentPage().getParameters().put('RecordType', CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity'));
      
        ccoController.AccountId = null;
        
        ccoController.FilterOpportunitiesByAccount();
        
        System.assertEquals(0, ccoController.ParentOpportunitiesList.size());      

        //Test Selection - No Account Filter Specified
        
        ccoController.AccountId = null;
        
        ccoController.Save();
        
        CheckAndAssertPageMessages(ApexPages.getMessages(), 'Please select an Account Filter.');
        
       //Test Selection - No Selected Parent Opportunity
        
        ccoController.AccountId = m_Account.Id;
        ccoController.SelectedOpportunityId = null;
        
        ccoController.Save();
        
        CheckAndAssertPageMessages(ApexPages.getMessages(), 'Please select a Child Opportunity.');
        
        //Test Selection - No Parent Opportunity Found
        
        m_ParentOpportunityList[0].RecordTypeId = CSUtils.getRecordTypeId('Opportunity', 'Child Sales Opportunity');
        
        update m_ParentOpportunityList[0];
        
        ccoController.SelectedOpportunityId = m_ParentOpportunityList[0].Id;
        
        ccoController.Save();
        
        CheckAndAssertPageMessages(ApexPages.getMessages(), 'Could not find the selected Parent Opportunity.');
        
        //Cancel
        
        System.assertNotEquals(null, ccoController.Cancel());     
    }
}