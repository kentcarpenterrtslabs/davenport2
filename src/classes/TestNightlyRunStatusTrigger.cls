@isTest
private class TestNightlyRunStatusTrigger {


  @isTest
  private static void testHandleAfterInsert() {  

    Test.startTest();

    Nightly_Run_Status__c status = new Nightly_Run_Status__c(Status__c = 'Complete');
    insert status;

        Nightly_Run_Status__c status1 = new Nightly_Run_Status__c(Status__c = 'rollup');
        insert status1;
        Nightly_Run_Status__c status2 = new Nightly_Run_Status__c(Status__c = 'security');
        insert status2;

    Test.stopTest();
  }

}