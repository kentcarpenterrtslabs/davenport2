/**
 * Created by Eric Stansbury on 7/19/2019.
 */

@isTest
public class UPIAccessToggleControllerTest {
    @isTest static void testIsFirmwideAccessEnabled(){
        User testUser = [Select Id from User where Davenport_Username__c = :SecurityAssignmentTestFactory.davenportUsernameFour];
        System.runAs(testUser){
            System.assertEquals(true, UPIAccessToggleController.isFirmwideAccessEnabled(), 'This should default to \'true\'');
        }
    }

    @isTest static void disableUPIAccessTest(){
        User testUser = [Select Id from User where Davenport_Username__c = :SecurityAssignmentTestFactory.davenportUsernameFour][0];

        integer membershipsCount = [Select count() from GroupMember where UserOrGroupId = :testUser.Id];
        System.assertNotEquals(0, membershipsCount, 'The user should have group memberships from the test data (granted via UPI)');

        Test.startTest();
        System.runAs(testUser){
            UPIAccessToggleController.disableUPIAccess();
        }
        Test.stopTest();

        System.assertNotEquals(membershipsCount, [Select count() from GroupMember where UserOrGroupId = :testUser.Id], 'The user should have had group memberships removed');
        System.assertEquals(false, [Select Firm_Wide_Access_Enabled__c from User where Id = :testUser.Id][0].Firm_Wide_Access_Enabled__c);
    }

    @isTest static void enableUPIAccessTest(){
        User testUser = [Select Id from User where Davenport_Username__c = :SecurityAssignmentTestFactory.davenportUsernameFour][0];

        // delete existing shares from the test data
        delete [Select Id from GroupMember where UserOrGroupId = :testUser.Id];

        Test.startTest();
        System.runAs(testUser){
            UPIAccessToggleController.enableUPIAccess();
        }
        Test.stopTest();

        System.assertNotEquals(0, [Select count() from GroupMember where UserOrGroupId = :testUser.Id], 'The user should have had group memberships added');
        System.assertEquals(true, [Select Firm_Wide_Access_Enabled__c from User where Id = :testUser.Id][0].Firm_Wide_Access_Enabled__c);
    }

    // todo: build test cases around Account Splits and Rep Splits

    @testSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}