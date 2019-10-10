@isTest 
private class TestSecurityRepSecurityBatchable {

	@isTest
	private static void testRepSecurity() {
		Rep__c rep1 = new Rep__c(
			Rep_Number__c = 'TS01'
		);
		insert rep1;

		Group groupRep1 = new Group(
			Name = 'Rep-' + rep1.Rep_Number__c + '-' + rep1.Id
		);
		insert groupRep1;
		rep1.GroupId__c = groupRep1.Id;
		update rep1;

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

		User user2 = new User(
			Username = 'daventestuser2@test.com',
			LastName = 'TestUser2',
			Email = 'testuser2@test.com',
			Alias = 'tus2',
			Davenport_Username__c = 'testuser2',
			ProfileId = profileId,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles');
		insert user2;


		Rep_Security__c repSecurity = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurity;

		Rep_Security__c repSecurityUPI = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPI;

		Group groupRepSecurityUPI = new Group(
			Name = 'Rep-Sec' + repSecurityUPI.Rep_Number__c + '-' + repSecurityUPI.Id
		);
		insert groupRepSecurityUPI;
		repSecurityUPI.GroupId__c = groupRepSecurityUPI.Id;
		update repSecurityUPI;

		Rep_Security__c repSecurityNoRep = new Rep_Security__c(
			Rep_Number__c = 'DNE',
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityNoRep;

		Rep_Security__c repSecurityNoUser = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = 'no user',
			Type__c = 'Rep');
		insert repSecurityNoUser;

		Assistant_Assignment__c assistant = new Assistant_Assignment__c(
			Assistee__c = user1.Id,
			Assistant__c = user2.Id
		);
		insert assistant;

		Test.startTest();
		Database.executeBatch(new SecurityRepSecurityBatchable());
		Test.stopTest();

		List<GroupMember> groupMembers = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];

		System.assertEquals(2, groupMembers.size());
		System.assert(
			(groupMembers[0].UserOrGroupId == user1.Id && groupMembers[1].UserOrGroupId == user2.Id) ||
			(groupMembers[1].UserOrGroupId == user1.Id && groupMembers[0].UserOrGroupId == user2.Id));

		Rep_Security__c repSecurityAfter = [
			SELECT
				GroupId__c
			FROM Rep_Security__c
			WHERE Id = :repSecurity.Id
		];
		System.assert(null != repSecurityAfter);

		List<GroupMember> upiGroupMembers = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRepSecurityUPI.Id
		];
		System.assertEquals(2, upiGroupMembers.size());
		System.assert(
			(upiGroupMembers[0].UserOrGroupId == user1.Id && upiGroupMembers[1].UserOrGroupId == user2.Id) ||
			(upiGroupMembers[1].UserOrGroupId == user1.Id && upiGroupMembers[0].UserOrGroupId == user2.Id));
	}
}