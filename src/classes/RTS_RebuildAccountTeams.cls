/**
 * @author  andrew.mcguiness@rtslabs.com
 * @updated 6/25/2019
 * Batchable class that rebuilds AccountTeamMembers from Legacy_AccountTeamMember__c's.  AccountTeams must be enabled
 * in the target org with the roles required.
 */
public class RTS_RebuildAccountTeams implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
                'SELECT ' +
                        'Legacy_AccountAccessLevel__c, Legacy_AccountId__c, Legacy_CaseAccessLevel__c, Legacy_ContactAccessLevel__c, ' +
                        'Legacy_OpportunityAccessLevel__c, Legacy_PhotoUrl__c, Legacy_TeamMemberRole__c, Legacy_Title__c, Legacy_UserId__c, ' +
                        'Rebuilt__c ' +
                        'FROM Legacy_AccountTeamMember__c ' +
                        'WHERE Rebuilt__c = false '
        );
    }

    public void execute(Database.BatchableContext bc, List<Legacy_AccountTeamMember__c> records) {
        rebuildAccountTeams(records);
    }

    public void finish(Database.BatchableContext bc) {
        // STUB
    }

    public void rebuildAccountTeams(List<Legacy_AccountTeamMember__c> records) {
        Map<String, String> userMappings = getUserMapping(records);
        Map<String, String> accountMappings = getAccountMapping(records);

        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();


        for (Legacy_AccountTeamMember__c record : records) {
            String user = userMappings.get(record.Legacy_UserId__c);
            String account = accountMappings.get(record.Legacy_AccountId__c);

            if (user != null && account != null) {
                AccountTeamMember teamMember = new AccountTeamMember();

                teamMember.UserId = user;
                teamMember.AccountId = account;

                teamMember.TeamMemberRole = record.Legacy_TeamMemberRole__c;
                //teamMember.Title = record.Legacy_Title__c;        // Pulled from User
                //teamMember.PhotoUrl = record.Legacy_PhotoUrl__c;  // Pulled from User

                teamMember.AccountAccessLevel = record.Legacy_AccountAccessLevel__c;
                teamMember.ContactAccessLevel = record.Legacy_ContactAccessLevel__c;
                teamMember.CaseAccessLevel = record.Legacy_CaseAccessLevel__c;
                teamMember.OpportunityAccessLevel = record.Legacy_OpportunityAccessLevel__c;

                accountTeamMembers.add(teamMember);
                record.Rebuilt__c = true;
            }
        }

        List<Database.SaveResult> updateResults = Database.update(records, false);
        List<Database.SaveResult> insertResults = Database.insert(accountTeamMembers, false);
    }


    private Map<String, String> getUserMapping(List<Legacy_AccountTeamMember__c> records) {
        Set<String> legacyUserIds = new Set<String>();
        for (Legacy_AccountTeamMember__c record : records) {
            if (record.Legacy_UserId__c != null) {
                legacyUserIds.add(record.Legacy_UserId__c);
            }
        }


        // Create map of Legacy ID's to New ID's
        List<User> legacyUsers = [SELECT Id, Legacy_ID__c FROM User WHERE Legacy_ID__c IN :legacyUserIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for (User owner : legacyUsers) {
            legacyToNewMap.put(owner.Legacy_ID__c, owner.Id);
        }

        return legacyToNewMap;
    }

    private Map<String, String> getAccountMapping(List<Legacy_AccountTeamMember__c> records) {
        Set<String> legacyWhatIds = new Set<String>();
        for (Legacy_AccountTeamMember__c record : records) {
            if (record.Legacy_AccountId__c != null) {
                legacyWhatIds.add(record.Legacy_AccountId__c);
            }
        }


        // ACCOUNTS/CONTACTS
        List<Account> legacyAccounts = [SELECT Id, Legacy_ID__c FROM Account WHERE Legacy_ID__c IN :legacyWhatIds];
        Map<String, String> legacyToNewMap = new Map<String, String>();
        for (Account what : legacyAccounts) {
            legacyToNewMap.put(what.Legacy_ID__c, what.Id);
        }

        return legacyToNewMap;
    }
}