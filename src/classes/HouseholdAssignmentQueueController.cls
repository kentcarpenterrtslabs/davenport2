/**
 * Created by Eric Stansbury on 4/29/2019.
 */

public with sharing class HouseholdAssignmentQueueController {
    public static final String HOUSEHOLD_RECORDTYPE_NAME = 'Household';

    @AuraEnabled public static List<HouseholdAssignmentRow> getRows(){
        List<FinServ__FinancialAccount__c> finAccts = getUnassignedFinancialAccounts();
        List<HouseholdAssignmentRow> rows = new List<HouseholdAssignmentRow>();
        for (FinServ__FinancialAccount__c finAcct : finAccts){
            // TODO: suggested households
            HouseholdAssignmentRow row = new HouseholdAssignmentRow();
            row.financialAccount = finAcct;
            row.household = null;
            rows.add(row);
        }
        return rows;
    }

    static List<FinServ__FinancialAccount__c> getUnassignedFinancialAccounts(){
        Id userId = System.UserInfo.getUserId();

        List<FinServ__FinancialAccount__c> finAccts = [Select Id,
                Name, Suggested_Household__c
            from FinServ__FinancialAccount__c
            where FinServ__Household__r.Placeholder_Household__c = true OR
                  FinServ__Household__c = NULL 
            limit 50
        ];
        return finAccts;
    }

    @AuraEnabled public static String getSearchableFields(){
        return JSON.serialize(Schema.SObjectType.Account.fieldSets.Household_Assignment_Search_Fields.getFields());
    }

    @AuraEnabled public static String getResultFields(){
        return JSON.serialize(Schema.SObjectType.Account.fieldSets.Household_Assignment_Result_Fields.getFields());
    }

    @AuraEnabled public static String getNewHouseholdDisplayFields(){
        return JSON.serialize(Schema.SObjectType.Account.fieldSets.Household_Assignment_New_Display_Fields.getFields());
    }

    @AuraEnabled
    public static Id getNewHouseholdRecordTypeId() {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId();
    }

    @AuraEnabled public static List<Account> searchHouseholds(Map<String,String> paramsMap){
        if (paramsMap == null || paramsMap.keySet().size() == 0){
            return new List<Account>();
        }
        String selectString = '';
        for (FieldSetMember fsm : Schema.SObjectType.Account.fieldSets.Household_Assignment_Result_Fields.getFields()){
            if (String.isNotBlank(selectString)){
                selectString += ', ';
            }
            selectString += fsm.getFieldPath();
        }
        String whereString = '';
        for (String param : paramsMap.keySet()){
            if (String.isNotBlank(whereString)){
                whereString += ' and ';
            }
            if (Schema.SObjectType.Account.fields.getMap().get(param).getDescribe().getType() == DisplayType.REFERENCE){
                whereString += param +' = \'' + paramsMap.get(param) + '\''; // use exact matching for lookups, LIKE otherwise
            }else{
                whereString += param +' LIKE \'%' + paramsMap.get(param) + '%\'';
            }
        }

        String queryString = 'SELECT ' + selectString + ' FROM Account WHERE ' + whereString + ' and RecordType.Name = \'' + HOUSEHOLD_RECORDTYPE_NAME + '\'';
        System.debug('queryString:' + queryString);
        return Database.query(queryString);
    }

    @AuraEnabled public static void assignHousehold(Id householdId, Id financialAccountId){
        FinServ__FinancialAccount__c finAcct = [select id, finserv__household__c from finserv__financialaccount__c where id = :financialAccountId];
        finAcct.finserv__household__c = householdId;
        update finAcct;
    }

    @AuraEnabled public static String getComparisonRows(Id householdId, Id financialAccountId){
        Account household = householdId != null ? [Select Id, Name, BillingStreet, FinServ__TaxId__pc	 from Account where Id = :householdId limit 1] : null;
        FinServ__FinancialAccount__c finAcct = [Select Id, Name, FinServ__Address1__c, FinServ__TaxID__c from FinServ__FinancialAccount__c where Id = :financialAccountId limit 1];
        List<ComparisonRow> rows = new List<ComparisonRow>();
        ComparisonRow row = new ComparisonRow();
        row.label = 'Name';
        if (household != null) row.householdValue = household.Name;
        row.financialAccountValue = finAcct.Name;
        //row.color = (row.householdValue == row.financialAccountValue) ? 'green' : 'red';
        //if (row.householdValue == null) row.color = null;
        //rows.add(row);
        //row = new ComparisonRow();
        //row.label = 'Address Street';
        //if (household != null) row.householdValue = household.BillingStreet;
        //row.financialAccountValue = finAcct.FinServ__Address1__c;
        //row.color = (row.householdValue == row.financialAccountValue) ? 'green' : 'red';
        //if (row.householdValue == null) row.color = null;
        //rows.add(row);
        //row = new ComparisonRow();
        //row.label = 'Tax ID';
        //if (household != null) row.householdValue = household.FinServ__TaxId__pc;
        //row.financialAccountValue = finAcct.FinServ__TaxID__c;
        //row.color = (row.householdValue == row.financialAccountValue) ? 'green' : 'red';
        //if (row.householdValue == null) row.color = null;
        rows.add(row);
        return JSON.serialize(rows);
    }

    class ComparisonRow{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String householdValue{get;set;}
        @AuraEnabled public String financialAccountValue{get;set;}
        @AuraEnabled public String color{get;set;}
    }

    @TestVisible class HouseholdAssignmentRow{
        @AuraEnabled public FinServ__FinancialAccount__c financialAccount{get;set;}
        @AuraEnabled public Account household{get;set;}
    }
}