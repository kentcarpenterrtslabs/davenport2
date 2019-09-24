/**
 * Created by Eric Stansbury on 6/7/2019.
 */

@isTest
public class FinancialAccountTriggerHandlerTest {
    @isTest static void doTest(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        FinServ__FinancialAccount__c finAcct;
        Test.startTest();
        System.runAs([Select ID from User where Id = :UserInfo.getUserId()][0]){
            insert new Rep_Assignment__c(Rep__c = rep1Id, User__c = user.Id);

            // create a new financial account and assign it to rep 1
            finAcct = new FinServ__FinancialAccount__c(
                    Name = 'New Test Financial Account',
                    FinServ__Household__c = [Select Id from Account where Name = 'Test Household' limit 1][0].Id,
                    FinServ__PrimaryOwner__c = [Select Id from Account where Name = 'Test Person Account' limit 1][0].Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = rep1Id
            );
            insert finAcct;
        }
        Test.stopTest();

//        System.runAs(user){
//            System.assertEquals(1, [select count() from FinServ__FinancialAccount__c where Id = :finAcct.Id],
//                    'User 1 (who has Rep 1 access) should have access to the new financial account');
//        }
    }

    @isTest static void doTestSplitRep(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        FinServ__FinancialAccount__c finAcct;
        System.runAs([Select ID from User where Id = :UserInfo.getUserId()][0]) {
            insert new Rep_Assignment__c(Rep__c = rep1Id, User__c = user.Id);

            Id rep4Id = [Select id from Rep__c where Rep_Number__c = 'REP4' limit 1][0].Id;
            // create a new financial account and assign it to rep 4, which is a split rep that rep 1 has access to
            finAcct = new FinServ__FinancialAccount__c(
                    Name = 'New Test Financial Account',
                    FinServ__Household__c = [Select Id from Account where Name = 'Test Household' limit 1][0].Id,
                    FinServ__PrimaryOwner__c = [Select Id from Account where Name = 'Test Person Account' limit 1][0].Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = rep4Id
            );
            insert finAcct;
        }

//        System.runAs(user){
//            System.assertEquals(1, [select count() from FinServ__FinancialAccount__c where Id = :finAcct.Id],
//                    'User 1 (who has Rep 1 access) should have access to the new financial account via the rep 4 split');
//        }
    }

    @isTest static void updateTest() {
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        FinServ__FinancialAccount__c finAcct;
        Test.startTest();
        System.runAs([Select ID from User where Id = :UserInfo.getUserId()][0]) {
            insert new Rep_Assignment__c(Rep__c = rep1Id, User__c = user.Id);

            // create a new financial account and assign it to rep 1
            finAcct = new FinServ__FinancialAccount__c(
                    Name = 'New Test Financial Account',
                    FinServ__Household__c = [Select Id from Account where Name = 'Test Household' limit 1][0].Id,
                    FinServ__PrimaryOwner__c = [Select Id from Account where Name = 'Test Person Account' limit 1][0].Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = rep1Id
            );
            insert finAcct;
        }

        finAcct.Rep__c = null;
        update finAcct;

        FinancialAccountTriggerHandler.handleAfterUpdate(new Map<Id, FinServ__FinancialAccount__c>{ finAcct.Id => finAcct }, new Map<Id, FinServ__FinancialAccount__c>{ finAcct.Id => finAcct });
    }


    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}