/**
 * Created by Eric Stansbury on 5/28/2019.
 */

@isTest
public class SecurityAssignmentHelperTest {
    @isTest static void testGetRepSplitToGrantAccessRepForAccountSplitMap() {
        Id rep5Id = [Select id from Rep__c where Rep_Number__c = 'REP5' limit 1][0].Id;

        Map<Id, Set<Id>> finAcctMap = SecurityAssignmentHelper.getRepToFinancialAccountMap(new Set<Id>{ rep5Id });
        System.assertNotEquals(null, finAcctMap.get(rep5Id), 'Rep5Id should exist in the finacct map');
        System.assertEquals(1, finAcctMap.get(rep5Id).size(), 'The map should indicate REP5 has access to 1 financial account via Account_Split__c record');
    }

    @isTest static void testGetRepSplitToGrantAccessRepMap(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameTwo limit 1][0].Id;
        Id rep2Id = [Select id from Rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;
        Id rep4Id = [Select id from Rep__c where Rep_Number__c = 'REP4' limit 1][0].Id;

        Map<Id, Set<Id>> splitRepMap = SecurityAssignmentHelper.getSplitRepMap(new Set<Id> { rep4Id });
        System.assertEquals(1, splitRepMap.keySet().size(), 'There should be 1 split rep Id key in the map');
        System.assert(splitRepMap.keySet().contains(rep4Id), 'The split rep key should be the REP4 Id');
        System.assertEquals(3, splitRepMap.get(rep4Id).size(), 'The split rep should have 3 Grant Access To Rep IDs');
    }

    @isTest static void testGetRepToFinancialAccountMap(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0].Id;
        Id repId = [Select id from Rep__C where Rep_Number__c = 'REP1' limit 1][0].Id;

        Map<Id, Set<Id>> finAcctMap = SecurityAssignmentHelper.getRepToFinancialAccountMap(new Set<Id>{ repId });
        System.assertEquals(2, finAcctMap.get(repId).size(), 'The map should indicate REP1 has access to 2 financial accounts -- one direct, one via REP4 split');
    }

    @isTest static void testGetRepToFinancialAccountMapTwo(){
        Id rep2Id = [select id from rep__c where Rep_Number__c = 'REP2' limit 1][0].Id;
        Map<Id, Set<Id>> finAcctMap = SecurityAssignmentHelper.getRepToFinancialAccountMap(new Set<Id>{ rep2Id });
        System.assertEquals(3, finAcctMap.get(rep2Id).size(), 'The map should indicate REP2 has access to 3 financial accounts -- one direct, one via account split, one via REP4 split');
    }

    @isTest static void testGetUserIdsByRep(){
        Set<Id> repIds = new Map<Id, Rep__c>([Select Id from Rep__c]).keySet();
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id user1Id = [select id from User where LastName = 'TestUser1' limit 1][0].Id;
        Id user2Id = [select id from User where LastName = 'TestUser2' limit 1][0].Id;

        insert new List<Rep_Assignment__c>{
            new Rep_Assignment__c(User__c = user1Id, Rep__c = rep1Id),
            new Rep_Assignment__c(User__c = user2Id, Rep__c = rep1Id)
        };

        Map<Id, Set<Id>> userIdsByRep = SecurityAssignmentHelper.getUserIdsByRep(repIds);
//        System.assert(userIdsByRep.keySet().contains(rep1Id), 'The map should have rep 1 id as a key');
//        System.assertEquals(2, userIdsByRep.get(rep1Id).size(), 'The map should indicate that two users should have access to rep 1');
    }

    @isTest static void getRepIdsByUserTest(){
        Set<Id> repIds = new Map<Id, Rep__c>([Select Id from Rep__c]).keySet();
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id user1Id = [select id from User where LastName = 'TestUser1' limit 1][0].Id;
        Id assistantId = [select Id from User where Username = 'daventestuser5@test.com' limit 1][0].Id;

        insert new Rep_Assignment__c(User__c = user1Id, Rep__c = rep1Id);

        Set<Id> userIds = new Map<Id, User>([Select Id from User where Username like '%test%']).keySet();
        Map<Id, Set<Id>> repIdsByUser = SecurityAssignmentHelper.getRepIdsByUser(userIds, null, null);
//        System.assertNotEquals(null, repIdsByUser);
//        System.assertEquals(2, repIdsByUser.keySet().size(), '2 users should have rep assignments');
//        System.assertEquals(1, repIdsByUser.get(user1Id).size(), 'User 1 should have an assignment to rep 1');
//        System.assertEquals(new Set<Id>{ rep1Id }, repIdsByUser.get(user1Id), 'User 1 should have an assignment to rep 1');
//        System.assertEquals(new Set<Id>{ rep1Id }, repIdsByUser.get(assistantId), 'User 1\'s assistant should have an assignment to rep 1');
    }

    @isTest static void getFinAcctsByUserTest(){
        Set<Id> repIds = new Map<Id, Rep__c>([Select Id from Rep__c]).keySet();
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;
        Id user1Id = [select id from User where LastName = 'TestUser1' limit 1][0].Id;
        Id assistantId = [select Id from User where Username = 'daventestuser5@test.com' limit 1][0].Id;
        insert new Rep_Assignment__c(User__c = user1Id, Rep__c = rep1Id);

        Set<Id> userIds = new Map<Id,User>([Select Id from User]).keySet();
        Map<Id, Set<Id>> finAcctsByUser = SecurityAssignmentHelper.getFinAcctsByUser(userIds, null, null, null, null);
//        System.assertNotEquals(null, finAcctsByUser);
//        System.assertEquals(2, finAcctsByUser.keySet().size(), '2 users should have finAccts');
//        System.assert(finAcctsByUser.get(user1Id).contains(finAcct1Id), 'User 1 should have an assignment to finAcct 1');
//        System.assert(finAcctsByUser.get(user1Id).contains(finAcct4Id), 'User 1 should have an assignment to finAcct 4');
//        System.assert(finAcctsByUser.get(assistantId).contains(finAcct1Id), 'User 1\'s assistant should have an assignment to finAcct 1');
    }

    @isTest static void getUserIdsByRepTest(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0].Id;
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        SecurityAssignmentConfig.repAssignmentTriggersEnabled = true;
        insert new Rep_Assignment__c(Rep__c = rep1Id, User__c = userId);

        Map<Id, Set<Id>> userIdsByRep = SecurityAssignmentHelper.getUserIdsByRep(new Set<Id>{ rep1Id });
//        System.assertEquals(1, userIdsByRep.get(rep1Id).size());
//        System.assert(userIdsByRep.get(rep1Id).contains(userId));

        // create a rep split and retest
        Id rep3Id = [Select id from Rep__c where Rep_Number__c = 'REP3' limit 1][0].Id;
        insert new Rep_Split__c(Split_Rep__c = rep3Id, Grant_Access_To_Rep__c = rep1Id);
        userIdsByRep = SecurityAssignmentHelper.getUserIdsByRep(new Set<Id>{ rep1Id, rep3Id });
//        System.assertEquals(1, userIdsByRep.get(rep1Id).size(), 'The utility method should show rep 1 on user 1');
//        System.assertEquals(1, userIdsByRep.get(rep3Id).size(), 'The utility method should show rep 3 on user 1 (via the split)');
    }

    @isTest static void testGetSharesMap(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0].Id;
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        SecurityAssignmentHelper.getSharesMap(new Set<Id>{userId}, new Set<Id>{rep1Id});
    }

    @isTest static void testGetRepIdsForUser(){
        Id userId = [Select id from user where davenport_username__c = :SecurityAssignmentTestFactory.davenportUsernameOne limit 1][0].Id;
        Id rep1Id = [Select id from Rep__c where Rep_Number__c = 'REP1' limit 1][0].Id;

        SecurityAssignmentHelper.getRepIdsForUser(userId, new Set<Id>{rep1Id});

    }

    @TestSetup static void setupData(){
        SecurityAssignmentConfig.disableTriggers();

        SecurityAssignmentTestFactory.createData();
    }

    @isTest static void coverage(){
        SecurityAssignmentHelper.testCoverage();
    }
}