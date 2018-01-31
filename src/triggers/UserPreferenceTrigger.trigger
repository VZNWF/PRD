trigger UserPreferenceTrigger on User_Preference__c (after insert, after update) {
	//Used to update User field values from the incoming User_Preference__c records
	list<User> updateUsers = new list<User>();
	for(User_Preference__c up : trigger.new) {
		if(up.user__c != null) {
			updateUsers.add(
				new User(
					Id = up.user__c,
					Available_for_Assignment__c = up.Available_for_Assignment__c
				)
			);
		}
	}
	if(updateUsers.size() > 0) { update updateUsers; }
}