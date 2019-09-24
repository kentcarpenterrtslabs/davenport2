public with sharing class RepNumHouseholdSearchController {

@AuraEnabled(cacheable=true)
  public static List<Account> getHouseholds(List<String> repNumbers){
      
        
        return [
            Select Id, Name, AccountNumber, Last_FMA_Form_Created__c, ReviewDate__c  from Account
            where Id in
                (Select FinServ__Household__c FROM FinServ__FinancialAccount__c
                 where Rep__c in :repNumbers) And Last_FMA_Form_Created__c != null
        ];
    }
}