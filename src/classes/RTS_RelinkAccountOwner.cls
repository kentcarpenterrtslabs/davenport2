/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Batchable wrapper class that relinks the ownerId of an Account Owner to a User based on their Legacy_ID__c.
 */
public without sharing class RTS_RelinkAccountOwner implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT ' +
                        'OwnerId, Legacy_Owner_ID__c ' +
                        'FROM Account '
        );
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        relinkAcountOwner(records);
    }

    public void finish(Database.BatchableContext bc) {
    }

    private void relinkAcountOwner( List<Account> records){
        // Get list of all Legacy Owner IDs
        Set<String> allOwnerIds = new Set<String>();
        for(Account record : records){
            if(record.Legacy_Owner_ID__c != null){
                allOwnerIds.add(record.Legacy_Owner_ID__c);
            }
        }

        // Create a mapping of all Owners Legacy to New
        List<User> owners  = [SELECT Id, Legacy_ID__c FROM User WHERE Legacy_ID__c IN :allOwnerIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for(User owner : owners){
            legacyToNewMap.put(owner.Legacy_ID__c, owner.Id);
        }

        // Relink owners
        for(Account record : records){
            String owner = legacyToNewMap.get(record.Legacy_Owner_ID__c);
            if(owner != null){
                record.OwnerId = owner;
            }
        }

        List<Database.SaveResult> updateResults = Database.update(records, false);
//        update records;
    }
}