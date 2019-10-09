@isTest 
private class TestSecurityRepSplitsBatchable {

	@isTest
	private static void testRepSplits() {
		Rep__c rep1 = new Rep__c(
			Rep_Number__c = 'TS01'
		);
		insert rep1;

		Rep__c rep2 = new Rep__c(
			Rep_Number__c = 'TS02'
		);
		insert rep2;

		Group groupRep1 = new Group(
			Name = 'Rep-' + rep1.Rep_Number__c + '-' + rep1.Id
		);
		insert groupRep1;
		rep1.GroupId__c = groupRep1.Id;
		update rep1;

		Group groupRep2 = new Group(
			Name = 'Rep-' + rep2.Rep_Number__c + '-' + rep2.Id
		);
		insert groupRep2;
		rep2.GroupId__c = groupRep2.Id;
		update rep2;

		Rep_Split__c repSplit = new Rep_Split__c(
			Split_Rep__c = rep1.Id,
			Grant_Access_to_Rep__c = rep2.Id
		);
		insert repSplit;

		Test.startTest();
		Database.executeBatch(new SecurityRepSplitsBatchable());
		Test.stopTest();

		List<GroupMember> groupMembers = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
		];

		System.assertEquals(1, groupMembers.size());
		System.assertEquals(groupRep2.Id, groupMembers[0].UserOrGroupId);
	}
}