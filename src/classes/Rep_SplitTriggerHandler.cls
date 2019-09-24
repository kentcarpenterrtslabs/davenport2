/**
 * Created by Eric Stansbury on 5/16/2019.
 */

public class Rep_SplitTriggerHandler {
    public static void handleAfterInsert(List<Rep_Split__c> repSplits){
        Set<Id> repIds= new Set<Id>();
        for (Rep_Split__c repSplit : repSplits){
            repIds.add(repSplit.Split_Rep__c);
            repIds.add(repSplit.Grant_Access_To_Rep__c);
        }
        Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(repIds);

        List<GroupMember> groupMembers = new List<GroupMember>();
        for (Rep_Split__c repSplit : repSplits){
            Id splitRepGroupId = repGroups.get(repSplit.Split_Rep__c);
            Id grantAccessToRepGroupId = repGroups.get(repSplit.Grant_Access_to_Rep__c);

            groupMembers.add(
                new GroupMember(
                    GroupId = splitRepGroupId,
                    UserOrGroupId = grantAccessToRepGroupId
                )
            );
        }
        System.enqueueJob(new SObjectInsertQueueable(groupMembers));
    }

    public static void handleAfterDelete(List<Rep_Split__c> repSplits){
        Set<Id> splitRepIds = new Set<Id>();
        List<String> groupNames = new List<String>();
        Set<Id> grantAccessToRepIds = new Set<Id>();
        for (Rep_Split__c repSplit : repSplits){
            splitRepIds.add(repSplit.Split_Rep__c);
            groupNames.add('Rep-' + repSplit.Split_Rep__c);
            grantAccessToRepIds.add(repSplit.Grant_Access_To_Rep__c);
        }

        Set<Id> allRepIds = new Set<Id>(splitRepIds);
        allRepIds.addAll(grantAccessToRepIds);
        Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(allRepIds);

        List<GroupMember> membersToDelete = new List<GroupMember>();
        List<GroupMember> members = [Select Id, UserOrGroupId, GroupId from GroupMember where Group.Name in :groupNames];
        Map<String, GroupMember> memberMap = new Map<String, GroupMember>();
        for (GroupMember member : members){
            String key = '' + member.UserOrGroupId + member.GroupId;
            memberMap.put(key, member);
        }

        for (Rep_Split__c repSplit : repSplits){
            Id splitRepGroupId = repGroups.get(repSplit.Split_Rep__c);
            Id grantAccessToRepGroupId = repGroups.get(repSplit.Grant_Access_To_Rep__c);
            String key = '' + grantAccessToRepGroupId + splitRepGroupId;
            GroupMember gm = memberMap.get(key);
            if (gm != null) {
                membersToDelete.add(gm);
            }
        }

        System.debug('Rep_SplitTriggerHandler handleAfterDelete deleting ' + membersToDelete.size() + ' group memberships');
        System.enqueueJob(new SObjectDeleteQueueable(membersToDelete));
    }
}