/**
 * Created by Eric Stansbury on 7/25/2019.
 */

@isTest
public class RepSecurityInitializationScriptTest {
    @isTest static void doTest(){
        SecurityAssignmentTestFactory.createData();

        Database.executeBatch(new RepSecurityInitializationScript());
    }
}