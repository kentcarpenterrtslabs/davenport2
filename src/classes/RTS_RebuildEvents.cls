/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Batchable class that relinks the whoId, whatId and ownerId of Events to the correct objects based
 * on the Legacy_ID__c of those objects.  This class currently only relinks to Accounts as What and Contacts as Who.
 */
public without sharing class RTS_RebuildEvents implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Legacy_WhatId__c, WhatId, Legacy_WhoId__c, WhoId, Legacy_Owner_ID__c, OwnerId, Rebuilt__c, Legacy_Recurrence__c ' +
                        ' FROM Event' +
                        ' WHERE Rebuilt__c = false'
        );
    }

    public void execute(Database.BatchableContext bc, List<Event> records) {
        rebuildEvents(records);
    }

    public void finish(Database.BatchableContext bc) {
        // STUB
    }


    public void rebuildEvents(List<Event> records) {
        Map<String, String> whoMappings = getWhoMapping(records);
        Map<String, String> whatMappings = getWhatMapping(records);

        List<Event> recordsToAdd = new List<Event>();
        List<Event> recordsToDelete = new List<Event>();

        for (Event record : records) {
            record.WhoId = whoMappings.get(record.Legacy_WhoId__c);
            record.WhatId = whatMappings.get(record.Legacy_WhatId__c);

            record.Rebuilt__c = true;
        }

        Database.update(records, false);
        Database.insert(recordsToAdd, false);
        Database.delete(recordsToDelete, false);
    }


    // WhatId represents nonhuman objects such as:
    // accounts, opportunities, campaigns, cases, or custom objects.
    // The label is "Related To ID".
    private Map<String, String> getWhatMapping(List<Event> records) {
        Set<String> legacyWhatIds = new Set<String>();
        for (Event record : records) {
            if(record.Legacy_WhatId__c != null){
                legacyWhatIds.add(record.Legacy_WhatId__c);
            }
        }


        // ACCOUNTS/CONTACTS
        List<Account> legacyAccounts = [SELECT Id, Legacy_ID__c FROM Account WHERE Legacy_ID__c IN :legacyWhatIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for (Account what : legacyAccounts) {
            legacyToNewMap.put(what.Legacy_ID__c, what.Id);
        }

        return legacyToNewMap;
    }

    //  WhoId is equivalent to a:
    //  contact’s ID or a lead’s ID.
    //  The label is "Name ID".
    private Map<String, String> getWhoMapping(List<Event> records) {
        Set<String> legacyWhoIds = new Set<String>();
        for (Event record : records) {
            if(record.Legacy_WhoId__c != null){
                legacyWhoIds.add(record.Legacy_WhoId__c);
            }
        }


        // ACCOUNTS/CONTACTS
        List<Contact> legacyContacts = [SELECT Id, Legacy_ID__c FROM Contact WHERE Legacy_ID__c IN :legacyWhoIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for (Contact who : legacyContacts) {
            legacyToNewMap.put(who.Legacy_ID__c, who.Id);
        }

        return legacyToNewMap;
    }
}