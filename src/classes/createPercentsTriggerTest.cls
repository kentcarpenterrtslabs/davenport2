@isTest
public class createPercentsTriggerTest {

    @isTest static void testCreatePercentRecords(){
        
        Account testAccount = new Account(Name = 'Test', Cash_Value__c = 1, Equity_Value__c = 2, Fixed_Income_Value__c = 3, Other_Value__c = 4);
        
        insert testAccount;
        
        Household_Percent__c perc = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Cash'];  
        System.assertEquals(testAccount.Cash_Value__c, perc.Value__c);
        
    }
    
    @isTest static void testCreateNullValueRecords(){
        
        Account testAccount = new Account(Name = 'Test', Cash_Value__c = null, Equity_Value__c = null, Fixed_Income_Value__c = null, Other_Value__c = null);
        
        insert testAccount;
        
        Household_Percent__c perc = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Cash'];  
        System.assertEquals(0.00, perc.Value__c);
        
        Household_Percent__c percF = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Fixed Income'];  
        System.assertEquals(0.00, percF.Value__c);
        
        Household_Percent__c percO = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Other'];  
        System.assertEquals(0.00, percO.Value__c);
        
        Household_Percent__c percE = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Equities'];  
        System.assertEquals(0.00, percE.Value__c);
        
    }
    
    
}