/**
 * Created by Eric Stansbury on 5/28/2019.
 */

public class SecurityAssignmentConfig {
    public static boolean repSecurityTriggersEnabled{get{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        return config.RepSecurityTriggerEnabled__c;
    }set{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.RepSecurityTriggerEnabled__c = value;
        upsert config;
    }}

    public static boolean repAssignmentTriggersEnabled{get{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        return config.RepAssignmentTriggerEnabled__c;
    }set{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.RepAssignmentTriggerEnabled__c = value;
        upsert config;
    }}

    public static boolean accountSplitTriggersEnabled{get{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        return config.AccountSplitTriggerEnabled__c;
    }set{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.AccountSplitTriggerEnabled__c = value;
        upsert config;
    }}

    public static boolean repSplitTriggersEnabled{get{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        return config.RepSplitTriggerEnabled__c;
    }set{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.RepSplitTriggerEnabled__c = value;
        upsert config;
    }}

    public static boolean assistantAssignmentTriggersEnabled{get{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        return config.AssistantAssignmentTriggerEnabled__c;
    }set{
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.AssistantAssignmentTriggerEnabled__c = value;
        upsert config;
    }}

    public static void disableTriggers(){
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(UserInfo.getUserId());
        config.RepSecurityTriggerEnabled__c = false;
        config.AccountSplitTriggerEnabled__c = false;
        config.RepAssignmentTriggerEnabled__c = false;
        config.RepSplitTriggerEnabled__c = false;
        config.AssistantAssignmentTriggerEnabled__c = false;
        upsert config;
    }

    public static void enableTriggers(){
        enableTriggers(UserInfo.getUserId());
    }

    public static void enableTriggers(Id userId){
        SecurityAssignmentConfiguration__c config = SecurityAssignmentConfiguration__c.getInstance(userId);
        config.RepSecurityTriggerEnabled__c = true;
        config.AccountSplitTriggerEnabled__c = true;
        config.RepAssignmentTriggerEnabled__c = true;
        config.RepSplitTriggerEnabled__c = true;
        config.AssistantAssignmentTriggerEnabled__c = true;
        upsert config;
    }
}