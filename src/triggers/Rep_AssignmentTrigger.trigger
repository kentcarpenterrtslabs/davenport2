trigger Rep_AssignmentTrigger on Rep_Assignment__c (after insert, after delete, after update) {
    if (SecurityAssignmentConfig.repAssignmentTriggersEnabled) {
        if (Trigger.isInsert) {
            Rep_AssignmentTriggerHandler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            for (Id recordId : Trigger.newMap.keySet()) {
                if (Trigger.newMap.get(recordId).Rep__c != Trigger.oldMap.get(recordId).Rep__c
                        || Trigger.newMap.get(recordId).User__c != Trigger.oldMap.get(recordId).User__c
                        || Trigger.newMap.get(recordId).Type__c != Trigger.oldMap.get(recordId).Type__c) {
                    throw new SecurityAssignmentException('Update not allowed to Rep Assignment object except to set active/inactive flag.');
                }
            }
        } else if (Trigger.isDelete) {
            Rep_AssignmentTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}