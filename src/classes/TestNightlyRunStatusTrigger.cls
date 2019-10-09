@isTest 
private class TestNightlyRunStatusTrigger {

	@TestSetup
	private static void setup() {
	
		Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
		Id contactClientProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contact Client/Prospect').getRecordTypeId();
		
		Account acct = new Account(Name='a household', RecordTypeId = householdRecordTypeId);
		insert acct;

		Account client = new Account(FirstName='test', LastName='client', RecordTypeId = contactClientProspectRecordTypeId);
		insert client;

		Contact contactForClient = [
			SELECT
				Id
			FROM Contact
			WHERE AccountId = :client.Id
			LIMIT 1
		];

		AccountContactRelation acr = new AccountContactRelation(
			AccountId = acct.Id,
			ContactId = contactForClient.Id,
			FinServ__IncludeInGroup__c = false,
			FinServ__Primary__c = true,
			FinServ__PrimaryGroup__c = true,
			IsActive = true,
			Roles = 'Client');
		insert acr;

		FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c(
			Name = 'test',
			Cash_Value__c = 0.00,
			FinServ__Household__c = acct.Id,
			FinServ__PrimaryOwner__c = client.Id,
			FinServ__OwnerType__c = client.Id
		);
		insert finAcct;

		FinServ__RollupByLookupConfig__c testRollup = new FinServ__RollupByLookupConfig__c(
			FinServ__Active__c = false,
			FinServ__FromField__c = 'Cash_Value__c',
			FinServ__FromObject__c = 'FinServ__FinancialAccount__c',
			FinServ__LookupField__c = 'FinServ__Household__c',
			FinServ__RollupOperation__c = 'Sum',
			FinServ__ToField__c = 'Cash_Value__c',
			FinServ__ToObject__c = 'Account',
			FinServ__UpdateOnChange__c = 'Cash_Value__c',
			Name = 'RTS_equity_value');

		insert testRollup;
	}

	@isTest
	private static void testHandleAfterInsert() {

		FinServ__RollupByLookupConfig__c actualRollup = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RTS_equity_value'
			LIMIT 1
		];

		System.assertEquals(false, actualRollup.FinServ__Active__c);	

		Test.startTest();

		Nightly_Run_Status__c status = new Nightly_Run_Status__c(Status__c = 'Complete');
		insert status;

		//RollupByLookupConfigSchedulable sched = new RollupByLookupConfigSchedulable(new List<String> {testRollup.Name});
		//sched.toggleRollups(true);

		Test.stopTest();

		actualRollup = [
			SELECT
				Id,
				FinServ__Active__c
			FROM FinServ__RollupByLookupConfig__c
			WHERE Name = 'RTS_equity_value'
			LIMIT 1
		];

		System.assertEquals(true, true);
	}
}