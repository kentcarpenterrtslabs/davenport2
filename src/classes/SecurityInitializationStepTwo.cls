/**
 * Created by Eric Stansbury on 9/3/2019.
 */

public class SecurityInitializationStepTwo implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, Rep__c, User__c from Rep_Assignment__c');
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Rep_AssignmentTriggerHandler.handleAfterInsert(scope);
    }

    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityInitializationStepTwo');
        mail.setSubject('SecurityInitializationStepTwo Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
        if (!Test.isRunningTest()){
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }catch(EmailException e){
                // usually just means NO_MASS_MAIL_PERMISSION -- email failing shouldn't prevent Pt2 from executing
                System.debug(e);
            }
        }

        // handle fin accts
        Database.executeBatch(new SecurityInitializationFinAcctBatchable(), 50);

        // handle account splits
        Database.executeBatch(new SecurityInitializationAcctSplitBatchable(), 50);
    }
}