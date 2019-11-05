/**
 * Created by Eric Stansbury on 5/6/2019.
 */
({
    toggleModal: function(component,event,helper){
        component.set("v.searchParams", {'sobjectType':'Account'});
        component.set("v.results", null);
        component.set("v.resultRecords", null);
        component.set("v.showModal", !component.get("v.showModal"));
		if (component.get("v.showModal") === true) {
			helper.loadFields(component);
		}
    },

    loadFields: function(component){
		var searchableFields = component.get("v.searchableFields");
		if (searchableFields.length === 0) {
			// populate searchableFields from field set
			var getSearchableFieldsAction = component.get("c.getSearchableFields");
			getSearchableFieldsAction.setCallback(this, function(response1){
				var state1 = response1.getState();
				if (state1 == 'SUCCESS'){
					var fields1 = JSON.parse(response1.getReturnValue());
					console.log('searchableFields', fields1);
					component.set("v.searchableFields", fields1);

					var resultFields = component.get("v.resultFields");
					if (resultFields.length === 0) {
						var getResultFieldsAction = component.get("c.getResultFields");
						getResultFieldsAction.setCallback(this, function(response2){
							var state2 = response2.getState();
							if (state2 == 'SUCCESS'){
								var fields2 = JSON.parse(response2.getReturnValue());;
								console.log('resultFields', fields2);
								component.set("v.resultFields", fields2);
							}else{
								throw response2.getError();
							}
						});
						$A.enqueueAction(getResultFieldsAction);
					}
				}else{
					throw response1.getError();
				}
			});
			$A.enqueueAction(getSearchableFieldsAction);
		}

    }
})