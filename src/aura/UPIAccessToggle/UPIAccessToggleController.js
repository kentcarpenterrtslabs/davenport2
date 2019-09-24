/**
 * Created by Eric Stansbury on 7/18/2019.
 */
({
    doInit: function(component, event, helper){
        component.set("v.loading", true);
        var action = component.get("c.isFirmwideAccessEnabled");
        action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    component.set("v.value", returnValue? 'true' : 'false');
                    component.set("v.loading", false);
                }
                else if (state === "INCOMPLETE") {
                    console.log("INCOMPLETE");
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "message": errors[0].message,
                                type: "error"
                            });
                            toastEvent.fire();
                            component.set("v.loading", false);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    component.set("v.loading", false);
                }
            }
        )
        $A.enqueueAction(action);
    },

    handleSubmit: function(component, event, helper){
        component.set("v.loading", true);
        var value = component.get("v.value");

        var action = (value == 'true') ? component.get("c.enableUPIAccess") : component.get("c.disableUPIAccess");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Universal access " + (value == "true" ? "enabled." : "disabled."),
                    type: "success"
                });
                toastEvent.fire();
                component.set("v.loading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": errors[0].message,
                            type: "error"
                        });
                        toastEvent.fire();
                        component.set("v.loading", false);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.loading", false);
            }
        })
        $A.enqueueAction(action);
    }
})