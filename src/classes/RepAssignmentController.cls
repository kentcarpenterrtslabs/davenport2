public with sharing class RepAssignmentController {
  @AuraEnabled(cacheable=true)
  public static List<Rep_Assignment__c> getRepLabelData(){

    List<Rep_Assignment__c> repAssignmentData = new List<Rep_Assignment__c>(); 
    
    repAssignmentData = [
        SELECT Id,Rep__r.Rep_Number__c,User__r.Name, User__r.id FROM Rep_Assignment__c
    ];
    
    return repAssignmentData;
  }
}