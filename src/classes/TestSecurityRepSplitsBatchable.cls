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

		Rep__c rep3 = new Rep__c(
			Rep_Number__c = 'TS03'
		);
		insert rep3;

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

		Group groupRep3 = new Group(
			Name = 'Rep-' + rep3.Rep_Number__c + '-' + rep3.Id
		);
		insert groupRep3;
		rep3.GroupId__c = groupRep3.Id;
		update rep3;


		Rep_Split__c repSplit1_2 = new Rep_Split__c(
			Split_Rep__c = rep2.Id,
			Grant_Access_to_Rep__c = rep1.Id
		);
		insert repSplit1_2;

		Rep_Split__c repSplit1_3 = new Rep_Split__c(
			Split_Rep__c = rep3.Id,
			Grant_Access_to_Rep__c = rep1.Id
		);
		insert repSplit1_3;


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

		List<GroupMember> groupMembers1_2 = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
			AND UserOrGroupId = :groupRep2.Id
		];

		List<GroupMember> groupMembers1_3 = [
			SELECT
				GroupId,
				UserOrGroupId
			FROM GroupMember
			WHERE GroupId = :groupRep1.Id
			AND UserOrGroupId = :groupRep3.Id
		];

		System.assertEquals(2, groupMembers.size());
		System.assertEquals(1, groupMembers1_2.size());
		System.assertEquals(1, groupMembers1_3.size());
	}
}