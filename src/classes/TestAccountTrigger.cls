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
    public static void testEmail_PrimaryContactSetOnInsert() {

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com', 
                                       Demo_Email__c = 'demo@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.Id
		];
        
        Account household = new Account (RecordTypeId=hh_id, Name='email_hh-05',  
										 FinServ__PrimaryContact__c = primaryContact.PersonContactId);
		Test.startTest();
        insert household;
		Test.stopTest();

		household = [
			SELECT
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :household.Id
		];

		System.assertEquals(primaryContact.Daml_Email__c, household.Daml_Email__c);
		System.assertEquals(primaryContact.Demo_Email__c, household.Demo_Email__c);
    }
    
    @isTest
    public static void testEmail_PrimaryContactSetOnUpdate() {
		Test.startTest();

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com', 
                                       Demo_Email__c = 'demo@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.Id
		];
        
        Account household = new Account (RecordTypeId=hh_id, Name='email_hh-05');
        insert household;
		
		household = [
			SELECT
				FinServ__PrimaryContact__c
			FROM Account
			WHERE Id = :household.Id
		];

		household.FinServ__PrimaryContact__c = primaryContact.PersonContactId;
		update household;

		Test.stopTest();

		household = [
			SELECT
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :household.Id
		];

		System.assertEquals(primaryContact.Daml_Email__c, household.Daml_Email__c);
		System.assertEquals(primaryContact.Demo_Email__c, household.Demo_Email__c);
    }
     
    @isTest
    public static void testEmail_UpdateParentWhenPrimaryContactDamlEmailChanged() {

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com', 
                                       Demo_Email__c = 'demo@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.Id
		];
        
		Test.startTest();

        Account household = new Account (RecordTypeId=hh_id, Name='email_hh-05',
										 FinServ__PrimaryContact__c = primaryContact.PersonContactId);
        insert household;

        primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.id
		];

		primaryContact.Daml_Email__c = 'changed' + primaryContact.Daml_Email__c;
		update primaryContact;

		Test.stopTest();

		household = [
			SELECT
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :household.Id
		];

		System.assertEquals(primaryContact.Daml_Email__c, household.Daml_Email__c);
		System.assertEquals(primaryContact.Demo_Email__c, household.Demo_Email__c);
    }
    

    @isTest
    public static void testEmail_UpdateParentWhenPrimaryContactDemoEmailChanged() {

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com', 
                                       Demo_Email__c = 'demo@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId
			FROM Account
			WHERE Id = :primaryContact.Id
		];
        
		Test.startTest();

        Account household = new Account (RecordTypeId=hh_id, Name='email_hh-05',
										 FinServ__PrimaryContact__c = primaryContact.PersonContactId);
        insert household;

        primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.id
		];

		primaryContact.Demo_Email__c = 'changed' + primaryContact.Demo_Email__c;
		update primaryContact;

		Test.stopTest();

		household = [
			SELECT
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :household.Id
		];

		System.assertEquals(primaryContact.Daml_Email__c, household.Daml_Email__c);
		System.assertEquals(primaryContact.Demo_Email__c, household.Demo_Email__c);
    }
     
    @isTest
    public static void testEmail_PersonEmailSetToDamlEmailAfterInsert() {

		Test.startTest();

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Daml_Email__c = 'daml@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.Id
		];

		Test.stopTest();

        Account primaryContactActual = [
			SELECT
				PersonEmail,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.id
		];

		System.assertEquals(primaryContact.Daml_Email__c, primaryContactActual.PersonEmail);
    }
     
    @isTest
    public static void testEmail_PersonEmailSetToDemoEmailAfterInsert() {

		Test.startTest();

        Account primaryContact = new Account(RecordTypeId=client_id, LastName='email-05-01', 
                                       Demo_Email__c = 'demo@email.com');
        insert primaryContact;

		primaryContact = [
			SELECT
				PersonContactId,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.Id
		];

		Test.stopTest();

        Account primaryContactActual = [
			SELECT
				PersonEmail,
				Daml_Email__c,
				Demo_Email__c
			FROM Account
			WHERE Id = :primaryContact.id
		];

		System.assertEquals(primaryContact.Demo_Email__c, primaryContactActual.PersonEmail);
    }


    @isTest
    public static void testPhones() {

		Contact primaryContact = new Contact(LastName='primaryContact', Phone='8045551212');
		insert primaryContact;

		Test.startTest();

		List<Account> toInsert = new List<Account>();

        Account acctPhone = new Account(RecordTypeId=client_id, LastName='acctPhone', Phone='8045551212');
        toInsert.add(acctPhone);

        Account acctPersonMobilePhone = new Account(RecordTypeId=client_id, LastName='testPersonMobilePhone', PersonMobilePhone='8045551212');
        toInsert.add(acctPersonMobilePhone);

        Account acctPersonHomePhone = new Account(RecordTypeId=client_id, LastName='vPersonHomePhone', PersonHomePhone='8045551212');
        toInsert.add(acctPersonHomePhone);

        Account acctContact_Work_Phone = new Account(RecordTypeId=client_id, LastName='testContact_Work_Phone__pc', Contact_Work_Phone__pc='8045551212');
        toInsert.add(acctContact_Work_Phone);

        Account acctPrimary_Contact_Phone = new Account(RecordTypeId=client_id, LastName='testPrimary_Contact_Phone__c', FinServ__PrimaryContact__c = primaryContact.Id);
        toInsert.add(acctPrimary_Contact_Phone);
         
		insert toInsert;

		Test.stopTest();

        // validate
        
        Account acctPhoneAfter = [SELECT PhoneB__c FROM Account WHERE Id = :acctPhone.Id];
		System.assertEquals(acctPhone.Phone, acctPhoneAfter.PhoneB__c);
        
        Account acctPersonMobilePhoneAfter = [SELECT PhoneB__c FROM Account WHERE Id = :acctPersonMobilePhone.Id];
		System.assertEquals(acctPersonMobilePhone.PersonMobilePhone, acctPersonMobilePhoneAfter.PhoneB__c);
        
        Account acctPersonHomePhoneAfter = [SELECT PhoneB__c FROM Account WHERE Id = :acctPersonHomePhone.Id];
		System.assertEquals(acctPersonHomePhone.PersonHomePhone, acctPersonHomePhoneAfter.PhoneB__c);
        
        Account acctContact_Work_PhoneAFter = [SELECT PhoneB__c FROM Account WHERE Id = :acctContact_Work_Phone.Id];
		System.assertEquals(acctContact_Work_Phone.Contact_Work_Phone__pc, acctContact_Work_PhoneAFter.PhoneB__c);
        
        Account acctPrimary_Contact_PhoneAfter = [SELECT PhoneB__c FROM Account WHERE Id = :acctPrimary_Contact_Phone.Id];
		System.assertEquals(primaryContact.Phone, acctPrimary_Contact_PhoneAfter.PhoneB__c);
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