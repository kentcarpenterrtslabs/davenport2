public class NightlyRunStatusTriggerHander  {

  public void handleAfterInsert(List<Nightly_Run_Status__c> newStatuses) {

		// we will look at only the first record, in it -
		// if the status posted is

		// 'disable rollups'     -- disable FinServ rollups
		// 'enable rollups'      -- run custom rollup calculations, then enable FinServ rollups
		// 'security deletions'  -- run rep security deletions
		// 'security creations ' -- run rep security creations
		// 'data load starting'  -- run rep security deletions
		// 'data load finsihed'  -- run rep security creation and rollup calculations
        
		Boolean disableRollups = false;
		Boolean enableRollups = false;
		Boolean runSecurityDeletions = false;
		Boolean runSecurityCreations = false;

		System.debug('NightlyRunStatusTriggerHander.handleAfterInsert newStatuses[0].Status__c = ' + newStatuses[0].Status__c);

		switch on newStatuses[0].Status__c {
			when 'disable rollups' {
				disableRollups = true;
			}
			when 'enable rollups' {
				enableRollups = true;
			}
			when 'security deletions' {
				runSecurityDeletions = true;
			}
			when 'security creations' {
				runSecurityCreations = true;
			}
			when 'data load starting' {
				disableRollups = true;
				runSecurityDeletions = true;
			}
			when 'data load finished' {
				enableRollups = true;
				runSecurityCreations = true;
			}
		}

		System.debug(
			'disableRollups = ' + disableRollups +
			', enableRollups = ' + enableRollups +
			', runSecurityDeletions = ' + runSecurityDeletions +
			', runSecurityCreations = ' + runSecurityCreations);

		if ( !Test.isRunningTest() ) {
			if (disableRollups) {
				RollupByLookupConfigSchedulable rollups = new RollupByLookupConfigSchedulable();
				rollups.toggleRollups(false);
			}
			if (enableRollups) {
				RollupByLookupConfigSchedulable rollups = new RollupByLookupConfigSchedulable();
				rollups.toggleRollups(true);
				Database.executeBatch(new FinancialAccountRollupBatchable());
			}
			if (runSecurityDeletions) {
				System.enqueueJob(new SecurityDeleteAllLauncher());
			}
			if (runSecurityCreations) {
				Database.executeBatch(new SecurityResetFirmWideAccessBatchable());
			}
		}
	}
}