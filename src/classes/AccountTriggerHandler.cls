public class AccountTriggerHandler  {
	private static boolean firstRunBeforeUpdate = true;
	private static boolean firstRunAfterUpdate = true;

	public void beforeInsert(List<Account> newRecords) {
		populatePhoneAndEmail(null, null, newRecords);
		setServiceLevels(null, null, newRecords);
	}

	public void beforeUpdate(Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {
		if (firstRunBeforeUpdate) {
			firstRunBeforeUpdate = false; // prevent reentry in this execution context
		}

		populatePhoneAndEmail(oldRecordsMap, newRecordsMap, null);
		setServiceLevels(oldRecordsMap, newRecordsMap, null);
	}

	public void afterInsert(Map<Id,Account> newRecordMap) {
		createPercents(null, newRecordMap);
	}

	public void afterUpdate(Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap) {
		if (firstRunAfterUpdate) {
			firstRunAfterUpdate = false; // prevent reentry in this execution context
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
	// Written by Deepak Patil at RTS Labs on 10/17/2019
	// 
	// there are several phone number fields
	// but not all of them have data, we need one for sure in the highlights panel.
	// for that we will fill in the PhoneB field based on available values.
	// 
	// Similarly there are mainly two email fields, Demo_Email and Daml_email.
	// on HH record, none these two have any data.
	// on client record, sometimes Demo_Email has data.
	// This trigger will copy Demo_Email field from Primary Contact to Demo_Email field on parent HH (or Client) record.
	// and similarly copy Daml_Email also.
	// 
	// before insert, before update
	private void populatePhoneAndEmail (Map<Id,Account> oldRecordsMap, Map<Id,Account> newRecordsMap, List<Account> newRecords) {

		List<Account> toProcess = new List<Account>();

		if (null != newRecords) { // before insert
			toProcess.addAll(newRecords);

		} else { // before update
			for (Id acctId : newRecordsMap.keySet()) { // only process records where the phone changed
				Account oldAcct = oldRecordsMap.get(acctId);
				Account newAcct = newRecordsMap.get(acctId);

				if (oldAcct.Phone != newAcct.Phone) {
					toProcess.add(newAcct);
				}
			}
		}

		Map<Id,Account> mapPrimaryContactToAccount = new Map<Id,Account>();

		for (Account acct : toProcess) {
        
			// process the phone numbers.
			acct.PhoneB__c = null;
			if (acct.Phone != null) {
				acct.PhoneB__c = acct.Phone;
			} else if (acct.Primary_Contact_Phone__c != null) {
				acct.PhoneB__c = acct.Primary_Contact_Phone__c;
			} else if ( acct.Other_Phone__c != null ) {
				acct.PhoneB__c = acct.Other_Phone__c;
			} else if (acct.PersonHomePhone  != null) {
				acct.PhoneB__c = acct.PersonHomePhone;
			}  

			if (null != acct.FinServ__PrimaryContact__c) {
				mapPrimaryContactToAccount.put(acct.FinServ__PrimaryContact__c, acct);
			}
		}

		if (mapPrimaryContactToAccount.size() > 0) {
			List <Account> allPrimaryContactAccounts = [
				SELECT Id, 
					Demo_Email__c, 
					Daml_Email__c, 
					PersonContactId
				FROM Account
				WHERE PersonContactId in :mapPrimaryContactToAccount.keySet()
			];
    
			for (Account primaryContactAccount : allPrimaryContactAccounts) {
				Account parentAccount = mapPrimaryContactToAccount.get(primaryContactAccount.PersonContactId);

				if ( parentAccount.PersonContactId != primaryContactAccount.PersonContactId ) {
					parentAccount.Demo_Email__c = primaryContactAccount.Demo_Email__c;
					parentAccount.Daml_Email__c = primaryContactAccount.Daml_Email__c;
				}
			}
		}
	}
}