/**
 * Created by Eric Stansbury on 7/25/2019.
 */

global class RepSecurityInitializationScript implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, Davenport_Username__c, Rep_Number__c, Type__c from Rep_Security__c');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Rep_SecurityTriggerHandler.handleAfterInsert(scope);
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('RepSecurityInitializationScript');
        mail.setSubject('RepSecurityInitializationScript Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
        if (!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
        }
    }
}