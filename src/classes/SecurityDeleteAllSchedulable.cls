global class SecurityDeleteAllSchedulable implements Schedulable {
	String prefix = 'Rep-';

	public SecurityDeleteAllSchedulable() {}

	public SecurityDeleteAllSchedulable(String prefix) { // for testing so that it does not try to delete existing Groups
		this.prefix = prefix;
	}

	global void execute(SchedulableContext sc) {
		startDelete();
    }

	public void startDelete() {
		SecurityDeleteAllLauncher deleteQueueable = new SecurityDeleteAllLauncher(prefix);
		System.enqueueJob(deleteQueueable);
	}
}