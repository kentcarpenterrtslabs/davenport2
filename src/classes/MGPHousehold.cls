@RestResource(urlMapping='/Household/*')
global with sharing class MGPHousehold {

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        return MoneyGuideProRequestController.buildRequestBody(accountId);
    }

}