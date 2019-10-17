@RestResource(urlMapping='/Household/*')
global with sharing class MGPHousehold {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		System.debug('MGPHousehold.doGet: UserInfo.getUserId() = ' + UserInfo.getUserId() + ', accountId = ' + accountId);
		res.responseBody = Blob.valueOf(buildRequestBody(accountId));
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
}