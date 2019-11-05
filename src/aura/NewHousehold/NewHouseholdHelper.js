({
    loadFields: function(component){
 		var fields = component.get("v.fields");
		if (fields.length === 0) {
			var action = component.get("c.getNewHouseholdDisplayFields");
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state == 'SUCCESS'){
					fields = JSON.parse(response.getReturnValue());;
					console.log('NewHousehold fields', fields);
					component.set("v.fields", fields);
				}else{
					throw response.getError();
				}
			})
			$A.enqueueAction(action);
		}
    }
})