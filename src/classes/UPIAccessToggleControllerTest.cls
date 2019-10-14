/**
 * Created by Eric Stansbury on 7/19/2019.
 */

@isTest
public class UPIAccessToggleControllerTest {

    @isTest
	public static void testToggleUPIAccess(){
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
			Firm_Wide_Access_Enabled__c = false,
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

		Rep_Security__c repSecurityUPI = new Rep_Security__c(
			Rep_Number__c = rep1.Rep_Number__c,
			Rep__c = rep1.Id,
			Davenport_Username__c = user1.Davenport_Username__c,
			Type__c = 'UPI');
		insert repSecurityUPI;

		Group groupRepSecurityUPI = new Group(
			Name = 'Rep-UPI' + user1.Davenport_Username__c + '-' + user1.Id
		);
		insert groupRepSecurityUPI;
		user1.UPI_GroupId__c = groupRepSecurityUPI.Id;
		update user1;

		Assistant_Assignment__c assistant = new Assistant_Assignment__c(
			Assistee__c = user1.Id,
			Assistant__c = user2.Id
		);
		insert assistant;

		
		List<GroupMember> groupMembersBeforeEnabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];

		System.assertEquals(0, groupMembersBeforeEnabled.size());
		
		List<GroupMember> upiGroupMembersBeforeEnabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRepSecurityUPI.Id
		];

		System.assertEquals(0, upiGroupMembersBeforeEnabled.size());

		// test enable

        System.runAs(user1){
            UPIAccessToggleController.enableUPIAccess();
        }

		List<GroupMember> groupMembersAfterEnabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];

		System.assertEquals(0, groupMembersAfterEnabled.size());

		List<GroupMember> upiGroupMembersAfterEnabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRepSecurityUPI.Id
		];

		System.assertEquals(2, upiGroupMembersAfterEnabled.size());

		User user1AfterEnabled = [
			SELECT
				Firm_Wide_Access_Enabled__c
			FROM User
			WHERE Id = :user1.Id
		];

		System.assertEquals(true, user1AfterEnabled.Firm_Wide_Access_Enabled__c);

		// test disable

        System.runAs(user1){
            UPIAccessToggleController.disableUPIAccess();
        }


		List<GroupMember> groupMembersAfterDisabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];

		System.assertEquals(0, groupMembersAfterDisabled.size());

		List<GroupMember> upiGroupMembersAfterDisabled = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRepSecurityUPI.Id
		];

		System.assertEquals(0, upiGroupMembersAfterDisabled.size());

		User user1AfterDisabled = [
			SELECT
				Firm_Wide_Access_Enabled__c
			FROM User
			WHERE Id = :user1.Id
		];

		System.assertEquals(false, user1AfterDisabled.Firm_Wide_Access_Enabled__c);
    }
}