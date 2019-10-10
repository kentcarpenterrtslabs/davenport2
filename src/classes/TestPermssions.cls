@isTest 
private class TestPermssions {
    public static String davenportUsernameOne = 'testuser1';
    public static String davenportUsernameTwo = 'testuser2';
    public static String davenportUsernameThree = 'testuser3';
    public final static String HOUSEHOLD_RECORDTYPE_NAME = 'IndustriesHousehold';
    public final static String INDIVIDUAL_RECORDTYPE_NAME = 'Contact Client/Prospect';

	@TestSetup
	private static void setup() {
        Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

		User testUserOne = new User(
			Username = 'daventestuser1@test.com',
			LastName = 'TestUser1',
			Email = 'testuser1@test.com',
			Alias = 'tus1',
			Davenport_Username__c = davenportUsernameOne,
			ProfileId = profileId,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles'
		);
		User testUserTwo = new User(
			Username = 'daventestuser2@test.com',
			LastName = 'TestUser2',
			Email = 'testuser2@test.com',
			Alias = 'tus2',
			Davenport_Username__c = davenportUsernameTwo,
			ProfileId = profileId,
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles'
		);
        User testUserThree = new User(
            Username = 'daventestuser3@test.com',
            LastName = 'TestUser3',
            Email = 'testuser3@test.com',
            Alias = 'tus3',
            Davenport_Username__c = davenportUsernameThree,
            ProfileId = profileId,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
		List<User> userToInsert = new List<User> { testUserOne, testUserTwo, testUserThree };
		insert userToInsert;


        // create reps and financial accounts
        Rep__c repOne = new Rep__c(Rep_Number__c = 'REP1');
        Rep__c repTwo = new Rep__c(Rep_Number__c = 'REP2');
        Rep__c repThree = new Rep__c(Rep_Number__c = 'REP3');
        List<Rep__c> reps = new List<Rep__c>{
                repOne, repTwo, repThree
        };
		insert reps;

        // rep 1 owned by user 1, rep 2 owned by user 2, rep 3 owned by user 3
        Rep_Security__c repSecurityOne = new Rep_Security__c(Rep_Number__c = repOne.Rep_Number__c, Davenport_Username__c = davenportUsernameOne, Type__c = 'Rep');
        Rep_Security__c repSecurityTwo = new Rep_Security__c(Rep_Number__c = repTwo.Rep_Number__c, Davenport_Username__c = davenportUsernameTwo, Type__c = 'Rep');
        Rep_Security__c repSecurityThree = new Rep_Security__c(Rep_Number__c = repThree.Rep_Number__c, Davenport_Username__c = davenportUsernameThree, Type__c = 'Rep');
		List<Rep_Security__c> repSecurities = new List<Rep_Security__c> { repSecurityOne, repSecurityTwo, repSecurityThree };
		insert repSecurities;
        
		// 1     2
		// |     |
		// +--3--+
		
		Rep_Split__c repSplitOneGrantedToThree = new Rep_Split__c(Grant_Access_To_Rep__c = repThree.Id, Split_Rep__c = repOne.Id); // rep split repOne to grant access to repThree
		Rep_Split__c repSplitTwoGrantedToThree = new Rep_Split__c(Grant_Access_To_Rep__c = repThree.Id, Split_Rep__c = repTwo.Id); // rep split repTwo to grant access to repThree
        List<Rep_Split__c> repSplits = new List<Rep_Split__c>{ repSplitOneGrantedToThree, repSplitTwoGrantedToThree };
		insert repSplits;
	}

	@isTest
	private static void testRepSecurity_SplitWithMoreThanOneParent() {

		Test.startTest();

		Account owner = new Account(
				LastName = 'Test Person Account',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
				//ParentId = household.Id,
				FinServ__IndividualType__c = 'Individual'
		);
		Account owner2 = new Account(
				LastName = 'Test Person Account2',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
				//ParentId = household2.Id,
				FinServ__IndividualType__c = 'Individual'
		);
		Account owner3 = new Account(
				LastName = 'Test Person Account3',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
				//ParentId = household3.Id,
				FinServ__IndividualType__c = 'Individual'
		);
		List<Account> accounts = new List<Account>{ owner, owner2, owner3 };
		insert accounts;

        Account household1 = new Account(
            Name = 'Test Household',
            Placeholder_Household__c = false,
            FMA_Account__c = true,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
            FinServ__IndividualType__c = 'Group'
            //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
            //FinServ__IndividualType__c = 'Individual'
        );
        Account household2 = new Account(
            Name = 'Test Household2',
            Placeholder_Household__c = false,
            FMA_Account__c = true,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
            FinServ__IndividualType__c = 'Group'
            //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
            //FinServ__IndividualType__c = 'Individual'
        );
		List<Account> households = new List<Account> { household1, household2 };
		insert households;

		Rep__c repOne = [SELECT Id FROM Rep__c WHERE Rep_Number__c = 'REP1'];
        Rep__c repTwo =  [SELECT Id FROM Rep__c WHERE Rep_Number__c = 'REP2'];
        Rep__c repThree =  [SELECT Id FROM Rep__c WHERE Rep_Number__c = 'REP3'];

		FinServ__FinancialAccount__c testFinAcctOne = new FinServ__FinancialAccount__c(
            Name = 'Financial Account One (REP1)',
            FinServ__Household__c = household1.Id,
            FinServ__PrimaryOwner__c = owner.Id,
            FinServ__JointOwner__C = null,
            FinServ__FinancialAccountSource__c = 'Manually Entered',
            Cost_Basis__c = 123.45,
            FinServ__Description__c = 'This is a description of my financial account.',
            Rep__c = repOne.Id,
            FinServ__Ownership__c = 'Individual',
            RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
		);
        FinServ__FinancialAccount__c testFinAcctTwo = new FinServ__FinancialAccount__c(
            Name = 'Financial Account Two (REP2)',
            FinServ__Household__c = household2.Id,
            FinServ__PrimaryOwner__c = owner2.Id,
            FinServ__JointOwner__C = null,
            FinServ__FinancialAccountSource__c = 'Manually Entered',
            Cost_Basis__c = 123.45,
            FinServ__Description__c = 'This is a description of my financial account.',
            Rep__c = repTwo.Id,
            FinServ__Ownership__c = 'Individual',
            RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
        );

        List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>{ testFinAcctOne, testFinAcctTwo };
		insert finAccounts;

		Test.stopTest();

		List<FinServ__FinancialAccount__Share> shares = [
			SELECT
				Id,
				Parent.Name,
				RowCause,
				UserOrGroup.Name,
				UserOrGroupId
			FROM FinServ__FinancialAccount__Share
		];

		List<Id> groupIds = new List<Id>();
		for (FinServ__FinancialAccount__Share share :shares) {
			groupIds.add(share.UserOrGroupId);
		}

		List<Group> groups = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Id in :groupIds
		];

		List<GroupMember> groupMembers = [
			SELECT
				Id,
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId IN :groupIds
		];

		List<Id> userIds = new List<Id>();
		for (GroupMember member : groupMembers) {
			userIds.add(member.UserOrGroupId);
		}

		List<User> users = [
			SELECT
				Id,
				Username
			FROM User
			WHERE Id IN :userIds
		];


		System.debug(JSON.serializePretty(new List<Rep__c> { repOne, repTwo, repThree }));
		System.debug(JSON.serializePretty(shares));
		System.debug(JSON.serializePretty(groups));
		System.debug(JSON.serializePretty(users));
		System.debug(JSON.serializePretty(groupMembers));

		//Map<Id,FinServ__FinancialAccount__Share> mapUserOrGroupIdToShare = new Map<Id,FinServ__FinancialAccount__Share>();
		//for (FinServ__FinancialAccount__Share share : shares) {
			//mapUserOrGroupIdToShare.put(share.UserOrGroupId, share);
		//}

		// User 1 should have access to Financial Account 1

		
	}
}