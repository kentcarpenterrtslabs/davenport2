/**
 * Created by Eric Stansbury on 5/9/2019.
 */

@isTest
public with sharing class MGPHouseholdTest {
    @isTest static void doTest(){
        Id householdId = [select id from account limit 1][0].Id;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/Household/' + householdId;
        RestContext.request  = req;
        RestContext.response = res;
        Test.startTest();
        MGPHousehold.doGet();
        Test.stopTest();
    }

    @isTest static void testGenerateXml(){
        Id householdId = [select id from Account limit 1][0].Id;
        String result = MGPHousehold.buildRequestBody(householdId);
        System.assertNotEquals(result, null);
        System.debug(result);
    }

    @isTest static void testBuildHoldings(){
        MGPHousehold.buildHoldings(null, new List<FinServ__FinancialHolding__c>{
            new FinServ__FinancialHolding__c(
                Cost_Basis__c = 1234,
                Quantity__c = 1234
            )
        });
    }

    @isTest static void testBuildCoclients(){
        MGPHousehold.buildCoclients(new List<Contact>{
                new Contact(
                    LastName = 'Test',
                    MailingState = 'VA'
                )
        });
    }

    @isTest static void testBuildClient(){
        MGPHousehold.buildClient(new Account(
                LastName = 'Test'
        ));
    }

    @isTest static void testBuildInvestmentAssets(){
        MGPHousehold.buildInvestmentAssets(new List<FinServ__FinancialAccount__c>{
            new FinServ__FinancialAccount__c(
                Name = 'Test'
            )
        }, new List<FinServ__FinancialHolding__c>{
                new FinServ__FinancialHolding__c(
                        Cost_Basis__c = 1234,
                        Quantity__c = 1234
                )
        });
    }

    @TestVisible @TestSetup public static void setupData(){
        Account household = new Account(
            Name = 'Test Household'
        );
        insert household;

        Account individual = new Account(
            LastName = 'Test Individual',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SecurityAssignmentTestFactory.INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId()
        );
        insert individual;

        FinServ__FinancialAccount__c testFinAcct = new FinServ__FinancialAccount__c(
            FinServ__Household__c = household.Id,
            FinServ__PrimaryOwner__c = individual.Id,
            FinServ__JointOwner__C = null,
            FinServ__FinancialAccountSource__c = 'Manually Entered',
            Cost_Basis__c = 123.45,
            FinServ__Description__c = 'This is a description of my financial account.'
        );

        FinServ__FinancialAccount__c testFinAcct2 = new FinServ__FinancialAccount__c(
            FinServ__Household__c = household.Id,
            FinServ__PrimaryOwner__c = individual.Id,
            FinServ__JointOwner__c = null,
            FinServ__FinancialAccountSource__c = 'Manually Entered',
            Cost_Basis__c = 9999.12,
            FinServ__Description__c = 'This is a description of my other financial account.'
        );
        insert new List<FinServ__FinancialAccount__c>{ testFinAcct, testFinAcct2 };

        //System.assertEquals(household.Id, [Select FinServ__Household__c from FinServ__FinancialAccount__c where Id = :testFinAcct.Id limit 1][0].FinServ__Household__c, 'The correct household should be assigned');

        FinServ__Securities__c security = new FinServ__Securities__c(
            FinServ__AssetCategory__c = 'U.S. Equity',
            FinServ__AssetCategoryName__c = 'Large Growth',
            FinServ__AssetClass__c = 'Equities',
            FinServ__CUSIP__c = '037833100',
            FinServ__Exchange__c = 'NASDAQ',
            FinServ__LastUpdated__c = Date.today(),
            FinServ__Price__c = 1234.56,
            FinServ__SecuritiesName__c = 'TestSecurity',
            Name = 'AAPL'
        );

        FinServ__Securities__c security2 = new FinServ__Securities__c(
            FinServ__AssetCategory__c = 'U.S. Equity',
            FinServ__AssetCategoryName__c = 'Large Growth',
            FinServ__AssetClass__c = 'Equities',
            FinServ__CUSIP__c = '935935935',
            FinServ__Exchange__c = 'NASDAQ',
            FinServ__LastUpdated__c = Date.today(),
            FinServ__Price__c = 7777.00,
            FinServ__SecuritiesName__c = 'TestSecurity2',
            Name = 'MSFT'
        );
        insert new List<FinServ__Securities__c>{ security, security2 };

        FinServ__FinancialHolding__c holding = new FinServ__FinancialHolding__c(
            FinServ__FinancialAccount__c = testFinAcct.Id,
            Quantity__c = 123,
            Cost_Basis__c = 81365.20,
            FinServ__MarketValue__c = 62.00,
            FinServ__Securities__c = security.Id
        );
        FinServ__FinancialHolding__c holding2 = new FinServ__FinancialHolding__c(
            FinServ__FinancialAccount__c = testFinAcct.Id,
            Quantity__c = 10,
            Cost_Basis__c = 81365.20,
            FinServ__MarketValue__c = 9319519.00,
            FinServ__Securities__c = security2.Id
        );
        FinServ__FinancialHolding__c holding3 = new FinServ__FinancialHolding__c(
            FinServ__FinancialAccount__c = testFinAcct2.Id,
            Quantity__c = 15,
            Cost_Basis__c = 81365.20,
            FinServ__MarketValue__c = 9319519.00,
            FinServ__Securities__c = security.Id
        );
        //insert holding;
        insert new List<FinServ__FinancialHolding__c>{ holding, holding2, holding3 };
    }

}