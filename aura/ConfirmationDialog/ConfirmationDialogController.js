({
	onCancel : function(component, event, helper) {
        helper.closeMe(component, event, helper);		
	},
    onOk : function(component, event, helper) {
        var quoteId = component.get('v.quoteId');
        var forwardUrl = component.get('v.forwardUrl');
        /*
        if(forwardUrl == "/"){
        	var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": quoteId
            });
            navEvt.fire();   
        }
        */
    	document.location = forwardUrl+quoteId;
        helper.closeMe(component, event, helper);
	}
})