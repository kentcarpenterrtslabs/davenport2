/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){

        var action = component.get("c.getHouseholdData");
        action.setParam('householdId', component.get("v.recordId"));
		action.setParam('loggedInUserId', $A.get("$SObjectType.CurrentUser.Id"));

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == 'SUCCESS') {
                var householdInfo = response.getReturnValue();

				if (householdInfo.isFirmWideAccessEnabled) {
					component.set("v.cannotOpenMGPTitle","Universal Access Enabled");
					component.set("v.cannotOpenMGPReason","You must turn off universal access to use Money Guide Pro.");
				} else if (! householdInfo.hasMGPLicense) {
					component.set("v.cannotOpenMGPTitle","No MGP License");
					component.set("v.cannotOpenMGPReason","You must have a license to connect to Money Guide Pro.");
				} else if (! householdInfo.hasPrimaryContact) {
					component.set("v.cannotOpenMGPTitle","No Primary Contact On This Account");
					component.set("v.cannotOpenMGPReason","A household must have a primary contact to use Money Guide Pro.");
				} else if (householdInfo.mgpUsers.length <= 0) {
					component.set("v.cannotOpenMGPTitle","No Money Guide Pro Users Can Access This Account");
					component.set("v.cannotOpenMGPReason","There are no users that have access to this household and have access to Money Guide Pro.");
				} else {
					console.log('getPicklistOptions users' + householdInfo.mgpUsers);
					var loginAsOptions = [];
					householdInfo.mgpUsers.forEach(function(user) {
						loginAsOptions.push({
							"label" : user.FirstName + ' ' + user.LastName,
							"value" : user.Id
						});
					});
					component.set("v.loginAsOptions", loginAsOptions);
					component.set("v.allowOpenMGP", true);
				}
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
					console.log(response.getError());
				}
			});

			$A.enqueueAction(updateUserAction);
		}
    }
})