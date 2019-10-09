trigger NightlyRunStatusTrigger on Nightly_Run_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
	if (Trigger.isAfter && Trigger.isInsert) {
		NightlyRunStatusTriggerHander handler = new NightlyRunStatusTriggerHander();
		handler.handleAfterInsert(Trigger.new);
	}
}