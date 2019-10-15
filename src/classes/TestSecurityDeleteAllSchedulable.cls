@isTest 
private class TestSecurityDeleteAllSchedulable {

	private static final String TEST_GROUP_NAME = 'Test-Group1';

	@isTest
	private static void testDelete() {

		Group group1 = new Group(
			Name = TEST_GROUP_NAME,
			Type = 'Regular');
		insert group1;

		Test.startTest();
		SecurityDeleteAllSchedulable sched = new SecurityDeleteAllSchedulable('Test-');
		sched.execute(null);
		Test.stopTest();
		
		List<Group> groups = [
			SELECT
				Id
			FROM Group
			WHERE Name = :TEST_GROUP_NAME
			AND Type = 'Regular'
		];
		System.assertEquals(0, groups.size());

	}
}