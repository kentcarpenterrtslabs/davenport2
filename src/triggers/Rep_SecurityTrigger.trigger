trigger Rep_SecurityTrigger on Rep_Security__c (after insert, after delete, after update) {
    if (SecurityAssignmentConfig.repSecurityTriggersEnabled) {
        if (Trigger.isInsert) {
            Rep_SecurityTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            Rep_SecurityTriggerHandler.handleAfterUpdate(Trigger.old, Trigger.new);
        } else if (Trigger.isDelete) {
            Rep_SecurityTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}