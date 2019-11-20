public with sharing class ActivityController {
    @AuraEnabled(cacheable=true)
    
    public static TaskPickLists getTaskPicklist() {
        
        List<Schema.PicklistEntry> subject = Task.Subject.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> status = Task.Status.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> priority = Task.Priority.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> type = Task.Type.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> regarding = Task.FinServ__Regarding__c.getDescribe().getPicklistValues();
		
        TaskPicklists picklists = new TaskPicklists();
        picklists.Subject = new List<String>();
        picklists.Status = new List<String>();
        picklists.Priority = new List<String>();
        picklists.Type = new List<String>();
        picklists.Regarding = new List<String>();

        for (Schema.PicklistEntry entry : subject) {
            picklists.Subject.add(entry.getLabel());
        }

        for (Schema.PicklistEntry entry : status) {
            picklists.Status.add(entry.getLabel());
        }

        for (Schema.PicklistEntry entry : priority) {
            picklists.Priority.add(entry.getLabel());
        }

        for (Schema.PicklistEntry entry : type) {
            picklists.Type.add(entry.getLabel());
        }

        for (Schema.PicklistEntry entry : regarding) {
            picklists.Regarding.add(entry.getLabel());
        }

        picklists.Owner = [
            SELECT
	            Id,
	            Name
            FROM User
            WHERE IsActive = true
        ];
		System.debug(picklists);
        return picklists;
    }
}