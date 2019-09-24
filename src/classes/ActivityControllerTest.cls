/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class ActivityControllerTest {
    @isTest static void testGetTaskPicklists(){
        TaskPicklists picklists = ActivityController.getTaskPicklist();

        System.assertNotEquals(null, picklists);
    }
}