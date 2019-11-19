@isTest
public class FinancialAccountRollupBatchableTest {
    
    @TestSetup static void setupData() {
        // pull the IDs for record types.
        List<RecordType> rtypes = [Select Name, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes) {
            accountRecordTypes.put(rt.Name,rt.Id);
        }

        Id hh_id = accountRecordTypes.get('Household');
        Id client_id = accountRecordTypes.get('Contact Client/Prospect');
         // create Households.
        Account hh01 = new Account (RecordTypeId=hh_id, Name='Household-01');
        Account hh02 = new Account (RecordTypeId=hh_id, Name='Household-02');
        insert hh01;
        insert hh02;
        Account hh03 = new Account (RecordTypeId=hh_id, Name='Household-03');
        insert hh03;
        Account hh_no_fa = new Account (RecordTypeId=hh_id, Name='Household-no-fin-accts');
        insert hh_no_fa;
        
        // create clients
        Account client0101 = new Account(RecordTypeId=client_id, LastName='Client-01-01');
        Account client0102 = new Account(RecordTypeId=client_id, LastName='Client-01-02');
        insert client0101;
        insert client0102;
        
        Account client0201 = new Account(RecordTypeId=client_id, LastName='Client-02-01');
        Account client0202 = new Account(RecordTypeId=client_id, LastName='Client-02-02');
        insert client0201;
        insert client0202;
        
        Account client0301 = new Account(RecordTypeId=client_id, LastName='Client-03-01');
        Account client0302 = new Account(RecordTypeId=client_id, LastName='Client-03-02');
        insert client0301;
        insert client0302;
        
        // create relationship for the clients
        Account a0101 = [Select PersonContactId From Account Where Id = :client0101.id];
        Account a0102 = [Select PersonContactId From Account Where Id = :client0102.id];
        AccountContactRelation acr0101 = new AccountContactRelation(AccountId=hh01.id, ContactId=a0101.PersonContactId, IsActive=True, Roles='Client');
        AccountContactRelation acr0102 = new AccountContactRelation(AccountId=hh01.id, ContactId=a0102.PersonContactId, IsActive=True, Roles='Client');
        insert acr0101;
        insert acr0102;
        
        Account a0201 = [Select PersonContactId From Account Where Id = :client0201.id];
        Account a0202 = [Select PersonContactId From Account Where Id = :client0202.id];
        AccountContactRelation acr0201 = new AccountContactRelation(AccountId=hh02.id, ContactId=a0201.PersonContactId, IsActive=True, Roles='Client');
        AccountContactRelation acr0202 = new AccountContactRelation(AccountId=hh02.id, ContactId=a0202.PersonContactId, IsActive=True, Roles='Client');
        insert acr0201;
        insert acr0202;
        
        Account a0301 = [Select PersonContactId From Account Where Id = :client0301.id];
        Account a0302 = [Select PersonContactId From Account Where Id = :client0302.id];
        AccountContactRelation acr0301 = new AccountContactRelation(AccountId=hh03.id, ContactId=a0301.PersonContactId, IsActive=True, Roles='Client');
        AccountContactRelation acr0302 = new AccountContactRelation(AccountId=hh03.id, ContactId=a0302.PersonContactId, IsActive=True, Roles='Client');
        insert acr0301;
        insert acr0302;
        
        // create financial accounts
        FinServ__FinancialAccount__c fin010101 = new FinServ__FinancialAccount__c(Name='fin0101-(Bailey)', FinServ__PrimaryOwner__c = client0101.Id,
                                                                                  FinServ__Household__c = hh01.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 10);
        FinServ__FinancialAccount__c fin010102 = new FinServ__FinancialAccount__c(Name='fin0101-(Jim)', FinServ__PrimaryOwner__c = client0101.Id,
                                                                                  FinServ__Household__c = hh01.Id, 
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 10);
        insert fin010101;
        insert fin010102;
        
        FinServ__FinancialAccount__c fin020101 = new FinServ__FinancialAccount__c(Name='fin0201-(Bailey)', FinServ__PrimaryOwner__c = client0201.Id,
                                                                                  FinServ__Household__c = hh02.Id, 
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 10);
        FinServ__FinancialAccount__c fin020201 = new FinServ__FinancialAccount__c(Name='fin0202-(Jim)', FinServ__PrimaryOwner__c = client0202.Id,
                                                                                  FinServ__Household__c = hh02.Id, 
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 10);
        insert fin020101;
        insert fin020201;
        
        FinServ__FinancialAccount__c fin030101 = new FinServ__FinancialAccount__c(Name='fin0301-(Aric)', FinServ__PrimaryOwner__c = client0301.Id,
                                                                                  FinServ__Household__c = hh03.Id, 
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 10);
        insert fin030101;
    }
    
    @isTest
    static void doTest(){
        Test.startTest();
        Database.executeBatch(new FinancialAccountRollupBatchable());
        Test.stopTest(); 
    }
}