/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){

        var action = component.get("c.getPicklistOptions");
        action.setParam('householdId', component.get("v.recordId"));

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == 'SUCCESS') {
                var users = response.getReturnValue();
				console.log('getPicklistOptions users' + users);
				var loginAsOptions = [];
                users.forEach(function(user) {
                    loginAsOptions.push({
                        "label" : user.FirstName + ' ' + user.LastName,
                        "value" : user.Id
                    });
                });
				component.set("v.loginAsOptions", loginAsOptions);
                //component.set("v.requestDisplay", helper.formatXml(returnValue));

            } else {

                console.log('getPicklistOptions ' + state);
                console.log('getPicklistOptions ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    submit: function(component, event, helper){
        var updateUserAction = component.get("c.updateUser");

        updateUserAction.setParam('householdId', component.get("v.recordId"));
        updateUserAction.setParam('userId', component.find("loginAsCmbx").get("v.value"));

        updateUserAction.setCallback(this, function(response){
            var state = response.getState();

            if (state == 'SUCCESS') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
				  "url" : 'https://investdavenport--rtskent.my.salesforce.com/idp/login?app=0sp0v0000004CON'
				  //"url": 'https://investdavenport--rtskent.my.salesforce.com/idp/login?app=0sp0b000000XZVT'
                });
                eUrl.fire();
            } else {
                //console.log('buildRequestBody ' + state);
                console.log(response.getError());
            }
        });

        $A.enqueueAction(updateUserAction);
    }
})
//"url": 'https://qa.moneyguidepro.com/davenport/ssosamlnoref.aspx?IntegrationId=170'