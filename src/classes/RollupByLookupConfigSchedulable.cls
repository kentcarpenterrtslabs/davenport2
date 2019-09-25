global class RollupByLookupConfigSchedulable implements Schedulable {

	List<String> names = new List<String> {
		'RTS_equity_value',
		'RTS_fixed_income_value',
		'RTS_other_value',
		'RTS_cash_value',
		'RBLForFARForInvestmentsClientJointOwner',
		'RBLForFARForInvestmentsClientPrimaryOwner' };

	//global RollupByLookupConfigSchedulable() {
	//}

	//global RollupByLookupConfigSchedulable(List<String> names) {
		//this.names = names;
	//}

	global void execute(SchedulableContext sc) {
		toggleRollups(false);
	}

	public List<FinServ__RollupByLookupConfig__c> getRollups() {
		List<FinServ__RollupByLookupConfig__c> rollups = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name IN :names
		];
		return rollups;
	}

	public void toggleRollups(Boolean active) {
		List<FinServ__RollupByLookupConfig__c> rollups = getRollups();

		for (FinServ__RollupByLookupConfig__c rollup : rollups) {
			rollup.FinServ__Active__c = active;
		}

		update rollups;

		if (active) {
			// Create your list of IDs
			List<Id> rollupsToRun = new List<Id>();
			List<FinServ__RollupByLookupConfig__c> queriedRollups = getRollups();
			for (FinServ__RollupByLookupConfig__c rollup : queriedRollups) {
				System.debug('Adding to rollupsToRun: ' + rollup.Id + 'active: ' + rollup.FinServ__Active__c);
				rollupsToRun.add(rollup.Id);
			}

			System.debug('rollupsToRun: ' + JSON.serializePretty(rollupsToRun));
			// Create an instance of RollupRecalculationBatchable
			FinServ.RollupRecalculationBatchable job = new FinServ.RollupRecalculationBatchable(rollupsToRun);

			// Run the rollups
			Database.executeBatch(job);
		}
	}
}