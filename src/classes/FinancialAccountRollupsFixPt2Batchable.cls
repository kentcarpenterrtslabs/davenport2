/**
 * Created by Eric Stansbury on 8/26/2019.
 */

global class FinancialAccountRollupsFixPt2Batchable implements Database.Batchable<SObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('Select Id, finserv__balance__c, balance_rollupsfix__c from finserv__financialaccount__c where balance_rollupsfix__c != null');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<FinServ__FinancialAccount__c> finAccts = (List<FinServ__FinancialAccount__c>)scope;

        // move value of balance to our temporary field and update
        for (finserv__financialaccount__c finAcct : finAccts){
            finAcct.FinServ__Balance__c = finAcct.balance_rollupsfix__c;
            finAcct.balance_rollupsfix__c = null;
        }

        update finAccts;
    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('FinancialAccountRollupsFixPt2Batchable ');
        mail.setSubject('FinancialAccountRollupsFixPt2Batchable Completed');
        mail.setPlainTextBody('Job ID: ' + bc.getJobId());
        if (!Test.isRunningTest()){
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }catch(EmailException e){
                // usually just means NO_MASS_MAIL_PERMISSION 
                System.debug(e);
            }
        }
    }
}