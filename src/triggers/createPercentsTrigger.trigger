trigger createPercentsTrigger on Account (after update, after insert) {

    List<Account> percents = new List<Account>();
	List<Household_Percent__c> percentsInsert = new List<Household_Percent__c>();
	List<Household_Percent__c> percentsUpdate = new List<Household_Percent__c>();


    	for(Account a : Trigger.new)
		{
    		Household_Percent__c percCash = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '1', Type__c = 'Cash', Value__c = a.Cash_Value__c);
    		Household_Percent__c percEq = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '2', Type__c = 'Equities', Value__c = a.Equity_Value__c);
    		Household_Percent__c percFix = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '3', Type__c = 'Fixed Income', Value__c = a.Fixed_Income_Value__c);
    		Household_Percent__c percOther = new Household_Percent__c(Household_Account__c = a.Id, External_Account_Id__c = a.Id + '4', Type__c = 'Other', Value__c = a.Other_Value__c);
            if(a.Cash_Value__c == null)
            {
                percCash.Value__c = 0.00;
            }
            if(a.Equity_Value__c == null)
            {
                percEq.Value__c = 0.00;
            }
            if(a.Fixed_Income_Value__c == null)
            {
                percFix.Value__c = 0.00;
            }
            if(a.Other_Value__c == null)
            {
                percOther.Value__c = 0.00;
            }
              
    		percentsInsert.add(percCash);
    		percentsInsert.add(percEq);
    		percentsInsert.add(percFix);
    		percentsInsert.add(percOther);
                 
    	}

	upsert percentsInsert External_Account_Id__c;

}