global class SecurityRepSecurityGroupsBatchable implements Database.Batchable<SObject> {

	global String log;
	
	global SecurityRepSecurityGroupsBatchable() {
		log = '';
	}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				Rep__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {
		proc(scope);
	}

	public void proc(List<Rep_Security__c> scope) {
		Map<String,Rep_Security__c> mapGroupNameToRepSecurity = new Map<String,Rep_Security__c>();
		Map<String,List<Rep_Security__c>> mapRepNumberToRepSecurity = new Map<String,List<Rep_Security__c>>();
		Map<String,List<Rep_Security__c>> mapDavenportUsernameToRepSecurity = new Map<String,List<Rep_Security__c>>();

		List<Group> groups = new List<Group>();

		for (Rep_Security__c repSecurity : scope) {
			if (!mapRepNumberToRepSecurity.containsKey(repSecurity.Rep_Number__c)) {
				mapRepNumberToRepSecurity.put(repSecurity.Rep_Number__c, new List<Rep_Security__c>());
			}
			if (!mapDavenportUsernameToRepSecurity.containsKey(repSecurity.Davenport_Username__c)) {
				mapDavenportUsernameToRepSecurity.put(repSecurity.Davenport_Username__c, new List<Rep_Security__c>());
			}

			mapRepNumberToRepSecurity.get(repSecurity.Rep_Number__c).add(repSecurity);
			mapDavenportUsernameToRepSecurity.get(repSecurity.Davenport_Username__c).add(repSecurity);

			if ('UPI' == repSecurity.Type__c) {
				String groupName = 'Rep-Sec' + repSecurity.Rep_Number__c + '-' + repSecurity.Id;
				groups.add(new Group(
					Name = groupName,
					Type = 'Regular'
				));
				mapGroupNameToRepSecurity.put(groupName,repSecurity);
			}
		}
		insert groups;

		for (Group grp : groups) {
			mapGroupNameToRepSecurity.get(grp.Name).GroupId__c = grp.Id;
		}

		List<Rep__c> reps = [
			SELECT
				Rep_Number__c,
				GroupId__c
			FROM Rep__c
			WHERE Rep_Number__c IN :mapRepNumberToRepSecurity.keySet()
		];

		for (Rep__c rep : reps) {
			for (Rep_Security__c rs : mapRepNumberToRepSecurity.get(rep.Rep_Number__c)) {
				rs.Rep__c = rep.Id;
				if ('Rep' == rs.Type__c) {
					rs.GroupId__c = rep.GroupId__c;
				}
			}
		}

		List<User> users = [
			SELECT
				Id,
				Davenport_Username__c
			FROM User
			WHERE Davenport_Username__c IN :mapDavenportUsernameToRepSecurity.keySet()
		];

		// log all DavenportUsernames that did not match a user
		if (users.size() != mapDavenportUsernameToRepSecurity.keySet().size()) {
			Set<String> missingDavenportUsernames = new Set<String>(mapDavenportUsernameToRepSecurity.keySet());
			List<String> matchingDavenportUsernames = new List<String>();
			for (User usr : users) {
				matchingDavenportUsernames.add(usr.Davenport_Username__c);
			}
			missingDavenportUsernames.removeAll(matchingDavenportUsernames);
			log += '\n' + 'Davenport Usernames in Rep_Security records do not exist in User records:';
			log += '\n' + JSON.serializePretty(missingDavenportUsernames);
		}

		for (User usr : users) {
			for (Rep_Security__c rs : mapDavenportUsernameToRepSecurity.get(usr.Davenport_Username__c)) {
				rs.User__c = usr.Id;
			}
		}

		List<Rep_Security__c> repSecuritiesToUpdate = new List<Rep_Security__c>();
		update scope;
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
        }

		Database.executeBatch(new SecurityRepSplitsBatchable());
	}
}