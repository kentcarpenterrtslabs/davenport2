/**
 * Created by Eric Stansbury on 6/4/2019.
 */

@isTest
public class Rep_SplitTriggerHandlerTest {
    @isTest static void testHandleInsert(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id rep3Id = [Select id from Rep__c where Rep_Number__c = 'REP3' limit 1][0].Id;

        integer shareCount;

        System.runAs(user){
            shareCount = [select count() from FinServ__FinancialAccount__c];
        }

        Test.startTest();
        // create a new rep split granting REP 1 access to REP 3
        Rep_Split__c repSplit = new Rep_Split__c(Split_Rep__c = rep3Id, Grant_Access_to_Rep__c = rep1Id);
        Rep_SplitTriggerHandler.handleAfterInsert(new List<Rep_Split__c>{ repSplit });
        Test.stopTest();
    }

    @isTest static void testHandleInsert2(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id finAcctId = [Select Id from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)' limit 1][0].Id;
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id rep2Id = [Select id from Rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;

        Test.startTest();
        Rep_SplitTriggerHandler.handleAfterInsert(
            new List<Rep_Split__c>{
                new Rep_Split__c(
                    Split_Rep__c = rep2Id,
                    Grant_Access_to_Rep__c = rep1Id
                )
            }
        );
        Test.stopTest();
    }

    @isTest static void testHandleDelete(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id rep3Id = [Select id from Rep__c where Rep_Number__c = 'REP3' limit 1][0].Id;
        Id finAcct3Id = [Select id from FinServ__FinancialAccount__c where Name = 'Financial Account Three (REP3)' limit 1][0].Id;
//        System.assertEquals(1, [select count() from rep_assignment__c where User__c = :user.Id and Rep__c = :rep1Id],
//            'User should have an existing rep 1 assignment from the test data.');
//        System.runAs(user){
//            System.assertEquals(0, [select count() from FinServ__FinancialAccount__c where Name = 'Financial Account Three (REP3)'],
//                    'User 1 should not be able to see finacct3.');
//        }

        // create a new rep split granting REP 1 access to REP 3

        Rep_Split__c repSplit = new Rep_Split__c(Split_Rep__c = rep3Id, Grant_Access_to_Rep__c = rep1Id);
        insert repSplit;

        Test.startTest();
        delete repSplit;
        Test.stopTest();

        // System.runAs(user){
        //     System.assertEquals(0, [select count() from FinServ__FinancialAccount__c where Name = 'Financial Account Three (REP3)'],
        //             'User 1 should no longer be able to see finacct3 via the rep split.');
        // }

        Rep_SplitTriggerHandler.handleAfterDelete(new List<Rep_Split__c>{ repSplit });
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
        delete [select id from account_split__c];
        delete [select id from rep_split__c];
        delete [select id from assistant_assignment__c];
    }
}