@isTest 
private class TestSecurityGroupsBatchable {

	@isTest
	private static void testCreateGroups() {

		Rep__c rep1 = new Rep__c(
			Rep_Number__c = 'TS01'
		);
		insert rep1;

		Rep__c rep2 = new Rep__c(
			Rep_Number__c = 'TS02'
		);
		insert rep2;
		
		Test.startTest();
		Database.executeBatch(new SecurityGroupsBatchable());
		Test.stopTest();

		Group group1 = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Type = 'Regular'
			AND Name = :('Rep-' + rep1.Rep_Number__c + '-' + rep1.Id)
		];

		Group group2 = [
			SELECT
				Id,
				Name
			FROM Group
			WHERE Type = 'Regular'
			AND Name = :('Rep-' + rep2.Rep_Number__c + '-' + rep2.Id)
		];

		Rep__c rep1After = [
			SELECT
				GroupId__c
			FROM Rep__c
			WHERE Id = :rep1.Id
			LIMIT 1
		];

		Rep__c rep2After = [
			SELECT
				GroupId__c
			FROM Rep__c
			WHERE Id = :rep2.Id
			LIMIT 1
		];
		System.assertNotEquals(null, group1);
		System.assertNotEquals(null, group2);
		System.assertEquals(rep1After.GroupId__c, group1.Id);
		System.assertEquals(rep2After.GroupId__c, group2.Id);
	}
}