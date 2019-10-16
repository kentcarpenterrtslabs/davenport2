@isTest
private class TestNightlyRunStatusTrigger {


  @isTest
  private static void testHandleAfterInsert() {  

    Test.startTest();

        Nightly_Run_Status__c status1 = new Nightly_Run_Status__c(Status__c = 'disable rollups');
        insert status1;
        Nightly_Run_Status__c status2 = new Nightly_Run_Status__c(Status__c = 'enable rollups');
        insert status2;
        Nightly_Run_Status__c status3 = new Nightly_Run_Status__c(Status__c = 'security deletions');
        insert status3;
        Nightly_Run_Status__c status4 = new Nightly_Run_Status__c(Status__c = 'security creations');
        insert status4;
        Nightly_Run_Status__c status5 = new Nightly_Run_Status__c(Status__c = 'data load starting');
        insert status5;
        Nightly_Run_Status__c status6 = new Nightly_Run_Status__c(Status__c = 'data load finished');
        insert status6;

    Test.stopTest();
  }

}