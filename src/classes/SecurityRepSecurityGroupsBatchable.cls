global class SecurityRepSecurityGroupsBatchable implements Database.Batchable<SObject> {
	
	global SecurityRepSecurityGroupsBatchable() {}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c,
				Rep__c,
				Davenport_Username__c,
				Type__c
			FROM Rep_Security__c
			WHERE Type__c = 'UPI'
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Security__c> scope) {
		Map<String,Rep_Security__c> mapGroupNameToRepSecurity = new Map<String,Rep_Security__c>();
		Map<String,Rep_Security__c> mapRepNumberToRepSecurity = new Map<String,Rep_Security__c>();
		List<Group> groups = new List<Group>();

		for (Rep_Security__c repSecurity : scope) {
			mapRepNumberToRepSecurity.put(repSecurity.Rep_Number__c, repSecurity);

			String groupName = 'Rep-Sec' + repSecurity.Rep_Number__c + '-' + repSecurity.Id;
			groups.add(new Group(
				Name = groupName,
				Type = 'Regular'
			));
			mapGroupNameToRepSecurity.put(groupName,repSecurity);
		}
		insert groups;

		for (Group grp : groups) {
			mapGroupNameToRepSecurity.get(grp.Name).GroupId__c = grp.Id;
		}

		List<Rep__c> reps = [
			SELECT
				Rep_Number__c
			FROM Rep__c
			WHERE Rep_Number__c IN :mapRepNumberToRepSecurity.keySet()
		];

		for (Rep__c rep : reps) {
			mapRepNumberToRepSecurity.get(rep.Rep_Number__c).Rep__c = rep.Id;
		}

		update mapGroupNameToRepSecurity.values();
	}
	
	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityRepSecurityGroupsBatchable');
        mail.setSubject('SecurityRepSecurityGroupsBatchable Completed');
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

		Database.executeBatch(new SecurityRepSplitsBatchable());
	}
}