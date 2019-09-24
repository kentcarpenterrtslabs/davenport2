/**
 * Created by Eric Stansbury on 9/3/2019.
 */

public virtual class SObjectDeleteBatchable implements Database.Batchable<SObject>{
    String query;
    List<String> queries; // for chaining deletions
    String followupBatchJobClassName;

    public SObjectDeleteBatchable(String query){
        this.query = query;
        queries = new List<String>();
    }

    public SObjectDeleteBatchable(List<String> queries){
        if (queries == null || queries.isEmpty()){
            throw new SObjectDeleteBatchableException('Invalid value for queries parameter');
        }

        this.query = queries.remove(0);
        this.queries = queries;
    }

    public SObjectDeleteBatchable(List<String> queries, String followupBatchJobClassName){
        if (queries == null || queries.isEmpty()){
            throw new SObjectDeleteBatchableException('Invalid value for queries parameter');
        }
        if (followupBatchJobClassName == null || String.isBlank(followupBatchJobClassName)){
            throw new SObjectDeleteBatchableException('Invalid value for followupBatchJobClassName parameter');
        }

        this.query = queries.remove(0);
        this.queries = queries;
        this.followupBatchJobClassName = followupBatchJobClassName;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SObjectDeleteBatchable');
        mail.setSubject('SObjectDeleteBatchable Completed');
        mail.setPlainTextBody(
            'Query: ' + query + '\r\n' +
            'Job ID: ' + bc.getJobId()
        );
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

        if (!queries.isEmpty()){
            Database.executeBatch(new SObjectDeleteBatchable(queries, followupBatchJobClassName));
        }else if (followupBatchJobClassName != null){
            Type customType = Type.forName(followupBatchJobClassName);
            Database.executeBatch((Database.Batchable<sObject>)customType.newInstance());
        }
    }

    class SObjectDeleteBatchableException extends Exception{}
}