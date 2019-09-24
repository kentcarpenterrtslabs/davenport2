/**
 * Created by Eric Stansbury on 6/3/2019.
 */

@isTest
public class RepAssignmentControllerTest {
    /*@isTest*/ static void doTest(){
        SecurityAssignmentTestFactory.createData();

        List<Rep_Assignment__c> repAssignments = RepAssignmentController.getRepLabelData();
        System.assertNotEquals(null, repAssignments);
        System.assertEquals(0, repAssignments.size());
    }
}