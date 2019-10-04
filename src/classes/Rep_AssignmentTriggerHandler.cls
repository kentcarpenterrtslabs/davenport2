/**
 * Created by Eric Stansbury on 5/16/2019.
 */

public with sharing class Rep_AssignmentTriggerHandler {
    public static void handleAfterInsert(List<Rep_Assignment__c> repAssignments){
        Set<Id> repIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            repIds.add(repAssignment.Rep__c);
            userIds.add(repAssignment.User__c);
        }

        System.debug('Rep_AssignmentTrigger Handler handleAfterInsert() on ' + repAssignments.size() + ' rep assignments with ' + repIds.size() +' rep IDs and ' + userIds.size() + ' user IDs');

        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        Map<Id, Set<Id>> userAssistantMap = SecurityAssignmentHelper.getUserAssistantMap(userIds);
        Map<Id, Id> repGroupsMap = SecurityAssignmentHelper.getRepGroups(repIds);

        for (Rep_Assignment__c repAssignment : repAssignments) {
            Id repId = repAssignment.Rep__c;
            Id userId = repAssignment.User__c;
            Id groupId = repGroupsMap.get(repId);

            groupMembersToInsert.add(
                new GroupMember(
                        GroupId = groupId,
                        UserOrGroupId = userId
                )
            );

            Set<Id> assistantIds = userAssistantMap.get(userId);
            if (assistantIds != null){
                for (Id assistantId : assistantIds) {
                    groupMembersToInsert.add(
                        new GroupMember(
                            GroupId = groupId,
                            UserOrGroupId = assistantId
                        )
                    );
                }
            }
        }

        System.debug('Rep_AssignmentTriggerHandler handleAfterInsert() inserting ' + groupMembersToInsert.size() + ' group memberships');
        try{
            insert groupMembersToInsert;
        }catch(DMLException e){
            // MIXED_DML_ERROR will occur here if this is being called from a trigger, so pass it to a queueable and insert asynchronously
            System.enqueueJob(new SObjectInsertQueueable(groupMembersToInsert));
        }
    }

    //public static void handleAfterDelete(List<Rep_Assignment__c> repAssignments){
    //    Set<Id> repIds = new Set<Id>();
    //    Set<Id> userIds = new Set<Id>();
    //    List<String> groupNames = new List<String>();
    //    for (Rep_Assignment__c assignment : repAssignments){
    //        repIds.add(assignment.Rep__c);
    //        groupNames.add('Rep-' + assignment.Rep__c);
    //        userIds.add(assignment.User__c);
    //    }
	//
    //    Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(repIds);
	//
    //    Map<Id, GroupMember> membersToDelete = new Map<Id,GroupMember>();
    //    List<GroupMember> members = [Select Id, UserOrGroupId, GroupId from GroupMember where Group.Name in :groupNames];
    //    Map<String, GroupMember> memberMap = new Map<String, GroupMember>();
    //    for (GroupMember member : members){
    //        String key = '' + member.UserOrGroupId + member.GroupId;
    //        memberMap.put(key, member);
    //    }
	//
    //    for (Rep_Assignment__c repAssignment : repAssignments){
    //        Id repGroupId = repGroups.get(repAssignment.Rep__c);
    //        String key = '' + repAssignment.User__c + repGroupId;
    //        GroupMember gm = memberMap.get(key);
    //        if (gm != null && !membersToDelete.keySet().contains(gm.Id)){
    //            membersToDelete.put(gm.Id, gm);
    //        }
    //    }
	//
    //    System.debug('Rep_AssignmentTriggerHandler handleAfterDelete deleting ' + membersToDelete.values().size() + ' group memberships');
    //    delete membersToDelete.values();
    //}


    //@AuraEnabled(cacheable=true)
    //public static List<Account> getHouseholds(List<String> repNumbers){
    //    return [
    //        Select Id from Account
    //        where Id in
    //            (Select FinServ__Household__c FROM FinServ__FinancialAccount__c
    //             where Rep__r.Rep_Number__c in :repNumbers)
    //    ];
    //}
}