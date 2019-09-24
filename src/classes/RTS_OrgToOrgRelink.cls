/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Class that will launch all the batches required to rebuild the legacy data in the new Salesforce instance.
 */
public class RTS_OrgToOrgRelink implements Queueable{
    public void execute(QueueableContext context) {
        Database.executeBatch(new RTS_RebuildAccountTeams(), 200);
        Database.executeBatch(new RTS_RebuildAnnouncements(), 200);
        Database.executeBatch(new RTS_RebuildEvents(), 200);
        Database.executeBatch(new RTS_RebuildNotes(), 200);
        Database.executeBatch(new RTS_RebuildTasks(), 200);


        Database.executeBatch(new RTS_RelinkAccountOwner(), 200);
        Database.executeBatch(new RTS_RelinkBranchProductionOwner(), 200);
        Database.executeBatch(new RTS_RelinkBranchRegionOwner(), 200);
        Database.executeBatch(new RTS_RelinkContactOwner(), 200);
        Database.executeBatch(new RTS_RelinkEmployeeOwner(), 200);
        Database.executeBatch(new RTS_RelinkKYCOwner(), 200);
        Database.executeBatch(new RTS_RelinkOpportunityOwner(), 200);
        Database.executeBatch(new RTS_RelinkRecuitOwner(), 200);
        Database.executeBatch(new RTS_RelinkRepOwner(), 200);
        Database.executeBatch(new RTS_RelinkWealthcareOwner(), 200);
    }
}