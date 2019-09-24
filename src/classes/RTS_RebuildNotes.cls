/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Batchable class that takes Legacy_Notes__c's and turns them into normal Salesforce Notes.  This is used as a way
 * of preserving the historical data while also creating the Salesforce objects.
 */
public class RTS_RebuildNotes implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Body__c, IsPrivate__c, Legacy_Owner_ID__c, Legacy_Parent_ID__c, Title__c ' +
                        'FROM Legacy_Note__c ' +
                        'WHERE Rebuilt__c = false'
        );
    }

    public void execute(Database.BatchableContext bc, List<Legacy_Note__c> records) {
        rebuildNotes(records);
    }

    public void finish(Database.BatchableContext bc) {
        // STUB
    }

    public void rebuildNotes(List<Legacy_Note__c> records) {
        Map<String, String> ownerMapping = getOwnerMapping(records);
        Map<String, String> parentMapping = getParentMapping(records);

        List<Note> notes = new List<Note>();
        for(Legacy_Note__c record : records){
            String owner = ownerMapping.get(record.Legacy_Owner_ID__c);
            String parent = parentMapping.get(record.Legacy_Parent_ID__c);

            if(owner != null || parent != null){
                Note newNote = new Note();

                if(owner != null){
                    newNote.OwnerId = owner;
                }

                if(parent != null){
                    newNote.ParentId = parent;
                }


                newNote.Title = record.Title__c;
                newNote.Body = record.Body__c;
                newNote.IsPrivate = record.IsPrivate__c;

                notes.add(newNote);
                record.Rebuilt__c = true;
            }
        }

        List<Database.SaveResult> updateResults = Database.update(records, false);
        List<Database.SaveResult> insertResults = Database.insert(notes, false);
//        update records;
//        insert notes;
    }

    /**
     * Construct a mapping of User.Legacy_ID__c -> User.Id
     *
     * @param records List of Legacy Notes we are building notes from.
     *
     * @return User.Legacy_ID__c -> User.Id Map
     */
    private Map<String, String> getOwnerMapping(List<Legacy_Note__c> records){
        // Build a list of all Legacy Owner Ids.
        Set<String> legacyOwnerIds = new Set<String>();
        for(Legacy_Note__c record : records){
            legacyOwnerIds.add(record.Legacy_Owner_ID__c);
        }


        // Create map of Legacy ID's to New ID's
        List<User> legacyOwners = [SELECT Id, Legacy_ID__c FROM User WHERE Legacy_ID__c IN :legacyOwnerIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for(User owner : legacyOwners){
            legacyToNewMap.put(owner.Legacy_ID__c, owner.Id);
        }

        return legacyToNewMap;
    }


    /**
     * Construct a mapping of Account.Legacy_ID__c -> Account.Id
     *
     * @param records List of Legacy Notes we are building notes from.
     *
     * @return Account.Legacy_ID__c -> Account.Id map
     */
    private Map<String, String> getParentMapping(List<Legacy_Note__c> records){
        // Build a list of all Legacy Parent Ids.
        Set<String> legacyParentIds = new Set<String>();
        for(Legacy_Note__c record : records){
            legacyParentIds.add(record.Legacy_Parent_ID__c);
        }


        // Create map of Legacy ID's to New ID's
        List<Account> accounts = [SELECT Id, Legacy_ID__c FROM Account WHERE Legacy_ID__c IN :legacyParentIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for(Account parent : accounts){
            legacyToNewMap.put(parent.Legacy_ID__c, parent.Id);
        }

        return legacyToNewMap;
    }
}