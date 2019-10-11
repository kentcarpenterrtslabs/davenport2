// The FSC Rollups are too slow to run.
// they are Ok when someone is doing manual updates in front of computer, but not for Nightly Data load.
// So we turn them off before nightly data load, and then turn them back on after nightly load is done.
// After nightly data load is complete, some of the rollup calculations are done by our custom code, 
// while the others will be kicked off through this class.
// 

global class RollupByLookupConfigSchedulable implements Schedulable {

  List<String> namesToToggle = new List<String> {
        'RBLforAUMHH',
            'RBLForInvestmentsHH',
            'RTS_equity_value',
            'RTS_fixed_income_value',
            'RTS_other_value',
            'RTS_cash_value'};
                
      List<String> namesToToggleAndRun = new List<String> {                
            'RBLForTotalOutstandingCreditBankerHH',
            'RBLForFinAcctsHHHeld',
            'RBLForBankingHH',
            'RBLForTotalNumberOfAccountsBankerHH',
            'RBLForFARForLastTransactionDateHH',
            'RBLForFinAcctsHHTotal',
            'RBLForFARForTotalNumberOfAccountsPrimaryOwner',
            'RBLForFARForTotalNumberOfAccountsJointOwner',
            'RBLForFARForLastTransactionDatePrimaryOwner',
            'RBLForFARForLastTransactionDateJointOwner',
            'RBLForFARForFinAcctsClientHeldJointOwner',
            'RBLForFARForFinAcctsClientHeldPrimaryOwner',
            'RBLForFARForFinAcctsClientJointOwner',
            'RBLForFARForFinAcctsClientPrimaryOwner',
            'RBLForFARForInvestmentsClientJointOwner',
            'RBLForFARForInvestmentsClientPrimaryOwner',
            'RBLForFARforAUMClientJointOwner',
            'RBLForFARforAUMClientPrimaryOwner',
                'RBLForFARForTotalOutstandingCreditPrimaryOwner',
                'RBLForFARForTotalOutstandingCreditJointOwner',
                'RBLForFARForTotalBankDepositsJointOwner',
                'RBLForFARForTotalBankDepositsPrimaryOwner',
                'RBLForFARForInsuranceClientJointOwner',
                'RBLForFARForInsuranceClientPrimaryOwner',
                'RBLForFARForInsurancePremium'};
                    
                /*
    'RTS_equity_value',
    'RTS_fixed_income_value',
    'RTS_other_value',
    'RTS_cash_value',
    'RBLForFARForInvestmentsClientJointOwner',
    'RBLForFARForInvestmentsClientPrimaryOwner' 
*/

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
    
    public List<FinServ__RollupByLookupConfig__c> getInactiveRollups() {
    List<FinServ__RollupByLookupConfig__c> rollups = [
      SELECT
        Id,
        FinServ__Active__c
      FROM FinServ__RollupByLookupConfig__c
      WHERE ((Name IN :namesToToggle OR Name IN :namesToToggleAndRun) AND FinServ__Active__c = False)
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
    List<FinServ__RollupByLookupConfig__c> inactive_rollups = getInactiveRollups();

    for (FinServ__RollupByLookupConfig__c rollup : inactive_rollups) {
      rollup.FinServ__Active__c = active;
    }

    update inactive_rollups;
        
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