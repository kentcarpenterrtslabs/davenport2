/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){
        var action = component.get("c.getNewHouseholdDisplayFields");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var fields = JSON.parse(response.getReturnValue());;
                console.log('NewHousehold fields', fields);
                component.set("v.fields", fields);
            }else{
                throw response.getError();
            }
        })
        $A.enqueueAction(action);
    },

    toggleModal: function(component, event, helper){
        component.set("v.showModal", !component.get("v.showModal"));
    },

    onSuccess: function(component, event, helper){
        component.set("v.showModal", false);
        console.log('onSuccess');

        var record = event.getParam("response");
        console.log('record', record);
        var recordId = record.id;
        var recordName = record.fields.Name.value;
        console.log('recordId', recordId);
        console.log('recordName', recordName);
        component.set("v.newHousehold", {'sobjectType' : 'Account', 'Id': recordId, 'Name': recordName });
    }
})