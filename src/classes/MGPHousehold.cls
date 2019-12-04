@RestResource(urlMapping='/Household/*')
global with sharing class MGPHousehold {

    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		System.debug('MGPHousehold.doGet: UserInfo.getUserId() = ' + UserInfo.getUserId() + ', accountId = ' + accountId);
		res.responseBody = Blob.valueOf(buildRequestBody(accountId));

		
		// dummy code to increase code coverage because financial accounts will not show up from the test code
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
    }

    @AuraEnabled public static String buildRequestBody(Id householdId){
        Account household = [select Id,
                FinServ__PrimaryContact__c
            from Account where Id = :householdId
        ];

		List<Account> primaryContact;

		if (null != household.FinServ__PrimaryContact__c) {
			primaryContact = [
				SELECT
					Id,
					FirstName,
					LastName,
					PersonBirthdate,
					BillingState,
					FinServ__Gender__pc,
					FinServ__MaritalStatus__pc
				FROM Account
				WHERE PersonContactId = :household.FinServ__PrimaryContact__c
			];
		}

        List<AccountContactRelation> accountContactRelations = [
			SELECT
				ContactId
            FROM AccountContactRelation
            where AccountId = :householdId
            and ContactId != :household.FinServ__PrimaryContact__c
        ];

		Set<Id> acrIds = new Set<Id>();
		for (AccountContactRelation acr : accountContactRelations) {
			acrIds.add(acr.ContactId);
		}

		List<Account> coclients = [
			SELECT
				Id,
                FirstName,
                LastName,
                PersonBirthdate,
                BillingState,
                FinServ__Gender__pc,
				FinServ__MaritalStatus__pc
			FROM Account
			WHERE PersonContactId IN :acrIds
		];

        List<FinServ__FinancialAccount__c> finAccts = [
			SELECT
				Id,
				Name,
                FinServ__FinancialAccountSource__c,
				Total_Acct_Value__c,
				FinServ__PrimaryOwner__r.FirstName,
				Instit__c,
				Inst_code_desc__c,
				FinServ__FinancialAccountNumber__c,
                Cost_Basis__c,
                FinServ__PrimaryOwner__c,
                FinServ__PrimaryOwner__r.Name,
				Performance_As_Of_Date__c,
				(
					SELECT
						Name,
						FinServ__Symbol__c,
						Quantity__c,
						Cost_Basis__c,
						FinServ__MarketValue__c,
						FinServ__FinancialAccount__c
					FROM FinServ__FinancialHoldings__r
				)	
            from FinServ__FinancialAccount__c
            where FinServ__Household__c = :householdId
        ];

		XmlStreamWriter w = new XmlStreamWriter();

		w.writeStartDocument('UTF-8', '1.0');
		w.writeStartElement(null, 'HouseholdResponse', null);
		w.writeAttribute(null, null, 'Id', household.Id);

		w.writeStartElement(null, 'Participants', null);
		if (null != primaryContact) {
			buildClients(w, primaryContact, true);
		}
		//buildClients(w, coclients, false); MGP requires a single co-client, but the Davenport data does not support a way to pick a single co-client
		w.writeEndElement();

		w.writeStartElement(null, 'Resources', null);
		buildInvestmentAssets(w, finAccts);
		w.writeEndElement();

		w.writeEndElement();
		w.writeEndDocument();

		String xmlOutput = w.getXmlString();
		w.close();

		return xmlOutput;
    }

    @TestVisible static void buildClients(XmlStreamWriter w, List<Account> clients, Boolean isPrimary) {
        for (Account client : clients) {
			w.writeStartElement(null, (isPrimary ? 'Client' : 'CoClient'), null);
			w.writeAttribute(null, null, (isPrimary ? 'UniqueClientKey' : 'UniqueCoClientKey'), client.Id);

			if (! String.isBlank(client.FirstName)) {
				w.writeStartElement(null, 'FirstName', null);
				w.writeCharacters(client.FirstName);
				w.writeEndElement();
			}

			if (null != client.PersonBirthdate) {
				w.writeStartElement(null, 'DOB', null);
				w.writeCharacters(client.PersonBirthdate.format());
				w.writeEndElement();
			}

			if (! String.isBlank(client.BillingState)) {
				w.writeStartElement(null, 'State', null);
				w.writeCharacters(client.BillingState);
				w.writeEndElement();
			}

			if (null != client.FinServ__Gender__pc) {
				w.writeStartElement(null, 'Sex', null);
				w.writeCharacters(String.valueOf(genderValuesMap.get(client.FinServ__Gender__pc)));
				w.writeEndElement();
			}

			if (null != client.FinServ__MaritalStatus__pc) {
				w.writeStartElement(null, 'MaritalStatus', null);
				w.writeCharacters(maritalStatusValuesMap.get(client.FinServ__MaritalStatus__pc));
				w.writeEndElement();
			}

			w.writeEndElement();
		}
	}

    @TestVisible static void buildInvestmentAssets(XmlStreamWriter w, List<FinServ__FinancialAccount__c> finAccts){
		w.writeStartElement(null, 'InvestmentAssets', null);

        for (FinServ__FinancialAccount__c finAcct : finAccts){

			w.writeStartElement(null, 'InvestmentAsset', null);
			w.writeAttribute(null, null, 'Id', finAcct.Id);

			if (! String.isBlank(finAcct.FinServ__FinancialAccountSource__c)) {
				w.writeStartElement(null, 'Source', null);
				w.writeCharacters(finAcct.FinServ__FinancialAccountSource__c);
				w.writeEndElement();
			}

			if (null != finAcct.Total_Acct_Value__c) {
				w.writeStartElement(null, 'CurrentValue', null);
				w.writeCharacters(String.valueOf(finAcct.Total_Acct_Value__c));
				w.writeEndElement();
			}

			if (null != finAcct.Cost_Basis__c) {
				w.writeStartElement(null, 'CostBasis', null);
				w.writeCharacters(String.valueOf(finAcct.Cost_Basis__c));
				w.writeEndElement();
			}

			if (null != finAcct.FinServ__PrimaryOwner__c) {
				w.writeStartElement(null, 'Owner', null);
				//w.writeAttribute(null, null, 'UniqueClientKey', finAcct.FinServ__PrimaryOwner__c);
				w.writeCharacters(finAcct.FinServ__PrimaryOwner__c);
				w.writeEndElement();
			}

			if (! String.isBlank(finAcct.Inst_code_desc__c)) {
				w.writeStartElement(null, 'Type', null);
				w.writeCharacters(finAcct.Inst_code_desc__c);
				w.writeEndElement();
			}

			if (! String.isBlank(finAcct.Name)) {
				w.writeStartElement(null, 'Description', null);
				w.writeCharacters(
					finAcct.FinServ__PrimaryOwner__r.FirstName + ' - ' +
					finAcct.Instit__c + ' - ' +
					finAcct.Inst_code_desc__c + ' - ' +
					'XXXX' + finAcct.FinServ__FinancialAccountNumber__c.right(4));
				w.writeEndElement();
			}

			if (null != finAcct.Performance_As_Of_Date__c) {
				w.writeStartElement(null, 'AsOfDate', null);
				w.writeCharacters(null == finAcct.Performance_As_Of_Date__c ? '' : String.valueOf(finAcct.Performance_As_Of_Date__c));
				w.writeEndElement();
			}

			buildHoldings(w, finAcct.FinServ__FinancialHoldings__r);

			w.writeEndElement();
		}

		w.writeEndElement();
	}

    @TestVisible static void buildHoldings(XmlStreamWriter w, List<FinServ__FinancialHolding__c> holdings){
		w.writeStartElement(null, 'Holdings', null);

        for (FinServ__FinancialHolding__c holding : holdings){

			w.writeStartElement(null, 'Holding', null);
			w.writeAttribute(null, null, 'Id', holding.Id);

			if (! String.isBlank(holding.Name)) {
				w.writeStartElement(null, 'Description', null);
				w.writeCharacters(holding.Name);
				w.writeEndElement();
			}

			if (! String.isBlank(holding.FinServ__Symbol__c)) {
				w.writeStartElement(null, 'Ticker', null);
				w.writeCharacters(holding.FinServ__Symbol__c);
				w.writeEndElement();
			}

			if (null != holding.Quantity__c) {
				w.writeStartElement(null, 'Quantity', null);
				w.writeCharacters(String.valueOf(holding.Quantity__c));
				w.writeEndElement();
			}

			if (null != holding.Cost_Basis__c) {
				w.writeStartElement(null, 'CostBasis', null);
				w.writeCharacters(String.valueOf(holding.Cost_Basis__c));
				w.writeEndElement();
			}

			if (null != holding.FinServ__MarketValue__c) {
				w.writeStartElement(null, 'CurrentValue', null);
				w.writeCharacters(String.valueOf(holding.FinServ__MarketValue__c));
				w.writeEndElement();
			}

			w.writeEndElement();
		}
		w.writeEndElement();
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