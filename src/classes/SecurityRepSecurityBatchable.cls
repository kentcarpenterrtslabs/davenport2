global class SecurityRepSecurityBatchable implements Database.Batchable<SObject>, Database.Stateful {

	global SecurityRepSecurityBatchable () {}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {

		Set<String> davenportUserNames = new Set<String>();
		Set<String> repTypeDavenportUserNames = new Set<String>();
		Set<String> repNumbers = new Set<String>();
			

		for (Rep_Security__c repSecurity : scope) {
			if ('Rep' == repSecurity.Type__c) {
				davenportUserNames.add(repSecurity.Davenport_Username__c);
				repTypeDavenportUserNames.add(repSecurity.Davenport_Username__c);
			}
			repNumbers.add(repSecurity.Rep_Number__c);
		}

		// update the rep security records with references to the Rep records and users

		Map<String,User> mapDaveportUsernameToUser = getMapDaveportUsernameToUser(davenportUserNames);
		Map<String,Rep__c> mapRepNumberToRep = getMapRepNumberToRep(repNumbers);

		for (Rep_Security__c repSecurity : scope) {
			if (mapRepNumberToRep.containsKey(repSecurity.Rep_Number__c)) {
				repSecurity.Rep__c = mapRepNumberToRep.get(repSecurity.Rep_Number__c).Id;
			}
			if (mapDaveportUsernameToUser.containsKey(repSecurity.Davenport_Username__c)) {
				repSecurity.User__c = mapDaveportUsernameToUser.get(repSecurity.Davenport_Username__c).Id;
			}
		}

		update scope;
	}

	public Map<String,Rep__c> getMapRepNumberToRep(Set<String> repNumbers) {

		List<Rep__c> reps = [
			SELECT
				Id,
				Rep_Number__c
			FROM Rep__c
			WHERE Rep_Number__c IN :repNumbers
		];

		Map<String,Rep__c> mapRepNumberToRep = new Map<String,Rep__c>();
		
		for (Rep__c rep : reps) {
			mapRepNumberToRep.put(rep.Rep_Number__c,rep);
		}

		return mapRepNumberToRep;
	}

	public Map<String,User> getMapDaveportUsernameToUser(Set<String> davenportUsernames) {

		// Get the list of users that match the list of DavenportUserNames in the Rep Security records
		List<User> users = [
			SELECT
				Id,
				Davenport_Username__c
			FROM User
			WHERE Davenport_Username__c IN :davenportUsernames
		];
		
		Map<String,User> mapDaveportUsernameToUser = new Map<String,User>();

		for (User usr : Users) {
			mapDaveportUsernameToUser.put(usr.Davenport_Username__c,usr);
		}
		return mapDaveportUsernameToUser;
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

			Database.executeBatch(new SecurityRepSecurityGroupsBatchable(), 5);		
        }
	}
}