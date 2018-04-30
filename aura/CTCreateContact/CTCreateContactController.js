({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var strParentId;
        var strRecordTypeId;
        var currentURL = window.location.toString();

        
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseUser = response.getReturnValue();
            }
            
            var iAccId = currentURL.indexOf('=accid');
            if(iAccId>=0){  // look for the parent account id  
                strParentId = currentURL.substring(iAccId+9,iAccId+24);
            }
    
            var iRecordTypeId = currentURL.indexOf('recordTypeId=');
            if(iRecordTypeId>=0){          // look for the record type id parameter in the requested URL
                strRecordTypeId = currentURL.substring(iRecordTypeId+13,iRecordTypeId+28);
            }
    
            alert('responseUser JSON: '+JSON.stringify(responseUser));
            alert('responseUser.Country: '+responseUser.Country);
            alert('responseUser.Country.toString(): '+responseUser.Country.toString());
            alert('responseUser.Id: '+responseUser.id);
            
            createRecordEvent.setParams({
                "entityApiName": "Contact",
                "defaultFieldValues":{
                    'RecordTypeId':strRecordTypeId,
                    'AccountId':strParentId,
                    'MailingCountryCode':responseUser.CountryCode.toString()
    
                    }
            });
            createRecordEvent.fire();
            
        });
        $A.enqueueAction(action);
        

    }
})