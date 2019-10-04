global class SecurityRepSplitsBatchable implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Split_Rep__c,
				Split_Rep__r.GroupId__c,
				Grant_Access_to_Rep__c,
				Grant_Access_to_Rep__r.GroupId__c
			FROM Rep_Split__c
		]);
	}

   	global void execute(Database.BatchableContext context, List<Rep_Split__c> scope) {
		List<GroupMember> groupMembers = new List<GroupMember>();
		for (Rep_Split__c repSplit : scope) {
			groupMembers.add(new GroupMember(
				GroupId = Id.valueOf(repSplit.Split_Rep__r.GroupId__c),
				UserOrGroupId = Id.valueOf(repSplit.Grant_Access_to_Rep__r.GroupId__c)
			));
		}
		insert groupMembers;
	}
	
	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityRepSplitsBatchable');
        mail.setSubject('SecurityRepSplitsBatchable Completed');
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

			Database.executeBatch(new SecurityRepSecurityBatchable());
        }
	}
}