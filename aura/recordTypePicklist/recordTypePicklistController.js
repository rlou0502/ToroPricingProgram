({
    doInit : function(component) {
        var action = component.get("c.getRecordTypePickListValuesIntoList");
        action.setParams({
            objectType: component.get("v.sObjectName"),
        });
        action.setCallback(this, function(response) {
            var list = response.getReturnValue();
            component.set("v.recordTypePicklistValues", list);
        })
        $A.enqueueAction(action);
    }
})