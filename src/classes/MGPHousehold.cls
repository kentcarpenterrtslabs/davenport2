@RestResource(urlMapping='/Household/*')
global with sharing class MGPHousehold {

    @HttpGet
    global static void doGet() {
		System.debug('MGPHousehold.doGet: UserInfo.getUserId() = ' + UserInfo.getUserId());
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
		res.responseBody = Blob.valueOf(MoneyGuideProRequestController.buildRequestBody(accountId));
    }

}