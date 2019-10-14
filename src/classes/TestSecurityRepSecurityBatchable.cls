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
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurity;

		Rep_Security__c repSecurityUPI = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			User__c = user2.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPI;

		Rep_Security__c repSecurityNoRep = new Rep_Security__c(
			Rep_Number__c = 'DNE',
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityNoRep;

		Rep_Security__c repSecurityNoUser = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = 'no user',
			Type__c = 'Rep');
		insert repSecurityNoUser;

		Test.startTest();
		Database.executeBatch(new SecurityRepSecurityBatchable());
		Test.stopTest();


		Rep_Security__c repSecurityAfter = [
			SELECT
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurity.Id
		];

		System.assert(null != repSecurityAfter);
		System.assertEquals(rep1.Id, repSecurityAfter.Rep__c);


		Rep_Security__c repSecurityUPIAfter = [
			SELECT
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityUPI.Id
		];

		System.assert(null != repSecurityUPIAfter);
		System.assertEquals(rep1.Id, repSecurityUPIAfter.Rep__c);
		System.assertEquals(user1.Id, repSecurityUPIAfter.User__c);


		Rep_Security__c repSecurityNoRepAfter = [
			SELECT
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityNoRep.Id
		];

		System.assert(null != repSecurityNoRepAfter);
		System.assertEquals(null, repSecurityNoRepAfter.Rep__c);
		System.assertEquals(user1.Id, repSecurityNoRepAfter.User__c);


		Rep_Security__c repSecurityNoUserAfter = [
			SELECT
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityNoUser.Id
		];

		System.assert(null != repSecurityNoUserAfter);
		System.assertEquals(rep1.Id, repSecurityNoUserAfter.Rep__c);
		System.assertEquals(null, repSecurityNoUserAfter.User__c);
	}
}