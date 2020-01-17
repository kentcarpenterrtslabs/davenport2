@isTest
public class TestUpdatePhoneAndEmailBatchable  {

	@isTest 
	public static void test1() {
		Account testAccount = new Account(Name='abc', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());

		insert testAccount;

		Test.startTest();
		Database.executeBatch(new UpdatePhoneAndEmailBatchable('Household'), 100);
		Test.stopTest();
	}
}