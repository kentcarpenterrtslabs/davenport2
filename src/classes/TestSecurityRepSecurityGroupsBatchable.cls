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

		Rep_Security__c repSecurityRep = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityRep;

		Rep_Security__c repSecurityUPI = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPI;

		Rep_Security__c repSecurityNoRep = new Rep_Security__c(
			Rep_Number__c = 'DNE',
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurityNoRep;

		Rep_Security__c repSecurityNoUser = new Rep_Security__c(
			Rep_Number__c = rep2.Rep_Number__c,
			Davenport_Username__c = 'no user',
			Type__c = 'Rep');
		insert repSecurityNoUser;

		Test.startTest();
		SecurityRepSecurityGroupsBatchable batch = new SecurityRepSecurityGroupsBatchable();
		Database.executeBatch(batch);
		Test.stopTest();

		List<Group> groupsUPI = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Type = 'Regular'
			AND Name = :('Rep-Sec' + repSecurityUPI.Rep_Number__c + '-' + repSecurityUPI.Id)
		];
		System.assertEquals(1, groupsUPI.size());

		Rep_Security__c repSecurityUPIAfter = [
			SELECT
				GroupId__c,
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityUPI.Id
			LIMIT 1
		];

		System.assertEquals(groupsUPI[0].Id, repSecurityUPIAfter.GroupId__c);
		System.assertEquals(rep1.Id, repSecurityUPIAfter.Rep__c);
		System.assertEquals(user1.Id, repSecurityUPIAfter.User__c);

		Rep_Security__c repSecurityRepAfter = [
			SELECT
				GroupId__c,
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityRep.Id
			LIMIT 1
		];

		System.assertEquals(groupRep1.Id, repSecurityRepAfter.GroupId__c);
		System.assertEquals(rep1.Id, repSecurityRepAfter.Rep__c);
		System.assertEquals(user1.Id, repSecurityRepAfter.User__c);

		Rep_Security__c repSecurityNoRepAfter = [
			SELECT
				GroupId__c,
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityNoRep.Id
			LIMIT 1
		];

		System.assertEquals(null, repSecurityNoRepAfter.GroupId__c);
		System.assertEquals(null, repSecurityNoRepAfter.Rep__c);
		System.assertEquals(user1.Id, repSecurityNoRepAfter.User__c);

		Rep_Security__c repSecurityNoUserAfter = [
			SELECT
				GroupId__c,
				Rep__c,
				User__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityNoUser.Id
			LIMIT 1
		];

		System.assertEquals(groupRep2.Id, repSecurityNoUserAfter.GroupId__c);
		System.assertEquals(rep2.Id, repSecurityNoUserAfter.Rep__c);
		System.assertEquals(null, repSecurityNoUserAfter.User__c);

		//System.assertNotEquals(0, batch.log.length());
	}
}