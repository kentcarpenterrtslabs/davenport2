/**
 * Created by Eric Stansbury on 7/19/2019.
 */

public class SObjectUpdateQueueable implements Queueable{
    List<SObject> updateMe{get;set;}

    public SObjectUpdateQueueable(List<SObject> updateMe){
        this.updateMe = updateMe;
    }

    public void execute(QueueableContext qc){
        update updateMe;
    }
}