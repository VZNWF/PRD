public class CSUtils {

	private static Map<String, Schema.SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
	private static Map<String, Map<String, Schema.RecordTypeInfo>> sObjectTypeToRecordTypesMap = new Map<String,  Map<String, Schema.RecordTypeInfo>>();

	// Mapping of standard object prefixes to their names.
	private static Map<String, String> OBJECT_NAMES =
		new Map<String, String>{'001' => 'Account',
		                        '002' => 'Note',
		                        '003' => 'Contact',
		                        '005' => 'User',
		                        '006' => 'Opportunity',
		                        '00Q' => 'Lead',
		                        '00G' => 'Group',
		                        '500' => 'Case',
		                        '00T' => 'Task',
		                        '701' => 'Campaign',
		                        '00U' => 'Event'};


	/**
	 * Determine if a String object is empty.
	 */
	public static Boolean isEmpty(String str) {
		return (str == null || str.trim().length() < 1);
	}

	/**
	 * Determine if a String object has a numeric value.
	 */
	public static Boolean isNumeric(String str) {
		try {
			Double.valueOf(str);
			return true;
		} catch (Exception e) {
			return false;
		}
	}
	
	public static void sendErrorEmail(Id batchId, Exception ex, String message){
		AsyncApexJob batchJob = [SELECT Id, Status, NumberOfErrors, JobType, MethodName, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:batchId];
		List<String> toAddresses = new List<String>();
		try {
			PRM_API_Settings__c settings = PRM_API_Settings__c.getOrgDefaults();
			if(URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs')) {
				if(!string.isBlank(settings.Sandbox_Notification_Email__c)) {
					if(settings.Sandbox_Notification_Email__c.contains(';')) {
						toAddresses = settings.Sandbox_Notification_Email__c.split(';');
					}
					else {
						toAddresses.add(settings.Sandbox_Notification_Email__c);
					}
				}
			}
			else {
				if(!string.isBlank(settings.Production_Notification_Email__c)) {
					if(settings.Production_Notification_Email__c.contains(';')) {
						toAddresses = settings.Production_Notification_Email__c.split(';');
					}
					else {
						toAddresses.add(settings.Production_Notification_Email__c);
					}
				}
			}
			if(toAddresses.size() == 0) {
	    		toAddresses.add('networkfleet@codescience.com'); 
			}
		}
		catch(Exception e) {
			toAddresses.add('networkfleet@codescience.com');
		}
		String body = '<strong>*********************NOTIFICATION*********************</strong><br /><br />';
		body += 'The following Batch process failed:<br/>';
		body += '<ul>';
		body += '<li><strong>Batch Name: </strong> PRMLeadBatch</li>'; 
		body += '<li><strong>Apex Method: </strong> ' + batchJob.MethodName + '</li>';
		body += '<li><strong>Submitted Date/Time </strong> ' + DateTime.now() +'</li>'; 
		body += '<li><strong>Jop Type: </strong> ' + batchJob.JobType + '</li>'; 
		body += '<li><strong>Submitted By: </strong> ' + batchJob.CreatedBy.Email + '</li>';
		if(ex != null){  
			body += '<li><strong>Status Detail: </strong> ' + ex.getMessage() + '<br /> ' + ex.getStackTraceString() + '</li>'; 
		}
		else{
			body += '<li>' + message + '</li>'; 
		}
		body += '</ul>';
		sendEmail(toAddresses, 'Batch Failure Notification', null, body);
	}

	/**
	 * Determine if a String object has an alpha-numeric value.
	 */
	public static Boolean isAlphaNumeric(String str) {
		return Pattern.compile('[a-zA-Z0-9]*').matcher(str).matches();
	}

	/**
	 * Determine if a String is a valid Id.
	 */
	public static Boolean isValidId(String idValue) {
		try {
			Id id = idValue;
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Determine if a String is a valid email address.
	 */
	public static Boolean isValidEmail(String email) {
		if (email == null) return true;

		return Pattern.matches('[a-zA-Z0-9]+[a-zA-Z0-9\\.\\_]*[a-zA-Z0-9]+@[a-zA-Z0-9\\-]+(\\.[a-zA-Z]+)+', email);
	}

	/**
	 * Parse a string representation of a Boolean into a Boolean object.
	 */
	public static Boolean parseBoolean(String str) {
		if (str == null) return null;
		if ('true'.equalsIgnoreCase(str)) {
			return true;
		} else {
			return false;
		}
	}

	/**
	 * Left pad a String to the given length with the given pad character.
	 */
	public static String leftPad(String str, String pad, Integer length) {
		if (str != null) {
			while ((length - str.length()) > 0) {
				str = pad + str;
			}
		}

		return str;
	}

	/**
	 * Right pad a String to the given length with the given pad character.
	 */
	public static String rightPad(String str, String pad, Integer length) {
		if (str != null) {
			while ((length - str.length()) > 0) {
				str += pad;
			}
		}

		return str;
	}

	/**
	 * Convert a String to an array (List) of characters (1-letter Strings).
	 */
	public static List<String> toCharacterArray(String value) {
		if (value == null) return null;

		List<String> characters = new List<String>();
		for (Integer i = 0; i < value.length(); i++) {
			characters.add(value.substring(i, i + 1));
		}

		return characters;
	}

	/*
	 * Convert a Decimal to an Integer by removing everything after the decimal.
	 */
	public static Integer convertDecimalToInteger(Decimal dec) {
		String decimalString = dec + '';

		Integer decimalPlace = decimalString.indexOf('.');
		if (decimalPlace != -1) {
			decimalString = decimalString.substring(0, decimalPlace);
		}

		return Integer.valueOf(decimalString);
	}

	/**
	 * Perform a null-safe equals comparison on two strings.
	 */
	public static Boolean nullSafeEquals(String a, String b) {
		return a == null ? (b == null ? true : false) : (b == null ? false : a.equals(b));
	}

	/**
	 * Join a list of String values into one string separated by the specified separator.
	 */
	public static String join(List<String> values, String separator) {
		if (values == null || values.size() < 1) return null;
		
		String joined = '';

		Iterator<String> iterator = values.iterator();
		if (iterator.hasNext()) {
			joined += iterator.next();
			while (iterator.hasNext()) {
				joined += separator + iterator.next();
			}
		}

		return joined;
	}
	
	/**
	 * Join a set of String values into one string separated by the specified separator.
	 * NOTE: For consistency, the values in the set are sorted after being converted to a list.
	 */
	public static String join(Set<String> values, String separator) {
		List<String> valuesList;

		if (values != null) {
			valuesList = new List<String>();
			valuesList.addAll(values);
			valuesList.sort();
		}

		return join(valuesList, separator);
	}

	/**
	 * Join a list of field values from a list of SObjects into one string separated by the specified separator.
	 */
	public static String join(List<sObject> objects, String fieldName, String separator) {
		List<String> valuesList;

		if (objects != null) {
			valuesList = new List<String>();

			for (sObject obj : objects) {
				valuesList.add(String.valueOf(obj.get(fieldName)));
			}
		}

		return join(valuesList, separator);
	}

	/*
	 * Shuffles a list of Strings into random order.
	 */
	public static List<String> shuffle(List<String> values) {
		if (values == null) return null;

		Integer top = values.size();
		Integer current = top;

		if (top > 1) {
			while(--top > 0) {
				current = Math.floor(Math.random() * (top + 1)).intValue();
				String value = values[current];
				values[current] = values[top];
				values[top] = value;
			}
		}

		return values;
	}

	/**
	 * Wraps a string in quote (") characters and escapes any existing quotes in the string.
	 */
	public static String quote(String value) {
		if (isEmpty(value)) return '""';

		String escaped = value.replace('"', '""');

		return '"' + escaped + '"';
	}
	
	/**
	 * Quotes a list of values.
	 */
	public static List<String> quote(List<String> values) {
		if (values == null) return null;

		List<String> quotedValues = new List<String>();
		for (String value : values) {
			String quotedValue = quote(value);
			quotedvalues.add(quotedValue);
		}

		return quotedValues;
	}

	/**
	 * Wraps a string in sinql quote (') characters and escapes any existing single quotes in the string.
	*/
	public static String singleQuote(String value) {
		if (isEmpty(value)) return '\'\'';

		return '\'' + String.escapeSingleQuotes(value) + '\'';
	}

	/**
	* Single quotes a list of values.
	*/
	public static List<String> singleQuote(List<String> values) {
		if (values == null) return null;

		List<String> quotedValues = new List<String>();
		for (String value : values) {
			String quotedValue = singleQuote(value);
			quotedvalues.add(quotedValue);
		}

		return quotedValues;
	}

	/**
	 * Format a Date with the given format.
	 */
	public static String formatDate(Date d, String format) {
		if (d == null) return null;

		DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
		return dt.format(format);
	}

	/**
	 * Format a DateTime as UTC format (e.g., 2010-03-12T19:44:00Z).
	 */
	public static String formatDateTimeUTC(DateTime d) {
		if (d == null) return null;

		return d.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	}

	/**
	 * Convert a DateTime object to a Date object.
	 */
	public static Date convertDateTimeToDate(DateTime dt) {
		if (dt == null) return null;
		
		return Date.newInstance(dt.year(), dt.month(), dt.day());
	}

	/**
	 * Given an SObject name and Record Type name, return the Record Type's Id.
	 */
	public static Id getRecordTypeId(String sObjectType, String recordType) {
		if (sObjectTypeToRecordTypesMap.containsKey(sObjectType) == false) {
			Schema.SObjectType sotype = sObjectTypeMap.get(sObjectType);
			Map<String, Schema.RecordTypeInfo> recordTypesMap = sotype.getDescribe().getRecordTypeInfosByName();
			sObjectTypeToRecordTypesMap.put(sObjectType, recordTypesMap);
		}

		Map<String, Schema.RecordTypeInfo> recordTypesMap = sObjectTypeToRecordTypesMap.get(sObjectType);
		if (recordTypesMap != null) {
			Schema.RecordTypeInfo recordTypeInfo = recordTypesMap.get(recordType);
			if (recordTypeInfo != null) {
				return recordTypeInfo.getRecordTypeId();
			}
		}

		return null;
	}

	/**
	 * Get metadata for an SObject.
	 */
	public static Schema.DescribeSObjectResult getObjectMetadata(String objectName) {
		Schema.sObjectType objectType = sObjectTypeMap.get(objectName);
		if (objectType == null) {
			return null;
		}
		
		return objectType.getDescribe();
	}

	/**
	 * Get metadata for an SObject's field.
	 */
	public static Schema.DescribeFieldResult getFieldMetadata(String objectName, String fieldName) {
		Map<String, Schema.SObjectField> fieldsMap = getObjectMetadata(objectName).fields.getMap();
		return fieldsMap.get(fieldName).getDescribe();
	}

	/**
	 * Get a list of a field's picklist values.
	 */
	public static List<String> getPicklistValues(String objectName, String fieldName, Boolean sortValues) {
		List<String> values = new List<String>();

		for (Schema.PickListEntry entry : getFieldMetadata(objectName, fieldName).getPickListValues()){
			values.add(entry.getValue());
		}

		if (sortValues) values.sort();

		return values;
	}

	/**
	 * Get a field's picklist default value.
	 */
	public static String getPicklistDefaultValue(String objectName, String fieldName) {
		for (Schema.PickListEntry entry : getFieldMetadata(objectName, fieldName).getPickListValues()){
			if (entry.isDefaultValue()) {
				return entry.getValue();
			}
		}

		return null;
	}

	/**
	 * Get a field's picklist values as list of SelectOptions that can be used with a VF page.
	 */
	public static List<SelectOption> getPicklistAsSelectOptions(String objectName, String fieldName, Boolean sortValues) {
		List<SelectOption> selectOptions = new List<SelectOption>();
		for (String value : getPicklistValues(objectName, fieldName, sortValues)) {
			selectOptions.add(new SelectOption(value, value));
		}

		return selectOptions;
    }

	/**
	 * Get the field length for a text field.
	 */
	public static Integer getTextFieldLength(String objectName, String fieldName) {
		return getFieldMetadata(objectName, fieldName).getLength();
	}

	/**
	 * Given a Salesforce object id, return the name of the object that the id is for.
	 */
	public static String getObjectNameFromId(String id) {
		if (id == null) return null;
		
		String prefix = id.substring(0, 3);
		return OBJECT_NAMES.get(prefix);
	}

	/**
	 * Converts a Salesforce id to fifteen character variant.
	 */
	public static String fifteenCharacterId(String originalId) {
		if (CSUtils.isEmpty(originalId) || originalId.length() <= 15) {
			return originalId;
		}

		return originalId.substring(0, 15);
	}

	/**
	 * Given two objects and a set of field names, determine if any of the fields' values are different.
	 */
	public static Boolean fieldValuesDifferent(SOBject objectA, SObject objectB, Set<String> fieldNames) {
		for (String fieldName : fieldNames) {
			if (objectA.get(fieldName) != objectB.get(fieldName)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Send an email.
	 */
	public static void sendEmail(List<String> recipients, String subject, String message){
		sendEmail(recipients, subject, message, null);
	}
	
	public static void sendEmail(List<String> recipients, String subject, String message, String htmlMessage) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setToAddresses(recipients);
		email.setSubject(subject);
		if(htmlMessage == null){
			email.setPlainTextBody(message);
		}
		else{
			email.setHtmlBody(htmlMessage);
		}
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	}


	// --------------------------------------------------------------------------------------------
	// UNIT TESTS
	// --------------------------------------------------------------------------------------------

	static testMethod void testIsEmpty() {
		System.assertEquals(true, CSUtils.isEmpty(null));
		System.assertEquals(true, CSUtils.isEmpty(''));
		System.assertEquals(true, CSUtils.isEmpty('  '));
		System.assertEquals(false, CSUtils.isEmpty('not empty'));
	}

	static testMethod void testIsNumeric() {
		System.assertEquals(false, CSUtils.isNumeric(null));
		System.assertEquals(false, CSUtils.isNumeric(''));
		System.assertEquals(true, CSUtils.isNumeric('1'));
		System.assertEquals(true, CSUtils.isNumeric('1.0'));
		System.assertEquals(true, CSUtils.isNumeric('01'));
		System.assertEquals(true, CSUtils.isNumeric('.01'));
		System.assertEquals(false, CSUtils.isNumeric('text'));
	}

	static testMethod void testIsAlphaNumeric() {
		System.assertEquals(true, CSUtils.isAlphaNumeric('abc'));
		System.assertEquals(true, CSUtils.isAlphaNumeric('abc123'));
		System.assertEquals(true, CSUtils.isAlphaNumeric('123'));
		System.assertEquals(false, CSUtils.isAlphaNumeric('abc_123'));
		System.assertEquals(false, CSUtils.isAlphaNumeric('%'));
	}

	static testMethod void testIsValidId() {
		System.assertEquals(true, CSUtils.isValidId(null));
		System.assertEquals(false, CSUtils.isValidId('1234'));
		System.assertEquals(false, CSUtils.isValidId('1234567890123456'));

		Contact contact = new Contact();
		contact.LastName = 'Test';
		insert contact;

		System.assertEquals(true, CSUtils.isValidId('' + contact.Id));
	}

	static testMethod void testIsValidEmail() {
		System.assertEquals(true, CSUtils.isValidEmail(null));
		System.assertEquals(true, CSUtils.isValidEmail('test@test.com'));
		System.assertEquals(false, CSUtils.isValidEmail('test'));
		System.assertEquals(false, CSUtils.isValidEmail('test@test'));
		System.assertEquals(false, CSUtils.isValidEmail('@test'));
		System.assertEquals(false, CSUtils.isValidEmail('@test.com'));
	}

	static testMethod void testParseBoolean() {
		System.assertEquals(null, CSUtils.parseBoolean(null));
		System.assertEquals(true, CSUtils.parseBoolean('true'));
		System.assertEquals(false, CSUtils.parseBoolean('false'));
		System.assertEquals(false, CSUtils.parseBoolean('neither'));
	}

	static testMethod void testLeftPad() {
		System.assertEquals(null, CSUtils.leftPad(null, null, null));
		System.assertEquals('1234', CSUtils.leftPad('1234', '0', 4));
		System.assertEquals('0555', CSUtils.leftPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.leftPad('12345', '0', 4));
	}

	static testMethod void testRightPad() {
		System.assertEquals(null, CSUtils.rightPad(null, null, null));
		System.assertEquals('1234', CSUtils.rightPad('1234', '0', 4));
		System.assertEquals('5550', CSUtils.rightPad('555', '0', 4));
		System.assertEquals('12345', CSUtils.rightPad('12345', '0', 4));
	}

	static testMethod void testToCharacterArray() {
		System.assertEquals(null, CSUtils.toCharacterArray(null));

		List<String> characters = CSUtils.toCharacterArray('abc');
		System.assertEquals('a', characters.get(0));
		System.assertEquals('b', characters.get(1));
		System.assertEquals('c', characters.get(2));
   	}

	static testMethod void testConvertDecimalToInteger() {
		System.assertEquals(1, convertDecimalToInteger(Decimal.valueOf(1)));
		System.assertEquals(1, convertDecimalToInteger(Decimal.valueOf('1.1')));
	}

	static testMethod void testNullSafeEquals() {
		System.assertEquals(true, CSUtils.nullSafeEquals(null, null));
		System.assertEquals(false, CSUtils.nullSafeEquals(null, 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('val', null));
		System.assertEquals(true, CSUtils.nullSafeEquals('val', 'val'));
		System.assertEquals(false, CSUtils.nullSafeEquals('vala', 'valb'));
	}

	static testMethod void testJoin() {
		// List version.
		System.assertEquals(null, CSUtils.join((List<String>) null, ','));
		System.assertEquals('one', CSUtils.join(new List<String>{'one'}, '|'));
		System.assertEquals('one,two', CSUtils.join(new List<String>{'one', 'two'}, ','));
		System.assertEquals('one;two;three', CSUtils.join(new List<String>{'one', 'two', 'three'}, ';'));

		// Set version.
		System.assertEquals(null, CSUtils.join((Set<String>) null, ','));
		System.assertEquals('one', CSUtils.join(new Set<String>{'one'}, '|'));
		System.assertEquals('one,three,two', CSUtils.join(new Set<String>{'one', 'two', 'three'}, ','));

		// SObject version.
		System.assertEquals(null, CSUtils.join((List<sObject>) null, 'Name', ','));
		System.assertEquals('Account1', CSUtils.join(new List<sObject>{new Account(Name='Account1')}, 'Name', '|'));
		System.assertEquals('Account1|Account2', CSUtils.join(new List<sObject>{new Account(Name='Account1'), new Account(Name='Account2')}, 'Name', '|'));
	}

	static testMethod void testShuffle() {
		System.assertEquals(null, CSUtils.shuffle(null));
		System.assertNotEquals(null, CSUtils.shuffle(new List<String>{'aaa', 'bbb'}));
	}

	static testMethod void testQuote() {
		System.assertEquals('""', CSUtils.quote((String) null));
		System.assertEquals('""', CSUtils.quote(''));
		System.assertEquals('"John Doe"', CSUtils.quote('John Doe'));
		System.assertEquals('"This has ""quotes"" embedded."', CSUtils.quote('This has "quotes" embedded.'));

		List<String> quotedValues = CSUtils.quote(new List<String>{'John Doe', 'Jane Doe'});
		System.assertNotEquals(null, quotedValues);
		System.assertEquals('"John Doe"', quotedValues.get(0));
		System.assertEquals('"Jane Doe"', quotedValues.get(1));
		System.assertEquals(null, CSUtils.quote((List<String>) null));
	}

	static testMethod void testSingleQuote() {
		System.assertEquals('\'\'', CSUtils.singleQuote((String) null));
		System.assertEquals('\'\'', CSUtils.singleQuote(''));
		System.assertEquals('\'John Doe\'', CSUtils.singleQuote('John Doe'));
		System.assertEquals('\'This has \\\'quotes\\\' embedded.\'', CSUtils.singleQuote('This has \'quotes\' embedded.'));

		List<String> quotedValues = CSUtils.singleQuote(new List<String>{'John Doe', 'Jane Doe'});
		System.assertNotEquals(null, quotedValues);
		System.assertEquals('\'John Doe\'', quotedValues.get(0));
		System.assertEquals('\'Jane Doe\'', quotedValues.get(1));
		System.assertEquals(null, CSUtils.quote((List<String>) null));
	}

	static testMethod void testFormatDate() {
		System.assertEquals(null, CSUtils.formatDate(null, null));
		
		Date d1 = Date.newInstance(2009, 4, 6);
		System.assertEquals('2009-04-06', CSUtils.formatDate(d1, 'yyyy-MM-dd'));

		Date d2 = Date.newInstance(2009, 10, 22);
		System.assertEquals('2009/10/22', CSUtils.formatDate(d2, 'yyyy/MM/dd'));
	}

	static testMethod void testFormatDateTimeUTC() {
		System.assertEquals(null, CSUtils.formatDateTimeUTC(null));

		DateTime d = DateTime.newInstance(2010, 4, 6);
		//System.assertEquals('2010-04-06T00:00:00Z', CSUtils.formatDateTimeUTC(d));
	}

	static testMethod void testConvertDateTimeToDate() {
		// Test positive scenario.
		DateTime dt = DateTime.newInstance(2009, 4, 6);
		Date d = CSUtils.convertDateTimeToDate(dt);

		System.assertEquals(2009, d.year());
		System.assertEquals(4, d.month());
		System.assertEquals(6, d.day());

		// Test negative scenario.
		dt = null;
		d = CSUtils.convertDateTimeToDate(dt);

		System.assertEquals(null, d);
	}

	static testMethod void testGetRecordTypeId() {
		System.assertEquals(null, CSUtils.getRecordTypeId('Account', 'Test'));
	}

	static testMethod void testGetObjectMetadata() {
		System.assertEquals(null, CSUtils.getObjectMetadata(null));
		System.assert(CSUtils.getObjectMetadata('Account') != null);
	}

	static testMethod void testGetFieldMetadata() {
		System.assert(CSUtils.getFieldMetadata('Account', 'Name') != null);
	}

	static testMethod void testGetPicklistValues() {
		System.assertNotEquals(null, CSUtils.getPicklistValues('Account', 'Industry', true));
	}

	static testMethod void testGetPicklistDefaultValue() {
		CSUtils.getPicklistDefaultValue('Account', 'Industry');
	}

	static testMethod void testGetPicklistAsSelectOptions() {
		System.assertNotEquals(null, CSUtils.getPicklistAsSelectOptions('Account', 'Industry', true));
	}

	static testMethod void testGetTextFieldLength() {
		System.assert(CSUtils.getTextFieldLength('Account', 'Name') != 0);
	}

	static testMethod void testGetObjectNameFromId() {
		System.assertEquals(null, CSUtils.getObjectNameFromId(null));

		try {
			Account account = new Account();
			account.Name = 'Test';
			insert account;
			System.assertEquals('Account', CSUtils.getObjectNameFromId(account.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Contact contact = new Contact();
			contact.FirstName = 'Test';
			contact.LastName = 'Test';
			insert contact;
			System.assertEquals('Contact', CSUtils.getObjectNameFromId(contact.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Opportunity opportunity = new Opportunity();
			opportunity.Name = 'Test';
			opportunity.StageName = 'Prospecting';
			opportunity.CloseDate = Date.today();
			insert opportunity;
			System.assertEquals('Opportunity', CSUtils.getObjectNameFromId(opportunity.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}

		try {
			Lead lead = new Lead();
			lead.LastName = 'Test';
			lead.Company = 'Test';
			insert lead;
			System.assertEquals('Lead', CSUtils.getObjectNameFromId(lead.Id));
		} catch (Exception e) {
			// Org has custom validation(s) preventing the record from
			// inserting and thus this test from running. Ignore exception.
		}
	}

	static testMethod void testFifteenCharacterId() {
		System.assertEquals(null, CSUtils.fifteenCharacterId(null));
		System.assertEquals('01234', CSUtils.fifteenCharacterId('01234')); // 5 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234')); // 15 characters
		System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234567')); // 18 characters
	}

	static testMethod void testFieldValuesDifferent() {
		// Test String field.
		Contact contactA = new Contact();
		contactA.FirstName = 'Test';

		Contact contactB = new Contact();
		contactB.FirstName = 'Test';

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'FirstName'}));

		contactB.FirstName = 'Test 2';

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'FirstName'}));

		// Test Boolean field.
		contactA = new Contact();
		contactA.DoNotCall = false;

		contactB = new Contact();
		contactB.DoNotCall = false;

		System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'DoNotCall'}));

		contactB.DoNotCall = true;

		System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{'DoNotCall'}));
    }

	static testMethod void testSendEmail() {
		CSUtils.sendEmail(new List<String>{'test@test.com'}, 'test', 'test message');
	}

}