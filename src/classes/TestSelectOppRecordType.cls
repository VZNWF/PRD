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
@isTest
private class TestSelectOppRecordType {   
    
    static testMethod void TestRecordTypes() {
    	
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        
        SelectOppRecordType ccontroller = new SelectOppRecordType(sc);
        
        test.startTest();
        //getting record types
        List<SelectOption> recordTypeOptions = ccontroller.GetOppRecordTypes();
        System.assert(recordTypeOptions != null && recordTypeOptions.size() > 0);
        
        //Cancel        
       // System.assertNotEquals(null, ccontroller.Cancel());
        
        //Save without record type
        System.assertEquals(null, ccontroller.RedirectBasedonRecordType());
        
        //Save with record type
        ccontroller.SelectedRecordType = '012f00000008YItAAM';
        System.assertNotEquals(null,ccontroller.RedirectBasedonRecordType());
        test.stoptest();
    }
}