public with sharing class SalesforceUrl{
    public String sfUrl;
    
    public String getSfUrl(){
       return  URL.getSalesforceBaseUrl().toExternalForm();
    }

}