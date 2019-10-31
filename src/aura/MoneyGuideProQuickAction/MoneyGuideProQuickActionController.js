/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){

        var action = component.get("c.getHouseholdData");
        action.setParam('householdId', component.get("v.recordId"));

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == 'SUCCESS') {
                var householdInfo = response.getReturnValue();
				console.log('getPicklistOptions users' + householdInfo.mgpUsers);
				var loginAsOptions = [];
                householdInfo.mgpUsers.forEach(function(user) {
                    loginAsOptions.push({
                        "label" : user.FirstName + ' ' + user.LastName,
                        "value" : user.Id
                    });
                });
				component.set("v.loginAsOptions", loginAsOptions);
				component.set("v.allowOpenMGP", householdInfo.hasPrimaryContact);

				//if (! householdInfo.hasPrimaryContact) {
				//	var error = {};
				//	error.message = "This household does not have a primary contact. This is required to use Money Guide Pro.";
				//	component.find("errorMessage").setError(error);
				//}
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