/**
 * Created by Eric Stansbury on 5/6/2019.
 */
({
    initRows: function(component, event, helper){
        var getComparisonRowsAction = component.get("c.getComparisonRows");
        getComparisonRowsAction.setParam('householdId', component.get("v.household.Id"));
        getComparisonRowsAction.setParam('financialAccountId', component.get("v.financialAccount.Id"));
        getComparisonRowsAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                component.set("v.comparisonRows", JSON.parse(response.getReturnValue()));
            }else{
                throw response.getError();
            }
        });
        $A.enqueueAction(getComparisonRowsAction);
    },

    selectHousehold: function(component, event, helper){
        var household = event.getParam("household");
        console.log('HouseholdAssignmentRowController selectHousehold', household);
        component.set("v.household", household);
    },

    assign: function(component, event, helper){
        console.log('assign()');
        console.log('component.get("v.household") != null', component.get("v.household") != null);

        if (component.get("v.household") != null){
            var assignHouseholdAction = component.get("c.assignHousehold");
            assignHouseholdAction.setParam('householdId', component.get("v.household.Id"));
            assignHouseholdAction.setParam('financialAccountId', component.get("v.financialAccount.Id"));
            assignHouseholdAction.setCallback(this, function(response){
                var state = response.getState();
                if (state == 'SUCCESS'){
                    component.set("v.hidden", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": 'Success!',
                        "message": 'The financial account was assigned to the ' + component.get("v.household.Name") + ' household',
                        "type": "success",
                        "messageTemplate": '{0} was assigned to the {1} household.',
                        "messageTemplateData": [{
                                url: '/' + component.get("v.financialAccount.Id"),
                                label: component.get("v.financialAccount.Name")
                            },
                            component.get("v.household.Name")
                        ]
                    });
                    toastEvent.fire();
                }else{
                    throw response.getError();
                }
            })
            $A.enqueueAction(assignHouseholdAction);
        }
    }
})