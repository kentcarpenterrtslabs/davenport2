public with sharing class FormDataController {
  @AuraEnabled (cacheable=false)
  public static String createFormData(String formIds, String repLabel){

    
   
      FormData__c form = new FormData__c();
      form.Forms_For_VF_Page__c = formIds;
      form.RepUserName__c = repLabel;


      try {
          insert form;
          System.debug(form.Id);
          return form.Id;
      }
      catch(DmlException e){
         System.debug('The following exception has occurred: ' + e.getMessage());
            return e.getMessage(); 
      }
      
  }
}