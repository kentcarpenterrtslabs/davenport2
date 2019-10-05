global class SecurityFinancialAccountBatchable implements Database.Batchable<SObject> {

	global String log;

	global SecurityFinancialAccountBatchable () {
		log = '';
	}
		
	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([
			SELECT
				Id,
				Rep__r.GroupId__c,
				FinServ__Household__c,
				(
					SELECT
						Rep__r.GroupId__c
					FROM Account_Split_IDs__r
					WHERE Rep__c != null
					AND Rep__r.GroupId__c != null ),
				(
					SELECT
						FinServ__RelatedAccount__c,
						FinServ__RelatedContact__c
					FROM FinServ__FinancialAccountRoles__r )
			FROM FinServ__FinancialAccount__c
			WHERE Rep__c != null
			AND Rep__r.GroupId__c != null
		]);
	}

   	global void execute(Database.BatchableContext context, List<FinServ__FinancialAccount__c> scope) {
		Map<Id,Set<String>> mapFinAcctIdToGroupId = new Map<Id,Set<String>>();
		Map<Id,Set<String>> mapHouseholdIdToGroupId = new Map<Id,Set<String>>();

		// For each financial account and household, build a unique list of groups to share them with
		for (FinServ__FinancialAccount__c financialAccount : scope) {

			// if the financial account does not have a group list, create it
			if (!mapFinAcctIdToGroupId.containsKey(financialAccount.Id)) {
				mapFinAcctIdToGroupId.put(financialAccount.Id, new Set<String>());
			}

			if (null != financialAccount.FinServ__Household__c) {
				// if the household does not have a group list, create it
				if (!mapHouseholdIdToGroupId.containsKey(financialAccount.FinServ__Household__c)) {
					mapHouseholdIdToGroupId.put(financialAccount.FinServ__Household__c, new Set<String>());
				}
			}

			// Get the group lists for the current financial account and household
			Set<String> finAcctGroupIdSet = mapFinAcctIdToGroupId.get(financialAccount.Id);
			Set<String> householdGroupIdSet;
			if (null != financialAccount.FinServ__Household__c) {
				 householdGroupIdSet = mapHouseholdIdToGroupId.get(financialAccount.FinServ__Household__c);
			} else {
				log += '\n' + ' financial account ' + financialAccount.Name + ' ' + financialAccount.Id + ' does not have a household';
			}
			
			// Add the group to the lists for the current financial account and household
			finAcctGroupIdSet.add(financialAccount.Rep__r.GroupId__c);
			if (null != householdGroupIdSet) {
				householdGroupIdSet.add(financialAccount.Rep__r.GroupId__c);
			}

			// For each account split, add the group for that split to the lists for the current financial account and household
			for (Account_Split__c accountSplit : financialAccount.Account_Split_IDs__r) {
				finAcctGroupIdSet.add(accountSplit.Rep__r.GroupId__c);
				if (null != householdGroupIdSet) {
					householdGroupIdSet.add(accountSplit.Rep__r.GroupId__c);
				}
			}

			// For each account role, add the group for the financial account to a list for the related household for that role
			for (FinServ__FinancialAccountRole__c accountRole : financialAccount.FinServ__FinancialAccountRoles__r) {
				if (null != accountRole.FinServ__RelatedAccount__c) {
					if (!mapHouseholdIdToGroupId.containsKey(accountRole.FinServ__RelatedAccount__c)) {
						mapHouseholdIdToGroupId.put(accountRole.FinServ__RelatedAccount__c, new Set<String> { financialAccount.Rep__r.GroupId__c} );
					}
				}
			}
		}

		List<FinServ__FinancialAccount__Share> financialAccountShares = new List<FinServ__FinancialAccount__Share>();

		for (Id financialAccountId : mapFinAcctIdToGroupId.keySet()) {
			for (String groupId : mapFinAcctIdToGroupId.get(financialAccountId)) {
				financialAccountShares.add(new FinServ__FinancialAccount__Share(
					AccessLevel = 'Edit',
					ParentId = financialAccountId,
					RowCause = 'RTSSecurityAssignment__c',
					UserOrGroupId = Id.valueOf(groupId)
				));
			}
		}
		insert financialAccountShares;
		
		List<AccountShare> accountShares = new List<AccountShare>();

		for (Id householdId : mapHouseholdIdToGroupId.keySet()) {
			for (String groupId : mapHouseholdIdToGroupId.get(householdId)) {
				accountShares.add(new AccountShare(
					RowCause = 'Manual',
					AccountAccessLevel = 'Edit',
					OpportunityAccessLevel = 'Edit',
					AccountId = householdId,
					UserOrGroupId = Id.valueOf(groupId)
				));
			}
		}
		insert accountShares;
	}
	
	global void finish(Database.BatchableContext context) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('SecurityFinancialAccountBatchable');
        mail.setSubject('SecurityFinancialAccountBatchable Completed');
        mail.setPlainTextBody('Job ID: ' + context.getJobId() + log);
        if (!Test.isRunningTest()){
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                        mail
                });
            }catch(EmailException e){
                // usually just means NO_MASS_MAIL_PERMISSION
                System.debug(e);
            }
        }
	}
}