/**
 * Created by Eric Stansbury on 6/28/2019.
 */

public with sharing class HouseholdRollupsController {
    @AuraEnabled public static Response getRollups(Id recordId){
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
            // else if (aggregateResult.get('recordTypeName') == 'Insurance Policy'){
            //     decimal insuredAmount = (Decimal)aggregateResult.get('insuredAmount');
            //     if (insuredAmount != null){
            //         response.totalInsurance += insuredAmount;
            //     }
            // }
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