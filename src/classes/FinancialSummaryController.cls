/**
 * Created by Eric Stansbury on 6/28/2019.
 */

public with sharing class FinancialSummaryController {
    @AuraEnabled public static Response getRollups(Id recordId){
        if (recordId.getSobjectType().getDescribe().getName() != 'Account'){
            throw new AuraHandledException('Only SObjectType of Account is supported by FinancialSummaryController');
        }
        List<Account> accounts = [Select RecordType.DeveloperName, RecordType.Name from Account where Id = :recordId limit 1];
        if (accounts.isEmpty()){
            throw new AuraHandledException('Failed to retrieve account with id ' + recordId);
        }

        List<String> personRecordTypes = new List<String>{'PersonAccount', 'Contact_Client_Prospect', 'Contact_Client', 'Contact_Prospect'};
        List<String> householdRecordTypes = new List<String>{'Non_Client', 'Industries_Household', 'Household_Client', 'Household_Prospect', 'Household', 'IndustriesHousehold'};

        String recordTypeDeveloperName = accounts[0].RecordType.DeveloperName;
        if (personRecordTypes.contains(recordTypeDeveloperName)){
            return getPersonRollups(recordId);
        }else if (householdRecordTypes.contains(recordTypeDeveloperName)){
            return getHouseholdRollups(recordId);
        }
        else{
            throw new AuraHandledException('Record type ' + accounts[0].RecordType.DeveloperName + ' not supported by FinancialSummaryController');
        }
    }

    @AuraEnabled public static Response getPersonRollups(Id recordId){
        List<AggregateResult> aggregateResults = [
                Select count(id) recordCount, sum(Total_Acct_Value__c) balance, sum(FinServ__InsuredAmount__c) insuredAmount, RecordType.Name recordTypeName, FinServ__Managed__c managed
                from Finserv__FinancialAccount__c
                where FinServ__PrimaryOwner__c = :recordId
                group by RecordType.Name, FinServ__Managed__c
        ];

        decimal insuranceResult = (decimal)[Select sum(Face_Amount_2__c) amount from Insurance__c where Household_Insurance__c = :recordId][0].get('amount');
        if (insuranceResult == null){
            insuranceResult = 0;
        }

        Response response = new Response();
        response.totalInvestments = 0;
        response.totalBankDeposits = 0;
        response.totalInsurance = insuranceResult;
        decimal managedBalance = 0;
        decimal unmanagedBalance = 0;
        for (AggregateResult aggregateResult : aggregateResults){
            if (aggregateResult.get('recordTypeName') == 'Investment Account'){
                decimal balance = (Decimal)aggregateResult.get('balance');
                if (balance != null){
                    response.totalInvestments += balance;

                    if ((boolean)aggregateResult.get('managed')){
                        managedBalance += balance;
                    }else{
                        unmanagedBalance += balance;
                    }
                }
            }
            else if (aggregateResult.get('recordTypeName') == 'Bank Account' || aggregateResult.get('recordTypeName') == 'Checking Account' || aggregateResult.get('recordTypeName') == 'Savings Account'){
                decimal balance = (Decimal)aggregateResult.get('balance');
                if (balance != null){
                    response.totalBankDeposits += balance;

                    if ((boolean)aggregateResult.get('managed')){
                        managedBalance += balance;
                    }else{
                        unmanagedBalance += balance;
                    }
                }
            }
        }

        if (unmanagedBalance == 0){
            response.walletShare = 100;
        }else{
            response.walletShare = (managedBalance / (managedBalance + unmanagedBalance)) * 100;
        }
        return response;
    }

    @AuraEnabled public static Response getHouseholdRollups(Id recordId){
        List<AggregateResult> aggregateResults = [
                  Select sum(Total_Acct_Value__c) balance, sum(FinServ__InsuredAmount__c) insuredAmount, RecordType.Name recordTypeName, FinServ__Managed__c managed
                    from Finserv__FinancialAccount__c
                   where FinServ__Household__c = :recordId
                group by RecordType.Name, FinServ__Managed__c
        ];

        decimal insuranceResult = (decimal)[Select sum(Face_Amount_2__c) amount from Insurance__c where Household_Insurance__c = :recordId][0].get('amount');
        if (insuranceResult == null){
            insuranceResult = 0;
        }

        Response response = new Response();
        response.totalInvestments = 0;
        response.totalBankDeposits = 0;
        response.totalInsurance = insuranceResult;
        decimal managedBalance = 0;
        decimal unmanagedBalance = 0;
        for (AggregateResult aggregateResult : aggregateResults){
            if (aggregateResult.get('recordTypeName') == 'Investment Account'){
                decimal balance = (Decimal)aggregateResult.get('balance');
                if (balance != null){
                    response.totalInvestments += balance;

                    if ((boolean)aggregateResult.get('managed')){
                        managedBalance += balance;
                    }else{
                        unmanagedBalance += balance;
                    }
                }
            }
            else if (aggregateResult.get('recordTypeName') == 'Bank Account' || aggregateResult.get('recordTypeName') == 'Checking Account' || aggregateResult.get('recordTypeName') == 'Savings Account'){
                decimal balance = (Decimal)aggregateResult.get('balance');
                if (balance != null){
                    response.totalBankDeposits += balance;

                    if ((boolean)aggregateResult.get('managed')){
                        managedBalance += balance;
                    }else{
                        unmanagedBalance += balance;
                    }
                }
            }
        }

        if (unmanagedBalance == 0){
            response.walletShare = 100;
        }else{
            response.walletShare = (managedBalance / (managedBalance + unmanagedBalance)) * 100;
        }
        return response;
    }

    public class Response{
        @AuraEnabled Decimal totalInvestments{get;set;}
        @AuraEnabled Decimal totalBankDeposits{get;set;}
        @AuraEnabled Decimal totalInsurance{get;set;}
        @AuraEnabled Decimal walletShare{get;set;}

        Response(){
            totalInvestments = 0;
            totalBankDeposits = 0;
            totalInsurance = 0;
            walletShare = 0;
        }
    }
}