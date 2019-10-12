public class NightlyRunStatusTriggerHander  {

  public void handleAfterInsert(List<Nightly_Run_Status__c> newStatuses) {

        // we will look at only the first record, in it -
        // if the status posted is 'rollup', then do only Rollup Calculations
        // If the status is 'security' , only run the rep securities.
        // for anything else, run both.
            
        Boolean doOnlyRollups = False;
        Boolean doOnlySecurity = False;
        if (newStatuses[0].Status__c == 'rollup') {
            doOnlyRollups = True;
        }
        if (newStatuses[0].Status__c == 'security') {
            doOnlySecurity = True;
        }
        
        if ( doOnlyRollups == True ) {
            Database.executeBatch(new FinancialAccountRollupBatchable());
            return;
        }
        if (doOnlySecurity == True) {
            if ( !Test.isRunningTest() ) {
                Database.executeBatch(new SecurityDeleteAllLauncher());
            }
            return;
        }
        
        Database.executeBatch(new FinancialAccountRollupBatchable());
        if ( !Test.isRunningTest() ) {
            Database.executeBatch(new SecurityDeleteAllLauncher());
        }
  }
}