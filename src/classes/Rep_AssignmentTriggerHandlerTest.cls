/**
 * Created by Eric Stansbury on 5/22/2019.
 */
@isTest
public class Rep_AssignmentTriggerHandlerTest {
    @isTest static void testHandleDelete(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0];
        Id rep2Id = [Select id from Rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;
        Id rep4Id = [Select id from Rep__c where Rep_Number__c = 'REP4' limit 1][0].Id;

        Rep_Assignment__c repAssignment = new Rep_Assignment__c(User__c = user.Id, Rep__c = rep2Id);
        Rep_AssignmentTriggerHandler.handleAfterInsert(new List<Rep_Assignment__c>{ repAssignment });

//        System.runAs(user){
//            System.assertEquals(1, [Select count() from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)'],
//                    'User should see the rep2 financial account via the rep assignment');
//        }

        Rep_AssignmentTriggerHandler.handleAfterDelete(new List<Rep_Assignment__c>{ repAssignment });

//        System.runAs(user){
//            System.assertEquals(0, [Select count() from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)'],
//                    'User should no longer see the rep2 financial account');
//        }
    }

    @isTest static void testHandleDeleteTwoWayAccess(){
       // test case: rep has access to a finacct via two different rep numbers. remove one assignment but not the other and assert the user still has access to the finacct
    }

    @isTest static void testHandleInsert(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0].Id;
        Id rep2Id = [Select id from Rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;
        Id rep4Id = [Select id from Rep__c where Rep_Number__c = 'REP4' limit 1][0].Id;

        Rep_Assignment__c repAssignment = new Rep_Assignment__c(User__c = userId, Rep__c = rep2Id);

        Test.startTest();
        Rep_AssignmentTriggerHandler.handleAfterInsert(new List<Rep_Assignment__c>{ repAssignment });
        Test.stopTest();

//        System.assertEquals(1, [Select count() from GroupMember where UserOrGroupId = :userId and Group.Name = :rep2Id],
//                'User should be a member of the rep group');
//
//        System.runAs([Select id from User where Id = :userId limit 1][0]){
//            System.assertEquals(1, [select count() from finserv__financialaccount__c where Name = 'Financial Account Two (REP2)'],
//                    'User should have access to the rep 2 financial account');
//        }

        /*
        Id householdId = [Select FinServ__Household__c from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)' limit 1][0].FinServ__Household__c;
        System.assertEquals(1, [select count() from AccountShare where AccountId = :householdId and UserOrGroup.Name = :rep2Id],
            'The rep group should have access to the household associated with financial account 2');
        */
    }

    @isTest static void testHandleInsertWithTrigger(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0].Id;
        Id rep2Id = [Select id from Rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;
        Id rep4Id = [Select id from Rep__c where Rep_Number__c = 'REP4' limit 1][0].Id;

        System.runAs([Select Id from User where Id != :UserInfo.getUserId() and Profile.Name = 'System Administrator' and IsActive = true limit 1][0]) {
            SecurityAssignmentConfig.repAssignmentTriggersEnabled = true;
            Rep_Assignment__c repAssignment = new Rep_Assignment__c(User__c = userId, Rep__c = rep2Id);
            insert repAssignment;
        }

//        System.assertEquals(1, [Select count() from Group where Name = :rep2Id],
//                'A rep 2 group should exist');
//
//        System.assertEquals(1, [Select count() from GroupMember where UserOrGroupId = :userId and Group.Name = :rep2Id],
//            'The user should have been added to the Rep 2 group');

        // trigger fires this method:
        // Rep_AssignmentTriggerHandler.handleAfterInsert(new List<Rep_Assignment__c>{ repAssignment });
//        System.runAs([Select Id from User where Id = :userId][0]){
//            System.assertEquals(3, [Select count() from FinServ__FinancialAccount__c],
//                    'User should have 3 financial accounts from the rep assignment that got inserted. One from REP2, one from REP4 (split rep), and one from the account split');
//        }
    }

    /*@isTest*/ static void hhTestTest(){
        Id householdId = [Select Id from Account where Name = 'Test Household2' limit 1][0].Id;

        FinServ__FinancialAccount__c finAcct = [Select Id, Name, FinServ__Household__c from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)' limit 1];
        finAcct.FinServ__Household__c = householdId;
        update finAcct;

        finAcct = [Select Id, Name, FinServ__Household__c from FinServ__FinancialAccount__c where Name = 'Financial Account Two (REP2)' limit 1];
        System.assertEquals(householdId, finAcct.FinServ__Household__c);
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}