public class EventToFMABatchable implements Database.Batchable<SObject>{
	public Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator(
        	'Select Id, WhatId, Info_Reviewed__c, CreatedDate, Description, Subject from Task where Info_Reviewed__c != null'
        );
   	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Task> Tasks = (List<Task>)scope;
        Set<Id> accountIds = new Set<Id>();
        List<FMA_Review_Form__c> insertMe = new List<FMA_Review_Form__c>();
        for (Task Task : Tasks){
            insertMe.add(
            	buildFMAReview(Task)
            );

            accountIds.add(Task.WhatId);
        }
        System.debug('EventToFMABatchable inserting ' + insertMe.size() + ' FMA Review forms');
        insert insertMe;

        Map<Id, Account> accounts = new Map<Id, Account>([Select Id, Last_FMA_Form_Created__c From Account Where Id in :accountIds]);

        for (Task Task : Tasks){
            Account acct = accounts.get(Task.WhatId);
            if (acct != null){
                acct.Last_FMA_Form_Created__c = Date.newInstance(Task.CreatedDate.year(), Task.CreatedDate.month(), Task.CreatedDate.day());
            }
        }
        
        update accounts.values();
    }

   	public void finish(Database.BatchableContext BC){
       	// do nothing
   	}
    
    // picklist values for FMA Review fields
    static String yes = 'Reviewed, No Change';
    static String no = 'Not Applicable';
    
    // Task -> FMA Review mapping here
    static FMA_Review_Form__c buildFMAReview(Task Task){
        FMA_Review_Form__c fmaReview = new FMA_Review_Form__c();
        fmaReview.Personal_Client_Info_pl__c 		  = (Task.Info_Reviewed__c.contains('Personal Client Info') ? yes : no );
        fmaReview.Investment_Objective_and_Risk_pl__c = (Task.Info_Reviewed__c.contains('Investment Objective & Risk Tolerance') ? yes : no );
        fmaReview.Time_Horizon_pl__c 				  = (Task.Info_Reviewed__c.contains('Time Horizon & Liquidity Needs') ? yes : no );
        fmaReview.Investment_and_Performance_pl__c 	  = (Task.Info_Reviewed__c.contains('Investments & Performance') ? yes : no );
        fmaReview.Concentrated_Positions_pl__c 		  = (Task.Info_Reviewed__c.contains('Concentrated Positions') ? yes : no );
        fmaReview.High_Cash_Balance_pl__c 			  = (Task.Info_Reviewed__c.contains('High Cash Balance') ? yes : no );
        fmaReview.Trading_Low_Trading_pl__c 		  = (Task.Info_Reviewed__c.contains('Unsolicited Trading/Low Trading') ? yes : no );
        fmaReview.Legacy_CreatedDate__c 			  = Task.CreatedDate;
        fmaReview.Call_Notes__c 					  = Task.Description;
        fmaReview.Subject__c 						  = Task.Subject;
        fmaReview.Account__c 						  = Task.WhatId;
        return fmaReview;
    }




}