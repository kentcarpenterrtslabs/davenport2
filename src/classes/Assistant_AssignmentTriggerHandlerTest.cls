/**
 * Created by Eric Stansbury on 5/31/2019.
 */

@isTest
public class Assistant_AssignmentTriggerHandlerTest {
    @isTest static void handleAfterInsertTest(){
        User user1 = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        User user2 = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0];
        System.runAs(user2){
            System.assert([Select count() from FinServ__FinancialAccount__c] > 0, 'User 2 should already see financial accounts');
        }


        integer user1ShareCount;
        System.runAs(user1){
            user1ShareCount = [Select count() from FinServ__FinancialAccount__c];
        }

        Assistant_AssignmentTriggerHandler.handleAfterInsert(new List<Assistant_Assignment__c>{
            new Assistant_Assignment__c(
                Assistant__c = user1.Id,
                Assistee__c = user2.Id
            )
        });

        System.runAs(user1){
            System.assert(user1ShareCount < [Select count() from FinServ__FinancialAccount__c],
                    'User 1 should have been granted additional finacct access from being made the assistant of user 2.');
        }
    }

    @isTest static void insertAndHandleAfterDeleteTest(){
        User user1 = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        User user2 = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0];

        System.runAs(user2){
            System.assert([Select count() from FinServ__FinancialAccount__c] > 0, 'User 2 should have existing finacct access from the test data');
        }

        integer shareCount;
        System.runAs(user1){
            shareCount = [Select count() from FinServ__FinancialAccount__c];
        }

        Assistant_Assignment__c newAssignment;
        System.runAs([Select id from User where Id = :UserInfo.getUserId() limit 1][0]){
            newAssignment = new Assistant_Assignment__c(
                Assistant__c = user1.Id,
                Assistee__c = user2.Id
            );
            insert newAssignment;
        }

        System.runAs(user1){
            System.assert(shareCount < [Select count() from FinServ__FinancialAccount__c],
                'User 1 should have been granted additional financial accounts from being made the assistant of user 2.');
        }

        System.runAs([Select id from User where Id = :UserInfo.getUserId() limit 1][0]){
            delete newAssignment;
        }

        System.runAs(user1){
            System.assert(shareCount == [Select count() from FinServ__FinancialAccount__c],
                    'User 1 should have returned to their original set of financial accounts.');
        }
    }

    @TestSetup static void setupData(){
        SecurityAssignmentConfig.repSecurityTriggersEnabled = true;
        SecurityAssignmentTestFactory.createData();
    }
}