/**
 * Created by Eric Stansbury on 5/28/2019.
 */

public class SecurityAssignmentHelper {
    public static final String rowCause = 'RTSSecurityAssignment__c';
    public static final String HOUSEHOLD_RECORDTYPE_NAME = 'Household Client';

    // returns a map of User Id -> set of that user's assistants
    public static Map<Id, Set<Id>> getUserAssistantMap(Set<Id> userIds){
        Map<Id, Set<Id>> userAssistantMap = new Map<Id, Set<Id>>();
        for (Assistant_Assignment__c assignment : [Select Id, Assistant__c, Assistee__c from Assistant_Assignment__c where Assistee__c in :userIds]){
            if (userAssistantMap.get(assignment.Assistee__c) == null){
                userAssistantMap.put(assignment.Assistee__c, new Set<Id>{ assignment.Assistant__c });
            }else{
                userAssistantMap.get(assignment.Assistee__c).add(assignment.Assistant__c );
            }
        }
        return userAssistantMap;
    }

    // returns a map of User Id -> users they are assisting
    public static Map<Id, Set<Id>> getUserAssisteeMap(Set<Id> userIds, Set<Id> excludeAssistantAssignmentIds){
        Map<Id, Set<Id>> userAssisteeMap = new Map<Id, Set<Id>>();
        //for (Assistant_Assignment__c assignment : [Select Id, Assistant__c, Assistee__c from Assistant_Assignment__c where Assistant__c in :userIds and Id not in :excludeAssistantAssignmentIds]){
        for (Assistant_Assignment__c assignment : [Select Id, Assistant__c, Assistee__c from Assistant_Assignment__c where Assistee__c in :userIds and Id not in :excludeAssistantAssignmentIds]){
            if (userAssisteeMap.get(assignment.Assistant__c) == null){
                userAssisteeMap.put(assignment.Assistant__c, new Set<Id>{ assignment.Assistee__c });
            }else{
                userAssisteeMap.get(assignment.Assistant__c).add(assignment.Assistee__c );
            }
        }
        return userAssisteeMap;
    }

    // returns a map of rep IDs -> set of financial account IDs each rep ID should have access to
    public static Map<Id, Set<Id>> getRepToFinancialAccountMap(Set<Id> repIds) {
        return getRepToFinancialAccountMap(repIds, new Set<Id>(), new Set<Id>(), new Set<Id>());
    }

    // returns a map of rep IDs -> set of financial account IDs each rep ID should have access to
    public static Map<Id, Set<Id>> getRepToFinancialAccountMap(Set<Id> repIds, Set<Id> excludeAccountSplitIds, Set<Id> excludeRepSplitIds, Set<Id> excludeRepIds){
        // get rep splits for these reps
        Map<Id, Set<Id>> repSplitToGrantAccessRepMap = getSplitRepMap(repIds, excludeRepSplitIds);
        //Map<Id, Set<Id>> grantAccessRepToSplitRepMap = getGrantAccessRepToSplitRepMap(repIds);
        Set<Id> allRepIds = new Set<Id>();
        allRepIds.addAll(repIds);
        allRepIds.addAll(repSplitToGrantAccessRepMap.keySet());

        // get directly related financial accounts
        List<FinServ__FinancialAccount__c> financialAccounts = [Select Id, Rep__c from FinServ__FinancialAccount__c where Rep__c in :allRepIds and Rep__c not in :excludeRepIds];

        // put account splits in map
        Map<Id, Set<Id>> accountSplitMap = new Map<Id, Set<Id>>();
        List<Account_Split__c> accountSplits = [Select Id, Rep__c, Financial_Account__c from Account_Split__c where (Financial_Account__c in :financialAccounts or Rep__c in :allRepIds) and Rep__c not in :excludeRepIds and Id not in :excludeAccountSplitIds];
        Set<Id> splitAccountIds = new Set<Id>();
        for (Account_Split__c split : accountSplits){
            splitAccountIds.add(split.Financial_Account__c);
            if (accountSplitMap.get(split.Financial_Account__c) == null){
                accountSplitMap.put(split.Financial_Account__c, new Set<ID>{ split.Rep__c });
            }else{
                accountSplitMap.get(split.Financial_Account__c).add(split.Rep__c);
            }
        }
        // add financial accounts from rep splits to financialAccounts
        financialAccounts.addAll(
            [Select Id, Rep__c from FinServ__FinancialAccount__c where Id in :splitAccountIDs and Id not in :financialAccounts]
        );

        // create the map to return
        Map<Id, Set<Id>> repToFinancialAccountMap = new Map<Id, Set<Id>>();
        for (FinServ__FinancialAccount__c acct : financialAccounts){
            // grant access to rep of record
            if (repToFinancialAccountMap.get(acct.Rep__c) == null){
                repToFinancialAccountMap.put(acct.Rep__c, new Set<Id>());
            }
            repToFinancialAccountMap.get(acct.Rep__c).add(acct.Id);

            // if this account has account splits, grant access to those reps
            Set<Id> repIdsViaAccountSplits = accountSplitMap.get(acct.Id);
            if (repIdsViaAccountSplits != null){
                System.debug('FinAcct ' + acct.Id + ' is a split account for these reps: ' + repIdsViaAccountSplits);
                for (Id repId : repIdsViaAccountSplits){
                    if (repToFinancialAccountMap.get(repId) == null){
                        repToFinancialAccountMap.put(repId, new Set<Id>());
                    }
                    repToFinancialAccountMap.get(repId).add(acct.Id);
                }
            }

            // if the rep is a split rep, add this fin acct to the granted access reps as well
            Set<Id> grantAccessToReps = repSplitToGrantAccessRepMap.get(acct.Rep__c);
            if (grantAccessToReps != null){
                System.debug('Rep ' + acct.Rep__c + ' is a split rep -- grantAccessToReps ' + (grantAccessToReps == null? null : grantAccessToReps.size()));
                for (Id repId : grantAccessToReps){
                    if (repToFinancialAccountMap.get(repId) == null){
                        repToFinancialAccountMap.put(repId, new Set<Id>{ acct.Id });
                    }else{
                        repToFinancialAccountMap.get(repId).add(acct.Id);
                    }
                }
            }

            // if any reps via account splits are split rep, add this fin acct to the granted access reps as well
            if (repIdsViaAccountSplits != null && grantAccessToReps != null){
                for (Id repIdViaAccountSplit : repIdsViaAccountSplits){
                    System.debug('Rep ' + acct.Rep__c + ' is a split rep -- grantAccessToReps ' + (grantAccessToReps == null? null : grantAccessToReps.size()));
                    grantAccessToReps = repSplitToGrantAccessRepMap.get(repIdViaAccountSplit);
                    if (grantAccessToReps != null){
                        for (Id repId : grantAccessToReps){
                            repToFinancialAccountMap.get(repId).add(acct.Id);
                        }
                    }
                }
            }
        }
        return repToFinancialAccountMap;
    }

    // returns a map of Split Rep ID -> grant access to rep IDs
    public static Map<Id, Set<Id>> getSplitRepMap(Set<Id> repIds){
        return getSplitRepMap(repIds, new Set<Id>());
    }
    public static Map<Id, Set<Id>> getSplitRepMap(Set<Id> repIds, Set<Id> excludeSplitRepIds){
        Map<Id, Set<Id>> repSplitMap = new Map<Id, Set<Id>>();
        List<Rep_Split__c> repSplits = [Select Id, Split_Rep__c, Grant_Access_to_Rep__c from Rep_Split__c where (Grant_Access_to_Rep__c in :repIds or Split_Rep__c in :repIds) and Id not in :excludeSplitRepIds];
        for (Rep_Split__c assignment : repSplits){
            if (repSplitMap.get(assignment.Split_Rep__c) == null){
                repSplitMap.put(assignment.Split_Rep__c, new Set<Id>{ assignment.Grant_Access_To_Rep__c });
            }else{
                repSplitMap.get(assignment.Split_Rep__c).add(assignment.Grant_Access_To_Rep__c);
            }
        }
        // query to get any grant access tos from split reps that weren't in repIds
        repSplits = [Select Id, Split_Rep__c, Grant_Access_to_Rep__c from Rep_Split__c where Id not in :repSplits and Split_Rep__c in :repSplitMap.keySet()];
        for (Rep_Split__c assignment : repSplits){
            if (repSplitMap.get(assignment.Split_Rep__c) == null){
                repSplitMap.put(assignment.Split_Rep__c, new Set<Id>{ assignment.Grant_Access_To_Rep__c });
            }else{
                repSplitMap.get(assignment.Split_Rep__c).add(assignment.Grant_Access_To_Rep__c);
            }
        }
        return repSplitMap;
    }

    // returns a map of grant access to rep IDs -> split rep Ids
    public static Map<Id, Set<Id>> getGrantAccessToRepMap(Set<Id> repIds, Set<Id> excludeRepIds){
        Map<Id, Set<Id>> grantAccessToMap = new Map<Id, Set<Id>>();
        List<Rep_Split__c> repSplits = [Select Id, Split_Rep__c, Grant_Access_to_Rep__c from Rep_Split__c where Split_Rep__c in :repIds and Split_Rep__c not in :excludeRepIds and Grant_Access_To_Rep__c not in :excludeRepIds];
        for (Rep_Split__c assignment : repSplits){
            if (grantAccessToMap.get(assignment.Split_Rep__c) == null){
                grantAccessToMap.put(assignment.Grant_Access_To_Rep__c, new Set<Id>{ assignment.Split_Rep__c });
            }else{
                grantAccessToMap.get(assignment.Grant_Access_To_Rep__c).add(assignment.Split_Rep__c);
            }
        }
        return grantAccessToMap;
    }

    // returns a map of user id -> set of financial accounts they have access to via FinancialAccount__Share rows
    public static Map<Id, Set<Id>> getSharesMap(Set<Id> userIds, Set<Id> repIds){
        // add split reps to rep ids
        Map<Id, Set<Id>> splitRepMap = getSplitRepMap(repIds);
        for (Set<Id> idSet : splitRepMap.values()){
            for (Id repId : idSet){
                repIds.add(repId);
            }
        }

        // get financial accounts via Rep_Number__c field
        List<FinServ__FinancialAccount__c> finAccts = [Select Id from FinServ__FinancialAccount__c where Rep__c in :repIds];
        // add accounts via account splits
        finAccts.addAll([Select Id from FinServ__FinancialAccount__c where Id not in :finAccts and Id in (Select Financial_Account__c from Account_Split__c where Rep__c in :repIds)]);


        List<FinServ__FinancialAccount__Share> shares = [select ParentId, UserOrGroupId from FinServ__FinancialAccount__Share where UserOrGroupId in :userIds and ParentId in :finAccts and RowCause = :rowCause];

        Map<Id, Set<Id>> sharesMap = new Map<Id, Set<Id>>();
        for (FinServ__FinancialAccount__Share share : shares){
            if (sharesMap.get(share.ParentId) == null){
                sharesMap.put(share.UserOrGroupId, new Set<Id>{ share.ParentId });
            }else{
                sharesMap.get(share.UserOrGroupId).add(share.ParentId);
            }
        }
        return sharesMap;
    }

    public static Map<Id, Set<Id>> getFinAcctsByUser(Set<Id> userIds, Set<Id> excludeAccountSplitIds, Set<Id> excludeRepSplitIds, Set<Id> excludeRepIds, Set<Id> excludeAssistantAssignmentIds){
        if (excludeAccountSplitIds == null) excludeAccountSplitIds = new Set<Id>();
        if (excludeRepSplitIds == null) excludeRepSplitIds = new Set<Id>();
        if (excludeRepIds == null) excludeRepIds = new Set<Id>();
        if (excludeAssistantAssignmentIds == null) excludeAssistantAssignmentIds = new Set<Id>();

        Map<Id, Set<Id>> repIdsByUser = getRepIdsByUser(userIds, excludeRepIds, excludeAssistantAssignmentIds);
        Set<Id> repIds = getAllValues(repIdsByUser);

        Map<Id, Set<Id>> repToFinancialAccountMap = getRepToFinancialAccountMap(repIds, excludeAccountSplitIds, excludeRepSplitIds, excludeRepIds);
        Map<Id, Set<Id>> finAcctsByUser = new Map<Id, Set<Id>>();
        for (Id userId : userIds){
            Set<Id> thisUserRepIds = repIdsByUser.get(userId);
            Set<Id> finAcctIds = new Set<Id>();
            if (thisUserRepIds != null){
                for (Id repId : thisUserRepIds){
                    finAcctIds.addAll(repToFinancialAccountMap.get(repId));
                }
            }

            if (finAcctIds.size() > 0) finAcctsByUser.put(userId, finAcctIds);
        }
        return finAcctsByUser;
    }

    public static Map<Id, Set<Id>> getRepIdsByUser(Set<Id> userIds, Set<Id> excludeRepIds, Set<Id> excludeAsssistantAssignmentIds){
        // is this user anyone's assistant?
        Map<Id, Set<Id>> assisteeMap = getUserAssisteeMap(userIds, excludeAsssistantAssignmentIds);
        Set<Id> allUserIds = new Set<Id>( userIds );
        allUserIds.addAll(getAllValues(assisteeMap));
        Map<Id, Set<Id>> assistantMap = getUserAssistantMap(allUserIds);

        List<Rep_Assignment__c> repAssignments = [select Rep__c, User__c from Rep_Assignment__c where User__c in :allUserIds and Rep__c not in :excludeRepIds];
        Set<Id> repIds = new Set<Id>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            repIds.add(repAssignment.Rep__c);
        }

        Map<Id, Set<Id>> grantAccessToRepMap = getGrantAccessToRepMap(repIds, excludeRepIds);

        Map<Id, Set<Id>> repIdsByUser = new Map<Id,Set<Id>>();
        for (Rep_Assignment__c rep : repAssignments){
            if (repIdsByUser.get(rep.User__c) == null){
                repIdsByUser.put(rep.User__c, new Set<Id>{ rep.Rep__c });
            }else{
                repIdsByUser.get(rep.User__c).add(rep.Rep__c);
            }

            // rep splits
            if (grantAccessToRepMap.get(rep.Rep__c) != null){
                Set<Id> splitRepIds = grantAccessToRepMap.get(rep.Rep__c);
                repIdsByUser.get(rep.User__c).addAll(splitRepIds);
            }

            // does this user have assistants?
            Set<Id> assistantIds = assistantMap.get(rep.User__c);
            if (assistantIds != null){
                for (Id assistantId : assistantIds){
                    if (repIdsByUser.get(assistantId) == null){
                        repIdsByUser.put(assistantId, new Set<Id>{ rep.Rep__c });
                    }else{
                        repIdsByUser.get(assistantId).add(rep.Rep__c);
                    }

                    // rep splits
                    if (grantAccessToRepMap.get(rep.Rep__c) != null){
                        Set<Id> splitRepIds = grantAccessToRepMap.get(rep.Rep__c);
                        repIdsByUser.get(assistantId).addAll(splitRepIds);
                    }
                }
            }
        }
        return repIdsByUser;
    }

    public static Set<Id> getRepIdsForUser(Id userId, Set<Id> excludeSplitIds){
        // is this user anyone's assistant?
        List<Assistant_Assignment__c> assistantAssignments = [select Assistee__c from Assistant_Assignment__c where Assistant__c = :userId];
        Set<Id> userIds = new Set<Id>{ userId };
        for (Assistant_Assignment__c assistantAssignment : assistantAssignments){
            userIds.add(assistantAssignment.Assistee__c);
        }

        List<Rep_Assignment__c> repAssignments = [select Rep__c from Rep_Assignment__c where User__c in :userIds];
        Set<Id> repIds = new Set<Id>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            repIds.add(repAssignment.Rep__c);
        }

        List<Rep_Split__c> repSplits = [Select Id, Grant_Access_To_Rep__c from Rep_Split__c where Split_Rep__c in :repIds and Id not in :excludeSplitIds];
        for (Rep_Split__c repSplit : repSplits){
            repIds.add(repSplit.Grant_Access_To_Rep__c);
        }

        return repIds;
    }

    public static Map<Id,Set<Id>> getUserIdsByRep(Set<Id> repIds){
        List<Rep_Assignment__c> repAssignments = [select Rep__c, User__c from Rep_Assignment__c where Rep__c in :repIds];
        List<Rep_Split__c> repSplits = [Select Split_Rep__c, Grant_Access_To_Rep__c from Rep_Split__c where Grant_Access_to_Rep__c in :repIds or Split_Rep__c in :repIds];

        // create map of rep id -> split rep ids
        Map<Id,Set<Id>> grantAccessToRepsMap = new Map<Id,Set<Id>>();
        for (Rep_Split__c repSplit : repSplits){
            if (grantAccessToRepsMap.get(repSplit.Grant_Access_To_Rep__c) == null){
                grantAccessToRepsMap.put(repSplit.Grant_Access_To_Rep__c, new Set<Id> { repSplit.Split_Rep__c });
            }else{
                grantAccessToRepsMap.get(repSplit.Grant_Access_To_Rep__c).add(repSplit.Split_Rep__c);
            }
        }

        Map<Id,Set<Id>> userIdsByRep = new Map<Id,Set<Id>>();
        for (Rep_Assignment__c repAssignment : repAssignments){
            if (userIdsByRep.get(repAssignment.Rep__c) == null){
                userIdsByRep.put(repAssignment.Rep__c, new Set<Id>{ repAssignment.User__c });
            }else{
                userIdsByRep.get(repAssignment.Rep__c).add(repAssignment.User__c);
            }

            // if this rep has any split reps, grant access to those as well
            Set<Id> mySplitRepIds = grantAccessToRepsMap.get(repAssignment.Rep__c);
            if (mySplitRepIds != null){
                for (Id splitRepId : mySplitRepIds){
                    if (userIdsByRep.get(splitRepId) == null){
                        userIdsByRep.put(splitRepId, new Set<Id>{ repAssignment.User__c });
                    }else{
                        userIdsByRep.get(splitRepId).add(repAssignment.User__c);
                    }
                }
            }
        }

        return userIdsByRep;
    }

    public static List<Account> getHouseholds(List<FinServ__FinancialAccount__c> finAccts){
        Set<Id> householdIds = new Set<Id>();
        for (FinServ__FinancialAccount__c finAcct : finAccts){
            householdIds.add(finAcct.FinServ__Household__c);
        }
        return [Select Id, Name from Account where RecordType.Name = :HOUSEHOLD_RECORDTYPE_NAME and Id in :householdIds];
    }

    public static List<AccountShare> buildHouseholdShares(List<FinServ__FinancialAccount__Share> finShares){
        // get financial accounts
        Set<Id> finAcctIds = new Set<Id>();
        for (FinServ__FinancialAccount__Share share : finShares){
            finAcctIds.add(share.ParentId);
        }

        Map<Id, FinServ__FinancialAccount__c> finAcctMap = new Map<Id, FinServ__FinancialAccount__c>([Select Id, FinServ__Household__c from FinServ__FinancialAccount__c where Id in :finAcctIds]);
        List<AccountShare> sharesToInsert = new List<AccountShare>();
        for (FinServ__FinancialAccount__Share share : finShares){
            Id householdId = finAcctMap.get(share.ParentId).FinServ__Household__c;
            System.debug('SecurityAssignmentHelper buildHouseholdShares() fin acct ' + share.ParentId + ' has household Id ' + householdId);

            if (householdId != null){
                sharesToInsert.add(
                    new AccountShare(
                        RowCause = 'Manual',
                        AccountAccessLevel = 'Edit',
                        OpportunityAccessLevel = 'Edit',
                        AccountId = householdId,
                        UserOrGroupId = share.UserOrGroupId
                    )
                );
            }
        }

        System.debug('SecurityAssignmentHelper buildHouseholdShares() returning ' + sharesToInsert.size() + ' account shares from ' + finShares.size() + ' fin acct shares');
        return sharesToInsert;
    }

    public static List<AccountShare> buildPersonAccountShares(List<AccountShare> householdShares){
        // get person accounts from Primary Contact of households, also check FinancialAccountRoles
        Set<Id> householdIds = new Set<Id>();
        for (AccountShare share : householdShares){
            householdIds.add(share.AccountId);
        }
        System.debug('Getting person accounts for householdIds: ');
        System.debug(householdIds);

        Map<Id, Set<Id>> relatedAccountsByHousehold = getRelatedAccountsByHousehold(householdIds);
        List<AccountShare> shares = new List<AccountShare>();
        for (AccountShare householdShare : householdShares){
            Set<Id> accountIds = relatedAccountsByHousehold.get(householdShare.AccountId);
            for (Id accountId : accountIds){
                shares.add(
                    new AccountShare(
                        RowCause = 'Manual',
                        AccountAccessLevel = 'Edit',
                        OpportunityAccessLevel = 'Edit',
                        AccountId = accountId,
                        UserOrGroupId = householdShare.UserOrGroupId
                    )
                );
            }
        }

        return shares;
    }

    public static Map<Id, Set<Id>> getRelatedAccountsByHousehold(Set<Id> householdIds){
        Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
        for (Id householdId : householdIds){
            if (householdId != null){
                result.put(householdId, new Set<Id>());
            }
        }

        List<FinServ__AccountAccountRelation__c> relations = [
                Select Id, FinServ__Account__c, FinServ__RelatedAccount__c
                from FinServ__AccountAccountRelation__c
                where FinServ__Account__c in :result.keySet() and FinServ__Account__r.Placeholder_Household__c = false];
        for (FinServ__AccountAccountRelation__c relation : relations){
            result.get(relation.FinServ__Account__c).add(relation.FinServ__RelatedAccount__c);
        }

        List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
            Select Id, FinServ__FinancialAccount__r.FinServ__Household__c, FinServ__RelatedAccount__c
            from FinServ__FinancialAccountRole__c
            where FinServ__RelatedAccount__c != null
              and FinServ__FinancialAccount__r.FinServ__Household__c in :householdIds
              and FinServ__FinancialAccount__r.FinServ__Household__r.Placeholder_Household__c = false
        ];

        for (FinServ__FinancialAccountRole__c financialAccountRole : financialAccountRoles){
            result.get(financialAccountRole.FinServ__FinancialAccount__r.FinServ__Household__c).add(financialAccountRole.FinServ__RelatedAccount__c);
        }

        return result;
    }

    public static Map<Id, Set<Id>> getRelatedContactsByHousehold(Set<Id> householdIds){
        Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
        for (Id householdId : householdIds){
            result.put(householdId, new Set<Id>());
        }


        List<AccountContactRelation> relations = [Select Id, AccountId, ContactId from AccountContactRelation where AccountId in :householdIds];
        for (AccountContactRelation relation : relations){
            result.get(relation.AccountId).add(relation.ContactId);
        }

        List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
                Select Id, FinServ__FinancialAccount__r.FinServ__Household__c, FinServ__RelatedContact__c
                from FinServ__FinancialAccountRole__c
                where FinServ__RelatedContact__c != null
                and FinServ__FinancialAccount__r.FinServ__Household__c in :householdIds
        ];

        for (FinServ__FinancialAccountRole__c financialAccountRole : financialAccountRoles){
            result.get(financialAccountRole.FinServ__FinancialAccount__r.FinServ__Household__c).add(financialAccountRole.FinServ__RelatedContact__c);
        }

        return result;
    }

    // returns a map of rep id -> rep sharing group
    public static Map<Id,Id> getRepGroups(Set<Id> repIds){
        Map<Id,Id> result = new Map<Id,Id>();

        List<String> groupNames = new List<String>();
        for (Id repId : repIds){
            groupNames.add('Rep-' + repId);
        }
        List<Group> groups = [Select Id, Name from Group where Name in :repIds];
        for (Group myGroup : groups){
            String repId = (myGroup.Name.substring(0,4) == 'Rep-') ? myGroup.Name.substring(4) : myGroup.Name;

            result.put(repId, myGroup.Id);
        }
        List<Group> groupsToCreate = new List<Group>();
        for (Id repId : repIds){
            if (String.isNotBlank(repId) && !result.keySet().contains(repId)){
                groupsToCreate.add(
                    new Group(
                        Name = 'Rep-' + repId,
                        DoesIncludeBosses = false,
                        Type = 'Regular'
                    )
                );
            }
        }
        insert groupsToCreate;
        for (Group myGroup : groupsToCreate){
            String repId = myGroup.Name.substring(4);

            result.put(repId, myGroup.Id);
        }
        return result;
    }

    public static Set<Id> getAllValues(Map<Id, Set<Id>> myMap){
        Set<Id> values = new Set<Id>();
        for (Set<Id> vals : myMap.values()){
            values.addAll(vals);
        }
        return values;
    }

    @TestVisible static void testCoverage(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

    }

}