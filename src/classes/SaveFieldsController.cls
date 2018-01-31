public with sharing class SaveFieldsController {

	private String kHexChars = '0123456789abcdef';
	
	public SaveFieldsController() {
		
		
	}
	
	public PageReference Init() {
		
		List<Custom_Field_Settings__c> fieldSettingsList = new List<Custom_Field_Settings__c>();
		List<ToolingAPI.CustomField> customFieldsList = null;
		ToolingAPI toolingAPI = new ToolingAPI();
		ToolingAPI.CustomField customField = null;
		Custom_Field_Settings__c fieldSettings = null;
		String tableEnumOrId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('TableEnumOrId'));
		String fieldId = '';
		
		if(!Test.isRunningTest()) {
		
			customFieldsList = (List<ToolingAPI.CustomField>)toolingAPI.query('Select Id, DeveloperName, NamespacePrefix From CustomField Where tableEnumOrId = \'' + tableEnumOrId + '\'').records;
		}
		else {
			
			customFieldsList = new List<ToolingAPI.CustomField>();
			
			customField = new ToolingAPI.CustomField();
			customField.id = '00NM00000014SdXQQQ';
			customField.developerName = 'Affiliate_Area';
			
			customFieldsList.add(customField);
		}
		
		delete [SELECT Id FROM Custom_Field_Settings__c WHERE Table_Enum_Or_Id__c = :tableEnumOrId];
		
		for(ToolingAPI.CustomField tmpCustomField : customFieldsList) {

			fieldSettings = new Custom_Field_Settings__c();
			
			fieldId = tmpCustomField.id;
		
			fieldSettings.Id__c = fieldId.substring(0, fieldId.length() - 3);
			fieldSettings.Field_Name__c = tmpCustomField.developerName + '__c';
			fieldSettings.Table_Enum_Or_Id__c = tableEnumOrId;
			
			fieldSettings.Name = GenerateGuid();
			
			fieldSettingsList.add(fieldSettings);
		}
		
		if(fieldSettingsList.size() > 0) {
			
			insert fieldSettingsList;
		}
		
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'For TableEnumOrId: ' + tableEnumOrId + ', ' + fieldSettingsList.size() + ' fields were saved.'));
    	
		return null;
	}
	
	public String GenerateGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i = 0; i < 8; i++) {

            if (i == 4 || i == 6 || i == 8 || i == 10) {
                returnValue += '-';
            }

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i == 6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i == 8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    public String getCharAtIndex(String str, Integer index) {
    	
    	if (str == null) return null;

        if (str.length() <= 0) return str;    

        if (index == str.length()) return null;    

        return str.substring(index, index+1);
    }
}