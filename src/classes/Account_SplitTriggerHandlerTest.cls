/**
 * Created by Eric Stansbury on 5/31/2019.
 */

@isTest
public class Account_SplitTriggerHandlerTest {
    @isTest static void testHandleInsert(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        System.runAs([Select Id from User where Id = :UserInfo.getUserId() limit 1][0]){
            insert new Rep_Assignment__c(User__c = user.Id, Rep__c = rep1Id);
        }

        // get a finacct ID the user does not already have access to -- we will grant access via account share
        Id finAcctId = [Select Id from FinServ__FinancialAccount__c where Name = 'Financial Account Three (REP3)' limit 1][0].Id;

        integer shareCount;
        System.runAs(user){
            shareCount = [select count() from FinServ__FinancialAccount__c];
        }

        // create a new account share granting REP 1 access to this account
        Account_Split__c  accountSplit = new Account_Split__c(Rep__c = rep1Id, Financial_Account__c = finAcctId);
        Test.startTest();
        System.runAs([Select Id from User where Id = :UserInfo.getUserId() limit 1][0]) {
            Account_SplitTriggerHandler.handleAfterInsert(new List<Account_Split__c>{
                    accountSplit
            });
        }
        Test.stopTest();

        System.runAs(user) {
            System.assertEquals(1, [select count() from FinServ__FinancialAccount__c where Id = :finAcctId],
                'Check that user 1 (with rep 1 access) was granted access to finacct 3');
            System.assert(shareCount < [select count() from FinServ__FinancialAccount__c],
                    'Check that user 1 (with rep 1 access) was granted additional shares because of the rep 3 split');
        }
    }

    @isTest static void testHandleInsertWithSplitRep(){
        // TODO: this case is implemented but needs test
    }

    @isTest static void testHandleDelete(){
        User user = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0];
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id finAcctId = [Select Id from FinServ__FinancialAccount__c where Name = 'Financial Account Three (REP3)' limit 1][0].Id;

        System.runAs([Select Id from User where Id = :UserInfo.getUserId() limit 1][0]) {
            SecurityAssignmentConfig.enableTriggers();
            insert new Rep_Assignment__c(User__c = user.Id, Rep__c = rep1Id);
        }

        integer shareCount;
        System.runAs(user){
            shareCount = [select count() from FinServ__FinancialAccount__c];
        }

        // create a new account share granting REP 1 access to this account
        Account_Split__c accountSplit;
        System.runAs([Select Id from User where Id = :UserInfo.getUserId() limit 1][0]) {
            accountSplit = new Account_Split__c(Rep__c = rep1Id, Financial_Account__c = finAcctId);
            insert accountSplit;
        }

        System.runAs(user) {
            System.assert(shareCount < [select count() from FinServ__FinancialAccount__c],
                    'Check that user 1 (with rep 1 access) was granted additional access because of the account split ');
        }

        Test.startTest();
        delete accountSplit;
        Test.stopTest();

        System.runAs(user) {
            System.assert(shareCount == [select count() from FinServ__FinancialAccount__c],
                    'Check that user 1 (with rep 1 access) was returned to the original number of finaccts');
        }
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}