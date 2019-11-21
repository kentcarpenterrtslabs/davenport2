@isTest 
private class TestNewCall {

	@isTest
	private static void testCreateTask() {
		Account acct1 = new Account(
			Name = 'test account'
		);
		insert acct1;

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
		insert user1;		String subject = Task.Subject.getDescribe().getPicklistValues()[0].getLabel();		String status = Task.Status.getDescribe().getPicklistValues()[0].getLabel();		String regarding = Task.FinServ__Regarding__c.getDescribe().getPicklistValues()[0].getLabel();		String comments = 'test comments';		Date dueDate = Date.today();

		Test.startTest();
		newCall.createTask(acct1.Id, user1.Id, subject, status, regarding, comments, dueDate);
		Test.stopTest();

		Task actual = [
			SELECT
				Id,
				Subject,
				Status,
				FinServ__Regarding__c,
				Description,
				ActivityDate,
				WhatId,
				OwnerId
			FROM Task
			WHERE Subject = :subject
		];

		System.assertEquals(subject, actual.Subject, 'subject');
		System.assertEquals(status, actual.Status, 'status');
		System.assertEquals(regarding, actual.FinServ__Regarding__c, 'regarding');
		System.assertEquals(comments, actual.Description, 'comments');
		System.assertEquals(dueDate, actual.ActivityDate, 'dueDate');
		System.assertEquals(acct1.Id, actual.WhatId, 'WhatId');
		System.assertEquals(user1.Id, actual.OwnerId, 'OwnerId');
	}
}