global  class SecurityDeleteAllBatchable implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([
			SELECT
				Id
			FROM Group
			WHERE Group.Type = 'Regular'
			AND Name like 'Rep-%'
		]);
    }

    global void execute(Database.BatchableContext BC, List<Group> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityDeleteAllBatchable');
        mail.setSubject('SecurityDeleteAllBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
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

		Database.executeBatch(new SecurityResetFirmWideAccessBatchable());
    }
}