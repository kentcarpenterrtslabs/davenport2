/**
 * Created by Eric Stansbury on 5/16/2019.
 */

@isTest
public class SecurityAssignmentTestFactory {
    public static String davenportUsernameOne = 'testuser1';
    public static String davenportUsernameTwo = 'testuser2';
    public static String davenportUsernameThree = 'testuser3';
    public static String davenportUsernameFour = 'testuser4';
    public static String davenportUsernameFive = 'testuser5';
    public final static String HOUSEHOLD_RECORDTYPE_NAME = 'IndustriesHousehold'; 
    public final static String INDIVIDUAL_RECORDTYPE_NAME = 'Contact Client/Prospect';

    public static void createData(){
        User user = [select id from User where IsActive = true and Profile.Name = 'System Administrator' limit 1][0];
        SecurityAssignmentConfig.enableTriggers(user.Id);
        System.runAs(user) {
            Id profileId = [Select Id from Profile where Name = 'Standard User' limit 1][0].Id;

            User testUserOne = new User(
                    Username = 'daventestuser1@test.com',
                    LastName = 'TestUser1',
                    Email = 'testuser1@test.com',
                    Alias = 'tus1',
                    Davenport_Username__c = davenportUsernameOne,
                    ProfileId = profileId,
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles'
            );
            User testUserTwo = new User(
                    Username = 'daventestuser2@test.com',
                    LastName = 'TestUser2',
                    Email = 'testuser2@test.com',
                    Alias = 'tus2',
                    Davenport_Username__c = davenportUsernameTwo,
                    ProfileId = profileId,
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles'
            );
            User testUserThree = new User(
                    Username = 'daventestuser3@test.com',
                    LastName = 'TestUser3',
                    Email = 'testuser3@test.com',
                    Alias = 'tus3',
                    Davenport_Username__c = davenportUsernameThree,
                    ProfileId = profileId,
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles'
            );
            User testUserFour = new User(
                    Username = 'daventestuser4@test.com',
                    LastName = 'TestUser4',
                    Email = 'testuser4@test.com',
                    Alias = 'tus4',
                    Davenport_Username__c = davenportUsernameFour,
                    ProfileId = profileId,
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles'
            );
            User testUserFive = new User(
                    Username = 'daventestuser5@test.com',
                    LastName = 'TestUser5',
                    Email = 'testuser5@test.com',
                    Alias = 'tus5',
                    Davenport_Username__c = davenportUsernameFive,
                    ProfileId = profileId,
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    TimeZoneSidKey = 'America/Los_Angeles'
            );
            insert new List<User>{
                    testUserOne, testUserTwo, testUserThree, testUserFour, testUserFive
            };

            // create household and person account to associate financial accounts with
            Account household = new Account(
                    Name = 'Test Household',
                    Placeholder_Household__c = false,
                    FMA_Account__c = true,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
                    FinServ__IndividualType__c = 'Group'
                    //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //FinServ__IndividualType__c = 'Individual'
            );
            Account household2 = new Account(
                    Name = 'Test Household2',
                    Placeholder_Household__c = false,
                    FMA_Account__c = true,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
                    FinServ__IndividualType__c = 'Group'
                    //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //FinServ__IndividualType__c = 'Individual'
            );
            Account household3 = new Account(
                    Name = 'Test Household3',
                    Placeholder_Household__c = false,
                    FMA_Account__c = true,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
                    FinServ__IndividualType__c = 'Group'
                    //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //FinServ__IndividualType__c = 'Individual'
            );
            Account household4 = new Account(
                    Name = 'Test Household4',
                    Placeholder_Household__c = false,
                    FMA_Account__c = true,
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId(),
                    FinServ__IndividualType__c = 'Group'
                    //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //FinServ__IndividualType__c = 'Individual'
            );
            insert new List<Account>{
                    household, household2, household3, household4
            };

            Account owner = new Account(
                    LastName = 'Test Person Account',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //ParentId = household.Id,
                    FinServ__IndividualType__c = 'Individual'
            );
            Account owner2 = new Account(
                    LastName = 'Test Person Account2',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //ParentId = household2.Id,
                    FinServ__IndividualType__c = 'Individual'
            );
            Account owner3 = new Account(
                    LastName = 'Test Person Account3',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //ParentId = household3.Id,
                    FinServ__IndividualType__c = 'Individual'
            );
            Account owner4 = new Account(
                    LastName = 'Test Person Account4',
                    RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                    //ParentId = household4.Id,
                    FinServ__IndividualType__c = 'Individual'
            );
            insert new List<Account>{
                    owner, owner2, owner3, owner4
            };

            Id roleRecordType = [Select Id from RecordType where SObjectType = 'FinServ__ReciprocalRole__c' and Name = 'Account Role' limit 1][0].Id;

            FinServ__ReciprocalRole__c householdRole = new FinServ__ReciprocalRole__c(
                    Name = 'Household',
                    RecordTypeId = roleRecordType,
                    FinServ__InverseRole__c = 'Member'
            );
            FinServ__ReciprocalRole__c memberRole = new FinServ__ReciprocalRole__c(
                    Name = 'Member',
                    RecordTypeId = roleRecordType,
                    FinServ__InverseRole__c = 'Household'
            );

            //insert new List<FinServ__ReciprocalRole__c>{ householdRole, memberRole };
            //householdRole.FinServ__InverseRelationship__c = memberRole.Id;
            //memberRole.FinServ__InverseRelationship__c = householdRole.Id;
            //update new List<FinServ__ReciprocalRole__c>{ householdRole, memberRole };

            //insert new List<FinServ__AccountAccountRelation__c>{
            //    new FinServ__AccountAccountRelation__c(FinServ__RelatedAccount__c = owner.Id, FinServ__Account__c = household.Id, FinServ__Role__c = householdRole.Id),
            //    new FinServ__AccountAccountRelation__c(FinServ__RelatedAccount__c = owner2.Id, FinServ__Account__c = household2.Id, FinServ__Role__c = householdRole.Id),
            //    new FinServ__AccountAccountRelation__c(FinServ__RelatedAccount__c = owner3.Id, FinServ__Account__c = household3.Id, FinServ__Role__c = householdRole.Id),
            //    new FinServ__AccountAccountRelation__c(FinServ__RelatedAccount__c = owner4.Id, FinServ__Account__c = household4.Id, FinServ__Role__c = householdRole.Id)
            //};

            // create reps and financial accounts
            Rep__c repOne = new Rep__c(Rep_Number__c = 'REP1');
            Rep__c repTwo = new Rep__c(Rep_Number__c = 'REP2');
            Rep__c repThree = new Rep__c(Rep_Number__c = 'REP3');
            Rep__c repFour = new Rep__c(Rep_Number__c = 'REP4');
            Rep__c repFive = new Rep__c(Rep_Number__c = 'REP5');
            insert new List<Rep__c>{
                    repOne, repTwo, repThree, repFour, repFive
            };

            FinServ__FinancialAccount__c testFinAcctOne = new FinServ__FinancialAccount__c(
                    Name = 'Financial Account One (REP1)',
                    FinServ__Household__c = household.Id,
                    FinServ__PrimaryOwner__c = owner.Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = repOne.Id,
                    FinServ__Ownership__c = 'Individual',
                    RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
            );
            FinServ__FinancialAccount__c testFinAcctTwo = new FinServ__FinancialAccount__c(
                    Name = 'Financial Account Two (REP2)',
                    FinServ__Household__c = household2.Id,
                    FinServ__PrimaryOwner__c = owner2.Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = repTwo.Id,
                    FinServ__Ownership__c = 'Individual',
                    RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
            );
            FinServ__FinancialAccount__c testFinAcctThree = new FinServ__FinancialAccount__c(
                    Name = 'Financial Account Three (REP3)',
                    FinServ__Household__c = household3.Id,
                    FinServ__PrimaryOwner__c = owner3.Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = repThree.Id,
                    FinServ__Ownership__c = 'Individual',
                    RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
            );
            FinServ__FinancialAccount__c testFinAcctFour = new FinServ__FinancialAccount__c(
                    Name = 'Financial Account Four (REP4 -- split rep)',
                    FinServ__Household__c = household4.Id,
                    FinServ__PrimaryOwner__c = owner4.Id,
                    FinServ__JointOwner__C = null,
                    FinServ__FinancialAccountSource__c = 'Manually Entered',
                    Cost_Basis__c = 123.45,
                    FinServ__Description__c = 'This is a description of my financial account.',
                    Rep__c = repFour.Id,
                    FinServ__Ownership__c = 'Individual',
                    RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
            );
            insert new List<FinServ__FinancialAccount__c>{
                    testFinAcctOne, testFinAcctTwo, testFinAcctThree, testFinAcctFour
            } ;

            // assign testUserFive as the assistant to testUserOne and testUserTwo
            Assistant_Assignment__c assistantAssignmentOne = new Assistant_Assignment__c(Assistant__c = testUserFive.Id, Assistee__c = testUserOne.Id);
            Assistant_Assignment__c assistantAssignmentTwo = new Assistant_Assignment__c(Assistant__c = testUserFive.Id, Assistee__c = testUserTwo.Id);
            insert new List<Assistant_Assignment__c>{
                    assistantAssignmentOne, assistantAssignmentTwo
            };

            // rep 1 owned by user 1, rep 2 owned by user 2, rep 3 owned by user 3
            Rep_Security__c repSecurityOne = new Rep_Security__c(Rep_Number__c = 'REP1', Davenport_Username__c = davenportUsernameOne, Type__c = 'Rep');
            Rep_Security__c repSecurityTwo = new Rep_Security__c(Rep_Number__c = 'REP2', Davenport_Username__c = davenportUsernameTwo, Type__c = 'Rep');
            Rep_Security__c repSecurityThree = new Rep_Security__c(Rep_Number__c = 'REP3', Davenport_Username__c = davenportUsernameThree, Type__c = 'Rep');

            // via UPI assignment, grant user 4 access to the three reps
            Rep_Security__c upiAssignmentOne = new Rep_Security__c(Rep_Number__c = 'REP1', Davenport_Username__c = davenportUsernameFour, Type__c = 'UPI');
            Rep_Security__c upiAssignmentTwo = new Rep_Security__c(Rep_Number__c = 'REP2', Davenport_Username__c = davenportUsernameFour, Type__c = 'UPI');
            Rep_Security__c upiAssignmentThree = new Rep_Security__c(Rep_Number__c = 'REP3', Davenport_Username__c = davenportUsernameFour, Type__c = 'UPI');
            insert new List<Rep_Security__c>{
                    repSecurityOne, repSecurityTwo, repSecurityThree, upiAssignmentOne, upiAssignmentTwo, upiAssignmentThree
            };

            // rep four will be split among the other 3 rep codes
            Rep_Split__c repSplitOne = new Rep_Split__c(Grant_Access_To_Rep__c = repOne.Id, Split_Rep__c = repFour.Id);
            Rep_Split__c repSplitTwo = new Rep_Split__c(Grant_Access_To_Rep__c = repTwo.Id, Split_Rep__c = repFour.Id);
            Rep_Split__c repSplitThree = new Rep_Split__c(Grant_Access_To_Rep__c = repThree.Id, Split_Rep__c = repFour.Id);
            insert new List<SObject>{
                    repSplitOne, repSplitTwo, repSplitThree
            };

            // also grant REP2 access to Test Financial Account 1, via account split
            Account_Split__c accountSplit = new Account_Split__c(Rep__c = repTwo.Id, Financial_Account__c = testFinAcctOne.Id);
            // rep 5 can only access one account, via this account split
            Account_Split__c accountSplit2 = new Account_Split__c(Rep__c = repFive.Id, Financial_Account__c = testFinAcctOne.Id);
            insert new List<Account_Split__c>{
                    accountSplit, accountSplit2
            };
        }
    }
}