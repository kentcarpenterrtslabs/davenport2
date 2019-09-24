/**
 * Created by Eric Stansbury on 8/26/2019.
 */

@isTest
public class FinancialAccountRollupsFixBatchableTest {
    @isTest static void doTest(){
        Account owner = new Account(
                Name = 'Test Person Account',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SecurityAssignmentTestFactory.INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId(),
                FinServ__IndividualType__c = 'Individual'
        );
        insert owner;

        FinServ__FinancialAccount__c finAcct = new FinServ__FinancialAccount__c(Name = 'Test', FinServ__PrimaryOwner__c = owner.Id, FinServ__Balance__c = 1234);
        insert finAcct;

        Test.startTest();
        Database.executeBatch(new FinancialAccountRollupsFixBatchable());
        Test.stopTest();

        System.assertEquals(1234, [select FinServ__Balance__c  from finserv__financialaccount__c limit 1][0].FinServ__Balance__c );
    }
}