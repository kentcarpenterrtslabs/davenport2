/*
    This is the controller for a Lightning component which allows a Branch Manager user to manually toggle their UPI assignments on and off

    Rep Security records come in as either 'Rep' type or 'UPI' type. UPI assignments include visibility for branch managers and so on, whereas Rep assignments
        are "book of business" assignments -- i.e., the rep numbers you actually work on day to day. Users need the ability to toggle between "Firm Wide Access"
        (UPI assignments + rep assignments) and "Rep Access" (rep assignments only). On the backend, switching to "Rep Access" will remove the user's access to records
        which they can only see because of a UPI assignment. Switching back to "Firm Wide Access" will grant their access back to the reps via the UPI records.
 */
public without sharing class UPIAccessToggleController {
    @AuraEnabled public static boolean isFirmwideAccessEnabled(){
        User myUser = [
			Select
				Firm_Wide_Access_Enabled__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			LIMIT 1
		];
        return myUser.Firm_Wide_Access_Enabled__c;
    }

    @AuraEnabled public static void enableUPIAccess(){
		Id userId = UserInfo.getUserId();

		User currentUser = [
			SELECT
				Davenport_Username__c,
				UPI_GroupId__c,
				(
					SELECT
						Assistant__c
					FROM Assistants__r
				)
			FROM User
			WHERE Id = :userId
		];

		if (null != currentUser.UPI_GroupId__c) {
			List<GroupMember> groupMembers = new List<GroupMember>();

			groupMembers.add(new GroupMember(
				GroupId = currentUser.UPI_GroupId__c,
				UserOrGroupId = currentUser.Id));

			for (Assistant_Assignment__c assistant : currentUser.Assistants__r) {
				groupMembers.add(new GroupMember(
					GroupId = currentUser.UPI_GroupId__c,
					UserOrGroupId = assistant.Assistant__c
				));
			}
			insert groupMembers;
		}

		currentUser.Firm_Wide_Access_Enabled__c = true;
		update currentUser;
    }

    @AuraEnabled public static void disableUPIAccess(){
		Id userId = UserInfo.getUserId();

		User currentUser = [
			SELECT
				UPI_GroupId__c
			FROM User
			WHERE Id = :userId
		];

		if (null != currentUser.UPI_GroupId__c) {
			List<GroupMember> groupMembers = [
				SELECT
					Id
				FROM GroupMember
				WHERE GroupId = :currentUser.UPI_GroupId__c
			];

			delete groupMembers;
		}

		currentUser.Firm_Wide_Access_Enabled__c = false;
		update currentUser;
    }
}