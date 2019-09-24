/**
 * Created by Eric Stansbury on 5/6/2019.
 */
({
    toggleModal: function(component){
        component.set("v.searchParams", {'sobjectType':'Account'});
        component.set("v.results", null);
        component.set("v.resultRecords", null);
        component.set("v.showModal", !component.get("v.showModal"));
    }
})