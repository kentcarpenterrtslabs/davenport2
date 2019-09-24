/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class FMAReviewControllerTest {
    @isTest static void doTest(){
        Id finAcctId = [select id from finserv__financialaccount__c limit 1][0].Id;
        Id accountId = [Select id from account where RecordType.DeveloperName = 'Household_Client' and FMA_Account__c = true limit 1][0].Id;
        Id repId = [Select Id from Rep__c limit 1][0].Id;
        String personClientBtn = 'Reviewed, No Change';
        String investObjBtn = 'Reviewed, No Change';
        String timeHorizonBtn = 'Reviewed, No Change';
        String concenPositionsBtn = 'Reviewed, No Change';
        String highCashBtn = 'Reviewed, No Change';
        String tradingBtn = 'Reviewed, No Change';
        String investPerfBtn = 'Reviewed, No Change';

        String fmaReview = FMAReviewController.createFMAReview(
            'personClientComments',
            personClientBtn,
            'InvestObjComments',
            investObjBtn,
            'TimeHorzonComments',
            timeHorizonBtn,
            'InvestPerfComment',
            investPerfBtn,
            'ConcenPositionsComments',
            concenPositionsBtn,
            'HighCashComments',
            highCashBtn,
            'TradingComments',
            tradingBtn,
            repId,
            accountId,
            'CallNotes',
            'Subject',
            new List<String> { finAcctId }
        );

        System.assertNotEquals(null, fmaReview);
    }

    @TestSetup static void setupData(){
        SecurityAssignmentConfig.disableTriggers();

        SecurityAssignmentTestFactory.createData();
    }
}