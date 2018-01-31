/*Provides functionality to Bulit SOAP Request in WSSE format with User Name , Password
It will also sign the request digitially with Private Key and Public Key Modulus of the CA Sign Certificate.*/

public with sharing class GlobalHeaderGenerator {
    
    public static String generateSoapHeader(String docBodyString,String userId, 
                                        String passWord){
        //Create UserNameToken and add UserName and Password
        String userNameTokenElement = '<wsse:UsernameToken><wsse:Username>'+userId
                                     + '</wsse:Username><wsse:Password>'+passWord+
                                     '</wsse:Password></wsse:UsernameToken>';
        //Create XMLSignature Element
        String signatureElement = generateXMLSignature(docBodyString);
    
        //Create Security Element
        String securityElement = '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/07/secext">';
              securityElement+=userNameTokenElement+signatureElement;
              securityElement+='</wsse:Security>';
    
        //Create Header Element
        String headerElement = '<soapenv:Header>'+securityElement+'</soapenv:Header>';
        return headerElement;
    }
    
    /**
     * Provides functionality to sign the request digitially with Private Key and Public Key Modulus of the CA Sign Certificate.
     *
     * @param Request XML Body in Canonical form
     * 
     * @return Signature Element 
    **/
    public static String generateXMLSignature(String docBodyString){
        
        /*1. Calculate the digest value of the SOAP body. 
             Body should be delivered in canonicalized form 
             (Salesforce.com doesn't offers any canonicalization algorithm))
        */
                    
        Blob bodyDigest = Crypto.generateDigest('SHA1',Blob.valueOf(docBodyString));
        /*2. Create a Reference element, including 
             (a) the identification of the XML Element ID (Body)
             (b) transform elements, 
             (c) the digest algorithm
             (d) Digest Value.
             This element and the references should be in the canonical form.
        */
                
        String referenceElement = '';
        referenceElement += '<Reference URI="#Body">';
        referenceElement += '<Transforms>';
        referenceElement += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>';
        referenceElement += '</Transforms>';
        referenceElement += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>';
        referenceElement += '<DigestValue>'+EncodingUtil.base64Encode(bodyDigest)+'</DigestValue>';
        referenceElement += '</Reference>'; 
               
        /*3.Create SignedInfo element with
            (a) SignatureMethod, 
            (b) CanonicalizationMethod 
            (c) Reference(s).
        */
                
        String signedInfoElement = '';
        signedInfoElement += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">';
        signedInfoElement += '<CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"></CanonicalizationMethod>';
        signedInfoElement += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>';
        signedInfoElement += referenceElement;
        signedInfoElement += '</SignedInfo>';
           
        /*4. Calculate the Signature Value of SignedInfo based on 
             algorithms specified in SignedInfo. 
             Signedinfo element should be delivered in canonicalized form.
             (Salesforce.com does not offer any canonicalization algorithm)
        */
                     
        String algorithmName = 'RSA-SHA1';
               
        // decrypted private key pkcs8 format from certificate
        // NH - New private key 25-Oct-2013
        // NH - New private Key 10-nov-2017
        String clientCert = 'MIIEowIBAAKCAQEAnxYpx8CoNqX4MW9AIo4538HS4ulBZpbyRDhKtQSt1fG7GMiH';
        clientCert += 'fVa53puJn+kxASzAaAynmGXxR4E3r3kr0cuizfVry2fpfVkbtlG+10hbdU61LihQ';
        clientCert += 'CentVMfvg88ndyeECIHetr/6PqjOiuBwAla4Qb4C0wzzL5smhCUju84C4GkuZNCF';
        clientCert += 'd3P89QuOX2jwIQ+KWD89G0kf1jECyUZ9OfYNrSiLTbGpBYEMq564AuXRWssLWucc';
        clientCert += 'z/TOmE+59TX6LEXh2hTNHqOb+ZSuRhdLN6G5XkfCxOXUE6G+c/aVqj2mIA+aSjrV';
        clientCert += 'HUmUb56YhhfEneCLtpvLhixNxBbZk8dwINwNPwIDAQABAoIBABYI9lmGLGaBX5rN';
        clientCert += 'S4ddxtNg3+pxH49rqfvcBjEDiGaBWIZqxCWOvSkBxzLAlHqSrcXbtt0Lhbt/QOzL';
        clientCert += 'rk+dUpwPedJPPs6PaKC8ut/L1GsvrzXI/Kka3zYmiVzq9Q7yiL2661PJzIogTJd8';
        clientCert += '1dblFxl4DaEZApgd99xG3qe1Nb3Ka+q/BTRJuMgwt1dPKkf24LqWN1CgqkFXBJMz';
        clientCert += 'Wsmiw5dW2hzzkLvWWu1PkX0VevUgV3Mtn08pszWGtmHcSfdfGHiGHkTGlULoHky6';
        clientCert += 'EA0BMxRd+JD5o6+Q3VTynH86H/h9Oapr1TXi8o+NUJLjhK4cRnITXGb9QuDE1UH5';
        clientCert += 'jPvgHo0CgYEAxsQkNqxabC+pY5hr5tnp3TgN1g05R3ML73K7A+6mstIeMyVAIPW6';
        clientCert += 'UlqfotRJrwNU2inwfMttwI5R2VbYyapiurNwOjpqULcVG1UHUUwnlpWEeNk79Uda';
        clientCert += 'IlxKFl+vlqR+2OmEGFXNGgWiokP+CHcmclY1+srHp5bReJfSv+mCFrMCgYEAzOUT';
        clientCert += '6/6VftZYxmvTmwUmpM6p6Sc/GbAdBsEFnYFbXMU6YxsSJgHmCcin6tGohw+Ga4aU';
        clientCert += '1h1JzfkEPU0VCmNth00JbbXvYGWrS3R4vMNExq0KDGZ5yDPkFtTEYrMJ1Os5YelH';
        clientCert += 'tDpcahlxqGNKjMwS/S3drDqwyHgZFmV6PPjz1UUCgYBuWTZBpC4PIebIhDZjU1ei';
        clientCert += 'mRwVWgISyKw3o1pwNG4XmM9rVaLkqYdncShvHaxKnW7eL6pznfywilKmdrCkRRPK';
        clientCert += '0xPbP9MGPJ5bLjmByOWxlBCXhwLiiVpg+RuokDbLS0eg5QOQ/xF/AOHpdBX0XTHb';
        clientCert += 'CEGvmiR9xh1E9gTqxpiSQQKBgE6CmJec/XuUdn/RYUvNNXmBFuoX973IFdc4rwYj';
        clientCert += 'QvbRPAYtoU6e+55UHMOFgqX99OvOrck9f8JE4LL8jktkvdtSUYKQbCDr1C8degYa';
        clientCert += 'bIgUVf1aZt+nwoZdEMMhB2tmlp5F3QvaMP8WsM5s/Wvl5oDMylvsQUEPg81pJOWo';
        clientCert += 'HwZhAoGBAISV6N/WCZ2dpCAMRuTDYRgRprxINcPlHdwtlGkRGuCtSf4XuMFOjmMC';
        clientCert += '709/xMvR5tCiCjHaLxQDSB+z+oyy/T0g1GR5LofdV9Fi1ik4CU4HicoXH6sLDubc';
        clientCert += 'q3triG37QgYQk7sOB/k/aePZeH3+bm6Inxd201Ggihieo7JLroea';
        
        //Replace this with your client cert
        String privateKeyPkcs8 =clientCert;
        Blob privateKey = EncodingUtil.base64Decode(privateKeyPkcs8);
        Blob siBlob = Blob.valueOf(signedInfoElement);
        Blob signatureValue = Crypto.sign(algorithmName, siBlob, privateKey);
        String signatureValueString = EncodingUtil.base64Encode(signatureValue);
           
        /*5. Construct the Signature element that includes 
             (a) SignedInfo
             (b) SignatureValue
             (c) KeyInfo. 
        */
        String signatureElement = '';
        signatureElement += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">';
        signatureElement += signedInfoElement; 
        signatureElement += '<SignatureValue>'+signatureValueString+'</SignatureValue>';
        signatureElement += '<KeyInfo>';
        signatureElement += '<KeyValue>';
        signatureElement += '<RSAKeyValue>';
                
        // Modulus of the public key associated the certificate
        // NH - New private key 25-Oct-2013
        // NH - New private key 10-nov-2017
        String publicKeyModulus = '9F1629C7C0A836A5F8316F40228E39DFC1D2E2E9416696F244384AB504ADD5F1BB18C8877D56B9DE9B899FE931012CC0680CA79865F1478137AF792BD1CBA2CDF56BCB67E97D591BB651BED7485B754EB52E285009E9ED54C7EF83CF277727840881DEB6BFFA3EA8CE8AE0700256B841BE02D30CF32F9B26842523BBCE02E0692E64D0857773FCF50B8E5F68F0210F8A583F3D1B491FD63102C9467D39F60DAD288B4DB1A905810CAB9EB802E5D15ACB0B5AE71CCFF4CE984FB9F535FA2C45E1DA14CD1EA39BF994AE46174B37A1B95E47C2C4E5D413A1BE73F695AA3DA6200F9A4A3AD51D49946F9E988617C49DE08BB69BCB862C4DC416D993C77020DC0D3F';
        //Replace this with the private key
        
        signatureElement += '<Modulus>'+publicKeyModulus+'</Modulus>';
        signatureElement += '<Exponent>AQAB</Exponent>';
        signatureElement += '</RSAKeyValue>';
        signatureElement += '</KeyValue>';
        signatureElement += '</KeyInfo>';
        signatureElement += '</Signature>';
        
        return signatureElement;
    }                
}