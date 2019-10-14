@isTest 
private class TestSecurityRepSecurityGroupsBatchable {

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

		Rep__c rep2 = new Rep__c(
			Rep_Number__c = 'TS02'
		);
		insert rep2;

		Group groupRep2 = new Group(
			Name = 'Rep-' + rep2.Rep_Number__c + '-' + rep2.Id
		);
		insert groupRep2;
		rep2.GroupId__c = groupRep2.Id;
		update rep2;


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

		Assistant_Assignment__c assistant = new Assistant_Assignment__c(
			Assistee__c = user1.Id,
			Assistant__c = user2.Id
		);
		insert assistant;

		Rep_Security__c repSecurityRep = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Rep__c = rep1.Id,
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityRep;

		Rep_Security__c repSecurityUPIRep1 = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Rep__c = rep2.Id,
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPIRep1;

		Rep_Security__c repSecurityUPIRep2 = new Rep_Security__c(
			Rep_Number__c = rep2.Rep_Number__c,
			Rep__c = rep2.Id,
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPIRep2;

		Rep_Security__c repSecurityNoRep = new Rep_Security__c(
			Rep_Number__c = 'DNE',
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityNoRep;

		Rep_Security__c repSecurityNoUser = new Rep_Security__c(
			Rep_Number__c = rep2.Rep_Number__c,
			Rep__c = rep2.Id,
			Davenport_Username__c = 'no user',
			Type__c = 'Rep');
		insert repSecurityNoUser;

		Test.startTest();
		SecurityRepSecurityGroupsBatchable batch = new SecurityRepSecurityGroupsBatchable(new List<Id> { user1.Id, user2.Id });
		Database.executeBatch(batch);
		Test.stopTest();

		List<Group> groupsUPI = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Type = 'Regular'
			AND Name = :('Rep-UPI-' + user1.Davenport_Username__c + '-' + user1.Id)
		];
		System.assertEquals(1, groupsUPI.size());

		User user1After = [
			SELECT
				UPI_GroupId__c
			FROM User
			WHERE Id = :user1.Id
		];
		System.assertEquals(groupsUPI[0].Id, user1After.UPI_GroupId__c);

		List<GroupMember> groupMembersRep1 = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];
		System.assertEquals(2, groupMembersRep1.size());
		System.assert(
			(user1.Id == groupMembersRep1[0].UserOrGroupId && user2.Id == groupMembersRep1[1].UserOrGroupId) ||
			(user2.Id == groupMembersRep1[0].UserOrGroupId && user1.Id == groupMembersRep1[1].UserOrGroupId));
	}
}