@isTest 
private class TestSecurityRepSecurityGroupsBatchable {

	@isTest
	private static void testRepSecurity() {
		Rep__c rep1 = new Rep__c(
			Rep_Number__c = 'TS01'
		);
		insert rep1;

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

		Rep_Security__c repSecurityUPI = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPI;

		Test.startTest();
		Database.executeBatch(new SecurityRepSecurityGroupsBatchable());
		Test.stopTest();


		Group group1 = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Type = 'Regular'
			AND Name = :('Rep-Sec' + repSecurityUPI.Rep_Number__c + '-' + repSecurityUPI.Id)
		];

		Rep_Security__c repSecurityUPIAfter = [
			SELECT
				GroupId__c,
				Rep__c
			FROM Rep_Security__c
			WHERE Id = :repSecurityUPI.Id
			LIMIT 1
		];

		System.assertNotEquals(null, group1);
		System.assertEquals(repSecurityUPIAfter.GroupId__c, group1.Id);
		System.assertEquals(repSecurityUPIAfter.Rep__c, rep1.Id);
	}
}