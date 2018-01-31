public class CaseTriggerUtil {

	@Future
	public static void checkNotifyFlags(Set<Id> caseIds) {
		List<Case> cases = new List<Case>();
		
		for (Id caseId : caseIds) {
			cases.add(new Case(Id=caseId, Notify__c = true));
		}
		
		update cases;
	}

}