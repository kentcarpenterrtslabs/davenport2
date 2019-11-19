// The FSC Rollups are too slow to run.
// they are Ok when someone is doing manual updates in front of computer, but not for Nightly Data load.
// So we turn them off before nightly data load, and then turn them back on after nightly load is done.
// After nightly data load is complete, some of the rollup calculations are done by our custom code, 
// while the others will be kicked off through this class.
// 

global class RollupByLookupConfigSchedulable implements Schedulable {

	global void execute(SchedulableContext sc) {
		toggleRollups(false);
	}

    public List<FinServ__RollupByLookupConfig__c> getRollupsForState(Boolean state) {
		List<FinServ__RollupByLookupConfig__c> rollups = [
			SELECT
				Id,
				Name,
				FinServ__Active__c,
				RTS_Order__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE RTS_Order__c != null
			AND FinServ__Active__c = :state
			ORDER BY RTS_Order__c
		];
		return rollups;
	}


	public void toggleRollups(Boolean active) {
        
		List<FinServ__RollupByLookupConfig__c> rollups = getRollupsForState(! active);

		for (FinServ__RollupByLookupConfig__c rollup : rollups) {
			rollup.FinServ__Active__c = active;
		}

		update rollups;
        
		Boolean dontRunRollups = false;

		if (active) {
			// Create your list of IDs
			List<Id> rollupsToRun = new List<Id>();

			for (FinServ__RollupByLookupConfig__c rollup : rollups) {
				if (rollup.RTS_Order__c > 0) {
					System.debug('Adding to rollupsToRun: ' + rollup.Id + ' ' + rollup.Name + 'active: ' + rollup.FinServ__Active__c);
					rollupsToRun.add(rollup.Id);
				}
			}

			System.debug('rollupsToRun: ' + JSON.serializePretty(rollupsToRun));

            if (! dontRunRollups) {
				// Create an instance of RollupRecalculationBatchable
				FinServ.RollupRecalculationBatchable job = new FinServ.RollupRecalculationBatchable(rollupsToRun);

				// Run the rollups
				Database.executeBatch(job);
			}
		}
	}
}