/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Stub class that contains most of the logic to rebuild announcements from a collection
 * of Legacy_Announcement__c's.  This code is not used, Announcements were not carried over.
 */
public class RTS_RebuildAnnouncements implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT ' +
                        'Legacy_ExpirationDate__c, Legacy_FeedItemId__c, Legacy_ParentId__c, Legacy_SendEmails__c, ' +
                        'Rebuilt__c ' +
                        'FROM Legacy_Announcement__c ' +
                        'WHERE Rebuilt__c = false '
        );
    }

    public void execute(Database.BatchableContext bc, List<Legacy_Announcement__c> records) {
        rebuildAnnouncements(records);
    }

    public void finish(Database.BatchableContext bc) {
        // STUB
    }

    public void rebuildAnnouncements(List<Legacy_Announcement__c> records) {
        return;
//        Map<String, String> feedMapping = getFeedMapping(records);
//        Map<String, String> parentMapping = getParentMapping(records);
//
//        List<Announcement> announcements = new List<Announcement>();
//        for (Legacy_Announcement__c record : records) {
//            String feedItemId = feedMapping.get(record.Legacy_FeedItemId__c);
//            //String parentId = parentMapping.get(record.Legacy_ParentId__c);
//
//            if(feedItemId != null){
//                Announcement newAnnouncement = new Announcement();
//
//                newAnnouncement.FeedItemId = feedItemId;    // Required
//
//                // Not Writeable...
//                //if(parentId != null){
//                //    newAnnouncement.ParentId = parentId;        // Not Required
//                //}
//
//                newAnnouncement.ExpirationDate = record.Legacy_ExpirationDate__c;
//                newAnnouncement.SendEmails = record.Legacy_SendEmails__c;
//
//                announcements.add(newAnnouncement);
//                record.Rebuilt__c = true;
//            }
//        }
//
//        update records;
//        insert announcements;
    }

//    public Map<String, String> getFeedMapping(List<Legacy_Announcement__c> records) {
//        Map<String, String> feedMapping = new Map<String, String>();
//        return feedMapping;
//    }
//
//    public Map<String, String> getParentMapping(List<Legacy_Announcement__c> records) {
//        Map<String, String> parentMapping = new Map<String, String>();
//        return parentMapping;
//    }
}