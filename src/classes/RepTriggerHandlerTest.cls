/**
 * Created by Eric Stansbury on 6/10/2019.
 */

@isTest
public class RepTriggerHandlerTest {
    @isTest static void handleAfterDeleteTest(){
        User user1 = [select id from User where LastName = 'TestUser1' limit 1][0];
//        System.runAs(user1){
//            System.assertEquals(2, [select count() from FinServ__FinancialAccount__c], 'User1 should see two fin accts');
//        }

        delete [select id from rep__c];

        System.runAs(user1){
            System.assertEquals(0, [select count() from FinServ__FinancialAccount__c], 'User1 should see zero fin accts');
        }
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}