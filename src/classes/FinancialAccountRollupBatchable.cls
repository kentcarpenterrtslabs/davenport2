global class FinancialAccountRollupBatchable implements Database.Batchable<SObject> {
	
	global FinancialAccountRollupBatchable() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id
			FROM Account
		]);
	}
  
   	global void execute(Database.BatchableContext context, List<Account> scope) {
        Integer a = 0;
        
        System.debug('scope: ' + JSON.serializePretty(scope));
        List<AggregateResult> sums = [
			SELECT
                FinServ__Household__c,
                SUM(FinServ__Balance__c) Balance,
                SUM(Cash_Value__c) Cash,
                SUM(Equity_Value__c) Equity,
                SUM(Fixed_Income_Value__c) FixedIncome,
                SUM(Other_Value__c) Other
            FROM FinServ__FinancialAccount__c	
            WHERE FinServ__Household__c IN :scope
            GROUP BY FinServ__Household__c
		];
        
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;
        a = a+1;

		System.debug('sums: ' + JSON.serializePretty(sums));

		Map<Id,AggregateResult> householdSums = new Map<Id,AggregateResult>();

		for (AggregateResult sum : sums) {
			householdSums.put((Id)sum.get('FinServ__Household__c'),sum);
		}

		System.debug(JSON.serializePretty(householdSums));

		List<Account> accounts = [
			SELECT
				Id,
            	FinServ__TotalInvestmentsPrimaryOwner__c,
				Cash_Value__c,
				Equity_Value__c,
				Fixed_Income_Value__c,
				Other_Value__c
			FROM Account
			WHERE Id IN :householdSums.keySet()
		];
        System.debug(JSON.serializePretty(accounts));

		for (Account acct : accounts) {
			AggregateResult sum = householdSums.get(acct.Id);
            acct.FinServ__TotalInvestmentsPrimaryOwner__c = (Decimal)sum.get('Balance');
			acct.Cash_Value__c = (Decimal)sum.get('Cash');
			acct.Equity_Value__c = (Decimal)sum.get('Equity');
			acct.Fixed_Income_Value__c =(Decimal) sum.get('FixedIncome');
			acct.Other_Value__c = (Decimal)sum.get('Other');
		}

		//System.debug('accounts updated : ' + accounts.size());

		update accounts;
	}
	
	global void finish(Database.BatchableContext context) {
        // After our rollups are done, we will turn ON FSC rollups and run them.
        RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
        if ( !Test.isRunningTest() ) {
            sched.toggleRollups(true);
        }
	}
}