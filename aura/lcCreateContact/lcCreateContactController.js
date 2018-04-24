({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact",
            "recordTypeId" : null,
            "defaultFieldValues":{
            	'FirstName':'John',
            	'LastName': 'Spinarski'
	        }
        });
        createRecordEvent.fire();
    }
})