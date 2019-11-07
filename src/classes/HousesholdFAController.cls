public with sharing class HousesholdFAController {
  @AuraEnabled(cacheable=true)
  public static List<FinServ__FinancialAccount__c> getFinAccounts(String rId){

      return [SELECT id, FinServ__Household__c, Name, Plan_ID__c FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c = :rId];
      
  }
}