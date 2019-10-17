public class MoneyGuideProRequestController {
    //static String redirectToUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';
    //static String endpointUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';

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

    @AuraEnabled public static List<User> getPicklistOptions(Id householdId){
		String userTypePrefix = Schema.SObjectType.User.getKeyPrefix();
        String groupTypePrefix = Schema.SObjectType.Group.getKeyPrefix();

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

		//System.debug(JSON.serializePretty(users));
		return users;
   }

}