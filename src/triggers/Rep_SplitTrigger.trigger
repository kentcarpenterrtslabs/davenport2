trigger Rep_SplitTrigger on Rep_Split__c (after insert, after update, after delete) {
    if (SecurityAssignmentConfig.repSplitTriggersEnabled){
        if (Trigger.isInsert){
            Rep_SplitTriggerHandler.handleAfterInsert(Trigger.new);
        }else if (Trigger.isUpdate){
            throw new SecurityAssignmentException('Update not allowed to Rep Split object.');
        }else if (Trigger.isDelete){
            Rep_SplitTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}