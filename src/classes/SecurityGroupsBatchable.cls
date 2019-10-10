global class SecurityGroupsBatchable implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep_Number__c
			FROM Rep__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep__c> scope) {
		Map<String,Rep__c> mapGroupNameToRep = new Map<String,Rep__c>();
		List<Group> groups = new List<Group>();

		for (Rep__c rep : scope) {
			String groupName = 'Rep-' + rep.Rep_Number__c + '-' + rep.Id;
			groups.add(new Group(
				Name = groupName,
				Type = 'Regular'
			));
			mapGroupNameToRep.put(groupName,rep);
		}
		insert groups;
		for (Group grp : groups) {
			mapGroupNameToRep.get(grp.Name).GroupId__c = grp.Id;
		}
		update mapGroupNameToRep.values();
	}
	
	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityGroupsBatchable');
        mail.setSubject('SecurityGroupsBatchable Completed');
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

		Database.executeBatch(new SecurityRepSecurityGroupsBatchable());
	}
}