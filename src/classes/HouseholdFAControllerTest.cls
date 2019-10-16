/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class HouseholdFAControllerTest {
    @isTest static void doTest(){
        String householdId = [Select Id from Account where Name = 'Test Household' limit 1][0].Id;
        List<FinServ__FinancialAccount__c> finAccts = HousesholdFAController.getFinAccounts(householdId);
        System.assertNotEquals(null, finAccts);
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}