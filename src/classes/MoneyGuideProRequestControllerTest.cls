/**
 * Created by Eric Stansbury on 5/1/2019.
 */

@isTest
public class MoneyGuideProRequestControllerTest {

	@IsTest
	public static void test_updateUser() {

        Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

		User user1 = new User(
			Username = 'daventestuser1@test.com',
			FirstName = 'Test1',
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
			FirstName = 'test2',
			LastName = 'TestUser2',
			MGP_User_ID__c = 'mgp.testuser2@test.com',
			MGP_License_Type__c = 'Advisor',
			Firm_Wide_Access_Enabled__c = false,
			Email = 'testuser2@test.com',
			Alias = 'tus2',
			Davenport_Username__c = 'testuser2',
			ProfileId = profileId,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles');
		insert user2;
	
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

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs ( thisUser ) {
			GroupMember groupMember1 = new GroupMember(
				GroupId = groupRep1.Id,
				UserOrGroupId = user1.Id
			);
			insert groupMember1;

			GroupMember groupMember2 = new GroupMember(
				GroupId = groupRep1.Id,
				UserOrGroupId = user2.Id
			);
			insert groupMember2;
		}

		Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contact Client/Prospect').getRecordTypeId();

		Account client1 = new Account(LastName = 'test client one', RecordTypeId = clientRecordTypeId);
		insert client1;

		client1 = [
			SELECT
				PersonContactId
			FROM Account
			WHERE Id = :client1.Id
		];

		Account account1 = new Account(Name = 'test account one', RecordTypeId = householdRecordTypeId, FinServ__PrimaryContact__c = client1.PersonContactId);
		insert account1;

		AccountShare accountShare1 = new AccountShare(
			RowCause = 'Manual',
			AccountAccessLevel = 'Edit',
			OpportunityAccessLevel = 'Edit',
			AccountId = account1.Id,
			UserOrGroupId = groupRep1.Id
		);
		insert accountShare1;

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

		System.runAs(user1) {
			String url = MoneyGuideProRequestController.updateUser(account1.Id,user2.Id);
			System.assertNotEquals(0, url.length());
		}

		User user1After = [
			SELECT
				Id,
				SAML_UserId__c,
				SAML_HHID__c,
				SAML_MGP_FirstName__c,
				SAML_MGP_LastName__c,
				SAML_MGP_Username__c
			FROM User
			WHERE Id = :user1.Id
		];
		System.assertEquals(user2.Id, user1After.SAML_UserID__c);
		System.assertEquals(account1.Id, user1After.SAML_HHID__c);
		System.assertEquals(user2.FirstName, user1After.SAML_MGP_FirstName__c);
		System.assertEquals(user2.LastName, user1After.SAML_MGP_LastName__c);
		System.assertEquals(user2.MGP_User_ID__c, user1After.SAML_MGP_Username__c);

		MoneyGuideProRequestController.HouseholdData householdData = MoneyGuideProRequestController.getHouseholdData(account1.Id,user2.Id);
		System.assertEquals(true,householdData.hasPrimaryContact);
		System.assertEquals(false,householdData.isFirmWideAccessEnabled);
		System.assertEquals(true,householdData.hasMGPLicense);
		System.assertEquals(1, householdData.mgpUsers.size());
		System.assertEquals(user2.Id, householdData.mgpUsers[0].Id);
	}
}