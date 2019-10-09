@isTest 
private class TestSecurityResetFirmWideAccessBatchable {

	@isTest
	private static void testResetUserAccess() {

        Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

		User user1 = new User(
			Firm_Wide_Access_Enabled__c = true,
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

		validate(true, user1.Id);

		Test.startTest();
		Database.executeBatch(new SecurityResetFirmWideAccessBatchable());
		Test.stopTest();

		validate(false, user1.Id);
	}

	public static void validate(Boolean expected, Id userId) {
		User actual = [
			SELECT
				Id,
				Firm_Wide_Access_Enabled__c
			FROM User
			WHERE Id = :userId
			LIMIT 1
		];

		System.assertEquals(expected, actual.Firm_Wide_Access_Enabled__c);
	}
}