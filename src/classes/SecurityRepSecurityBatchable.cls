global class SecurityRepSecurityBatchable implements Database.Batchable<SObject>, Database.Stateful {

	global String log;

	global SecurityRepSecurityBatchable () {
		log = '';
	}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				GroupId__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {

		Set<String> repNumbers = new Set<String>();
		Set<String> davenportUsernames = new Set<String>();

		for (Rep_Security__c repSecurity : scope) {
			if ('Rep' == repSecurity.Type__c) {
				repNumbers.add(repSecurity.Rep_Number__c);
			}
			davenportUsernames.add(repSecurity.Davenport_Username__c);
		}

		Map<String,Id> mapRepNumberToGroupId = getMapRepNumberToGroupId(repNumbers);
		Map<String,User> mapDavenportUsernameToUser = getMapDavenportUsernameToUser(davenportUsernames);

		// For each Rep Security, add the user and the user's asistant(s) as a group member for the group related to the Rep Number
		List<GroupMember> groupMembers = new List<GroupMember>();

		for (Rep_Security__c repSecurity : scope) {
			Id groupId;

			if ('Rep' == repSecurity.Type__c) {
				groupId = mapRepNumberToGroupId.get(repSecurity.Rep_Number__c);
			} else {
				groupId = Id.valueOf(repSecurity.GroupId__c);
			}

			User usr = mapDavenportUsernameToUser.get(repSecurity.Davenport_Username__c);

			if (null != groupId && null != usr) {

				groupMembers.add(new GroupMember(
					GroupId = Id.valueOf(groupId),
					UserOrGroupId = usr.Id
				));

				// for each assistant of this user, add the assisant user as a member of the group related to the Rep Number
				for (Assistant_Assignment__c assistant : usr.Assistants__r) {
					groupMembers.add(new GroupMember(
						GroupId = Id.valueOf(groupId),
						UserOrGroupId = assistant.Assistant__c
					));
				}
			}
		}
		insert groupMembers;
	}

	public Map<String,Id> getMapRepNumberToGroupId(Set<String> repNumbers) {

		// Get the list of Reps that match the list of Rep Numbers in the Rep Security records
		List<Rep__c> reps = [
			SELECT
				Id,
				GroupId__c,
				Rep_Number__c
			FROM Rep__c
			WHERE Rep_Number__c IN :repNumbers
		];

		// log all Rep Number referenced in the Rep Security records that do not exist as Rep records
		if (reps.size() != repNumbers.size()) {
			Set<String> missingRepNumbers = new Set<String>(repNumbers);
			List<String> matchingRepNumbers = new List<String>();
			for (Rep__c rep : reps) {
				matchingRepNumbers.add(rep.Rep_Number__c);
			}
			missingRepNumbers.removeAll(matchingRepNumbers);
			log += '\n' + 'Rep Numbers in Rep_Security records do not exist in Rep records:';
			log += '\n' + JSON.serializePretty(missingRepNumbers);
		}

		// create a map of rep number to GroupId
		Map<String,Id> mapRepNumberToGroupId = new Map<String,Id>();
		for (Rep__c rep : reps) {
			if (!mapRepNumberToGroupId.containsKey(rep.Rep_Number__c)) {
				mapRepNumberToGroupId.put(rep.Rep_Number__c,rep.GroupId__c);
			}
		}
		return mapRepNumberToGroupId;
	}

	public Map<String,User> getMapDavenportUsernameToUser(Set<String> davenportUsernames) {

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
			WHERE Davenport_Username__c IN :davenportUsernames
		];

		// log all DavenportUsernames that did not match a user
		if (users.size() != davenportUsernames.size()) {
			Set<String> missingDavenportUsernames = new Set<String>(davenportUsernames);
			List<String> matchingDavenportUsernames = new List<String>();
			for (User usr : users) {
				matchingDavenportUsernames.add(usr.Davenport_Username__c);
			}
			missingDavenportUsernames.removeAll(matchingDavenportUsernames);
			log += '\n' + 'Davenport Usernames in Rep_Security records do not exist in User records:';
			log += '\n' + JSON.serializePretty(missingDavenportUsernames);
		}
		
		Map<String,User> mapDavenportUsernameToUser = new Map<String,User>();

		for (User usr : Users) {
			mapDavenportUsernameToUser.put(usr.Davenport_Username__c,usr);
		}
		return mapDavenportUsernameToUser;
	}

	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityRepSecurityBatchable');
        mail.setSubject('SecurityRepSecurityBatchable Completed');
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