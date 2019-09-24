/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    doInit: function(component, event, helper){
        // populate searchableFields from field set
        var getSearchableFieldsAction = component.get("c.getSearchableFields");
        getSearchableFieldsAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var fields = JSON.parse(response.getReturnValue());;
                console.log('searchableFields', fields);
                component.set("v.searchableFields", fields);
            }else{
                throw response.getError();
            }
        });

        var getResultFieldsAction = component.get("c.getResultFields");
        getResultFieldsAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var fields = JSON.parse(response.getReturnValue());;
                console.log('resultFields', fields);
                component.set("v.resultFields", fields);
            }else{
                throw response.getError();
            }
        });
        $A.enqueueAction(getSearchableFieldsAction);
        $A.enqueueAction(getResultFieldsAction);
    },

    search: function(component, event, helper){
        var searchableFields = component.get("v.searchableFields");

        var fieldElements = component.find("searchableField");
        console.log('fieldElements', fieldElements.length);

        var searchParams = {};
        for (var i in fieldElements){
            var fieldElement = fieldElements[i];
            var fieldName = searchableFields[i].fieldPath;
            var formValue = fieldElement.get("v.value");
            if (formValue != null){
                searchParams[fieldName] = formValue;
            }
        }

        console.log('searchParams', searchParams);

        var resultFields = component.get("v.resultFields");
        var searchHouseholdsAction = component.get("c.searchHouseholds");
        searchHouseholdsAction.setParam('paramsMap', searchParams);
        searchHouseholdsAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == 'SUCCESS'){
                var returnValue = response.getReturnValue();
                var returnValueList = returnValue.map(
                    function(record){
                        return { values: resultFields.map(
                            function(field){
                                console.log('field.fieldPath', field.fieldPath);
                                return record[field.fieldPath];
                            }
                        )}
                    }
                );

                console.log("v.results", returnValueList);
                component.set("v.results", returnValueList);
                component.set("v.resultRecords", returnValue);
                component.set("v.searched", true);
            }else{
                console.log(response.getError());
                throw response.getError();
            }
        });
        $A.enqueueAction(searchHouseholdsAction);
    },

    select: function(component, event, helper){
        var index = event.getSource().get("v.value");
        var selectedHousehold = component.get("v.resultRecords")[index];
        component.set("v.selectedHousehold", selectedHousehold);

        helper.toggleModal(component);
    },

    toggleModal: function(component, event, helper){
        helper.toggleModal(component);
    },

    clearHousehold: function(component, event, helper){
        component.set("v.selectedHousehold", null);
    }
})