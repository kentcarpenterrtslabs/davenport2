@isTest 
private class TestSecurityFinancialAccountBatchable {

	@isTest
	private static void testName() {
		Rep__c rep1 = new Rep__c(
			Rep_Number__c = 'TS01'
		);
		insert rep1;

		Rep__c rep2 = new Rep__c(
			Rep_Number__c = 'TS02'
		);
		insert rep2;

		Group groupRep1 = new Group(
			Name = 'Rep-' + rep1.Rep_Number__c + '-' + rep1.Id
		);
		insert groupRep1;
		rep1.GroupId__c = groupRep1.Id;
		update rep1;

		Group groupRep2 = new Group(
			Name = 'Rep-' + rep2.Rep_Number__c + '-' + rep2.Id
		);
		insert groupRep2;
		rep2.GroupId__c = groupRep2.Id;
		update rep2;
		
		Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contact Client/Prospect').getRecordTypeId();

		Account account1 = new Account(Name = 'test account one', RecordTypeId = householdRecordTypeId);
		insert account1;

		Account client1 = new Account(LastName = 'test client one', RecordTypeId = clientRecordTypeId);
		insert client1;

		FinServ__FinancialAccount__c financialAccount1 = new FinServ__FinancialAccount__c(
			Name = 'financial account one',
			Rep__c = rep1.Id,
			FinServ__PrimaryOwner__c = client1.Id);
		insert financialAccount1;

		FinServ__FinancialAccount__Share financialAcountShare1 = new FinServ__FinancialAccount__Share(
			AccessLevel = 'Edit',
			ParentId = financialAccount1.Id,
			RowCause = 'RTSSecurityAssignment__c',
			UserOrGroupId = groupRep1.Id);
		insert financialAcountShare1;

		Account_Split__c accountSplit = new Account_Split__c(
			Financial_Account__c = financialAccount1.Id,
			Rep__c = rep2.Id);
		insert accountSplit;

		Test.startTest();
		Database.executeBatch(new SecurityFinancialAccountBatchable());
		Test.stopTest();

		List<FinServ__FinancialAccount__Share> financialAccountShares = [
			SELECT
				ParentId,
				UserOrGroupId
			FROM FinServ__FinancialAccount__Share
			WHERE RowCause = 'RTSSecurityAssignment__c'
		];

		List<AccountShare> accountShares = [
			SELECT
				AccountId,
				UserOrGroupId
			FROM AccountShare
			WHERE RowCause = 'Manual'
		];

		System.assertEquals(2, financialAccountShares.size());
		System.assertEquals(2, accountShares.size());
	}
}