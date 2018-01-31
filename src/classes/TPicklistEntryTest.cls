@isTest                                
private class TPicklistEntryTest {

   static testmethod void TestTPicklistEntry(){
        Test.startTest();
            TPicklistEntry tpEntry = new TPicklistEntry();
            tpEntry.active = 'true';
            tpEntry.defaultValue = 'defVal';
            tpEntry.label = 'label';
            tpEntry.value = 'value';
            tpEntry.validFor = 'validFor';
        Test.stopTest();
   }
 }