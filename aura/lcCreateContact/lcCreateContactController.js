({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var strParentId;
        var strRecordTypeId;
        var currentURL = window.location.toString();
        var iAccId = currentURL.indexOf('=accid');
        var iRecordTypeId = currentURL.indexOf('recordTypeId=');
        if(iAccId>=0){          // this is id for account (you can get first 3 number from id of you parent record) 
    		strParentId = currentURL.substring(iAccId+9,iAccId+24); // find parent id from string url  
		}
        alert('strParentId: '+strParentId);	
        alert('component.get("v.account.Id");: '+component.get("v.account.Id"));
        alert('component.get("v.recordId");: '+component.get("v.recordId"));
        alert('component.get("v.simpleFields.BillingCity");: '+component.get("v.simpleFields.BillingCity"));

        if(iRecordTypeId>=0){          // this is record type id for the new record
    		strRecordTypeId = currentURL.substring(iRecordTypeId+13,iRecordTypeId+28); // find record type id from string url  
		}
        alert('strRecordTypeId: '+strRecordTypeId);		
        
        createRecordEvent.setParams({
            "entityApiName": "Contact",
            "defaultFieldValues":{
            	'FirstName':'John',
            	'LastName': 'Spinarski'
	        }
        });
        createRecordEvent.fire();
    }
})