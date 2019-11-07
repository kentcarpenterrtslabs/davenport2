/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class FMADashboardControllerTest {
    @isTest static void doTest(){
        Id finAcctId = [select id from finserv__financialaccount__c limit 1][0].Id;
		List<Account> accounts = [Select id from account where RecordType.DeveloperName = 'IndustriesHousehold' and FMA_Account__c = true limit 1];
        Id accountId = accounts[0].Id;
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

		Date yesterday = Date.today().addDays(-1);
		Date tomorrow = Date.today().addDays(1);

		Map<Id, List<FMA_Review_Form__c>> fmaReviewData = FMADashboardController.getFMAReviewData(
			accounts,
			yesterday.year() + '-' + yesterday.month() + '-' + yesterday.day(),
			tomorrow.year() + '-' + tomorrow.month() + '-' + tomorrow.day());

        System.assertNotEquals(0, fmaReviewData.size());
    }

    @TestSetup static void setupData(){
        SecurityAssignmentTestFactory.createData();
    }
}