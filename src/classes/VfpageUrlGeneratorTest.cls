/**
 * Created by melissaderricott on 9/20/19.
 */

@IsTest
public class VfpageUrlGeneratorTest {
    @IsTest static void testURL() {
        //Construct the url
        String [] urlString = System.url.getSalesforceBaseUrl().toExternalForm().split('.my.salesforce.com');
        String orgCode = [SELECT Id, InstanceName FROM Organization LIMIT 1].InstanceName;
        String urlToReturn = urlString[0] + '--c.' + orgCode.toLowerCase();

        String result =  VfpageUrlGenerator.getBaseUrl();

        System.assertEquals(urlToReturn, result);

    }
}