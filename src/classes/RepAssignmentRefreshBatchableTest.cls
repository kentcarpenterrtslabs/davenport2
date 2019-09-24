/**
 * Created by Eric Stansbury on 7/10/2019.
 */

@isTest
public class RepAssignmentRefreshBatchableTest {
    @isTest static void doTest(){
        delete [select id from Rep_Assignment__c];

        Test.startTest();
        Database.executeBatch(new RepAssignmentRefreshBatchable());
        Test.stopTest();

        //System.assertNotEquals(0, [Select count() from Rep_Assignment__c], 'Some rep assignments should have been created from the test data by the batchable class execution');
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }

}