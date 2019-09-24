/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Contains all of the testing methods for the org to org transfer.
 */
@IsTest
private class RTS_OrgToOrg_Test {
    @testSetup static void TestSetup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.fsc',
                Legacy_ID__c='TEST_USER');
        insert u;
    }

    @IsTest
    static void RTS_RebuildAccountTeams() {
        Account testAccount = new Account(
                Name='Test Account',
                Legacy_ID__c='LEGACY_ACCT'
        );
        insert testAccount;

        Legacy_AccountTeamMember__c latm = new Legacy_AccountTeamMember__c(
                Legacy_AccountAccessLevel__c='Read',
                Legacy_AccountId__c=testAccount.Legacy_ID__c,
                Legacy_CaseAccessLevel__c='Read',
                Legacy_ContactAccessLevel__c='Read',
                Legacy_OpportunityAccessLevel__c='Read',
                Legacy_TeamMemberRole__c='Rep',
                Legacy_UserId__c='TEST_USER'
        );
        insert latm;


        System.assertEquals(0, [SELECT Id FROM AccountTeamMember].size());
        Test.startTest();
        Database.executeBatch(new RTS_RebuildAccountTeams());
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM AccountTeamMember].size());

        User u = [SELECT Id FROM User WHERE Legacy_ID__c='TEST_USER'];
        System.assertNotEquals(null, u);
        System.assertEquals(u.Id, [SELECT UserId FROM AccountTeamMember][0].UserId);
    }

    @IsTest
    static void RTS_RebuildAnnouncements() {
        Test.startTest();
        Database.executeBatch(new RTS_RebuildAnnouncements());
        Test.stopTest();
    }

    @IsTest
    static void RTS_RebuildEvents() {
        insert new Contact(LastName='Labs', Legacy_ID__c='SERVICE_ID');
        insert new Account(Name='Labs', Legacy_ID__c='SERVICE_ID');

        Contact RTS_ServiceContact = [SELECT Id FROM Contact WHERE Legacy_ID__c = 'SERVICE_ID'][0];
        Account RTS_ServiceAccount = [SELECT Id FROM Account WHERE Legacy_ID__c = 'SERVICE_ID'][0];

        Account testAccount = new Account(
                Name='Test Account',
                Legacy_ID__c='LEGACY_ACCT'
        );
        insert testAccount;

        Contact testContact = new Contact(
                LastName='Test Account',
                Legacy_ID__c='LEGACY_CON'
        );
        insert testContact;

        Event testEvent = new Event(
                Legacy_WhatId__c='LEGACY_ACCT',
                Legacy_WhoId__c='LEGACY_CON',
                Legacy_Owner_ID__c='TEST_USER',
                WhoId = RTS_ServiceContact.Id,
                WhatId = RTS_ServiceAccount.Id,
                DurationInMinutes=10,
                ActivityDateTime=System.now()
        );
        insert testEvent;

        System.assertEquals(1, [SELECT Id FROM Event].size());
        Test.startTest();
        Database.executeBatch(new RTS_RebuildEvents());
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Event].size());

        Event rebuilt = [SELECT OwnerId, WhoId, WhatId FROM Event WHERE Id = :testEvent.Id];
        System.assertEquals(testAccount.Id, rebuilt.WhatId);
        System.assertEquals(testContact.Id, rebuilt.WhoId);
    }

    @IsTest
    static void RTS_RebuildNotes() {
        Legacy_Note__c ln = new Legacy_Note__c(
                Body__c='TEST BODY',
                IsPrivate__c=false,
                Legacy_Owner_ID__c='TEST_USER',
                Legacy_Parent_ID__c='TEST_ACCT',
                Title__c='TEST TITLE'
        );
        insert ln;

        Account testParent = new Account(
                Name='Test Account',
                Legacy_ID__c='TEST_ACCT'
        );
        insert testParent;

        System.assertEquals(0, [SELECT Id FROM Note].size());
        Test.startTest();
        Database.executeBatch(new RTS_RebuildNotes());
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Note].size());


        Note n = [SELECT Body, OwnerId, ParentId, Title, IsPrivate FROM Note][0];
        System.assertNotEquals(null, n);
        System.assertEquals(ln.Body__c, n.Body);
        System.assertEquals(ln.IsPrivate__c, n.IsPrivate);
        System.assertEquals(ln.Title__c, n.Title);

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertEquals(u.Id, n.OwnerId);
        System.assertEquals(testParent.Id, n.ParentId);
    }

    @IsTest
    static void RTS_RebuildTasks() {
        insert new Contact(LastName='Labs', Legacy_ID__c='SERVICE_ID');
        insert new Account(Name='Labs', Legacy_ID__c='SERVICE_ID');

        Contact RTS_ServiceContact = [SELECT Id FROM Contact WHERE Legacy_ID__c = 'SERVICE_ID'][0];
        Account RTS_ServiceAccount = [SELECT Id FROM Account WHERE Legacy_ID__c = 'SERVICE_ID'][0];

        Account testAccount = new Account(
                Name='Test Account',
                Legacy_ID__c='LEGACY_ACCT'
        );
        insert testAccount;

        Contact testContact = new Contact(
                LastName='Test Account',
                Legacy_ID__c='LEGACY_CON'
        );
        insert testContact;

        Task testTask = new Task(
                Legacy_WhatId__c='LEGACY_ACCT',
                Legacy_WhoId__c='LEGACY_CON',
                Legacy_Owner_ID__c='TEST_USER',
                WhoId = RTS_ServiceContact.Id,
                WhatId = RTS_ServiceAccount.Id,
                Status = 'Not Started'
        );
        insert testTask;

        System.assertEquals(1, [SELECT Id FROM Task].size());
        Test.startTest();
        Database.executeBatch(new RTS_RebuildTasks());
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Task].size());

        Task rebuilt = [SELECT OwnerId, WhoId, WhatId FROM Task WHERE Id = :testTask.Id];
        System.assertEquals(testAccount.Id, rebuilt.WhatId);
        System.assertEquals(testContact.Id, rebuilt.WhoId);
    }




    @IsTest
    static void RTS_RelinkAccountOwner() {
        Account testRecord = new Account(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkAccountOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Account WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkBranchProductionOwner() {
        Branch_Production__c testRecord = new Branch_Production__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkBranchProductionOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Branch_Production__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkBranchRegionOwner() {
        Branch_Region__c testRecord = new Branch_Region__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkBranchRegionOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Branch_Region__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkContactOwner() {
        Contact testRecord = new Contact(
                LastName='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkContactOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Contact WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkEmployeeOwner() {
        Employees__c testRecord = new Employees__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkEmployeeOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Employees__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkKYCOwner() {
        KYC__c testRecord = new KYC__c(
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkKYCOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM KYC__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkOpportunityOwner() {
        Opportunity testRecord = new Opportunity(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER',
                StageName='Open',
                CloseDate=System.today()
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkOpportunityOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Opportunity WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkRecuitOwner() {
        Recruit__c testRecord = new Recruit__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkRecuitOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Recruit__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkRepOwner() {
        Rep__c testRecord = new Rep__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkRepOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM Rep__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }

    @IsTest
    static void RTS_RelinkWealthcareOwner() {
        WealthCare__c testRecord = new WealthCare__c(
                Name='Test Account',
                Legacy_Owner_ID__c='TEST_USER'
        );
        insert testRecord;

        User u = [SELECT Id FROM User WHERE Legacy_ID__c = 'TEST_USER'][0];
        System.assertNotEquals(null, u);
        System.assertNotEquals(u.Id, testRecord.OwnerId);

        Test.startTest();
        Database.executeBatch(new RTS_RelinkWealthcareOwner());
        Test.stopTest();

        testRecord = [SELECT OwnerId FROM WealthCare__c WHERE Id = :testRecord.Id][0];
        System.assertNotEquals(null, testRecord);
        System.assertEquals(u.Id, testRecord.OwnerId);
    }
}