/**
 * Created by Eric Stansbury on 5/16/2019.
 */

public class Rep_SecurityTriggerHandler {
    public static void handleAfterInsert(List<Rep_Security__c> newRecords){
        Set<String> davenportUsernames = new Set<String>();
        Set<String> repNumbers = new Set<String>();
        List<String> keys = new List<String>();      //concatenation of rep number, username, and type

        for (Rep_Security__c record : newRecords){
            davenportUsernames.add(record.Davenport_Username__c);
            repNumbers.add(record.Rep_Number__c);
            keys.add(getKey(record));
        }


        Map<String, Id> repNumbersMap = getRepNumbersMap(repNumbers); // map of rep numbers to rep Ids
        List<String> existingKeys = getExistingKeys(keys); // keys that already exist in Rep_Assignment__c

		// get user objects for the inserted Rep Security objects based on the user name
        List<User> users = [Select Id, Davenport_Username__c from User where Davenport_Username__c in :davenportUsernames];

		// build a map from username to user ID
        Map<String, Id> usernameMap = new Map<String, Id>();
        for (User user : users){
            if (String.isNotBlank(user.Davenport_Username__c)){
                usernameMap.put(user.Davenport_Username__c, user.Id);
            }
        }

		// a map from user Id to a list of rep numbers based on existing rep assignments
        Map<Id, Set<String>> mapUserIdToRepNumbers = getMapUserIdToRepNumbers(users);

        List<Rep_Assignment__c> repAssignmentsToInsert = new List<Rep_Assignment__c>();
        for (Rep_Security__c record : newRecords){

            Id userId = usernameMap.get(record.Davenport_Username__c);
            Id repId = repNumbersMap.get(record.Rep_Number__c);
            String key = getKey(record);

            if (userId == null){
				// TODO: log this error instead of throwing an exception. An exception prevents processing the rest of the records
                throw new SecurityAssignmentException('Rep Security ' + record.ID + ' error: No User ID found for Davenport Username ' + record.Davenport_Username__c);
            
            }else if (repId == null) {
                throw new SecurityAssignmentException('Rep Security ' + record.ID + ' error: No rep record found for rep number ' + record.Rep_Number__c);
            
            }else if (!existingKeys.contains(key)){
            
			    Set<String> repNumbersForUser = mapUserIdToRepNumbers.get(userId);
                if (repNumbersForUser == null || !repNumbersForUser.contains(record.Rep_Number__c)){  //TODO: remove check for repNumber, which prevents insert for Rep and UPI rows for same user / rep number
                    repAssignmentsToInsert.add(
                            new Rep_Assignment__c(User__c = userId, Rep__c = repId, Type__c = record.Type__c)
                    );
                }
            }
        }

        System.debug('Rep_SecurityTriggerHandler handleAfterInsert() creating ' + repAssignmentsToInsert.size() + ' rep assignment records' );
        insert repAssignmentsToInsert;
    }

    //public static void handleAfterUpdate(List<Rep_Security__c> oldRecords, List<Rep_Security__c> newRecords){
        //handleAfterDelete(oldRecords);
        //handleAfterInsert(newRecords);
    //}

    //public static void handleAfterDelete(List<Rep_Security__c> deletedRecords){
        //Set<String> davenportUsernames = new Set<String>();
        //Set<String> repNumbers = new Set<String>();

        //for (Rep_Security__c record : deletedRecords) {
            //davenportUsernames.add(record.Davenport_Username__c);
            //repNumbers.add(record.Rep_Number__c);
        //}
        //Map<String, Id> repNumbersMap = getRepNumbersMap(repNumbers);

        //List<User> users = [Select Id, Davenport_Username__c from User where Davenport_Username__c in :davenportUsernames];
        //Map<String, Id> usernameMap = new Map<String, Id>();
        //Map<Id, Set<Rep_Assignment__c>> getRepAssignmentRecordsMap = getRepAssignmentRecordsMap(users);
        //for (User user : users) {
            //if (String.isNotBlank(user.Davenport_Username__c)) {
                //usernameMap.put(user.Davenport_Username__c, user.Id);
            //}
        //}

        //List<Rep_Assignment__c> repAssignmentsToDelete = new List<Rep_Assignment__c>();
        //Set<Id> repAssignmentIdsToDelete = new Set<Id>();
        //for (Rep_Security__c record : deletedRecords) {
            //Id userId = usernameMap.get(record.Davenport_Username__c);
            //Id repId = repNumbersMap.get(record.Rep_Number__c);
            //if (userId == null || repId == null) {
                //System.debug('UserId or RepId is null on rep security ' + record.Id + ' but since it\'s being deleted anyway, don\'t throw an error');
            //} else {
                //Set<Rep_Assignment__c> usersRepAssignments = getRepAssignmentRecordsMap.get(userId);
                //System.debug('Rep_SecurityTriggerHandler handleAfterDelete() usersRepAssigments has size ' + (usersRepAssignments == null ? 0 : usersRepAssignments.size()));
                //if (usersRepAssignments != null) {
                    //for (Rep_Assignment__c repAssignment : usersRepAssignments) {
                        //if (repAssignment.Rep__r.Rep_Number__c == record.Rep_Number__c && !repAssignmentIdsToDelete.contains(repAssignment.Id)) { // don't try to delete the same record twice
                            //repAssignmentIdsToDelete.add(repAssignment.Id);
                            //repAssignmentsToDelete.add(repAssignment);
                        //}
                    //}
                //}
            //}
        //}

        //System.debug('Rep_SecurityTriggerHandler handleAfterDelete() deleting ' + repAssignmentsToDelete.size() + ' rep assignment records');
        //delete repAssignmentsToDelete;
    //}

	// return a map from user Id to a list of rep numbers based on existing rep assignments
    static Map<Id,Set<String>> getMapUserIdToRepNumbers(List<User> users){
        List<Rep_Assignment__c> repAssignments = [Select Id, Rep__c, Rep__r.Rep_Number__c, User__c from Rep_Assignment__c where User__c in :users];
        Map<Id, Set<String>> mapUserIdToRepNumbers = new Map<Id, Set<String>>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            if (mapUserIdToRepNumbers.get(repAssignment.User__c) == null){
                mapUserIdToRepNumbers.put(repAssignment.User__c, new Set<String>{ repAssignment.Rep__r.Rep_Number__c });
            }else{
                mapUserIdToRepNumbers.get(repAssignment.User__c).add(repAssignment.Rep__r.Rep_Number__c);
            }
        }
        return mapUserIdToRepNumbers;
    }

    //static Map<Id,Set<Rep_Assignment__c>> getRepAssignmentRecordsMap(List<User> users){
        //List<Rep_Assignment__c> repAssignments = [Select Id, Rep__c, Rep__r.Rep_Number__c, User__c from Rep_Assignment__c where User__c in :users];
        //Map<Id, Set<Rep_Assignment__c>> repAssignmentsMap = new Map<Id, Set<Rep_Assignment__c>>();
        //for (Rep_Assignment__c repAssignment : repAssignments){
            //if (repAssignmentsMap.get(repAssignment.User__c) == null){
                //repAssignmentsMap.put(repAssignment.User__c, new Set<Rep_Assignment__c>{ repAssignment });
            //}else{
                //repAssignmentsMap.get(repAssignment.User__c).add(repAssignment);
            //}
        //}
        //return repAssignmentsMap;
    //}

	// returns a map of rep numbers to rep Ids
    static Map<String,Id> getRepNumbersMap(Set<String> repNumbers){
        List<Rep__c> reps = [Select ID, Rep_Number__c from Rep__c where Rep_Number__c in :repNumbers];
        Map<String, Id> result = new Map<String, Id>();
        for (Rep__c rep : reps){
            result.put(rep.Rep_Number__c, rep.Id);
        }
        return result;
    }

    static String getKey(Rep_Security__c repSecurity){
        return '' + repSecurity.Davenport_Username__c + repSecurity.Rep_Number__c + repSecurity.Type__c;
    }

	// returns a subset of the keys parameter where the keys already exist in the Rep_Assignment__c objec
    static List<String> getExistingKeys(List<String> keys){
        List<Rep_Assignment__c> repAssignments = [Select Rep_Assignment_Key__c from Rep_Assignment__c where Rep_Assignment_Key__c in :keys];
        List<String> existingKeys = new List<String>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            existingKeys.add(repAssignment.Rep_Assignment_Key__c);
        }
        return existingKeys;
    }
}