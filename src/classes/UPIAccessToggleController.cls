/**
 * Created by Eric Stansbury on 7/18/2019.
 */
/*
    This is the controller for a Lightning component which allows a Branch Manager user to manually toggle their UPI assignments on and off

    Rep Security records come in as either 'Rep' type or 'UPI' type. UPI assignments include visibility for branch managers and so on, whereas Rep assignments
        are "book of business" assignments -- i.e., the rep numbers you actually work on day to day. Users need the ability to toggle between "Firm Wide Access"
        (UPI assignments + rep assignments) and "Rep Access" (rep assignments only). On the backend, switching to "Rep Access" will remove the user's access to records
        which they can only see because of a UPI assignment. Switching back to "Firm Wide Access" will grant their access back to the reps via the UPI records.
 */
public without sharing class UPIAccessToggleController {
    @AuraEnabled public static boolean isFirmwideAccessEnabled(){
        User myUser = [Select Firm_Wide_Access_Enabled__c from User where Id = :UserInfo.getUserId() limit 1];
        return myUser.Firm_Wide_Access_Enabled__c;
    }

    @AuraEnabled public static void enableUPIAccess(){
        Id userId = UserInfo.getUserId();

        List<Rep_Assignment__c> repAssignments = [Select Id, Rep__c, Type__c from Rep_Assignment__c where User__c = :userId];
        Set<Id> repRepIds = new Set<Id>();
        Set<Id> upiRepIds = new Set<Id>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            if (repAssignment.Type__c == 'Rep'){
                repRepIds.add(repAssignment.Rep__c);
            }else if (repAssignment.Type__c == 'UPI'){
                upiRepIds.add(repAssignment.Rep__c);
                repAssignment.Active__c = true;
            }
        }

        Set<Id> grantAccessToIds = new Set<Id>();
        List<String> groupNames = new List<String>();
        for (Id upiRepId : upiRepIds){
            // don't need to include ids from repRepIds because those didn't get removed by disableUPIAccess()
            if (!repRepIds.contains(upiRepId)){
                grantAccessToIds.add(upiRepId);
                groupNames.add('Rep-' + upiRepId);
            }
        }

        Set<Id> grantAccessToGroupIds = new Map<Id, Group>([Select Id from Group where Name in :groupNames]).keySet();
        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        for (Id grantAccessToGroupId : grantAccessToGroupIds){
            groupMembersToInsert.add(
                new GroupMember(
                    GroupId = grantAccessToGroupId,
                    UserOrGroupId = userId
                )
            );
        }

        System.debug('UPIAccessToggleController() inserting ' + groupMembersToInsert.size() + ' group memberships');
        insert groupMembersToInsert;

        User myUser = [Select Id, Firm_Wide_Access_Enabled__c from User where Id = :UserInfo.getUserId() limit 1];
        myUser.Firm_Wide_Access_Enabled__c = true;
        List<SObject> sObjectsToUpdate = new List<SObject>();
        sObjectsToUpdate.addAll(repAssignments);
        sObjectsToUpdate.add(myUser);
        System.enqueueJob(new SObjectUpdateQueueable(sObjectsToUpdate));
    }

    @AuraEnabled public static void disableUPIAccess(){
        Id userId = UserInfo.getUserId();

        List<Rep_Assignment__c> repAssignments = [Select Id, Rep__c, Type__c from Rep_Assignment__c where User__c = :userId];
        Set<Id> repRepIds = new Set<Id>();
        Set<Id> upiRepIds = new Set<Id>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            if (repAssignment.Type__c == 'Rep'){
                repRepIds.add(repAssignment.Rep__c);
            }else if (repAssignment.Type__c == 'UPI'){
                upiRepIds.add(repAssignment.Rep__c);
                repAssignment.Active__c = false;
            }
        }

        Set<Id> removeAccessToIds = new Set<Id>();
        List<String> groupNames = new List<String>();
        for (Id upiRepId : upiRepIds){
            if (!repRepIds.contains(upiRepId)){
                removeAccessToIds.add(upiRepId);
                groupNames.add('Rep-' + upiRepId);
            }
        }

        List<GroupMember> groupMembersToDelete = [Select Id from GroupMember where Group.Name in :groupNames and UserOrGroupId = :userId];
        System.debug('UPIAccessToggleController() deleting ' + groupMembersToDelete.size() + ' group memberships');
        delete groupMembersToDelete;

        User myUser = [Select Id, Firm_Wide_Access_Enabled__c from User where Id = :UserInfo.getUserId() limit 1];
        myUser.Firm_Wide_Access_Enabled__c = false;
        List<SObject> sObjectsToUpdate = new List<SObject>();
        sObjectsToUpdate.addAll(repAssignments);
        sObjectsToUpdate.add(myUser);
        System.enqueueJob(new SObjectUpdateQueueable(sObjectsToUpdate));
    }
}