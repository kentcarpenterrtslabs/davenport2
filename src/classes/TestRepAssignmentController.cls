@isTest 
private class TestRepAssignmentController {

	@isTest
	private static void testName() {

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

		Rep_Security__c repSecurity = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Rep__c = rep1.Id,
			User__c = user1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'Rep');
		insert repSecurity;

		List<Rep_Security__c> results = RepAssignmentController.getRepLabelData();

		System.assertEquals(1, results.size());
		System.assertEquals(rep1.Rep_Number__c, results[0].Rep__r.Rep_Number__c);
	}
}