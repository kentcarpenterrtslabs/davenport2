({
    loadFields: function(component){
 		var fields = component.get("v.fields");
		if (fields.length === 0) {
			var action = component.get("c.getNewHouseholdDisplayFields");
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state == 'SUCCESS'){
					fields = JSON.parse(response.getReturnValue());
					console.log('NewHousehold fields', fields);
					component.set("v.fields", fields);
				}else{
					throw response.getError();
				}
			})
			$A.enqueueAction(action);
		}
    },

    getRecordTypeId: function(component){
 		var recordTypeId = component.get("v.recordTypeId");
		if (recordTypeId.length === 0) {
			var action = component.get("c.getNewHouseholdRecordTypeId");
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state == 'SUCCESS'){
					recordTypeId = response.getReturnValue();
					console.log('recordTypeId', recordTypeId);
					component.set("v.recordTypeId", recordTypeId);
				}else{
					throw response.getError();
				}
			})
			$A.enqueueAction(action);
		}
    }
})