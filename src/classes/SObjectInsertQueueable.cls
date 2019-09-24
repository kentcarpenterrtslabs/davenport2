/**
 * Created by Eric Stansbury on 7/10/2019.
 */

/*
    using this class to do GroupMember inserts asynchronously to avoid MIXED_DML_OPERATION exception
 */
public class SObjectInsertQueueable implements Queueable{
    List<SObject> insertMe{get;set;}

    public SObjectInsertQueueable(List<SObject> insertMe){
        this.insertMe = insertMe;
    }

    public void execute(QueueableContext qc){
        try{
            insert insertMe;
        }catch(DMLException e){
            System.debug('SObjectInsertQueueable failed with error ' + e.getMessage());
            System.enqueueJob(new SObjectInsertQueueable(insertMe));
        }
    }
}