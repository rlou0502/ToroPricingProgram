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
        console.log('--- 111');        
        var getAction = component.get('c.svc_clearDirtyQuoteItem');
		var self = this;
        getAction.setParams({
            quoteId: quoteId
        });
        getAction.setCallback(this, 
	        function(response) {
                console.log("Clear Dirty Items " + Date.now());
	            var state = response.getState();
	            if (component.isValid() && state === "SUCCESS") {  
	                var data = response.getReturnValue();
                    document.location = forwardUrl+quoteId;
                    helper.closeMe(component, event, helper);
                }
	        }
	    );
		$A.enqueueAction(getAction);
	}
})