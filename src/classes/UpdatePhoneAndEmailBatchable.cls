global class UpdatePhoneAndEmailBatchable implements Database.Batchable<SObject> {

	String recordTypeName;

	global UpdatePhoneAndEmailBatchable(String recordTypeName) {
		this.recordTypeName = recordTypeName;
	}

    global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator([
			SELECT
				Id,
				RecordTypeId,
				PersonContactId,
				PersonEmail,
				FinServ__PrimaryContact__c,
				Daml_Email__c,
				Demo_Email__c,
				PhoneB__c,
				Phone,
				PersonMobilePhone,
				PersonHomePhone,
				Contact_Work_Phone__pc,
				Primary_Contact_Phone__c
			FROM Account
			WHERE RecordType.Name = :recordTypeName]);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
		Map<Id,Account> newRecords = new Map<Id,Account>(scope);

		AccountTriggerHandler handler = new AccountTriggerHandler();
		handler.populatePhones(null,null,newRecords.values());
		handler.populateEmails(null,null,newRecords.values());
		update newRecords.values();

		handler.populatePersonEmail(null,newRecords);
    }

    global void finish(Database.BatchableContext BC) {
    }
}