@isTest
public class EventToFMABatchableTest {
    @isTest static void doTest(){
        Test.startTest();
        Database.executeBatch(new EventToFMABatchable());
        Test.stopTest();
        
        List<FMA_Review_Form__c> fmaReviews = [
            Select Id, 
            	Personal_Client_Info_pl__c,
            	Investment_Objective_and_Risk_pl__c,
            	Time_Horizon_pl__c,
            	Investment_and_Performance_pl__c,
            	Concentrated_Positions_pl__c,
            	High_Cash_Balance_pl__c,
            	Trading_Low_Trading_pl__c,
            	Legacy_CreatedDate__c,
            	Call_Notes__c,
            	Subject__c
            from FMA_Review_Form__c
        ];
        System.assertEquals(1, fmaReviews.size(), 'One FMA Review should have been created from the event');
        System.assertEquals('Reviewed, No Change', fmaReviews[0].Personal_Client_Info_pl__c);
        System.assertEquals('Reviewed, No Change', fmaReviews[0].High_Cash_Balance_pl__c);
        System.assertEquals('Not Applicable', fmaReviews[0].Time_Horizon_pl__c);
        System.assertEquals('Not Applicable', fmaReviews[0].Investment_and_Performance_pl__c);
        System.assertEquals('Not Applicable', fmaReviews[0].Concentrated_Positions_pl__c);
        System.assertEquals('My Description', fmaReviews[0].Call_Notes__c);
        System.assertEquals('My Subject', fmaReviews[0].Subject__c);
        
    }
    
    @testSetup static void testSetup(){
        Account account = new Account(Name = 'My Test Account');
        insert account;
        
        Task task = new Task(
        	Info_Reviewed__c = 'Personal Client Info;High Cash Balance',
            Description = 'My Description',
            Subject = 'My Subject',
            Status = 'Complete',
            WhatId = account.Id

        );
        insert task;
    }
}