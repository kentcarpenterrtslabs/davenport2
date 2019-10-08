@isTest 
private class TestRollupByLookupConfigSchedulable {

	@isTest
	private static void testToggleRollupsOff() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = true,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			Name = 'RTS_equity_value');

		insert testRollup;

		Test.startTest();

		String jobId = System.schedule('RollupByLookupConfigSchedulableTest',
            '0 0 0 15 3 ? 2022', 
            new RollupByLookupConfigSchedulable()); 

		Test.stopTest();

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RTS_equity_value'
			LIMIT 1
		];

		System.assertEquals(false, actual.FinServ__Active__c);
	}

	@isTest
	private static void testToggleRollupsOn() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = false,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			Name = 'RTS_equity_value');

		insert testRollup;

		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(true);

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RTS_equity_value'
			LIMIT 1
		];

		System.assertEquals(true, actual.FinServ__Active__c);
	}
}