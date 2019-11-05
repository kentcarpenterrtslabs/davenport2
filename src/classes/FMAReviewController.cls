public with sharing class FMAReviewController {
    @AuraEnabled (cacheable=false)
    public static string createFMAReview(
        String personClientComments, 
        String personClientBtn, 
        String InvestObjComments, 
        String InvestObjBtn,
        String TimeHorzonComments,
        String TimeHorizonBtn,
        String InvestPerfComment,
        String InvestPerfBtn,
        String ConcenPositionsComments,
        String ConcenPositionsBtn,
        String HighCashComments,
        String HighCashBtn, 
        String TradingComments,
        String TradingBtn,
        String AccountRep,
        String AccountId,
        String CallNotes,
        String Subject,
        List <String> financialAcctsIds
    ){
        String message ='';

        FMA_Review_Form__c  fma =  new FMA_Review_Form__c();
        fma.Personal_Client_Info_pl__c = personClientBtn;
        fma.Personal_Client_Info_co__c = personClientComments;
        fma.Investment_Objective_and_Risk_comments__c = InvestObjComments;
        fma.Investment_Objective_and_Risk_pl__c = InvestObjBtn;
        fma.Time_Horizon_and_Liquidity_Needs_Comment__c = TimeHorzonComments;
        fma.Time_Horizon_pl__c = TimeHorizonBtn;
        fma.Investment_and_Performance_Comments__c = InvestPerfComment;
        fma.Investment_and_Performance_pl__c = InvestPerfBtn;
        fma.Concentrated_Positions_pl__c = ConcenPositionsBtn;
        fma.Concentrated_Positions_Comments__c = ConcenPositionsComments;
        fma.High_Cash_Balance_Comments__c = HighCashComments;
        fma.High_Cash_Balance_pl__c = HighCashBtn;
        fma.Trading_Low_Trading_pl__c = TradingBtn;
        fma.Trading_Low_Trading_Comments__c= TradingComments;
        fma.Rep__c = AccountRep;
        fma.Account__c = AccountId;
        fma.Call_Notes__c = CallNotes;
        fma.Subject__c = Subject;
        insert fma;


        Account acct = 
        [SELECT Id, Last_FMA_Form_Created__c FROM Account WHERE Id = :AccountId LIMIT 1];


        acct.Last_FMA_Form_Created__c = Date.today();

        update acct;

        // try{
        //     
        //     message = 'FMA form created ' + fma.Id;
        //     System.debug(message);
        //     return message;

        // }
        // catch(DmlException e) {
        //  System.debug('The following exception has occurred: ' + e.getMessage());
        //     return message;

        // }


        System.debug(financialAcctsIds.size());
        System.debug(financialAcctsIds);

		List<FMA_Account_Review_Association__c> toInsert = new List<FMA_Account_Review_Association__c>();

        for (Integer i=0; i<financialAcctsIds.size(); i++){

            toInsert.add(new FMA_Account_Review_Association__c(   
                FMA_Review_Form__c = fma.Id,
                Financial_Account__c = financialAcctsIds[i]
			));
		}
        insert toInsert;

        return fma.Id;
    }
}