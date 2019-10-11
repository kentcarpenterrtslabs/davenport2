@isTest 
private class TestSecurityDeleteAllBathable {

	private static final String TEST_GROUP_NAME = 'Rep-Group1';

	@isTest
	private static void testDeleteAll() {

        Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

		User user1 = new User(
			Username = 'daventestuser1@test.com',
			LastName = 'TestUser1',
			Email = 'testuser1@test.com',
			Alias = 'tus1',
			Davenport_Username__c = 'testuser1',
			ProfileId = profileId,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles');
		insert user1;

		Group group1 = new Group(
			Name = TEST_GROUP_NAME,
			Type = 'Regular');
		insert group1;

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
			GroupMember groupMember1 = new GroupMember(
				GroupId = group1.Id,
				UserOrGroupId = user1.Id);
			insert groupMember1;
		} 

        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contact Client/Prospect').getRecordTypeId();

		Account account1 = new Account(Name = 'test account one', RecordTypeId = householdRecordTypeId);
		insert account1;

		Account client1 = new Account(LastName = 'test client one', RecordTypeId = clientRecordTypeId);
		insert client1;

		AccountShare accountShare1 = new AccountShare(
			RowCause = 'Manual',
			AccountAccessLevel = 'Edit',
			OpportunityAccessLevel = 'Edit',
			AccountId = account1.Id,
			UserOrGroupId = group1.Id
		);
		insert accountShare1;

		FinServ__FinancialAccount__c financialAccount1 = new FinServ__FinancialAccount__c(Name = 'financial account one', FinServ__PrimaryOwner__c = client1.Id);
		insert financialAccount1;

		FinServ__FinancialAccount__Share financialAcountShare1 = new FinServ__FinancialAccount__Share(
			AccessLevel = 'Edit',
			ParentId = financialAccount1.Id,
			RowCause = 'RTSSecurityAssignment__c',
			UserOrGroupId = group1.Id);
		insert financialAcountShare1;

		validateCounts(1, user1);

		Test.startTest();
		Database.executeBatch(new SecurityDeleteAllBatchable());
		Test.stopTest();
		
		validateCounts(0, user1);
	}

	public static void validateCounts(Integer expected, User user1) {

		List<Group> groups = [
			SELECT
				Id
			FROM Group
			WHERE Name = :TEST_GROUP_NAME
			AND Type = 'Regular'
		];
		System.assertEquals(expected, groups.size());

		List<GroupMember> GroupMemberMembers = [
			SELECT
				Id
			FROM GroupMember
			WHERE UserOrGroupId = :user1.Id
		];
		System.assertEquals(expected, GroupMemberMembers.size());

		List<AccountShare> accountShares = [
			SELECT
				Id
			FROM AccountShare
			WHERE RowCause = 'Manual'
		];
		System.assertEquals(expected, accountShares.size());

		List<FinServ__FinancialAccount__Share> financialAcountShares = [
			SELECT
				Id
			FROM FinServ__FinancialAccount__Share
			WHERE RowCause = 'RTSSecurityAssignment__c'
		];
		System.assertEquals(expected, financialAcountShares.size());
	}

}