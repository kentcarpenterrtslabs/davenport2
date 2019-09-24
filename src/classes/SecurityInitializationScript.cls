/**
 * Created by Eric Stansbury on 6/18/2019.
 */

// security assignment around reps, financial accounts and so on is handled by triggers on the various objects
// this script is for handling the case where those records already exist and we need to assign security to existing rewcords

public class SecurityInitializationScript implements Schedulable{
    public void execute(System.SchedulableContext sc){
        Set<Id> repIds = new Map<Id, Rep__c>([Select Id from Rep__c]).keySet();
        String rowCause = SecurityAssignmentHelper.rowCause;

        Database.executeBatch(new SObjectDeleteBatchable(new List<String>{
                'Select Id from AccountShare where RowCause = \'' + rowCause + '\'',
                'Select Id from FinServ__FinancialAccount__Share where RowCause = \'' + rowCause + '\'',
                'Select Id from Group where Name like \'%Rep-%\''
            },
            'SecurityInitializationStepTwo'
        ));
    }
    public static void scheduleMe(){
        scheduleMe('0 30 06 * * ?'); // every day at 6:30 AM
    }

    public static void scheduleMe(String cronString){
        System.schedule('Security Initialization Script', cronString, new SecurityInitializationScript());
    }

    public static void unscheduleMe(){
        Id jobId = [Select Id from CronTrigger where CronJobDetail.Name = 'Security Initialization Script' limit 1][0].Id;
        System.abortJob(jobId);
    }
}