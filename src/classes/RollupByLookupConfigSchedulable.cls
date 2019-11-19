// The FSC Rollups are too slow to run.
// they are Ok when someone is doing manual updates in front of computer, but not for Nightly Data load.
// So we turn them off before nightly data load, and then turn them back on after nightly load is done.
// After nightly data load is complete, some of the rollup calculations are done by our custom code, 
// while the others will be kicked off through this class.
// 

global class RollupByLookupConfigSchedulable implements Schedulable {

	List<String> namesToToggle = new List<String> {
        'RBLforAUMHH',
            'RBLForInvestmentsHH', // HH - total Investments
            'RTS_equity_value',
            'RTS_fixed_income_value',
            'RTS_other_value',
            'RTS_cash_value'};
                
    	List<String> namesToToggleAndRun = new List<String> { 
            'RBLForFARForFinAcctsClientHeldJointOwner',    //for wallet-share in Client
                'RBLForFARForFinAcctsClientHeldPrimaryOwner',  //for wallet-share in Client
                'RBLForFinAcctsHHTotal',                       // for wallet-share in HH
                'RBLForFinAcctsClientHeldPrimaryOwner',  // for wallet share in HH
                'RBLForFinAcctsHHHeld',
                'RBLForFinAcctsClientPrimaryOwner',
                'RBLForFinAcctsClientHeldJointOwner',
                'RBLForFARForInvestmentsClientPrimaryOwner',
                'RBLForFARForFinAcctsClientPrimaryOwner'};
              
/*                
                'RBLForFARForFinAcctsClientJointOwner',
                'RBLForFARForInvestmentsClientJointOwner',

                'RBLForFARforAUMClientJointOwner',
                'RBLForFARforAUMClientPrimaryOwner',
                
                'RBLForTotalOutstandingCreditBankerHH',
                'RBLForBankingHH',
                'RBLForTotalNumberOfAccountsBankerHH',
                'RBLForFARForLastTransactionDateHH',
                'RBLForFARForTotalNumberOfAccountsPrimaryOwner',
                'RBLForFARForTotalNumberOfAccountsJointOwner',
                'RBLForFARForLastTransactionDatePrimaryOwner',
                'RBLForFARForLastTransactionDateJointOwner',
                'RBLForFARForTotalOutstandingCreditPrimaryOwner',
                'RBLForFARForTotalOutstandingCreditJointOwner',
                'RBLForFARForTotalBankDepositsJointOwner',
                'RBLForFARForTotalBankDepositsPrimaryOwner',
                'RBLForFARForInsuranceClientJointOwner',
                'RBLForFARForInsuranceClientPrimaryOwner',
                'RBLForFARForInsurancePremium'
                }; */
                    


	global void execute(SchedulableContext sc) {
		toggleRollups(false);
	}

	public List<FinServ__RollupByLookupConfig__c> getRollups() {
		List<FinServ__RollupByLookupConfig__c> rollups = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE (Name IN :namesToToggle OR Name IN :namesToToggleAndRun)
		];
		return rollups;
	}
    
    public List<FinServ__RollupByLookupConfig__c> getRollupsForState(Boolean state) {
		List<FinServ__RollupByLookupConfig__c> rollups = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE ((Name IN :namesToToggle OR Name IN :namesToToggleAndRun) AND FinServ__Active__c = :state)
		];
		return rollups;
	}
	public List<FinServ__RollupByLookupConfig__c> getRollupsToRun() {
		List<FinServ__RollupByLookupConfig__c> rollups = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE (Name IN :namesToToggleAndRun AND FinServ__Active__c = True)
		];
		return rollups;
	}
	public void toggleRollups(Boolean active) {
        
		List<FinServ__RollupByLookupConfig__c> rollups;
         if ( active == True ) {
            rollups = getRollupsForState(False);
         } else {
             rollups = getRollupsForState(True);
         }

		for (FinServ__RollupByLookupConfig__c rollup : rollups) {
			rollup.FinServ__Active__c = active;
		}

		update rollups;
        
Boolean dontrunit = False;
		if (active) {
            //if (dontrunit) {
			// Create your list of IDs
			List<Id> rollupsToRun = new List<Id>();
			List<FinServ__RollupByLookupConfig__c> queriedRollups = getRollupsToRun();
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