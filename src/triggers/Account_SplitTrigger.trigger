trigger Account_SplitTrigger on Account_Split__c (after insert, after update, after delete) {
    if (SecurityAssignmentConfig.accountSplitTriggersEnabled) {
        if (Trigger.isInsert) {
            Account_SplitTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            throw new SecurityAssignmentException('Update not allowed to Account Split object.');
        } else if (Trigger.isDelete) {
            Account_SplitTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}