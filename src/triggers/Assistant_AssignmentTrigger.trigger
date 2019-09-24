trigger Assistant_AssignmentTrigger on Assistant_Assignment__c (after insert, after update, after delete) {
    if (SecurityAssignmentConfig.assistantAssignmentTriggersEnabled) {
        if (Trigger.isInsert) {
            Assistant_AssignmentTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            throw new SecurityAssignmentException('Update not allowed to Assistant Assignment object.');
        } else if (Trigger.isDelete) {
            Assistant_AssignmentTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}