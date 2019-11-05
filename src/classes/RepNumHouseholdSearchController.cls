public with sharing class RepNumHouseholdSearchController {

@AuraEnabled(cacheable=true)
  public static List<Account> getHouseholds(List<String> repNumbers){
      
        
        return [
            SELECT
				Id,
				Name,
				Account_Numbers__c,
				Last_FMA_Form_Created__c,
				ReviewDate__c
			FROM Account
            WHERE Id IN
            (
				SELECT
					FinServ__Household__c
				FROM FinServ__FinancialAccount__c
				WHERE Rep__c IN :repNumbers
			)
			AND Last_FMA_Form_Created__c != null
        ];
    }
}