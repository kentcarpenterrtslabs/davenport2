/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){
        var action = component.get("c.buildRequestBody");
        action.setParam('householdId', component.get("v.recordId"));
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var returnValue = response.getReturnValue();
                component.set("v.request", returnValue);
                component.set("v.requestDisplay", helper.formatXml(returnValue));
            }else{
                console.log('buildRequestBody ' + state);
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    submit: function(component, event, helper){
        var updateUserAction = component.get("c.updateUser");
        updateUserAction.setParam('householdId', component.get("v.recordId"));
        updateUserAction.setParam('userId', null); // todo: pass from picklist once we have values
        updateUserAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                  "url": 'https://www.google.com/'
                });
                eUrl.fire();
            }else{
                console.log('buildRequestBody ' + state);
                console.log(response.getError());
            }
        });

        $A.enqueueAction(updateUserAction);
    }
})