public with sharing class newCall {
   @AuraEnabled (cacheable=false)
   public static String createTask(String rId, String uId, String subject, String status, String comments, Date dueDate){
       //String rId = (String) acctparams.get('id');

       
        String message ='';
       
       //String userId = UserInfo.getUserId();
        

        Task t = new Task();
        t.OwnerId = uId;
        t.Subject = subject;
        t.Status = status;
    
        t.WhatId = rId;
        t.Description = comments;
        t.ActivityDate = dueDate;

        //t.CallType = callType;
        //  insert t;

        try{
            insert t;
            message = 'Success';
            System.debug(message);
            return message;

        }
        catch(DmlException e) {
         System.debug('The following exception has occurred: ' + e.getMessage());
            return message;

        }

   }
}