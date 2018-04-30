({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var strRecordTypeId;
        var currentURL = window.location.toString();

        var iRecordTypeId = currentURL.indexOf('recordTypeId=');
        if(iRecordTypeId>=0){          // look for the record type id parameter in the requested URL
    		strRecordTypeId = currentURL.substring(iRecordTypeId+13,iRecordTypeId+28);
		}

        createRecordEvent.setParams({
            "entityApiName": "Lead",
            "defaultFieldValues":{
                'RecordTypeId':strRecordTypeId,
		        }
        });
        createRecordEvent.fire();
    }
})