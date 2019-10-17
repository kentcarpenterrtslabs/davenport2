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
		var selectedLoginAsUser = component.find("loginAsCmbx").get("v.value");

		if (typeof selectedLoginAsUser === "undefined") {
			var error = {};
			error.message = "Please choose a user.";
			component.find("errorMessage").setError(error);
		} else {
			var updateUserAction = component.get("c.updateUser");

			updateUserAction.setParam('householdId', component.get("v.recordId"));
			updateUserAction.setParam('userId', selectedLoginAsUser);

			updateUserAction.setCallback(this, function(response){
				var state = response.getState();

				if (state == 'SUCCESS') {
					var eUrl= $A.get("e.force:navigateToURL");

					var idpURL = response.getReturnValue();
					eUrl.setParams({
					  "url" : idpURL
					});
					eUrl.fire();
				} else {
					//console.log('buildRequestBody ' + state);
					console.log(response.getError());
				}
			});

			$A.enqueueAction(updateUserAction);
		}
    }
})