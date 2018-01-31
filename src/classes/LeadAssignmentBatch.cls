global class LeadAssignmentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful { 
	global List<Id> newLeadIds;
	global List<Lead> updateLeads = new List<Lead>();

	public LeadAssignmentBatch(List<Id> leadIds) {
		this.newLeadIds = leadIds;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select ' + getLeadFieldList() + ' From Lead where Id in :newLeadIds';
		System.debug(query);
        return Database.getQueryLocator(query);		
	}

	global void execute(Database.BatchableContext BC, List<Lead> leadsToAssign) {
		LeadAssignmentHelper helper = new LeadAssignmentHelper(false);
        boolean applyActions = false; // false to update the field on the lead records in memory only, true to commit the modified leads to the database
        String result = helper.assignNewLeads(leadsToAssign, applyActions);
        if (result != null) {
        	//Log error
        	String message = 'An error occured assigning leads:\n' + result;
        	System.debug('Message: ' + message);
        	CSUtils.sendErrorEmail(BC.getJobId(), null, message);
        }
        else {
        	updateLeads.addAll(leadsToAssign);
        }
	}

	global void finish(Database.BatchableContext BC) {
		if(updateLeads.size() > 0) {
			update updateLeads;
		}
	}

	private String getLeadFieldList() {
		String fieldList = '';
		Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Lead').getDescribe().fields.getMap();

		for(String fieldName : fieldMap.keyset()){
			if(fieldMap.get(fieldName).getDescribe().isAccessible()) {
		    	fieldList = fieldName + ',' + fieldList;
			}
		}
		return fieldList.substringBeforeLast(',');
	}
}