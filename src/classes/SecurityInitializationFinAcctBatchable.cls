/**
 * Created by Eric Stansbury on 6/18/2019.
 */

global class SecurityInitializationFinAcctBatchable implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, Rep__c, FinServ__Household__c from FinServ__FinancialAccount__c where Rep__c != null');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        FinancialAccountTriggerHandler.handleAfterInsert(scope);
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityInitializationFinAcctBatchable');
        mail.setSubject('SecurityInitializationFinAcctBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }
}