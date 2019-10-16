/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class RepNumHouseholdSearchControllerTest {
    @isTest static void doTest(){
        String repNumber = [Select Id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        List<Account> result = RepNumHouseholdSearchController.getHouseholds(new List<String>{repNumber});
        System.assertNotEquals(null, result);
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}