public class AccountTriggerHandler  {
	private static boolean firstRunBeforeUpdate = true;
	private static boolean firstRunAfterUpdate = true;

	public void beforeInsert(List<Account> newRecords) {
		System.debug('In AccountTriggerHandler.beforeInsert');
		populatePhones(null, null, newRecords);
		populateEmails(null, null, newRecords);
		setServiceLevels(null, null, newRecords);
	}

	public void beforeUpdate(Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {
		System.debug('In AccountTriggerHandler.beforeUpdate');
		if (firstRunBeforeUpdate) {
			firstRunBeforeUpdate = false; // prevent reentry in this execution context
		}

		populatePhones(oldRecordsMap, newRecordsMap, null);
		populateEmails(oldRecordsMap, newRecordsMap, null);
		setServiceLevels(oldRecordsMap, newRecordsMap, null);
	}

	public void afterInsert(Map<Id,Account> newRecordMap) {
		System.debug('In AccountTriggerHandler.afterInsert');
		createPercents(null, newRecordMap);
		populatePersonEmail(null, newRecordMap);
	}

	public void afterUpdate(Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {
		System.debug('In AccountTriggerHandler.afterUpdate');
		if (firstRunAfterUpdate) {
			System.debug('In AccountTriggerHandler.afterUpdate firstRunAfterUpdate');
			firstRunAfterUpdate = false; // prevent reentry in this execution context
			populatePersonEmail(oldRecordsMap, newRecordsMap);
		}

		createPercents(oldRecordsMap, newRecordsMap);
	}

	private void setServiceLevels(Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap, List<Account> newRecords) {
		List<Account> toProcess = new List<Account>();

		if (null != newRecords) { // before insert
			for (Account acct : newRecords) { // only process records where the user did not set any of these values
				if (
					null == acct.In_Person_Meetings_Year__c &&
					null == acct.Portfolio_Reviews_Year__c &&
					null == acct.Relationship_Calls_Year__c)
				{
					toProcess.add(acct);
				}
			}
		} else { // before update
			for (Id acctId : newRecordsMap.keySet()) { // only process records where the tier changed
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);

				if (oldAcct.Tier__c != newAcct.Tier__c) {
					toProcess.add(newAcct);
				}
			}
		}

		if (toProcess.size() > 0) {
			Service_Level_Defaults__c defaults = Service_Level_Defaults__c.getInstance();

			for (Account acct : toProcess) {
				switch on acct.Tier__c {
					when 'A' {
						acct.In_Person_Meetings_Year__c = defaults.Tier_A_In_Person_Meetings_Year__c;
						acct.Portfolio_Reviews_Year__c  = defaults.Tier_A_Portfolio_Review_Year__c;
						acct.Relationship_Calls_Year__c = defaults.Tier_A_Relationship_Calls_Year__c;
					}
					when 'B' {
						acct.In_Person_Meetings_Year__c = defaults.Tier_B_In_Person_Meetings_Year__c;
						acct.Portfolio_Reviews_Year__c  = defaults.Tier_B_Portfolio_Review_Year__c;
						acct.Relationship_Calls_Year__c = defaults.Tier_B_Relationship_Calls_Year__c;
					}
					when 'C' {
						acct.In_Person_Meetings_Year__c = defaults.Tier_C_In_Person_Meetings_Year__c;
						acct.Portfolio_Reviews_Year__c  = defaults.Tier_C_Portfolio_Review_Year__c;
						acct.Relationship_Calls_Year__c = defaults.Tier_C_Relationship_Calls_Year__c;
					}
					when 'D' {
						acct.In_Person_Meetings_Year__c = defaults.Tier_D_In_Person_Meetings_Year__c;
						acct.Portfolio_Reviews_Year__c  = defaults.Tier_D_Portfolio_Review_Year__c;
						acct.Relationship_Calls_Year__c = defaults.Tier_D_Relationship_Calls_Year__c;
					}
					when 'E' {
						acct.In_Person_Meetings_Year__c = defaults.Tier_E_In_Person_Meetings_Year__c;
						acct.Portfolio_Reviews_Year__c  = defaults.Tier_E_Portfolio_Review_Year__c;
						acct.Relationship_Calls_Year__c = defaults.Tier_E_Relationship_Calls_Year__c;
					}
				}
			}
		}
	}

	private void createPercents (Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {

		List<Account> toProcess = new List<Account>();

		if (null == oldRecordsMap) { // after insert
			toProcess.addAll(newRecordsMap.values());

		} else {
			for (Id acctId : newRecordsMap.keySet()) { // after update
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);

				if (
					oldAcct.Cash_Value__c != newAcct.Cash_Value__c ||
					oldAcct.Equity_Value__c != newAcct.Equity_Value__c ||
					oldAcct.Fixed_Income_Value__c != newAcct.Fixed_Income_Value__c ||
					oldAcct.Other_Value__c != newAcct.Other_Value__c)
				{
					toProcess.add(newAcct);
				}					
			}
		}

		List<Household_Percent__c> percentsToUpsert = new List<Household_Percent__c>();

    	for(Account a : toProcess)
		{
    		Household_Percent__c percCash = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '1', Type__c = 'Cash', Value__c = a.Cash_Value__c);
    		Household_Percent__c percEq = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '2', Type__c = 'Equities', Value__c = a.Equity_Value__c);
    		Household_Percent__c percFix = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '3', Type__c = 'Fixed Income', Value__c = a.Fixed_Income_Value__c);
    		Household_Percent__c percOther = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '4', Type__c = 'Other', Value__c = a.Other_Value__c);

			if(a.Cash_Value__c == null)
			{
				percCash.Value__c = 0.00;
			}
			if(a.Equity_Value__c == null)
			{
				percEq.Value__c = 0.00;
			}
			if(a.Fixed_Income_Value__c == null)
			{
				percFix.Value__c = 0.00;
			}
			if(a.Other_Value__c == null)
			{
				percOther.Value__c = 0.00;
			}
              
    		percentsToUpsert.add(percCash);
    		percentsToUpsert.add(percEq);
    		percentsToUpsert.add(percFix);
    		percentsToUpsert.add(percOther);
                 
    	}

		upsert percentsToUpsert External_Account_Id__c;
	}

	// 
	// there are several phone number fields
	// but not all of them have data, we need one for sure in the highlights panel.
	// for that we will fill in the PhoneB field based on available values.
	// before insert, before update
	public void populatePhones (Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap, List<Account> newRecords) {

		List<Account> toUpdatePhones = new List<Account>();

		if (null != newRecords) { // before insert
			toUpdatePhones.addAll(newRecords);

		} else { // before update -- only process records where one of the phones changed
			for (Id acctId : newRecordsMap.keySet()) {
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);

				// one of the phones changed
				if (oldAcct.Phone != newAcct.Phone ||
                    oldAcct.Primary_Contact_Phone__c != newAcct.Primary_Contact_Phone__c ||
                    oldAcct.PersonMobilePhone != newAcct.PersonMobilePhone ||
                    oldAcct.PersonHomePhone != newAcct.PersonHomePhone ||
                    oldAcct.Contact_Work_Phone__pc != newAcct.Contact_Work_Phone__pc ) {

					toUpdatePhones.add(newAcct);
				}
			}
		}

		// set the PhoneB field
		for (Account acct : toUpdatePhones) {
			acct.PhoneB__c = null;
			if ( String.isNotBlank(acct.Phone) ) {
				acct.PhoneB__c = acct.Phone;
			}  else if ( String.isNotBlank(acct.PersonMobilePhone) ) {
				acct.PhoneB__c = acct.PersonMobilePhone;
			} else if ( String.isNotBlank(acct.PersonHomePhone) ) { 
				acct.PhoneB__c = acct.PersonHomePhone;
			} else if ( String.isNotBlank(acct.Contact_Work_Phone__pc) ) {
				acct.PhoneB__c = acct.Contact_Work_Phone__pc;
			} else if ( String.isNotBlank(acct.Primary_Contact_Phone__c) ) {
				acct.PhoneB__c = acct.Primary_Contact_Phone__c;
			}
		}
	}

	// 
	// There are mainly two email fields, Demo_Email and Daml_email.
	// on HH record, none these two have any data.
	// on client record, sometimes Demo_Email has data.
	// This trigger will copy Demo_Email field from Primary Contact to Demo_Email field on parent HH (or Client) record.
	// and similarly copy Daml_Email also.
	// 
	public void populateEmails (Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap, List<Account> newRecords) {

		List<Account> toUpdateFromPrimaryContact = new List<Account>();

		if (null != newRecords) { // before insert
			System.debug('In populateEmails newRecords: ' + JSON.serializePretty(newRecords));
			for (Account acct : newRecords) {
				if (acct.FinServ__PrimaryContact__c != null) {
					toUpdateFromPrimaryContact.add(acct);
				}
			}
		} else { // before update
			Map<Id,Account> mapPersonContactIdToAccount = new Map<Id,Account>();
			List<Id> childAccountIds = new List<Id>();

			System.debug('In populateEmails newRecords.values: ' + JSON.serializePretty(newRecordsMap.values()));
			for (Id acctId : newRecordsMap.keySet()) {
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);
                
				Id clientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contact Client/Prospect').getRecordTypeId();
                
				if (newAcct.RecordTypeId == clientRecordTypeId) { // this is a child account
                    
                    // if either email changed, mark this record to check whether it is a primary contact for another account
                    if (oldAcct.Demo_Email__c != newAcct.Demo_Email__c ||
                        oldAcct.Daml_Email__c != newAcct.Daml_Email__c) {
    
                        System.debug('In populateEmails child account email changed: ' + JSON.serializePretty(newAcct));
                        mapPersonContactIdToAccount.put(newAcct.PersonContactId, newAcct);
                        childAccountIds.add(newAcct.Id);
                    }
                } else { // this is a parent account
					if (newAcct.FinServ__PrimaryContact__c != oldAcct.FinServ__PrimaryContact__c) { // the child has changed
						toUpdateFromPrimaryContact.add(newAcct);
					}
                }
			}

			System.debug('In populateEmails mapPersonContactIdToAccount: ' + JSON.serializePretty(mapPersonContactIdToAccount));
			// if there are child accounts that had email changes
			if (mapPersonContactIdToAccount.keySet().size() > 0) {
				// get the parent accounts
				List<Account> parentAccounts = [
					SELECT
						Id,
						Phone,
						PhoneB__c,
						PersonMobilePhone,
						PersonHomePhone,
						Contact_Work_Phone__pc,
						Primary_Contact_Phone__c,
						Demo_Email__c, 
						Daml_Email__c, 
						FinServ__PrimaryContact__c,
						PersonContactId
					FROM Account
					WHERE FinServ__PrimaryContact__c IN :mapPersonContactIdToAccount.keySet()
                    AND Id NOT IN :childAccountIds
				];

				System.debug('gathered parentAccounts:' + JSON.serializePretty(parentAccounts));

				if (parentAccounts.size() > 0) {
					for (Account parentAccount : parentAccounts) {
						Account childAccount = mapPersonContactIdToAccount.get(parentAccount.FinServ__PrimaryContact__c);

						parentAccount.Demo_Email__c = childAccount.Demo_Email__c;
						parentAccount.Daml_Email__c = childAccount.Daml_Email__c;
					}
					update parentAccounts;
				}
			}
		}

		// if there are accounts to update from their primary contact
		if (toUpdateFromPrimaryContact.size() > 0) {

			Map<Id,Account> mapPrimaryContactIdToParentAccount = new Map<Id,Account>();

			for (Account acct : toUpdateFromPrimaryContact) {
				mapPrimaryContactIdToParentAccount.put(acct.FinServ__PrimaryContact__c, acct);
			}

			List <Account> primaryContactAccounts = [
				SELECT Id, 
					Demo_Email__c, 
					Daml_Email__c, 
					PersonContactId
				FROM Account
				WHERE PersonContactId in :mapPrimaryContactIdToParentAccount.keySet()
			];
    
			for (Account primaryContactAccount : primaryContactAccounts) {
				Account parentAccount = mapPrimaryContactIdToParentAccount.get(primaryContactAccount.PersonContactId);

				parentAccount.Demo_Email__c = primaryContactAccount.Demo_Email__c;
				parentAccount.Daml_Email__c = primaryContactAccount.Daml_Email__c;
			}
		}
	}

	public void populatePersonEmail (Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {
		List<Account> toProcess = new List<Account>();

		if (null == oldRecordsMap) { // after insert
			toProcess.addAll(newRecordsMap.values());

		} else { // after update
			for (Id acctId : newRecordsMap.keySet()) {
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);

				if (oldAcct.Demo_Email__c != newAcct.Demo_Email__c ||
					oldAcct.Daml_Email__c != newAcct.Daml_Email__c) {
					toProcess.add(newAcct);
				}
			}
		}

		List<Account> toUpdate = [
			SELECT
				PersonContactId,
				Demo_Email__c,
				Daml_Email__c
			FROM Account
			WHERE Id IN :toProcess];

		for (Account acct : toUpdate) {
			if (acct.PersonContactId != null) {
				if (!String.IsBlank(acct.Demo_Email__c)) {
					acct.PersonEmail = acct.Demo_Email__c;
				} else if (!String.IsBlank(acct.Daml_Email__c)) {
					acct.PersonEmail = acct.Daml_Email__c;
				}
			}
		}

		update toUpdate;
	}
}