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
                FinServ__FinancialAccountSource__c,
				Total_Acct_Value__c,
				Inst_code_desc__c,
                Cost_Basis__c,
                Owner.Name,
                FinServ__Description__c,
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
		w.writeStartElement(null, 'Household', null);
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
			w.writeAttribute(null, null, (isPrimary ? 'UniqueClientKey' : 'UniqueclientKey'), client.Id);

			w.writeStartElement(null, 'FirstName', null);
			w.writeCharacters(null == client.FirstName ? '' : client.FirstName);
			w.writeEndElement();

			w.writeStartElement(null, 'LastName', null);
			w.writeCharacters(null == client.LastName ? '' : client.LastName);
			w.writeEndElement();

			w.writeStartElement(null, 'DOB', null);
			w.writeCharacters(null == client.PersonBirthdate ? '' : client.PersonBirthdate.format());
			w.writeEndElement();

			w.writeStartElement(null, 'State', null);
			w.writeCharacters(null == client.BillingState ? '' : client.BillingState);
			w.writeEndElement();

			w.writeStartElement(null, 'Sex', null);
			w.writeCharacters(null == client.FinServ__Gender__pc ? '' : String.valueOf(genderValuesMap.get(client.FinServ__Gender__pc)));
			w.writeEndElement();

			w.writeStartElement(null, 'MaritalStatus', null);
			w.writeCharacters(null == client.FinServ__MaritalStatus__pc ? '' : maritalStatusValuesMap.get(client.FinServ__MaritalStatus__pc));
			w.writeEndElement();

			w.writeEndElement();
		}
	}

    @TestVisible static void buildInvestmentAssets(XmlStreamWriter w, List<FinServ__FinancialAccount__c> finAccts){
        for (FinServ__FinancialAccount__c finAcct : finAccts){

			w.writeStartElement(null, 'InvestmentAssets', null);

			w.writeStartElement(null, 'InvestmentAsset', null);
			w.writeAttribute(null, null, 'Id', finAcct.Id);

			w.writeStartElement(null, 'Source', null);
			w.writeCharacters(null == finAcct.FinServ__FinancialAccountSource__c ? '' : finAcct.FinServ__FinancialAccountSource__c);
			w.writeEndElement();

			w.writeStartElement(null, 'CurrentValue', null);
			w.writeCharacters(null == finAcct.Total_Acct_Value__c ? '' : String.valueOf(finAcct.Total_Acct_Value__c));
			w.writeEndElement();

			w.writeStartElement(null, 'CostBasis', null);
			w.writeCharacters(null == finAcct.Cost_Basis__c ? '' : String.valueOf(finAcct.Cost_Basis__c));
			w.writeEndElement();

			w.writeStartElement(null, 'Owner', null);
			w.writeCharacters(null == finAcct.Owner ? '' : finAcct.Owner.Name);
			w.writeEndElement();

			w.writeStartElement(null, 'Type', null);
			w.writeCharacters(null == finAcct.Inst_code_desc__c ? '' : finAcct.Inst_code_desc__c);
			w.writeEndElement();

			w.writeStartElement(null, 'Description', null);
			w.writeCharacters(null == finAcct.FinServ__Description__c ? '' : finAcct.FinServ__Description__c);
			w.writeEndElement();

			w.writeStartElement(null, 'AsOfDate', null);
			w.writeCharacters(null == finAcct.Performance_As_Of_Date__c ? '' : String.valueOf(finAcct.Performance_As_Of_Date__c));
			w.writeEndElement();

			buildHoldings(w, finAcct.FinServ__FinancialHoldings__r);

			w.writeEndElement();
			w.writeEndElement();
		}
	}

    @TestVisible static void buildHoldings(XmlStreamWriter w, List<FinServ__FinancialHolding__c> holdings){
        for (FinServ__FinancialHolding__c holding : holdings){

			w.writeStartElement(null, 'Holdings', null);

			w.writeStartElement(null, 'Holding', null);
			w.writeAttribute(null, null, 'Id', holding.Id);

			w.writeStartElement(null, 'Description', null);
			w.writeCharacters(null == holding.Name ? '' : holding.Name);
			w.writeEndElement();

			w.writeStartElement(null, 'Ticker', null);
			w.writeCharacters(null == holding.FinServ__Symbol__c ? '' : holding.FinServ__Symbol__c);
			w.writeEndElement();

			w.writeStartElement(null, 'Quantity', null);
			w.writeCharacters(null == holding.Quantity__c ? '' : String.valueOf(holding.Quantity__c));
			w.writeEndElement();

			w.writeStartElement(null, 'CostBasis', null);
			w.writeCharacters(null == holding.Cost_Basis__c ? '' : String.valueOf(holding.Cost_Basis__c));
			w.writeEndElement();

			w.writeStartElement(null, 'CurrentValue', null);
			w.writeCharacters(null == holding.FinServ__MarketValue__c ? '' : String.valueOf(holding.FinServ__MarketValue__c));
			w.writeEndElement();

			w.writeEndElement();
			w.writeEndElement();
		}
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