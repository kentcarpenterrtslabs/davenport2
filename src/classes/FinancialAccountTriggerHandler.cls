/**
 * Created by Eric Stansbury on 5/16/2019.
 */

public with sharing class FinancialAccountTriggerHandler {
    public static void handleAfterInsert(List<FinServ__FinancialAccount__c> financialAccounts){
        Set<Id> repIds = new Set<Id>();
        for (FinServ__FinancialAccount__c finAcct : financialAccounts){
            repIds.add(finAcct.Rep__c);
        }

        // get rep splits for these reps
        Map<Id, Set<Id>> splitRepMap = SecurityAssignmentHelper.getSplitRepMap(repIds);
        Set<Id> allRepIds = new Set<Id>(repIds);
        for (Set<Id> val : splitRepMap.values()){
            allRepIds.addAll(val);
        }
        Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(allRepIds);

        List<FinServ__FinancialAccount__Share> sharesToInsert = new List<FinServ__FinancialAccount__Share>();

        for (FinServ__FinancialAccount__c finAcct : financialAccounts){
            if (String.isNotBlank(finAcct.Rep__c)){
                Id repGroupId = repGroups.get(finAcct.Rep__c);
                sharesToInsert.add(
                    new FinServ__FinancialAccount__Share(
                        ParentId = finAcct.Id,
                        UserOrGroupId = repGroupId,
                        AccessLevel = 'Edit',
                        RowCause = SecurityAssignmentHelper.rowCause
                    )
                );
            }
            // NOTE: we don't need to worry about account splits because that's handled in the account split trigger.
            // No account splits can exist for a financial account that doesn't exist yet.
        }

        System.debug('FinancialAccountTriggerHandler handleAfterInsert() creating ' + sharesToInsert.size() + ' finacct shares');
        insert sharesToInsert;

        List<AccountShare> householdShares = SecurityAssignmentHelper.buildHouseholdShares(sharesToInsert);
        insert householdShares;
        insert SecurityAssignmentHelper.buildPersonAccountShares(householdShares);
    }

    public static void handleAfterUpdate(Map<Id,FinServ__FinancialAccount__c> oldMap, Map<Id,FinServ__FinancialAccount__c> newMap){
        List<FinServ__FinancialAccount__c> reassignedFinAccts = new List<FinServ__FinancialAccount__c>();

        Set<Id> householdIds = new Set<Id>();
        Set<String> repIds = new Set<String>();


        for (Id finAcctId : newMap.keySet()){
            if (newMap.get(finAcctId).Rep__c != oldMap.get(finAcctId).Rep__c){
                reassignedFinAccts.add(newMap.get(finAcctId));
            }
            if (newMap.get(finAcctId).FinServ__Household__c != oldMap.get(finAcctId).FinServ__Household__c){
                reassignedFinAccts.add(newMap.get(finAcctId));
                householdIds.add(finAcctId);
                repIds.add(newMap.get(finAcctId).Rep__c);
            }
        }

        // clear all shares for the financial account and rebuild them
        delete [Select Id from FinServ__FinancialAccount__Share where ParentId in :reassignedFinAccts];

        // clear accountshares for households of reassigned fin accts
        delete [Select Id from AccountShare where UserOrGroup.Name in :repIds and AccountId in :householdIds];


        handleAfterInsert(reassignedFinAccts);
    }
}