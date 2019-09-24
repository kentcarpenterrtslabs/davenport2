/**
 * Created by Eric Stansbury on 4/25/2019.
 */

public class MoneyGuideProRequestController {
    static String redirectToUrl = 'https://qa.moneyguidepro.com/davenport/';
    static String endpointUrl = 'https://qa.moneyguidepro.com/davenport/';

    @AuraEnabled public static void updateUser(String householdId, String userId){
        String selectedUserId = (userId == null? UserInfo.getUserId() : userId);

        User me = [Select Id, SAML_HHID__c from User where Id = :UserInfo.getUserId()];
        me.SAML_UserId__c = selectedUserId;
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

    @AuraEnabled public static Map<String,String> getPicklistOptions(Id householdId){
        Id myUserId = UserInfo.getUserId();

        // get the Rep of Record
        Account household = [Select Id, Rep__c, Name from Account where Id = :householdId];
        if (household.Rep__c == null){
            return new Map<String,String>();
        }

        // get any sccount splits for the financial accounts of this household
        List<Account_Split__c> splits = [Select Id, Rep__c from Account_Split__c where Financial_Account__r.FinServ__Household__c = :household.Id];
        Set<Id> repIds = new Set<Id>{ householdId };

        for (Account_split__c split : splits){
            repIds.add(split.Rep__c);
        }
        // get all users with access to those reps, who also have MGP credentials on their User record
        List<User> users = [
                Select Id, FirstName, LastName from User
                 where Id in (Select User__c from Rep_Assignment__c where Rep__c in :repIds and Type__c = 'Rep')
                   and MGP_User_ID__c != null];

        // return a map of Username -> User ID for the picklist
        Map<String,String> result = new Map<String,String>();

        for (User user : users){
            String label = (user.Id == myUserId)? 'Myself' : (user.FirstName + user.LastName);
            result.put(label, user.MGP_User_Id__c);
        }
        return result;
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