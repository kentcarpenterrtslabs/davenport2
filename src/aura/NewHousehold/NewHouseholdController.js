/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({

    toggleModal: function(component, event, helper){
        component.set("v.showModal", !component.get("v.showModal"));
		if (component.get("v.showModal") === true) {
			helper.loadFields(component);
		}
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