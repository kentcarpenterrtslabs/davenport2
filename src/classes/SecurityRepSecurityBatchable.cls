global class SecurityRepSecurityBatchable implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
			WHERE Type__c = 'Rep'
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {
		
		Map<String,String> mapRepNumberToDavenportUsername = new Map<String,String>();

		for (Rep_Security__c repSecurity : scope) {
			mapRepNumberToDavenportUsername.put(repSecurity.Rep_Number__c,repSecurity.Davenport_Username__c);
		}

		// Get the list of Reps that match the list of Rep Numbers in the Rep Security records
		List<Rep__c> reps = [
			SELECT
				Id,
				GroupId__c,
				Rep_Number__c
			FROM Rep__c
			WHERE Rep_Number__c IN :mapRepNumberToDavenportUsername.keySet()
		];

		Map<String,Id> mapDavenportUsernameToGroupId = new Map<String,Id>();

		for (Rep__c rep : reps) {
			if (mapRepNumberToDavenportUsername.containsKey(rep.Rep_Number__c)) {
				mapDavenportUsernameToGroupId.put(mapRepNumberToDavenportUsername.get(rep.Rep_Number__c),rep.GroupId__c);
			} else {
				//TODO: Log error message
			}
		}

		// Get the list of users that match the list of DavenportUserNames in the Rep Security records
		List<User> users = [
			SELECT
				Id,
				Davenport_Username__c,
				(
					SELECT
						Assistant__c
					FROM Assistants__r
				)
			FROM User
			WHERE Davenport_Username__c IN :mapDavenportUsernameToGroupId.keySet()
		];

		// Verify that all of the DavenportUsernames matched a user
		if (users.size() != mapDavenportUsernameToGroupId.keySet().size()) {
			// TODO: log error message
		}

		// For each Rep Security, add the user as a group member for the group related to the Rep Number
		List<GroupMember> groupMembers = new List<GroupMember>();

		for (User usr : users) {
			if (mapDavenportUsernameToGroupId.containsKey(usr.Davenport_Username__c)) {
				groupMembers.add(new GroupMember(
					GroupId = Id.valueOf(mapDavenportUsernameToGroupId.get(usr.Davenport_Username__c)),
					UserOrGroupId = usr.Id
				));
				// for each assistant of this user, add the assisant user as a member of the group related to the Rep Number
				for (Assistant_Assignment__c assistant : usr.Assistants__r) {
					groupMembers.add(new GroupMember(
						GroupId = Id.valueOf(mapDavenportUsernameToGroupId.get(usr.Davenport_Username__c)),
						UserOrGroupId = assistant.Assistant__c
					));
				}
			} else {
				//TODO: Log error message
			}
		}
		insert groupMembers;
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
        }

		Database.executeBatch(new SecurityFinancialAccountBatchable());		
	}
}