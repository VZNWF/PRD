public class Web2CaseController{
    Public Case newCase {get; set;}
    Public Case_Vehicle__c newCaseVehicle {get; set;}
      
    public String FleetName{get; set;}   
    public String AcctName {get; set;}
    Public String FirstName {get; set;}
    Public String LastName {get; set;}
    Public String UserID{get; set;}
    Public String CustomerNbr{get; set;}
    Public String Email {get; set;}
    Public String ConfirmEmail {get; set;}
    Public String Phone {get; set;}
    Public String SellerKey {get; set;}
    Public Boolean Device {get; set;}
    Public String Other {get; set;}
    Public String WebSite{get; set;}
    Public String SerialNumber{get; set;}
    Public String VIN{get; set;}
    Public String VehicleLabel{get; set;}
    Public String Subject {get; set;}
    Public String CaseDesc {get; set;}
    Public Boolean WebSiteCB {get; set;}
    Public Boolean DeviceCB{get; set;}
    Public Boolean OtherCB{get; set;}
    Public Id recId {get;set;}  
    Public string fileName {get;set;}  
    Public Blob fileBody  {get;set;} 
    Public String Category {get; set;}
    Public String Site1{get; set;}

    Public String emailSubject {get; set;}
    Public String emailBody {get; set;}
    
    private String addresses;
    private String BCCAddresses;
    private OrgWideEmailAddress owe;
    
    
    public Web2CaseController(){
      //  a = new Account();
        newCase = new Case();
        newCaseVehicle = new Case_Vehicle__c();
        
        System.debug(DeviceCB);
        Site1 = String.valueof(Site.MasterLabel);
        owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address = 'nwfsupport@verizon.com' LIMIT 1];
    }
    
    
       
    
    public PageReference SubmitWeb2Case(){
       
       //Validation
       If ((AcctName.trim().length() == 0) || (Email.trim().length()== 0) || (Subject.trim().length() == 0) || (CaseDesc.trim().length() == 0)) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To better assist you, please make sure required fields - Fleet Name, Email, Case Summary & Case Detail are filled.'));
           return null; 
       }
        //Validation
       If (Email.trim().length()!= 0){
           String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
           // source: <A href="http://www.regular-expressions.info/email.html" target=_blank>http://www.regular-expressions.info/email.html</A>  
            Pattern MyPattern = Pattern.compile(emailRegex);  
            Matcher MyMatcher = MyPattern.matcher(Email);  
            if (!MyMatcher.matches()){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid email address'));
               return null;
              }
       }
       //Validation
       If (EMail.trim() != ConfirmEmail.trim()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email entered did not match Confirm Email Address'));
            return null;
       }
        //Validation
       If (DeviceCB == true && (SerialNumber.trim().length() == 0 && VIN.trim().length() == 0 && VehicleLabel.trim().length() == 0) ){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Device is selected, you must enter a Serial Number or VIN or Vehicle Label' ));
           return null;           
       }
        
        List<Account> accts = Database.Query('SELECT Id, OwnerId FROM Account WHERE Name = :AcctName ');
    
        List<Contact> cnt = [SELECT Id, LastName, FirstName, AccountId, Account.Name FROM Contact WHERE Email = :Email] ;
        List<Account> FltAcct = [SELECT Id, AccountNumber, Name FROM Account WHERE Name = :AcctName];
        List<Account> DefaultAcctId = [SELECT Id, AccountNumber, Name FROM Account WHERE Name = 'Web Account'];
                    
        if (cnt.size() != 0){
            newCase.ContactId = cnt.get(0).id;
            newCase.AccountId = cnt.get(0).AccountId;
            newCase.Fleet_Account__c = cnt.get(0).AccountId;
            FleetName = cnt.get(0).Account.Name;
        }
        else{
            Contact newCnt = new Contact();
            newCnt.LastName = LastName;
            newCnt.FirstName = FirstName;
            newCnt.Email = Email;
            newCnt.Phone = Phone;  
            newCnt.AccountId = DefaultAcctId.get(0).Id;
            
            try{            
                INSERT newCnt;
            } Catch (Exception e){           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We apologize, but we are unable to submit the support ticket. Please contact Networkfleet Customer Care at 866.227.7323. Representatives are available to assist you Monday - Friday, 5:00 am- 7:00 pm (PT) and Saturday 7:00 am - 2:00 pm (PT).' ));                       
                return null;
            }
            
            
            newCase.ContactId = newCnt.id;
            newCase.Fleet_Account__c = DefaultAcctId.get(0).Id;  
            CustomerNbr = DefaultAcctId.get(0).AccountNumber;   
            FleetName = DefaultAcctId.get(0).Name;                  
        }  
                           
        newCase.Subject = Subject;
        newCase.Description =   ' User Name: ' + UserId + '\n Phone: ' + Phone + '\n Case Detail: ' + CaseDesc ;
        newCase.Case_Owner__c = 'Web2Case Rep';  
        newCase.Origin = 'Web';   
        
        Category = '';
        /* Default Reason and Case Sub Reason */
        newCase.Reason = 'General Inquiries';
        newCase.Case_Sub_Reason__c = 'Customer General Inquiry';
        
        If (DeviceCB == true) {
            Category += 'Device ';
            newCase.Reason = 'Hardware Tech Support';
            newCase.Case_Sub_Reason__c = 'Troubleshooting';
        }
        
        If (WebSiteCB == true){
            Category += 'Website ';
            newCase.Reason = 'Software Tech Support';
            newCase.Case_Sub_Reason__c = 'Troubleshooting';
        }
        
        If (DeviceCB == true && WebSiteCB == true) {
            newCase.Reason = 'General Inquiries';
            newCase.Case_Sub_Reason__c = 'Customer General Inquiry';
        }             
        
        if (OtherCB == true){
            Category += 'Other ';
            newCase.Reason = 'General Inquiries';
            newCase.Case_Sub_Reason__c = 'Customer General Inquiry';
        }
        //newCase.Case_Owner__c = accts.get(0).OwnerId;  
        
        try{            
            INSERT newCase;
        } Catch (Exception e){           
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We apologize, but we are unable to submit the support ticket. Please contact Networkfleet Customer Care at 866.227.7323. Representatives are available to assist you Monday - Friday, 5:00 am- 7:00 pm (PT) and Saturday 7:00 am - 2:00 pm (PT).' ));                       
             return null;
        }
        

        if (SerialNumber.trim().length() != 0 || VIN.trim().length() != 0 || VehicleLabel.trim().length() != 0) {
            newCaseVehicle.Case__c = newCase.Id;
            newCaseVehicle.Serial_Number__c = SerialNumber;
            newCaseVehicle.Vehicle_Label__c = VehicleLabel;
            newCaseVehicle.VIN__c = VIN;
            
            try{            
                INSERT newCaseVehicle;
            } Catch (Exception e){           
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while creating new case - Site Administrator has been notified' ));                  
                return null;
            }
            
        }
      
       // Getting Case Number for the Inserted case.      
       Case insertedCase  = [SELECT id, CaseNumber FROM Case WHERE Id = :newCase.id LIMIT 1];
        
       sendEmail(insertedCase.CaseNumber); 
        
       PageReference prUploadFile ;
       prUploadFile = UploadFile();
            
       PageReference prRedirectToThankYouPage = new PageReference('/apex/Web2caseTY?CaseId=' + insertedCase.CaseNumber); 
       prRedirectToThankYouPage.SetRedirect(true);
       return prRedirectToThankYouPage; 
      
  
    }
    
    Public PageReference UploadFile(){
            
            if ((fileBody != null) && (fileName != null)){
                Attachment myAttachment = new Attachment();
                myAttachment.body = fileBody;
                myAttachment.Name = fileName;
                myAttachment.ParentId = newCase.Id;
                try{
                insert myAttachment;
                } catch (DMLException e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading file' ));
                    return null;
                }finally {
                    myAttachment = null;
                }
            }
            return null;
    }
    
   
    Public void sendEmail(String caseNumber){
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        Messaging.reserveSingleEmailCapacity(1);
        emailSubject = 'Networkfleet Online Request Confirmation - Case Number - ' + caseNumber ;
        emailBody = 'Your online request has been received and assigned case number ' + caseNumber + '.  A Customer Care Representative will be working on this item shortly and we will do our best to respond within 48 hours (Monday through Friday). ' +  '\n\nCategory: ' + Category + '\nSerial Number : ' + SerialNumber + '\nVIN : ' + VIN +  '\nVehicle Label : ' + VehicleLabel  + '\n\nCase Summary: ' + Subject + +  '\n\nCase Detail: '+ CaseDesc + '\n\nShould you require immediate assistance on this item, please contact Networkfleet Customer Care at 866.227.7323 with this case number (' + caseNumber + '). Representatives are available to assist you Monday - Friday, 5:00 am- 7:00 pm (PT) and Saturday 7:00 am - 2:00 pm (PT).' ;  
        addresses = Email;
        BCCAddresses = 'nwfsupport@verizon.com';
        String[] toAddress = addresses.split(':', 0);
        String[] toBCCAddresses = BCCAddresses.split(':', 0);
          
        newEmail.setOrgWideEmailAddressId(owe.Id);
        newEmail.setReplyTo('nwfsupport@verizon.com');
        //newEmail.setSenderDisplayName('nwfsupport@verizon.com');
        newEmail.setSubject (emailSubject);
        newEmail.setToAddresses(toAddress);
        newEmail.setBccAddresses(toBCCAddresses);
        newEmail.setPlainTextBody (emailBody);
        
        try{            
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {newEmail});
        } Catch (Exception e){           
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'We apologize, but we are unable to submit the support ticket. Please contact Networkfleet Customer Care at 866.227.7323. Representatives are available to assist you Monday - Friday, 5:00 am- 7:00 pm (PT) and Saturday 7:00 am - 2:00 pm (PT).' ));                                             
            return;
        }       
        
      
    }
}