/**
 * Created by Eric Stansbury on 5/31/2019.
 */

public class Assistant_AssignmentTriggerHandler {
    public static void handleAfterInsert(List<Assistant_Assignment__c> assistantAssignments){
        Set<Id> assisteeIds = new Set<Id>();
        for (Assistant_Assignment__c assistantAssignment : assistantAssignments){
            assisteeIds.add(assistantAssignment.Assistee__c);
        }
        // get GroupMemberships for these assistees
        Map<Id,List<GroupMember>> groupMembersByUser = getGroupMembersByUser(assisteeIds);

        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        for (Assistant_Assignment__c assistantAssignment : assistantAssignments){
            // get group members for the assistee user
            List<GroupMember> groupMembers = groupMembersByUser.get(assistantAssignment.Assistee__c);

            // assign same memberships to the assistant
            for (GroupMember groupMember : groupMembers){
                groupMembersToInsert.add(
                    new GroupMember(
                        UserOrGroupId = assistantAssignment.Assistant__c,
                        GroupId = groupMember.GroupId
                    )
                );
            }
        }

        insert groupMembersToInsert;
    }

    public static void handleAfterDelete(List<Assistant_Assignment__c> assistantAssignments){
        Set<Id> userIds = new Set<Id>();
        Set<Id> assistantIds = new Set<Id>();
        for (Assistant_Assignment__c assignment : assistantAssignments){
            userIds.add(assignment.Assistant__c);
            userIds.add(assignment.Assistee__c);
            assistantIds.add(assignment.Assistant__c);
        }

        Map<Id, Set<Id>> repsByUser = SecurityAssignmentHelper.getRepIdsByUser(userIds, null, new Map<Id, SObject>(assistantAssignments).keySet());

        Map<String, List<GroupMember>> memberMap = new Map<String, List<GroupMember>>();
        List<GroupMember> members = [Select Id, UserOrGroupId, GroupId, Group.Name from GroupMember where UserOrGroupId in :userIds];
        for (GroupMember member : members){
            if (memberMap.get(member.UserOrGroupId) == null){
                memberMap.put(member.UserOrGroupId, new List<GroupMember>{ member });
            }else{
                memberMap.get(member.UserOrGroupId).add(member);
            }
        }

        List<GroupMember> groupMembersToDelete = new List<GroupMember>();
        for (Assistant_Assignment__c assistantAssignment : assistantAssignments){
            // get reps belonging to this assistee
            Set<Id> repsForThisAssistee = repsByUser.get(assistantAssignment.Assistee__c);
            System.debug('Assistant_AssignmentTriggerHandler handleAfterDelete() Assistee ' + assistantAssignment.Assistee__c + ' has ' + (repsForThisAssistee == null? 0 : repsForThisAssistee.size()) + ' reps');

            // get reps which the assistant should still be able to access
            Set<Id> repsForThisAssistant = repsByUser.get(assistantAssignment.Assistant__c);
            System.debug('Assistant_AssignmentTriggerHandler handleAfterDelete() Assistant ' + assistantAssignment.Assistant__c + ' has ' + (repsForThisAssistant == null? 0 : repsForThisAssistant.size()) + ' reps');

            // delete rep group memberships in the first group but not in the second group
            List<GroupMember> myGroupMembers = memberMap.get(assistantAssignment.Assistant__c);
            System.debug(myGroupMembers);

            if (myGroupMembers != null && repsForThisAssistee != null){
                for (GroupMember gm : myGroupMembers){
                    Id repId = gm.Group.Name;

                    if (repsForThisAssistee.contains(repId) && (repsForThisAssistant == null || !repsForThisAssistant.contains(repId))){
                        groupMembersToDelete.add(gm);
                    }
                }
            }
        }

        System.debug('Assistant_AssignmentTriggerHandler handleAfterDelete() deleting ' + groupMembersToDelete.size() + ' group memberships');
        delete groupMembersToDelete;
    }

    static Map<Id, List<GroupMember>> getGroupMembersByUser(Set<Id> userIds){
        Map<Id, List<GroupMember>> groupMembersByUser = new Map<Id, List<GroupMember>>();
        for (Id userId : userIds){
            groupMembersByUser.put(userId, new List<GroupMember>());
        }

        List<GroupMember> groupMembers = [Select Id, UserOrGroupId, GroupId from GroupMember where UserOrGroupId in :userIds];
        for (GroupMember groupMember : groupMembers){
            groupMembersByUser.get(groupMember.UserOrGroupId).add(groupMember);
        }
        return groupMembersByUser;
    }
}