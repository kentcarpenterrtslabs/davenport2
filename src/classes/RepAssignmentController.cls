public with sharing class RepAssignmentController {
  @AuraEnabled(cacheable=true)
  public static List<Rep_Security__c> getRepLabelData(){

    List<Rep_Security__c> repAssignmentData = new List<Rep_Security__c>(); 
    
    repAssignmentData = [
		SELECT
			Rep__r.Id,
			Rep__r.Rep_Number__c,
			User__r.Id,
			User__r.Name
		FROM Rep_Security__c
		WHERE Rep__c != null
		AND User__c != null
    ];
    
    return repAssignmentData;
  }
}