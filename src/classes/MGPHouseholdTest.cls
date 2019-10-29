/**
 * Created by Eric Stansbury on 5/9/2019.
 */

@isTest
public class MGPHouseholdTest {
    @isTest static void doTest(){
        //Id householdId = [select id from account limit 1][0].Id;
        Id householdId = [
			SELECT
				Id
			FROM Account
			WHERE Name = 'Household-02'
			LIMIT 1][0].Id;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/Household/' + householdId;
        RestContext.request  = req;
        RestContext.response = res;
        Test.startTest();
        MGPHousehold.doGet();
        Test.stopTest();
    }

    //@isTest
	//static void testGenerateXml(){
        //Id householdId = [
			//SELECT
				//Id
			//FROM Account
			//WHERE Name = 'Household-02'
			//LIMIT 1][0].Id;
        //String result = MGPHousehold.buildRequestBody(householdId);
        //System.assertNotEquals(result, null);
        //System.debug(result);
    //}

    //@isTest static void testBuildHoldings(){
        //MGPHousehold.buildHoldings(new XmlStreamWriter(), new List<FinServ__FinancialHolding__c>{
            //new FinServ__FinancialHolding__c(
				//Id = Id.valueOf('000000000000000000'),
                //Cost_Basis__c = 1234,
                //Quantity__c = 1234
            //)
        //});
    //}

    //@isTest static void testBuildCoclients(){
        //MGPHousehold.buildCoclients(new XmlStreamWriter(), new List<Contact>{
                //new Contact(
					//Id = Id.valueOf('000000000000000000'),
                    //LastName = 'Test',
                    //MailingState = 'VA'
                //)
        //});
    //}

    //@isTest static void testBuildClient(){
        //MGPHousehold.buildClient(new XmlStreamWriter(), new Contact(
				//Id = Id.valueOf('000000000000000000'),
                //LastName = 'Test'
        //));
    //}

    //@isTest static void testBuildInvestmentAssets(){
        //MGPHousehold.buildInvestmentAssets(new XmlStreamWriter(), new List<FinServ__FinancialAccount__c>{
            //new FinServ__FinancialAccount__c(
 				//Id = Id.valueOf('000000000000000000'),
				//Name = 'Test'
			//)
				////FinServ__FinancialHoldings__r = 
					////new List<FinServ__FinancialHolding__c>{
						////new FinServ__FinancialHolding__c(
								////Cost_Basis__c = 1234,
								////Quantity__c = 1234
						////)
					////}
            ////)
        //});
    //}

	@TestSetup
	public static void setupData() {
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
       
        Account hh02 = new Account (RecordTypeId=hh_id, Name='Household-02');
       
        insert hh02;
        Account hh03 = new Account (RecordTypeId=hh_id, Name='Household-03');
        insert hh03;
        Account hh04 = new Account (RecordTypeId=hh_id, Name='Household-04 (Lee)');
        insert hh04;
        Account hh_no_fa = new Account (RecordTypeId=hh_id, Name='Household-no-fin-accts');
        insert hh_no_fa;
       
        // create clients
        Account client0101 = new Account(RecordTypeId=client_id, LastName='Client-01-01', Demo_Email__c = 'client0101@demoemail.com');
        Account client0102 = new Account(RecordTypeId=client_id, LastName='Client-01-02', Demo_Email__c = 'client0102@demo.com');
        insert client0101;
        insert client0102;
        client0101 = [select Id, PersonContactId from Account where id = :client0101.id];
        client0102 = [select Id, PersonContactId from Account where id = :client0102.id];
        System.debug('DataSetup: Assigning PrimaryContact: ' + client0102.PersonContactId);
        Account hh01 = new Account (RecordTypeId=hh_id, Name='Household-01', FinServ__PrimaryContact__c  = client0102.PersonContactId);
        insert hh01;
        hh01 = [select Id, BillingCity from Account where id = :hh01.id];
        hh01.BillingCity = 'x';
        update hh01;
       
        Account client0201 = new Account(RecordTypeId=client_id, LastName='Client-02-01');
        Account client0202 = new Account(RecordTypeId=client_id, LastName='Client-02-02');
        insert client0201;
        insert client0202;
       
        Account client0301 = new Account(RecordTypeId=client_id, LastName='Client-03-01');
        Account client0302 = new Account(RecordTypeId=client_id, LastName='Client-03-02');
        insert client0301;
        insert client0302;
       
        Account client0401 = new Account(RecordTypeId=client_id, LastName='Client-04-01 (Lee)');
        Account client0402 = new Account(RecordTypeId=client_id, LastName='Client-04-02 (Lee)');
        insert client0401;
        insert client0402;
       
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
       
        Account a0401 = [Select PersonContactId From Account Where Id = :client0401.id];
        Account a0402 = [Select PersonContactId From Account Where Id = :client0402.id];
        AccountContactRelation acr0401 = new AccountContactRelation(AccountId=hh04.id, ContactId=a0401.PersonContactId, IsActive=True, Roles='Client');
        AccountContactRelation acr0402 = new AccountContactRelation(AccountId=hh04.id, ContactId=a0402.PersonContactId, IsActive=True, Roles='Client');
        insert acr0401;
        insert acr0402;
       
        // create Rep Records.
        Rep__c rep01 = new Rep__c(Name='Rep01', Rep_Number__c = 'RP01');
        Rep__c rep02 = new Rep__c(Name='Rep02', Rep_Number__c = 'RP02');
        Rep__c rep03 = new Rep__c(Name='Rep03', Rep_Number__c = 'RP03');
        Rep__c rep04 = new Rep__c(Name='Rep04', Rep_Number__c = 'RP04');
        Rep__c rep05 = new Rep__c(Name='Rep05', Rep_Number__c = 'RP05');
        insert rep01;
        insert rep02;
        insert rep03;
        insert rep04;
        insert rep05;
       
        // create financial accounts
        FinServ__FinancialAccount__c fin010101 = new FinServ__FinancialAccount__c(Name='fin0101-(Bailey)', FinServ__PrimaryOwner__c = client0101.Id,
                                                                                  FinServ__Household__c = hh01.Id,
                                                                                  Rep__c = rep01.Id,
                                                                                  //Rep_Number__c = rep01.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        FinServ__FinancialAccount__c fin010102 = new FinServ__FinancialAccount__c(Name='fin0101-(Jim)', FinServ__PrimaryOwner__c = client0101.Id,
                                                                                  FinServ__Household__c = hh01.Id,
                                                                                  Rep__c = rep02.Id,
                                                                                  //Rep_Number__c = rep02.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        insert fin010101;
        insert fin010102;
       
        FinServ__FinancialAccount__c fin020101 = new FinServ__FinancialAccount__c(Name='fin0201-(Bailey)', FinServ__PrimaryOwner__c = client0201.Id,
                                                                                  FinServ__Household__c = hh02.Id,
                                                                                  Rep__c = rep01.Id,
                                                                                  //Rep_Number__c = rep01.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        FinServ__FinancialAccount__c fin020201 = new FinServ__FinancialAccount__c(Name='fin0202-(Jim)', FinServ__PrimaryOwner__c = client0202.Id,
                                                                                  FinServ__Household__c = hh02.Id,
                                                                                  Rep__c = rep02.Id,
                                                                                  //Rep_Number__c = rep02.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        insert fin020101;
        insert fin020201;
       
        FinServ__FinancialAccount__c fin030101 = new FinServ__FinancialAccount__c(Name='fin0301-(Aric)', FinServ__PrimaryOwner__c = client0301.Id,
                                                                                  FinServ__Household__c = hh03.Id,
                                                                                  Rep__c = rep03.Id,
                                                                                  //Rep_Number__c = rep03.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        insert fin030101;
       
        FinServ__FinancialAccount__c fin040101 = new FinServ__FinancialAccount__c(Name='fin0401-(Lee)', FinServ__PrimaryOwner__c = client0401.Id,
                                                                                  FinServ__Household__c = hh04.Id,
                                                                                  Rep__c = rep04.Id,
                                                                                  //Rep_Number__c = rep04.Id,
                                                                                  Cash_Value__c = 10,
                                                                                  Equity_Value__c = 10,
                                                                                  Fixed_Income_Value__c = 10,
                                                                                  Other_Value__c = 10,
                                                                                  FinServ__Balance__c = 40);
        insert fin040101;
        // Create Rep Security Records
        // McElhaney, Jon - jmcelhaney (RP01)
        // Jim Whelen - jwhelen (RP02)
        // Admin - salesforce (RP03)
        // Lee Chapman - lchapman (RP04)
        // Hargroves, Herbert - hhargroves (RP05)
        // Colin May - cmay
        Rep_Security__c rs01 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='jmcelhaney', Rep_Number__c='RP01');
        Rep_Security__c rs02 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='jwhelen',   Rep_Number__c='RP02');
        Rep_Security__c rs03 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='salesforce',   Rep_Number__c='RP03');
        Rep_Security__c rs04 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='lchapman',  Rep_Number__c='RP04');
        Rep_Security__c rs05 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='hhargroves',  Rep_Number__c='RP05');
        insert rs01;
        insert rs02;
        insert rs03;
        insert rs04;
        insert rs05;
       
        //Rep_Security__c rs06 = new Rep_Security__c(Type__c='Rep',Davenport_Username__c='lchapman',  Rep_Number__c='RP01');
        //insert rs06;
       
        // Rep Splits
     
        Rep_Split__c rsp01 = new Rep_Split__c (Split_Rep__c = rep01.Id, Grant_Access_to_Rep__c = rep04.id);
        insert rsp01;
        Rep_Split__c rsp02 = new Rep_Split__c (Split_Rep__c = rep02.Id, Grant_Access_to_Rep__c = rep04.id);
        insert rsp02;


        // Account Splits
       
        Account_Split__c asc01 = new Account_Split__c (Name = 'asc01', Financial_Account__c  = fin010101.id, Rep__c = rep05.id);
        insert asc01;

        // UPI Records.
        Rep_Security__c upi01 = new Rep_Security__c(Type__c='UPI',Davenport_Username__c='lchapman', Rep_Number__c='RP01');
        Rep_Security__c upi02 = new Rep_Security__c(Type__c='UPI',Davenport_Username__c='lchapman', Rep_Number__c='RP02');
        Rep_Security__c upi03 = new Rep_Security__c(Type__c='UPI',Davenport_Username__c='lchapman', Rep_Number__c='RP03');
        Rep_Security__c upi04 = new Rep_Security__c(Type__c='UPI',Davenport_Username__c='lchapman', Rep_Number__c='RP05');
        insert upi01;
        insert upi02;
        insert upi03;
        insert upi04;
       
        // circular reference in UPI
        Rep_Security__c upi05 = new Rep_Security__c(Type__c='UPI',Davenport_Username__c='jmcelhaney', Rep_Number__c='RP04');
        insert upi05;
	}

    //@TestSetup
	//public static void setupData(){

        //Account individual1 = new Account(
            //FirstName = 'IndFirst',
            //LastName = 'IndLast',
            //PersonBirthdate =  Date.valueOf('1975-10-23 00:00:00'),
            //PersonMailingState = 'VA',
            //FinServ__Gender__pc = 'Male',
			//FinServ__MaritalStatus__pc = 'Married',
            //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SecurityAssignmentTestFactory.INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId()
        //);
        //insert individual1;

        //Account individual2 = new Account(
            //FirstName = 'IndFirst2',
            //LastName = 'IndLast2',
            //PersonBirthdate =  Date.valueOf('1968-07-15 00:00:00'),
            //PersonMailingState = 'VA',
            //FinServ__Gender__pc = 'Female',
			//FinServ__MaritalStatus__pc = 'Married',
            //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SecurityAssignmentTestFactory.INDIVIDUAL_RECORDTYPE_NAME).getRecordTypeId()
        //);
        //insert individual2;

		//individual1 = [
			//SELECT
				//Id,
				//PersonContactId
			//FROM Account
			//WHERE Id = :individual1.Id
		//];

		//individual2 = [
			//SELECT
				//Id,
				//PersonContactId
			//FROM Account
			//WHERE Id = :individual2.Id
		//];
		
        //Account household = new Account(
				//Name = 'test account',
                //FinServ__PrimaryContact__c = individual1.PersonContactId,
            //RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SecurityAssignmentTestFactory.HOUSEHOLD_RECORDTYPE_NAME).getRecordTypeId()
        //);
        //insert household;

		//AccountContactRelation acr1 = new AccountContactRelation(
			//AccountId = household.id,
			//ContactId = individual2.PersonContactId,
			//IsActive = True,
			//Roles = 'Client');
		//insert acr1;

        //FinServ__FinancialAccount__c testFinAcct = new FinServ__FinancialAccount__c(
			//Name = 'financial account one',
            //FinServ__Household__c = household.Id,
            //FinServ__PrimaryOwner__c = individual1.Id,
            //FinServ__FinancialAccountSource__c = 'Manually Entered',
            //Cost_Basis__c = 123.45,
			//FinServ__Ownership__c = 'Individual',
            //FinServ__Description__c = 'This is a description of my financial account.',
            //RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
        //);

        //FinServ__FinancialAccount__c testFinAcct2 = new FinServ__FinancialAccount__c(
			//Name = 'financial account two',
            //FinServ__Household__c = household.Id,
            //FinServ__PrimaryOwner__c = individual1.Id,
            //FinServ__FinancialAccountSource__c = 'Manually Entered',
            //Cost_Basis__c = 9999.12,
			//FinServ__Ownership__c = 'Individual',
            //FinServ__Description__c = 'This is a description of my other financial account.',
            //RecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('InvestmentAccount').getRecordTypeId()
        //);
        //insert new List<FinServ__FinancialAccount__c>{ testFinAcct, testFinAcct2 };

        //FinServ__Securities__c security = new FinServ__Securities__c(
            //FinServ__AssetCategory__c = 'U.S. Equity',
            //FinServ__AssetCategoryName__c = 'Large Growth',
            //FinServ__AssetClass__c = 'Equities',
            //FinServ__CUSIP__c = '037833100',
            //FinServ__Exchange__c = 'NASDAQ',
            //FinServ__LastUpdated__c = Date.today(),
            //FinServ__Price__c = 1234.56,
            //FinServ__SecuritiesName__c = 'TestSecurity',
            //Name = 'AAPL'
        //);

        //FinServ__Securities__c security2 = new FinServ__Securities__c(
            //FinServ__AssetCategory__c = 'U.S. Equity',
            //FinServ__AssetCategoryName__c = 'Large Growth',
            //FinServ__AssetClass__c = 'Equities',
            //FinServ__CUSIP__c = '935935935',
            //FinServ__Exchange__c = 'NASDAQ',
            //FinServ__LastUpdated__c = Date.today(),
            //FinServ__Price__c = 7777.00,
            //FinServ__SecuritiesName__c = 'TestSecurity2',
            //Name = 'MSFT'
        //);
        //insert new List<FinServ__Securities__c>{ security, security2 };

        //FinServ__FinancialHolding__c holding = new FinServ__FinancialHolding__c(
            //FinServ__FinancialAccount__c = testFinAcct.Id,
            //Quantity__c = 123,
            //Cost_Basis__c = 81365.20,
            //FinServ__MarketValue__c = 62.00,
            //FinServ__Securities__c = security.Id
        //);
        //FinServ__FinancialHolding__c holding2 = new FinServ__FinancialHolding__c(
            //FinServ__FinancialAccount__c = testFinAcct.Id,
            //Quantity__c = 10,
            //Cost_Basis__c = 81365.20,
            //FinServ__MarketValue__c = 9319519.00,
            //FinServ__Securities__c = security2.Id
        //);
        //FinServ__FinancialHolding__c holding3 = new FinServ__FinancialHolding__c(
            //FinServ__FinancialAccount__c = testFinAcct2.Id,
            //Quantity__c = 15,
            //Cost_Basis__c = 81365.20,
            //FinServ__MarketValue__c = 9319519.00,
            //FinServ__Securities__c = security.Id
        //);

        //insert new List<FinServ__FinancialHolding__c>{ holding, holding2, holding3 };
    //}
}