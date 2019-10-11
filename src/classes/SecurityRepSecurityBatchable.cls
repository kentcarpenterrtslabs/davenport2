global class SecurityRepSecurityBatchable implements Database.Batchable<SObject>, Database.Stateful {

	global SecurityRepSecurityBatchable () {}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				GroupId__c,
				User__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {

		Set<Id> userIds = new Set<Id>();

		for (Rep_Security__c repSecurity : scope) {
			userIds.add(repSecurity.User__c);
		}

		Map<Id,User> mapUserIdToUser = getMapUserIdToUser(userIds);

		// For each Rep Security, add the user and the user's asistant(s) as a group member for the group on the rep security record
		Map<Id,Set<Id>> mapGroupIdToUserIds = new Map<Id,Set<Id>>(); // prevent trying to add the same group/user combination more than once

		for (Rep_Security__c repSecurity : scope) {
			String groupIdStr = repSecurity.GroupId__c;
			User usr = mapUserIdToUser.get(repSecurity.User__c);

			if (!String.isBlank(groupIdStr) && null != usr) {
				Id groupId = Id.valueOf(groupIdStr);

				if (!mapGroupIdToUserIds.containsKey(groupId)) {
					mapGroupIdToUserIds.put(groupId,new Set<Id>());
				}

				mapGroupIdToUserIds.get(groupId).add(usr.Id);

				// for each assistant of this user, add the assisant user as a member of the group related to the Rep Number
				for (Assistant_Assignment__c assistant : usr.Assistants__r) {
					mapGroupIdToUserIds.get(groupId).add(assistant.Assistant__c);
				}
			}
		}

		List<GroupMember> groupMembers = new List<GroupMember>();

		for (Id grpId : mapGroupIdToUserIds.keySet()) {
			for (Id userId : mapGroupIdToUserIds.get(grpId)) {
				groupMembers.add(new GroupMember(
					GroupId = grpId,
					UserOrGroupId = userId
				));
			}
		}
		insert groupMembers;
	}

	public Map<Id,User> getMapUserIdToUser(Set<Id> userIds) {

		// Get the list of users that match the list of DavenportUserNames in the Rep Security records
		List<User> users = [
			SELECT
				Id,
				(
					SELECT
						Assistant__c
					FROM Assistants__r
				)
			FROM User
			WHERE Id IN :userIds
		];
		
		Map<Id,User> mapUserIdToUser = new Map<Id,User>();

		for (User usr : Users) {
			mapUserIdToUser.put(usr.Id,usr);
		}
		return mapUserIdToUser;
	}

	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityRepSecurityBatchable');
        mail.setSubject('SecurityRepSecurityBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + context.getJobId());
        if (!Test.isRunningTest()){
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }catch(EmailException e){
                // usually just means NO_MASS_MAIL_PERMISSION -- email failing shouldn't prevent next step from executing
                System.debug(e);
            }

			Database.executeBatch(new SecurityFinancialAccountBatchable());		
        }
	}
}