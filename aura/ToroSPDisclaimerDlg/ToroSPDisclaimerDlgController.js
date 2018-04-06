({
	onCancel : function(component, event, helper) {
        helper.closeMe(component, event, helper);		
	},
    onOk : function(component, event, helper) {
        debugger;
        var quoteId = component.get('v.quoteId');
        var forwardUrl = component.get('v.forwardUrl');
        
        var cmpEvent = component.getEvent("proceedToSupportPlusEvent");
        cmpEvent.fire();
        
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
                    helper.closeMe(component, event, helper);
                }
	        }
	    );
		$A.enqueueAction(getAction);
	}
})