/**
 * Created by Eric Stansbury on 6/18/2019.
 */

@isTest
public class SecurityInitializationScriptTest {
    @isTest static void schedulerTest(){
        insert new Rep__c(Name = 'Test Rep');

        System.runAs([Select Id from User where Id = :UserInfo.getUserId()][0]){
            new SecurityInitializationScript().execute(null);
        }

        SecurityInitializationScript.scheduleMe();
        SecurityInitializationScript.unscheduleMe();
        SecurityInitializationScript.scheduleMe('0 30 06 * * ?');

    }

    @isTest static void sobjectDeleteBatchableTest(){
        Test.startTest();
        List<String> queries = new List<String>{'Select Id from Account'};
        Database.executeBatch(new SObjectDeleteBatchable(queries, 'SecurityInitializationStepTwo'));
        Test.stopTest();

        // coverage for other constructors
        queries = new List<String>{'Select Id from Account'};
        new SObjectDeleteBatchable(queries[0]);
        new SObjectDeleteBatchable(queries).execute(null, new List<SObject>());
    }

    @isTest static void stepTwoTest(){
        Test.startTest();
        Database.executeBatch(new SecurityInitializationStepTwo());
        Test.stopTest();

        new SecurityInitializationStepTwo().execute(null, new List<SObject>());
    }
}