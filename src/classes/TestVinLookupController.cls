@isTest(SeeAllData=true)
global Class TestVinLookupController implements HttpCalloutMock{

static Harness_Guide__c hg;
static Harness_Guide__c hg1;
static Harness_Guide__c hg2;
static List<Harness_Guide__c> hgList;
static{
    hg=new Harness_Guide__c();
    hg.Harness_Type__c='UNIVERSAL';
    hg.Is_Active__c=true;
    hg.Year_From__c='2011';
    hg.Year_To__c='2017';
    hg.Make__c='Acura';
    hg.Model__c='XC90';
    hg.Company_Name__c='Test';
    insert hg;
    
    hg1=new Harness_Guide__c();
    hg1.VIN_Number__c='2GNALCEK4F6255412';
    insert hg1;
    
    hg2=new Harness_Guide__c();
    insert hg2;
    
    Vin_Data__c vd = new Vin_Data__c();
    vd.Name = 'Endpoint';
    vd.EndPoint__c ='http://www.xmlvindecoder.com/rest/decoder.php';
    vd.Method__c = 'POST';
    vd.ClientId__c = '3950';
    vd.AuthCode__c = '73c63a784d9bf7a8b623f2c013fc4d86';
    insert vd;
    }
    
    static testMethod void TestVinMethod1(){
        ApexPages.StandardController sc = new ApexPages.StandardController(hg);
        VinLookupController vc=new VinLookupController(sc);   
        vc.getOptions();
        vc.getProducts();
        vc.getHardwareValues();
        vc.accountNameToSearch = 'Test';
        vc.harObjModel= 'Test';
        vc.harObjMake= 'Test';
        vc.harObjYearTo= 'Test';
        // vc.hardwareType= 'Test';
        vc.proAlign= 'Test';
        vc.performSearch();
       
        ApexPages.StandardController sc1 = new ApexPages.StandardController(hg1);
        VinLookupController vc1=new VinLookupController(sc1); 
        
        PageReference pageRef = Page.VinLookup;
        pageRef.getParameters().put('harObjMake','Acura');
        Test.setCurrentPageReference(pageRef);
        
        
        
        PageReference pageRef1= Page.VinLookup;
        pageRef1.getParameters().put('accountNameToSearch','Test');
        Test.setCurrentPageReference(pageRef1);
        
        
        PageReference pageRef2= Page.VinLookup;
        pageRef2.getParameters().put('proAlign','NWF');
        Test.setCurrentPageReference(pageRef2);
        
        
        VinLookupController.getCompany();
        try{
        Test.startTest();
        
        vc1.getVINDataMethod();
        hg1.VIN_Number__c='';
        update hg1;
        vc1.getVINDataMethod();
        
        VinWSClass.checkVal=true;
        vc.getVINDataMethod();
        Test.stopTest();
        
        
        }
        catch(Exception e){
            System.Debug('Exception here :'+e.getMessage()+e.getLineNumber()+e.getCause());
        }     
    
    }
    
    static testMethod void TestVinParser(){
        StaticResource sr = [Select Body From StaticResource Where Name = 'TestXML' LIMIT 1];
        String xml1=sr.body.toString();
        VINXmlParser vp=new VINXmlParser();
        vp.parseResponseDom(xml1);
    }
    
      
    static testMethod void TestWSCall() {
        Test.setMock(HttpCalloutMock.class, new TestVinLookupController());
        Test.startTest();
        try{
            VinWSClass.getVINData('1234567890');
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        StaticResource sr = [Select Body From StaticResource Where Name = 'TestXML' LIMIT 1];
        String xml1=sr.body.toString();
        HttpResponse res = new HttpResponse();
        res.setBody(xml1);
        res.setStatusCode(200);
        return res;
    }

}