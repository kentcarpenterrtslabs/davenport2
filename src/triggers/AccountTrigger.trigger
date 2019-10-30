trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete)  {
	if (Trigger.isBefore) {

		if (Trigger.isInsert) {
			AccountTriggerHandler handler = new AccountTriggerHandler();
			handler.beforeInsert(Trigger.new);
		}
	
		if (Trigger.isUpdate) {
			AccountTriggerHandler handler = new AccountTriggerHandler();
			handler.beforeUpdate(Trigger.oldMap,Trigger.newMap);
		}
	}

	if (Trigger.isAfter) {

		if (Trigger.isInsert) {
			AccountTriggerHandler handler = new AccountTriggerHandler();
			handler.afterInsert(Trigger.newMap);
		}
	
		if (Trigger.isUpdate) {
			AccountTriggerHandler handler = new AccountTriggerHandler();
			handler.afterUpdate(Trigger.oldMap,Trigger.newMap);
		}
	}
}