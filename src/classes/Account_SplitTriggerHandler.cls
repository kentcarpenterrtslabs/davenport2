/**
 * Created by Eric Stansbury on 5/16/2019.
 */

public with sharing class Account_SplitTriggerHandler {
    public static void handleAfterInsert(List<Account_Split__c> accountSplits){
        Set<Id> repIds = new Set<Id>();
        Set<Id> finAcctIds = new Set<Id>();
        for (Account_Split__c accountSplit : accountSplits){
            repIds.add(accountSplit.Rep__c);
        }

        Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(repIds);
        List<FinServ__FinancialAccount__Share> sharesToInsert = new List<FinServ__FinancialAccount__Share>();
        for (Account_Split__c accountSplit : accountSplits){
            Id repGroupId = repGroups.get(accountSplit.Rep__c);

            sharesToInsert.add(
                new FinServ__FinancialAccount__Share(
                    ParentId = accountSplit.Financial_Account__c,
                    UserOrGroupId = repGroupId,
                    AccessLevel = 'Edit',
                    RowCause = SecurityAssignmentHelper.rowCause
                )
            );
        }

        List<SObject> insertMe = new List<SObject>();
        insertMe.addAll(sharesToInsert);
        List<AccountShare> householdShares = SecurityAssignmentHelper.buildHouseholdShares(sharesToInsert);
        insertMe.addAll(householdShares);
        List<AccountShare> personAccountShares = SecurityAssignmentHelper.buildPersonAccountShares(householdShares);
        insertMe.addAll(personAccountShares);
        try{
            insert insertMe;
        }catch(DMLException e){
            System.enqueueJob(new SObjectInsertQueueable(insertMe));
        }catch(TypeException e){
            // Cannot have more than 10 chunks in a single operation. Please rearrange the data to reduce chunking.
            try{
                insert sharesToInsert;
                insert householdShares;
                insert personAccountShares;
            }catch(DMLException ex) {
                System.enqueueJob(new SObjectInsertQueueable(insertMe));
            }
        }
    }

    public static void handleAfterDelete(List<Account_Split__c> accountSplits){
        Set<Id> repIds = new Set<Id>();
        Set<Id> finAcctIds = new Set<Id>();
        for (Account_Split__c accountSplit : accountSplits){
            repIds.add(accountSplit.Rep__c);
            finAcctIds.add(accountSplit.Financial_Account__c);
        }

        Map<Id,Id> repGroups = SecurityAssignmentHelper.getRepGroups(repIds);
        List<Id> groupIds = repGroups.values();

        List<FinServ__FinancialAccount__Share> shares = [
                Select Id, UserOrGroupId, ParentId
                  from FinServ__FinancialAccount__Share
                 where RowCause = :SecurityAssignmentHelper.rowCause
                   and UserOrGroupId in :groupIds
                   and ParentId in :finAcctIds
        ];

        Map<String, FinServ__FinancialAccount__Share> shareMap = new Map<String, FinServ__FinancialAccount__Share>();
        for (FinServ__FinancialAccount__Share share : shares){
            String key = '' + share.UserOrGroupId + share.ParentId;
            shareMap.put(key, share);
        }

        List<FinServ__FinancialAccount__Share> sharesToDelete = new List<FinServ__FinancialAccount__Share>();
        for (Account_Split__c accountSplit : accountSplits){
            Id repGroupId = repGroups.get(accountSplit.Rep__c);
            String key = '' + repGroupId + accountSplit.Financial_Account__c;
            sharesToDelete.add(
                shareMap.get(key)
            );
        }

        System.debug('Account_SplitTriggerHandler handleAfterDelete deleting ' + sharesToDelete.size() + ' finacct shares');
        System.enqueueJob(new SObjectDeleteQueueable(sharesToDelete));
    }
}