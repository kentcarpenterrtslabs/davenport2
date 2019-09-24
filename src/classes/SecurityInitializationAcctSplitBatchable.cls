/**
 * Created by Eric Stansbury on 6/18/2019.
 */

global class SecurityInitializationAcctSplitBatchable implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, Rep__c, Financial_Account__c from Account_Split__c');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Account_SplitTriggerHandler.handleAfterInsert(scope);
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityInitializationAcctSplitBatchable');
        mail.setSubject('SecurityInitializationAcctSplitBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }
}