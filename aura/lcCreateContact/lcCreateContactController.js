({
    doInit : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var recordId = component.get("v.recordId");
        var recordTypeId = component.get("v.recordTypeId").toString();
        alert('recordTypeId: '+recordTypeId);
        var strParentId;
        var currentURL = window.location.toString();
        var iAccId = currentURL.indexOf('=accid');
        if(iAccId>=0){          // this is id for account (you can get first 3 number from id of you parent record) 
    		strParentId = currentURL.substring(iAccId+9,iAccId+24); // find parent id from string url  
		}
		alert(strParentId);		
        
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