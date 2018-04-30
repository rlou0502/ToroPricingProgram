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
    
            alert('strCountryCode en_US: '+getCountryCode('en_US'));
            alert('strCountryCode en_US: '+getCountryCode('en_US'));
            alert('strCountryCode en_US: '+getCountryCode('en_US'));
            alert('strCountryCode en_US: '+getCountryCode('en_US'));

			var strCountryCode = getCountryCode(responseUser.LocalSidKey.toString());
            
            createRecordEvent.setParams({
                "entityApiName": "Account",
                "defaultFieldValues":{
                    'RecordTypeId':strRecordTypeId,
                    'BillingCountryCode':strCountryCode
                }
            });
            createRecordEvent.fire();
			
        });
        $A.enqueueAction(action);            
        
        function getCountryCode(strLocale) {
            var strCountryCode = '';
            var iLocaleUnderScore = strLocale.toString().indexOf('_');
            if(iLocaleUnderScore > 0) {
                strCountryCode = strLocale.substring(iLocaleUnderScore+1,iLocaleUnderScore+3);
            } else {
                if(strLocale.length()>=2){
                    strCountryCode = strLocale.substring(0,2);
                }
            }
            return strCountryCode;
        } 
            
    }
})