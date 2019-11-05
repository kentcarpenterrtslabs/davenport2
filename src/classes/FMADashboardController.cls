public with sharing class FMADashboardController {
   @AuraEnabled (cacheable=false)



	public static  Map<Id, List<FMA_Review_Form__c>> getFMAReviewData(List<Account> households, String startDateRange, String endDateRange){
       
		Map<Id, List<FMA_Review_Form__c>> mappedFMAForms = new Map<Id, List<FMA_Review_Form__c>>();

		Set<Id> ids = new Set<Id>();

		for (Account hh : households) {
			ids.add(hh.Id);
		}

		// parameters to your contoller method
		List<String> splitStartDate = startDateRange.split('-');    
		List<String> splitEndDate = endDateRange.split('-');   
		Date startDate = Date.newInstance(Integer.valueOf(splitStartDate[0]), Integer.valueOf(splitStartDate[1]), Integer.valueOf(splitStartDate[2]));
		Date endDate = Date.newInstance(Integer.valueOf(splitEndDate[0]), Integer.valueOf(splitEndDate[1]), Integer.valueOf(splitEndDate[2]));
		Time t = Time.newInstance(0,0,0,0);
		Datetime startDateTime = Datetime.newInstance(startDate,t);
		Datetime endDateTime = Datetime.newInstance(endDate.addDays(1),t);
		List<FMA_Review_Form__c> houseNotes = new List<FMA_Review_Form__c>();

        houseNotes = [
            SELECT 
                Account__c, 
                Rep__c, 
                Account__r.Name, 
                Account__r.ReviewDate__c,
                Rep__r.Name, 
                Account__r.AccountNumber,
                Account__r.Id,
                Concentrated_Positions_pl__c, 
                Concentrated_Positions_Comments__c,
                High_Cash_Balance_pl__c,
                High_Cash_Balance_Comments__c,
                Investment_and_Performance_pl__c,
                Investment_and_Performance_Comments__c,
                Investment_Objective_and_Risk_comments__c,
                Investment_Objective_and_Risk_pl__c,
                Personal_Client_Info_pl__c,
                Personal_Client_Info_co__c,
                Time_Horizon_pl__c,
                Time_Horizon_and_Liquidity_Needs_Comment__c,
                Trading_Low_Trading_pl__c,
                Trading_Low_Trading_Comments__c,
                Call_Notes__c,
                Create_Date__c
            FROM FMA_Review_Form__c 
            WHERE Account__r.Id IN :ids
            AND Create_Date__c >= :startDateTime
            AND Create_Date__c < :endDateTime
        ];

        for(FMA_Review_Form__c form : houseNotes){
			if (!mappedFMAForms.containsKey(form.Account__r.Id)) {
				mappedFMAForms.put(form.Account__r.Id, new List<FMA_Review_Form__c>());
			}
            mappedFMAForms.get(form.Account__r.Id).add(form);
		}

		 return mappedFMAForms;
   }
}