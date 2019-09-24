/**
 * Created by Eric Stansbury on 6/2/2019.
 */

@isTest
public class FormDataControllerTest {
    @isTest static void doTest(){


        String repName = 'Test Rep Name';
        String formIds = 'Form Ids';
        String result = FormDataController.createFormData(repName, formIds);

        System.assertNotEquals(null, result);
    }
}