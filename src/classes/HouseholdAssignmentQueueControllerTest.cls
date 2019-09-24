/**
 * Created by Eric Stansbury on 5/6/2019.
 */

@isTest
public class HouseholdAssignmentQueueControllerTest {
    @isTest static void doTest(){
        System.assertEquals(1, [Select count()
            from FinServ__FinancialAccount__c
        ]);


        List<HouseholdAssignmentQueueController.HouseholdAssignmentRow> rows = HouseholdAssignmentQueueController.getRows();
        System.assertNotEquals(null, HouseholdAssignmentQueueController.getSearchableFields());
        System.assertNotEquals(null, HouseholdAssignmentQueueController.getResultFields());
        System.assertNotEquals(null, HouseholdAssignmentQueueController.getNewHouseholdDisplayFields());
        System.assertEquals(1, HouseholdAssignmentQueueController.searchHouseholds(new Map<String,String>{'Name' => 'Test'}).size());
    }
    
    @isTest static void doTest2(){
        System.assertEquals(1, [Select count()
            from FinServ__FinancialAccount__c
        ]);


        Id householdId = [SELECT Id FROM Account WHERE Name = 'Test Household'][0].Id;
        Id financialAccountId = [SELECT Id FROM FinServ__FinancialAccount__c WHERE Name = 'Test Financial Account'][0].Id;
        
        Test.startTest();
        String testString = HouseholdAssignmentQueueController.getComparisonRows(householdId, financialAccountId);
        HouseholdAssignmentQueueController.assignHousehold(householdId, financialAccountId);
        Test.stopTest();
        
        System.assertNotEquals(null, testString);
    }

    @testSetup static void testSetup(){
        Account household = new Account(
                Name = 'Test Household',
                Placeholder_Household__c = false,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HouseholdAssignmentQueueController.HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId()
        );
        insert household;

        Account placeholder = new Account(
                Name = 'Placeholder Household',
                Placeholder_Household__c = true,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(HouseholdAssignmentQueueController.HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId()
        );
        insert placeholder;

        Account owner = new Account(
            Name = 'Test Person Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId(),
            ParentId = placeholder.Id
        );
        insert owner;

        FinServ__FinancialAccount__c testFinAcct = new FinServ__FinancialAccount__c(
            	Name = 'Test Financial Account',
                FinServ__Household__c = placeholder.Id,
                FinServ__PrimaryOwner__c = owner.Id,
                FinServ__JointOwner__C = null,
                FinServ__FinancialAccountSource__c = 'Manually Entered',
                Cost_Basis__c = 123.45,
                FinServ__Description__c = 'This is a description of my financial account.'
        );
        insert testFinAcct;
        testFinAcct.FinServ__Household__c = placeholder.Id;
        update testfinAcct;
    }
    
    
}