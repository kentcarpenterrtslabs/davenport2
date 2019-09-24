/**
 * Created by melissaderricott on 9/20/19.
 */


//Class to generate url for Visualforce page
public with sharing class VfpageUrlGenerator {
    @AuraEnabled(cacheable=false)

    public static String getBaseUrl() {
        String urlString = System.url.getSalesforceBaseUrl().toExternalForm();
        String [] splitUrlString = urlString.split('.my.salesforce.com');
        String orgCode = [SELECT Id, InstanceName FROM Organization LIMIT 1].InstanceName ;

        //Create URL string  https://investdavenport--rtslayouts--c.cs16.
        String urlToReturn = splitUrlString[0] + '--c.' + orgCode.toLowerCase();
        System.debug(urlToReturn);
        return urlToReturn;
    }

}