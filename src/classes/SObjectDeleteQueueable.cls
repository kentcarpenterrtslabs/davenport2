/**
 * Created by Eric Stansbury on 7/17/2019.
 */

public class SObjectDeleteQueueable implements Queueable{
    List<SObject> deleteMe{get;set;}

    public SObjectDeleteQueueable(List<SObject> deleteMe){
        this.deleteMe = deleteMe;
    }

    public void execute(QueueableContext qc){
        try{
            delete deleteMe;
        }catch(DMLException e){
            System.debug('SObjectDeleteQueueable failed with error ' + e.getMessage());
            System.enqueueJob(new SObjectDeleteQueueable(deleteMe));
        }
    }
}