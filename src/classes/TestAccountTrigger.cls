@isTest 
private class TestAccountTrigger {

    @isTest
	private static void setServiceLevelInsert() {
		Service_Level_Defaults__c defaults = new Service_Level_Defaults__c (
			Tier_A_In_Person_Meetings_Year__c = 1,
			Tier_A_Portfolio_Review_Year__c = 2,
			Tier_A_Relationship_Calls_Year__c = 3,
			Tier_B_In_Person_Meetings_Year__c = 4,
			Tier_B_Portfolio_Review_Year__c = 5,
			Tier_B_Relationship_Calls_Year__c = 6,
			Tier_C_In_Person_Meetings_Year__c = 7,
			Tier_C_Portfolio_Review_Year__c = 8,
			Tier_C_Relationship_Calls_Year__c = 9,
			Tier_D_In_Person_Meetings_Year__c = 10,
			Tier_D_Portfolio_Review_Year__c = 11,
			Tier_D_Relationship_Calls_Year__c = 12,
			Tier_E_In_Person_Meetings_Year__c = 13,
			Tier_E_Portfolio_Review_Year__c = 14,
			Tier_E_Relationship_Calls_Year__c = 15
		);
		insert defaults;

		Test.startTest();

		Account acctA = new Account(
			Name = 'test account',
			Tier__c = 'A'
		);
		insert acctA;

		Account acctB = new Account(
			Name = 'test account',
			Tier__c = 'B'
		);
		insert acctB;

		Account acctC = new Account(
			Name = 'test account',
			Tier__c = 'C'
		);
		insert acctC;

		Account acctD = new Account(
			Name = 'test account',
			Tier__c = 'D'
		);
		insert acctD;

		Account acctE = new Account(
			Name = 'test account',
			Tier__c = 'E'
		);
		insert acctE;

		Test.stopTest();

		acctA = [
			SELECT
				In_Person_Meetings_Year__c,
				Portfolio_Reviews_Year__c,
				Relationship_Calls_Year__c
			FROM Account
			WHERE Id = :acctA.Id
		];

		System.assertEquals(defaults.Tier_A_In_Person_Meetings_Year__c,acctA.In_Person_Meetings_Year__c);
		System.assertEquals(defaults.Tier_A_Portfolio_Review_Year__c,acctA.Portfolio_Reviews_Year__c);
		System.assertEquals(defaults.Tier_A_Relationship_Calls_Year__c,acctA.Relationship_Calls_Year__c);

		acctB = [
			SELECT
				In_Person_Meetings_Year__c,
				Portfolio_Reviews_Year__c,
				Relationship_Calls_Year__c
			FROM Account
			WHERE Id = :acctB.Id
		];

		System.assertEquals(defaults.Tier_B_In_Person_Meetings_Year__c,acctB.In_Person_Meetings_Year__c);
		System.assertEquals(defaults.Tier_B_Portfolio_Review_Year__c,acctB.Portfolio_Reviews_Year__c);
		System.assertEquals(defaults.Tier_B_Relationship_Calls_Year__c,acctB.Relationship_Calls_Year__c);

		acctC = [
			SELECT
				In_Person_Meetings_Year__c,
				Portfolio_Reviews_Year__c,
				Relationship_Calls_Year__c
			FROM Account
			WHERE Id = :acctC.Id
		];

		System.assertEquals(defaults.Tier_C_In_Person_Meetings_Year__c,acctC.In_Person_Meetings_Year__c);
		System.assertEquals(defaults.Tier_C_Portfolio_Review_Year__c,acctC.Portfolio_Reviews_Year__c);
		System.assertEquals(defaults.Tier_C_Relationship_Calls_Year__c,acctC.Relationship_Calls_Year__c);

		acctD = [
			SELECT
				In_Person_Meetings_Year__c,
				Portfolio_Reviews_Year__c,
				Relationship_Calls_Year__c
			FROM Account
			WHERE Id = :acctD.Id
		];

		System.assertEquals(defaults.Tier_D_In_Person_Meetings_Year__c,acctD.In_Person_Meetings_Year__c);
		System.assertEquals(defaults.Tier_D_Portfolio_Review_Year__c,acctD.Portfolio_Reviews_Year__c);
		System.assertEquals(defaults.Tier_D_Relationship_Calls_Year__c,acctD.Relationship_Calls_Year__c);

		acctE = [
			SELECT
				In_Person_Meetings_Year__c,
				Portfolio_Reviews_Year__c,
				Relationship_Calls_Year__c
			FROM Account
			WHERE Id = :acctE.Id
		];

		System.assertEquals(defaults.Tier_E_In_Person_Meetings_Year__c,acctE.In_Person_Meetings_Year__c);
		System.assertEquals(defaults.Tier_E_Portfolio_Review_Year__c,acctE.Portfolio_Reviews_Year__c);
		System.assertEquals(defaults.Tier_E_Relationship_Calls_Year__c,acctE.Relationship_Calls_Year__c);
	}

    @isTest
	private static void createPercents() {
        
        Account testAccount = new Account(Name = 'Test', Cash_Value__c = 1, Equity_Value__c = 2, Fixed_Income_Value__c = 3, Other_Value__c = 4);
        
        insert testAccount;
        
        Household_Percent__c perc = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Cash'];  
        System.assertEquals(testAccount.Cash_Value__c, perc.Value__c);
        
    }
    
    @isTest
	private static void createPercentsNullValueRecords(){
        
		Test.startTest();
        Account testAccount = new Account(Name = 'Test', Cash_Value__c = null, Equity_Value__c = null, Fixed_Income_Value__c = null, Other_Value__c = null);
        
        insert testAccount;
		Test.stopTest();
        
        Household_Percent__c perc = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Cash'];  
        System.assertEquals(0.00, perc.Value__c);
        
        Household_Percent__c percF = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Fixed Income'];  
        System.assertEquals(0.00, percF.Value__c);
        
        Household_Percent__c percO = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Other'];  
        System.assertEquals(0.00, percO.Value__c);
        
        Household_Percent__c percE = [SELECT Id, Value__c FROM Household_Percent__c WHERE Household_Account__c = :testAccount.Id AND Type__c = 'Equities'];  
        System.assertEquals(0.00, percE.Value__c);
        
    }

    static Id hh_id, client_id;
    
    @isTest
    public static void phoneAndEmail_testEmail() {
		Test.startTest();

        Account client05 = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com', 
                                       Demo_Email__c = 'demo@email.com');
        insert client05;
        client05 = [select PersonContactId from Account where id = :client05.id];
        
        Account hh05 = new Account (RecordTypeId=hh_id, Name='email_hh-05',  
                                    FinServ__PrimaryContact__c = client05.PersonContactId);
        insert hh05;
		Test.stopTest();
    }
    
    @isTest
    public static void phoneAndEmail_testPhone1() {

        // pull the IDs for record types.
        List<RecordType> rtypes = [Select Name, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
            
        for(RecordType rt: rtypes) {
            accountRecordTypes.put(rt.Name,rt.Id);
        }
        
        Id hh_id = accountRecordTypes.get('Household');
        Id client_id = accountRecordTypes.get('Contact Client/Prospect');
        
		Test.startTest();

        Account client0101 = new Account(RecordTypeId=client_id, LastName='Client-01-01', 
                                         Phone='8045551212'
                                        );
        insert client0101;
        
        // validate
        Account a = [Select Phone, PhoneB__c 
                     FROM Account 
                     where LastName='Client-01-01'];
        System.assertEquals('8045551212', a.PhoneB__c);
        
        Contact c2 = new Contact (LastName = 'lname', Email = 'test@junk.com', Phone='8047771212');
        insert c2;
        Account client0102 = new Account(RecordTypeId=client_id, LastName='Client-01-02', 
                                         PersonHomePhone='8045551212', 
                                         FinServ__PrimaryContact__c = c2.Id);
        insert client0102;
        
        Account client0103 = new Account(RecordTypeId=client_id, LastName='Client-01-03', 
                                         PersonHomePhone='8045551212');
        insert client0103;
        
		Test.stopTest();

        // validate
        Account x = [Select Phone, PhoneB__c, PersonHomePhone
                     FROM Account 
                     where LastName='Client-01-03'];
        System.assertEquals('8045551212', x.PhoneB__c);
	}
	
    @isTest
    public static void phoneAndEmail_testPhone2() {

        // pull the IDs for record types.
        List<RecordType> rtypes = [Select Name, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
            
        for(RecordType rt: rtypes) {
            accountRecordTypes.put(rt.Name,rt.Id);
        }
        
        Id hh_id = accountRecordTypes.get('Household');
        Id client_id = accountRecordTypes.get('Contact Client/Prospect');
        
		Test.startTest();
        
        Contact c4 = new Contact (LastName = 'lname4', Email = 'test4@junk4.com', MobilePhone='8047771212');
        insert c4;
        Account client0104 = new Account(RecordTypeId=client_id, LastName='Client-01-04',  
                                         FinServ__PrimaryContact__c = c4.Id);
        insert client0104;

		Test.stopTest();
        
        // validate
        Account b = [Select Phone, PhoneB__c, PersonHomePhone
                     FROM Account 
                     where LastName='Client-01-04'];
        System.assertEquals('8047771212', b.PhoneB__c);
    }
    
    // following static code is run before each test and 
    // keep its scope for the test it is going to run. 
    // (like a static variable)
    // - Deepak.
    static {
        // pull the IDs for record types.
        List<RecordType> rtypes = [Select Name, Id From RecordType
                                   where sObjectType='Account' and isActive=true];
        Map<String,String> accountRecordTypes = new Map<String,String>{};
            
            for(RecordType rt: rtypes) {
                accountRecordTypes.put(rt.Name,rt.Id);
            }
        
        hh_id = accountRecordTypes.get('Household');
        client_id = accountRecordTypes.get('Contact Client/Prospect');
    }
}