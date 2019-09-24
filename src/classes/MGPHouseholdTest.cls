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

    @TestSetup static void setupData() {
        MoneyGuideProRequestControllerTest.setupData();
    }

}