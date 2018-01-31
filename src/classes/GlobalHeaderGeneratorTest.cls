@isTest
private class GlobalHeaderGeneratorTest {

    static testMethod void TestGenerateSoapHeader() {
        string header = GlobalHeaderGenerator.generateSoapHeader('<Request></Request>', 'testusername', 'testpw');
        system.assertEquals(true, header.contains('wsse:Security'));
        system.assertEquals(true, header.contains('<wsse:Username>testusername</wsse:Username>'));
    }
}