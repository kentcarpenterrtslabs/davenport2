public class MoneyGuideProRequestController {
    //static String redirectToUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';
    static String endpointUrl = 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170';

    @AuraEnabled public static void updateUser(String householdId, String userId){
		Id myUserId = UserInfo.getUserId();

        User me = [
			SELECT
				Id,
				SAML_UserId__c,
				SAML_HHID__c
			FROM User
			WHERE Id = :myUserId
		];

        me.SAML_UserId__c = (userId == null ? myUserId : userId);
        me.SAML_HHID__c = householdId;

        update me;
    }

    @AuraEnabled public static String sendRequest(Id householdId){
        String requestBody = buildRequestBody(householdId);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpointUrl);
        request.setMethod('POST');
        request.setBody(requestBody);
        if (Test.isRunningTest()) return null;

        HttpResponse response = http.send(request);
        return response.toString();
    }

    @AuraEnabled public static List<User> getPicklistOptions(Id householdId){
		String userTypePrefix = Schema.SObjectType.User.getKeyPrefix();
        String groupTypePrefix = Schema.SObjectType.Group.getKeyPrefix();

		//System.debug('userTypePrefix = ' + userTypePrefix);
		//System.debug('groupTypePrefix = ' + groupTypePrefix);

		// get user and group Ids from the account shares for this household
		List<AccountShare> accountShares = [
			SELECT
				UserOrGroupId
			FROM AccountShare
			WHERE AccountId = :householdId
		];
		//System.debug('accountShares = ' + JSON.serializePretty(accountShares));

		// split out the users and groups
		Set<Id> groupIds = new Set<Id>();
		Set<Id> userIds = new Set<Id>();

		for (AccountShare acctShare : accountShares) {
			String idAsString = String.valueOf(acctShare.UserOrGroupId);
			if (idAsString.startsWith(groupTypePrefix)) {
				groupIds.add(acctShare.UserOrGroupId);
			} else {
				userIds.add(acctShare.UserOrGroupId);
			}
		}
		//System.debug('groupIds = ' + JSON.serializePretty(groupIds));
		//System.debug('userIds = ' + JSON.serializePretty(userIds));


		// traverse the tree of sub groups
		Set<Id> parentGroups = groupIds;

		while (parentGroups.size() > 0) {

			List<GroupMember> subGroups = [
				SELECT
					UserOrGroupId
				FROM GroupMember
				WHERE GroupId IN :parentGroups
			];

			parentGroups = new Set<Id>();

			for (GroupMember grpMember : subGroups) {
				String idAsString = String.valueOf(grpMember.UserOrGroupId);
				if (idAsString.startsWith(groupTypePrefix)) {
					groupIds.add(grpMember.UserOrGroupId);
					parentGroups.add(grpMember.UserOrGroupId);
				} else {
					userIds.add(grpMember.UserOrGroupId);
				}
			}
		}				
		//System.debug('groupIds = ' + JSON.serializePretty(groupIds));
		//System.debug('userIds = ' + JSON.serializePretty(userIds));

		// get users with MGP credentials in the groups
		List<User> users = [
			SELECT
				Id,
				FirstName,
				LastName,
				MGP_User_Id__c
			FROM User
			WHERE Id IN :userIds
			AND MGP_User_Id__c != null
		];

		//System.debug(JSON.serializePretty(users));
		return users;
   }


    @AuraEnabled public static String buildRequestBody(Id householdId){
        Account household = [select Id,
                FinServ__PrimaryContact__c,
                FinServ__PrimaryContact__r.FirstName,
                FinServ__PrimaryContact__r.LastName,
                FinServ__PrimaryContact__r.Birthdate,
                FinServ__PrimaryContact__r.MailingState,
                FinServ__PrimaryContact__r.FinServ__Gender__c,
                Finserv__PrimaryContact__r.FinServ__MaritalStatus__c
            from Account where Id = :householdId
        ];

        List<Contact> coclients = [Select Id,
                FirstName,
                LastName,
                Birthdate,
                MailingState,
                Finserv__Gender__c
            from Contact
            where AccountId = :householdId
              and Id != :household.FinServ__PrimaryContact__c
        ];

        List<FinServ__FinancialAccount__c> finAccts = [Select Id,
                FinServ__FinancialAccountSource__c,
                FinServ__CurrentPostedBalance__c,
                Cost_Basis__c,
                OwnerId,
                FinServ__Description__c
            from Finserv__FinancialAccount__c
            where FinServ__Household__c = :householdId
        ];

        List<FinServ__FinancialHolding__c> holdings = [Select Id,
                FinServ__Symbol__c,
                FinServ__Shares__c,
                Cost_Basis__c,
                FinServ__MarketValue__c,
                FinServ__FinancialAccount__c
            from FinServ__FinancialHolding__c
            where FinServ__FinancialAccount__c in :finAccts
        ];

        String request =
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<Household Id="' + household.Id + '" MaritalStatus="' + maritalStatusValuesMap.get(household.Finserv__PrimaryContact__r.FinServ__MaritalStatus__c) + '">' +
                buildClient(household) +
                buildCoclients(coclients) +
                buildInvestmentAssets(finAccts, holdings) +
            '</Household>';

        return request;
    }

    @TestVisible static String buildCoclients(List<Contact> coClients){
        String result = '';
        if (coClients.size() == 0){
            return '';
        }else{
            for (Contact contact : coClients){
                result += '<Coclient Id="' + contact.Id + '">' +
                    '<FirstName>' + contact.FirstName + '</FirstName>' +
                    '<LastName>' + contact.LastName + '</LastName>' +
                    '<DOB>' + contact.Birthdate + '</DOB>' +
                    '<State>' + contact.MailingState + '</State>' +
                    '<Sex>' + genderValuesMap.get(contact.FinServ__Gender__c) + '</Sex>' +
                '</Coclient>';
            }
            return result;
        }
    }

    @TestVisible static String buildClient(Account household){
        if (household.FinServ__PrimaryContact__c == null){
            return '';
        }

        return
        '<Client Id="' + household.FinServ__PrimaryContact__c + '">' +
            '<FirstName>' + household.FinServ__PrimaryContact__r.FirstName + '</FirstName>' +
            '<LastName>' + household.FinServ__PrimaryContact__r.LastName + '</LastName>' +
            '<DOB>' + household.FinServ__PrimaryContact__r.Birthdate + '</DOB>' +
            '<State>' + household.FinServ__PrimaryContact__r.MailingState + '</State>' +
            '<Sex>' + genderValuesMap.get(household.FinServ__PrimaryContact__r.FinServ__Gender__c) + '</Sex>' +
        '</Client>';
    }

    @TestVisible static String buildInvestmentAssets(List<FinServ__FinancialAccount__c> finAccts, List<FinServ__FinancialHolding__c> holdings){
        String result = '<InvestmentAssets>';
        for (FinServ__FinancialAccount__c finAcct : finAccts){
            result += '<InvestmentAsset id="' + finAcct.Id + '">' +
                    '<Source>' + finAcct.FinServ__FinancialAccountSource__c + '</Source>' + // -> Held Account, Aggregated Account, Manually Entered
                    '<CurrentValue>' + finAcct.FinServ__CurrentPostedBalance__c + '</CurrentValue>' +
                    '<CostBasis>' + finAcct.Cost_Basis__c + '</CostBasis>' + //Amount can be passed at Account or Holding Level
                    '<Owner>' + finAcct.OwnerId + '</Owner>' +
                    '<Type></Type>' + // not sure what goes here
                    '<Company></Company>' + // not sure what goes here
                    '<Description>' + finAcct.FinServ__Description__c + '</Description>'
                    + buildHoldings(finAcct.Id, holdings)
                    + '</InvestmentAsset>';
        }
        result += '</InvestmentAssets>';

        return result;
    }

    @TestVisible static String buildHoldings(Id finAcctId, List<FinServ__FinancialHolding__c> holdings){
        String result = '<Holdings>';
        for (FinServ__FinancialHolding__c holding : holdings){
            if (holding.FinServ__FinancialAccount__c == finAcctId){
                result += '<Holding id="' + holding.Id +  '">' +
                            '<Description></Description>' + // no description field on holding in SF
                            '<Ticker>' + holding.FinServ__Symbol__c + '</Ticker>' +
                            '<Quantity>' + holding.FinServ__Shares__c + '</Quantity>' +
                            '<CostBasis>' + holding.Cost_Basis__c + '</CostBasis>' + //Can be passed at account or holding level
                            '<CurrentValue>' + holding.FinServ__MarketValue__c + '</CurrentValue>' +
                          '</Holding>';
            }
        }
        result += '</Holdings>';
        return result;
    }

    static final Map<String,Integer> genderValuesMap = new Map<String,Integer>{
        'Neither' => 0,
        'Other'   => 0,
        null      => 0,
        'Male'    => 1,
        'Female'  => 2
    };

    static final Map<String,String> maritalStatusValuesMap = new Map<String,String>{
        'Single'          => '1',
        'Married'         => '2',
        'Divorced'        => '3',
        'Separated'       => '4',
        'Widowed'         => '5',
        'DomesticPartner' => '6',
        null => ''
    };

    class Response{
        public String status{get;set;}
        public String message{get;set;}
    }
}