({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var strRecordTypeId;
        var currentURL = window.location.toString();

        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseUser = response.getReturnValue();
            }
            
            var iRecordTypeId = currentURL.indexOf('recordTypeId=');
            if(iRecordTypeId>=0){          // look for the record type id parameter in the requested URL
                strRecordTypeId = currentURL.substring(iRecordTypeId+13,iRecordTypeId+28);
            }
    
            createRecordEvent.setParams({
                "entityApiName": "Account",
                "defaultFieldValues":{
                    'RecordTypeId':strRecordTypeId,
                    'BillingCountryCode':responseUser.CountryCode.toString()
                }
            });
            createRecordEvent.fire();
            
        });
        $A.enqueueAction(action);            
            
    }
})