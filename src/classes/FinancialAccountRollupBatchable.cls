global class FinancialAccountRollupBatchable implements Database.Batchable<SObject> {
	
	global FinancialAccountRollupBatchable() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Name
			FROM FinServ__FinancialAccount__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<FinServ__FinancialAccount__c> scope) {
		List<AggregateResult> sums = [
			SELECT
				FinServ__Household__c,
				SUM(Cash_Value__c) Cash,
				SUM(Equity_Value__c) Equity,
				SUM(Fixed_Income_Value__c) FixedIncome,
				SUM(Other_Value__c) Other
			FROM FinServ__FinancialAccount__c
			WHERE Id IN :scope
			GROUP BY FinServ__Household__c
		];


		//System.debug(JSON.serializePretty(sums));

		Map<Id,AggregateResult> householdSums = new Map<Id,AggregateResult>();

		for (AggregateResult sum : sums) {
			householdSums.put((Id)sum.get('FinServ__Household__c'),sum);
		}

		//System.debug(JSON.serializePretty(householdSums));

		List<Account> accounts = [
			SELECT
				Id,
				Cash_Value__c,
				Equity_Value__c,
				Fixed_Income_Value__c,
				Other_Value__c
			FROM Account
			WHERE Id IN :householdSums.keySet()
		];

		for (Account acct : accounts) {
			AggregateResult sum = householdSums.get(acct.Id);
			acct.Cash_Value__c = (Decimal)sum.get('Cash');
			acct.Equity_Value__c = (Decimal)sum.get('Equity');
			acct.Fixed_Income_Value__c =(Decimal) sum.get('FixedIncome');
			acct.Other_Value__c = (Decimal)sum.get('Other');
		}

		//System.debug('accounts updated : ' + accounts.size());

		update accounts;
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}