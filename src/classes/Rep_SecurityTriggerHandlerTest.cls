/**
 * Created by Eric Stansbury on 5/21/2019.
 */

@isTest
public class Rep_SecurityTriggerHandlerTest {
    static String repNumber = 'XX12';
    static String dportUsername = 'testuser1';
    static String dportUsernameTwo = 'testuser2';
    @isTest static void insertTest(){
        SecurityAssignmentConfig.repSecurityTriggersEnabled = true;

        Test.startTest();
        insert new Rep_Security__c(
            Rep_Number__c = repNumber, Davenport_Username__c = dportUsername, Type__c = 'Rep'
        );
        Test.stopTest();

        System.assertEquals(1, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsername and Rep__r.Rep_Number__c = :repNumber],
                'The rep assignment record should have been created');

//        boolean errorThrown = false;
//        try{
//            insert new Rep_Security__c(
//                    Rep_Number__c = 'DOESNOTEXIST', Davenport_Username__c = dportUsername, Type__c = 'Rep'
//            );
//        }catch(DmlException e){
//            errorThrown = true;
//        }
//        System.assert(errorThrown, 'Trying to insert against a rep number that doesn\'t exist should throw an error');
//
//        errorThrown = false;
//        try{
//            insert new Rep_Security__c(
//                    Rep_Number__c = repNumber, Davenport_Username__c = 'DOESNOTEXIST', Type__c = 'Rep'
//            );
//        }catch(DmlException e){
//            errorThrown = true;
//        }
//        System.assert(errorThrown, 'Trying to insert against a rep number that doesn\'t exist should throw an error');
    }

    @isTest static void updateTest(){
        SecurityAssignmentConfig.repSecurityTriggersEnabled = true;

        Test.startTest();
        Rep_Security__c repSecurity = new Rep_Security__c(
                Rep_Number__c = repNumber, Davenport_Username__c = dportUsername, Type__c = 'Rep'
        );
        insert repSecurity;
        Test.stopTest();

        System.assertEquals(1, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsername and Rep__r.Rep_Number__c = :repNumber],
                'The rep assignment record should have been created');

        repSecurity.Davenport_Username__c = dportUserNameTwo;
        update repSecurity;

//        System.assertEquals(0, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsername and Rep__r.Rep_Number__c = :repNumber],
//                'The rep assignment record should have been deleted');
//
//        System.assertEquals(1, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsernameTwo and Rep__r.Rep_Number__c = :repNumber],
//                'The rep assignment record should have been created');
    }

    @isTest static void deleteTest(){
        SecurityAssignmentConfig.repSecurityTriggersEnabled = true;
        SecurityAssignmentConfig.repAssignmentTriggersEnabled = false;

        Test.startTest();
        insert new Rep_Security__c(
                Rep_Number__c = repNumber, Davenport_Username__c = dportUsername, Type__c = 'Rep'
        );
        Test.stopTest();

        System.assertEquals(1, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsername and Rep__r.Rep_Number__c = :repNumber],
                'The rep assignment record should have been created');

        delete [select id from rep_security__c limit 1];
        System.assertEquals(0, [select count() from Rep_Assignment__c where User__r.Davenport_Username__c = :dportUsername and Rep__r.Rep_Number__c = :repNumber],
                'The rep assignment record should have been deleted after the rep security record was deleted');

    }

    @TestSetup static void setupData(){
        SecurityAssignmentConfig.disableTriggers();

        Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

        // insert user with davenport username
        User testUser = new User(
            Username = 'daventestuser1@test.com',
            LastName = 'TestUser1',
            Email = 'testuser1@test.com',
            Alias = 'tus1',
            Davenport_Username__c = dportUsername,
            ProfileId = profileId,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        User testUser2 = new User(
                Username = 'daventestuser2@test.com',
                LastName = 'TestUser2',
                Email = 'testuser2@test.com',
                Alias = 'tus2',
                Davenport_Username__c = dportUsernameTwo,
                ProfileId = profileId,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert new List<User>{ testUser, testUser2 };
        // insert rep record
        Rep__c rep = new Rep__c(Rep_Number__c = repNumber);
        insert rep;
    }
}