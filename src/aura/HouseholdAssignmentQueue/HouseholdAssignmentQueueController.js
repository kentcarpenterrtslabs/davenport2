/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){
        var fieldMapping = [
            { finAcctField: "FinServ__Address1__c", householdField: "BillingStreet" },
            { finAcctField: "Name", householdField: "Name" },
            { finAcctField: "Name", householdField: "Name" },
            { finAcctField: "Name", householdField: "Name" }
        ];
        component.set("v.fieldMapping", fieldMapping);

        var getRowsAction = component.get("c.getRows");
        getRowsAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                component.set("v.rows", response.getReturnValue());
				component.set("v.showLoading", false);
            }else{
                throw response.getError();
            }
        });
        $A.enqueueAction(getRowsAction);
    },

    saveAll: function(component, event, helper){
        var saveAllEvent = $A.get("e.c:HouseholdAssignmentSaveAll");
        console.log('saveAllEvent: ' + saveAllEvent);
        saveAllEvent.fire();
    }
})