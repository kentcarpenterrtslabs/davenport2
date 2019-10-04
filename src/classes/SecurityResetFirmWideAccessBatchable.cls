global class SecurityResetFirmWideAccessBatchable implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Firm_Wide_Access_Enabled__c
			FROM User
			WHERE Firm_Wide_Access_Enabled__c = true
		]);
	}

   	global void execute(Database.BatchableContext context, List<User> scope) {
		for (User u : scope) {
			u.Firm_Wide_Access_Enabled__c = false;
		}
		update scope;
	}
	

	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityResetFirmWideAccessBatchable');
        mail.setSubject('SecurityResetFirmWideAccessBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + context.getJobId());
        if (!Test.isRunningTest()){
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }catch(EmailException e){
                // usually just means NO_MASS_MAIL_PERMISSION -- email failing shouldn't prevent Pt2 from executing
                System.debug(e);
            }

			Database.executeBatch(new SecurityGroupsBatchable());
        }
	}
}