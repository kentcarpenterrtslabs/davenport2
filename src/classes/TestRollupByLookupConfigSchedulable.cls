@isTest
private class TestRollupByLookupConfigSchedulable {

	@isTest
	private static void testToggleRollupsOffWithOrder() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = true,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			RTS_Order__c = 1,
			Name = 'RBLForFinAcctsHHHeld');

		insert testRollup;

		Test.startTest();

		//String jobId = System.schedule('RollupByLookupConfigSchedulableTest',
            //'0 0 0 15 3 ? 2022', 
            //new RollupByLookupConfigSchedulable()); 

		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(false);

		Test.stopTest();

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RBLForFinAcctsHHHeld'
			LIMIT 1
		];

		System.assertEquals(false, actual.FinServ__Active__c);
	}

	@isTest
	private static void testToggleRollupsOffWithNoOrder() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = true,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			Name = 'RBLForFinAcctsHHHeld');

		insert testRollup;

		Test.startTest();

		//String jobId = System.schedule('RollupByLookupConfigSchedulableTest',
            //'0 0 0 15 3 ? 2022', 
            //new RollupByLookupConfigSchedulable()); 

		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(false);

		Test.stopTest();

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RBLForFinAcctsHHHeld'
			LIMIT 1
		];

		System.assertEquals(true, actual.FinServ__Active__c);
	}

	@isTest
	private static void testToggleRollupsOnWithOrder() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = false,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			RTS_Order__c = 1,
			Name = 'RBLForFinAcctsHHHeld');

		insert testRollup;

		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(true);

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RBLForFinAcctsHHHeld'
			LIMIT 1
		];

		System.assertEquals(true, actual.FinServ__Active__c);
	}

	@isTest
	private static void testToggleRollupsOnNoOrder() {
		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = false,
			FinServ__FromField__c = 'FinServ__Balance__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'SUM',
			FinServ__ToField__c = 'Total_Acct_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'FinServ__Balance__c',
			Name = 'RBLForFinAcctsHHHeld');

		insert testRollup;

		RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable();
		sched.toggleRollups(true);

		FinServ__RollupByLookupConfig__c actual = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RBLForFinAcctsHHHeld'
			LIMIT 1
		];

		System.assertEquals(false, actual.FinServ__Active__c);
	}}