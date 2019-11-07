public class MoneyGuideProRequestController {
    //static String redirectToUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';
    //static String endpointUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';

	public class HouseholdData {
		@AuraEnabled public Boolean hasPrimaryContact;
		@AuraEnabled public Boolean hasMGPLicense;
		@AuraEnabled public List<User> mgpUsers;
	}

    @AuraEnabled public static string updateUser(String householdId, String userId){
		Id myUserId = UserInfo.getUserId();
		Id mgpUsrId = (userId == null ? myUserId : userId);

        User me = [
			SELECT
				Id,
				SAML_UserId__c,
				SAML_HHID__c,
				SAML_MGP_FirstName__c,
				SAML_MGP_LastName__c,
				SAML_MGP_Username__c
			FROM User
			WHERE Id = :myUserId
		];

		User mgpUser = [
			SELECT
				FirstName,
				LastName,
				MGP_User_ID__c
			FROM User
			WHERE Id = :mgpUsrId
		];

        me.SAML_UserId__c = mgpUsrId;
        me.SAML_HHID__c = householdId;
		me.SAML_MGP_FirstName__c = mgpUser.FirstName;
		me.SAML_MGP_LastName__c = mgpUser.LastName;
		me.SAML_MGP_Username__c = mgpUser.MGP_User_ID__c;

        update me;

		MGP_Configuration__mdt mgpConfig = [
			SELECT
				SAML_IdP_Initiated_Login_URL__c
			FROM MGP_Configuration__mdt
			LIMIT 1
		];
		return mgpConfig.SAML_IdP_Initiated_Login_URL__c;

		//return MGP_Config__c.getInstance().SAML_IdP_Initiated_Login_URL__c;
    }

    @AuraEnabled
	public static MoneyGuideProRequestController.HouseholdData getHouseholdData(Id householdId, Id loggedInUserId){

		//System.debug(JSON.serializePretty(users));
		MoneyGuideProRequestController.HouseholdData householdData = new MoneyGuideProRequestController.HouseholdData();

		// verify that the current user has an MGP license and if so, what type
		User loggedInUser = [
			SELECT
				Id,
				MGP_License_Type__c,
				MGP_User_Id__c
			FROM User
			WHERE Id = :loggedInUserId
		];

		if (null == loggedInUser || String.isBlank(loggedInUser.MGP_License_Type__c) || 'None' == loggedInUser.MGP_License_Type__c || 'Admin' == loggedInUser.MGP_License_Type__c) {
			return householdData; // no license
		}


		String userTypePrefix = Schema.SObjectType.User.getKeyPrefix();
        String groupTypePrefix = Schema.SObjectType.Group.getKeyPrefix();

        Account household = [
			select Id,
                FinServ__PrimaryContact__c
            from Account
			where Id = :householdId
        ];

		//System.debug('userTypePrefix = ' + userTypePrefix);
		//System.debug('groupTypePrefix = ' + groupTypePrefix);

		// get user and group Ids from the account shares for this household
		List<AccountShare> accountShares = [
			SELECT
				UserOrGroupId
			FROM AccountShare
			WHERE AccountId = :householdId
		];
		//System.debug('accountShares = ' + JSON.serializePretty(accountShares));

		// split out the users and groups
		Set<Id> groupIds = new Set<Id>();
		Set<Id> userIds = new Set<Id>();

		for (AccountShare acctShare : accountShares) {
			String idAsString = String.valueOf(acctShare.UserOrGroupId);
			if (idAsString.startsWith(groupTypePrefix)) {
				groupIds.add(acctShare.UserOrGroupId);
			} else {
				userIds.add(acctShare.UserOrGroupId);
			}
		}
		//System.debug('groupIds = ' + JSON.serializePretty(groupIds));
		//System.debug('userIds = ' + JSON.serializePretty(userIds));


		// traverse the tree of sub groups
		Set<Id> parentGroups = groupIds;

		while (parentGroups.size() > 0) {

			List<GroupMember> subGroups = [
				SELECT
					UserOrGroupId
				FROM GroupMember
				WHERE GroupId IN :parentGroups
			];

			parentGroups = new Set<Id>();

			for (GroupMember grpMember : subGroups) {
				String idAsString = String.valueOf(grpMember.UserOrGroupId);
				if (idAsString.startsWith(groupTypePrefix)) {
					groupIds.add(grpMember.UserOrGroupId);
					parentGroups.add(grpMember.UserOrGroupId);
				} else {
					userIds.add(grpMember.UserOrGroupId);
				}
			}
		}				
		//System.debug('groupIds = ' + JSON.serializePretty(groupIds));
		//System.debug('userIds = ' + JSON.serializePretty(userIds));

		// get users with MGP credentials in the groups
		List<User> users = [
			SELECT
				Id,
				FirstName,
				LastName,
				MGP_User_Id__c
			FROM User
			WHERE Id IN :userIds
			AND MGP_User_Id__c != null
		];

		Map<Id,User> mapIdToUser = new Map<Id,User>(users);
		
		householdData.hasPrimaryContact = (null != household.FinServ__PrimaryContact__c);
		householdData.hasMGPLicense = true;

		if ('Advisor' == loggedInUser.MGP_License_Type__c) { // advisor may only login to MGP as him/herself
			householdData.mgpUsers = new List<User>();
			if (mapIdToUser.containsKey(loggedInUserId)) {
				householdData.mgpUsers.add(mapIdToUser.get(loggedInUserId));
			}
		} else {
			householdData.mgpUsers = users;
		}

		return householdData;
   }
}