({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var strParentId;
        var strRecordTypeId;
        var currentURL = window.location.toString();

        var iAccId = currentURL.indexOf('=accid');
        if(iAccId>=0){  // look for the parent account id  
    		strParentId = currentURL.substring(iAccId+9,iAccId+24);
		}

        var iRecordTypeId = currentURL.indexOf('recordTypeId=');
        if(iRecordTypeId>=0){          // look for the record type id parameter in the requested URL
    		strRecordTypeId = currentURL.substring(iRecordTypeId+13,iRecordTypeId+28);
		}

        createRecordEvent.setParams({
            "entityApiName": "Contact",
            "defaultFieldValues":{
                'RecordTypeId':strRecordTypeId,
                'AccountId':strParentId,
                'MailingCountry':'{!$User.Country}'
		        } 
        });
        createRecordEvent.fire();
    }
})