public class NightlyRunStatusTriggerHander  {

	public void handleAfterInsert(List<Nightly_Run_Status__c> newStatuses) {
		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(true);
		if (!Test.isRunningTest()) {
			Database.executeBatch(new SecurityDeleteAllBatchable());
		}
	}
}