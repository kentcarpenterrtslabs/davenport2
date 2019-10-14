global class SecurityRepSecurityGroupsBatchable implements Database.Batchable<SObject>, Database.Stateful {

	String log;
	List<Id> testUserIds;
	
	global SecurityRepSecurityGroupsBatchable() {
		log = '';
	}
	
	global SecurityRepSecurityGroupsBatchable(List<Id> testUserIds) {
		log = '';
		this.testUserIds = testUserIds;
	}

	global Database.QueryLocator start(Database.BatchableContext context) {
		if (null != testUserIds && testUserIds.size() > 0) {
			return Database.getQueryLocator([
				SELECT
					Davenport_Username__c,
					UPI_GroupId__c,
					( SELECT
						Rep__r.GroupId__c,
						Type__c
					FROM Rep_Securities__r ),
					(
						SELECT
							Assistant__c
						FROM Assistants__r
					)
				FROM User
				WHERE Id IN :testUserIds
			]);
		} else {
			return Database.getQueryLocator([
				SELECT
					Davenport_Username__c,
					UPI_GroupId__c,
					( SELECT
						Rep__r.GroupId__c,
						Type__c
					FROM Rep_Securities__r ),
					(
						SELECT
							Assistant__c
						FROM Assistants__r
					)
				FROM User
			]);
		}
	}

   	global void execute(Database.BatchableContext context, List<User> scope) {

		Map<Id,User> mapUserIdToUser = new Map<Id,User>();
		Map<Id,Set<Id>> mapUserIdToRepGroupIds = new Map<Id,Set<Id>>();
		Map<Id,Set<Id>> mapUserIdToUPIRepGroupIds = new Map<Id,Set<Id>>();

		// find the Rep groups where the user has access and sort them by Type
		for (User usr : scope) {
			mapUserIdToUser.put(usr.Id, usr);

			for (Rep_Security__c repSeurity : usr.Rep_Securities__r) {
				if (null != repSeurity.Rep__c && null != repSeurity.Rep__r.GroupId__c) {
					if ('Rep' == repSeurity.Type__c) {
						if (!mapUserIdToRepGroupIds.containsKey(usr.Id)) {
							mapUserIdToRepGroupIds.put(usr.Id, new Set<Id>());
						}
						mapUserIdToRepGroupIds.get(usr.Id).add(repSeurity.Rep__r.GroupId__c);
					} else {
						if (!mapUserIdToUPIRepGroupIds.containsKey(usr.Id)) {
							mapUserIdToUPIRepGroupIds.put(usr.Id, new Set<Id>());
						}
						mapUserIdToUPIRepGroupIds.get(usr.Id).add(repSeurity.Rep__r.GroupId__c);
					}
				}
			}
		}

		Map<Id,Group> mapUserIdToGroupforUPIAccess = new Map<Id,Group>();

		// remove UPI Rep groups where the user already has access using a Rep Group
		for (Id usrId : mapUserIdToUPIRepGroupIds.keySet()) {
			User usr = mapUserIdToUser.get(usrId);

			if (mapUserIdToRepGroupIds.containsKey(usrId)) {
				mapUserIdToUPIRepGroupIds.get(usrId).removeAll(mapUserIdToRepGroupIds.get(usrId));
			}
			// create a group for each user that has UPI groups left
			if (mapUserIdToUPIRepGroupIds.get(usrId).size() > 0) {
				mapUserIdToGroupforUPIAccess.put(usrId, new Group(
					Name = 'Rep-UPI-' + usr.Davenport_Username__c + '-' + usrId,
					Type = 'Regular'
				));
			}
		}

		// insert the UPI user groups
		insert mapUserIdToGroupforUPIAccess.values();

		List<GroupMember> groupMembers = new List<GroupMember>();

		// add the UPI User groups as members to the UPI rep Groups
		for (Id usrId : mapUserIdToGroupforUPIAccess.keySet()) {
			User usr = mapUserIdToUser.get(usrId);

			usr.UPI_GroupId__c = mapUserIdToGroupforUPIAccess.get(usrId).Id;
			for (Id repGroupId : mapUserIdToUPIRepGroupIds.get(usrId)) {
				groupMembers.add(new GroupMember(
					GroupId = repGroupId,
					UserOrGroupId = usr.UPI_GroupId__c
				));
			}
		}

		// save the UPI Group Ids to the users that got them
		List<User> usersToUpdate = new List<User>();
		for (Id usrId : mapUserIdToGroupforUPIAccess.keySet()) {
			usersToUpdate.add(mapUserIdToUser.get(usrId));
		}
		update usersToUpdate;

		// add the user and assistants as members to the Rep type groups
		for (Id usrId : mapUserIdToRepGroupIds.keySet()) {
			User usr = mapUserIdToUser.get(usrId);

			for (Id repGroupId : mapUserIdToRepGroupIds.get(usrId)) {
				groupMembers.add(new GroupMember(
					GroupId = repGroupId,
					UserOrGroupId = usrId
				));
				for (Assistant_Assignment__c assistant : usr.Assistants__r) {
					groupMembers.add(new GroupMember(
						GroupId = repGroupId,
						UserOrGroupId = assistant.Assistant__c
					));
				}
			}
		}
		insert groupMembers;
	}
	
	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityRepSecurityGroupsBatchable');
        mail.setSubject('SecurityRepSecurityGroupsBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + context.getJobId() + log);
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