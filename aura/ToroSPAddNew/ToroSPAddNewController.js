({
	scriptsLoaded : function(component, event, helper) {
		
	},
    supportPlusChange : function(cmp, event, helper) {
        console.log('-----supportPlusQtyChangeEvent');
        var cmpEvent = cmp.getEvent("supportPlusAddNewEvent");
        cmpEvent.fire();
    }
})