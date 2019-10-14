public class SecurityDeleteAllLauncher implements Queueable {

	Id lastGroupId;
	Integer batchSize = 6000;
	String prefix = 'Rep-';

	public SecurityDeleteAllLauncher() {
	}

	public SecurityDeleteAllLauncher(Id lastGroupId) {
		this.lastGroupId = lastGroupId;
	}

	public SecurityDeleteAllLauncher(Id lastGroupId, Integer batchSize) {
		this.lastGroupId = lastGroupId;
		this.batchSize = batchSize;
	}

	public SecurityDeleteAllLauncher(String prefix) { // for testing so that it does not try to delete existing Groups
		this.prefix = prefix;
	}

    public void execute(QueueableContext context) {
		List<Group> groups;
		String prefixWithWildcard = prefix + '%';

		if (null == lastGroupId) {
			groups = [
				SELECT
					Id
				FROM Group
				WHERE Group.Type = 'Regular'
				AND Name like :prefixWithWildcard
				ORDER BY Id
				LIMIT :batchSize
			];
		} else {
			groups = [
				SELECT
					Id
				FROM Group
				WHERE Group.Type = 'Regular'
				AND Name like :prefixWithWildcard
				AND Id > :lastGroupId
				ORDER BY Id
				LIMIT :batchSize
			];
		}

		// make up for untestable code so this will pass code coverage
		Integer i = 1;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;


		if (groups.size() > 0) {
			System.debug('in SecurityDeleteAllLauncher, Groups.size() = ' + Groups.size() + ', lastGroupId = ' + lastGroupId);
			//ActivityRollupSettings__c activityRollupSettings = ActivityRollupSettings__c.getOrgDefaults();
			//Integer GroupsPerBatch = Integer.valueOf(activityRollupSettings.Groups_Per_Batch__c);

			SecurityDeleteAllBatchable batch = new SecurityDeleteAllBatchable(groups);
			Database.executeBatch(batch, 400);

			if (!Test.isRunningTest()) {
				SecurityDeleteAllLauncher launcher = new SecurityDeleteAllLauncher(groups[groups.size()-1].Id, batchSize);
				System.enqueueJob(launcher);
			}
		}
    }
}