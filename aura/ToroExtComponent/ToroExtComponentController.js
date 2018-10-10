({
	init : function(component, event, helper) {
		var action = component.get('c.retrieveRelatedData');
		action.setCallback(
			this, function(response) {
				if (component.isValid() && response.getState() === 'SUCCESS') {
					var ntData = response.getReturnValue();
					component.set('v.relatedList', ntData);
				}
			}
		);

		$A.enqueueAction(action);	
	},
    alert : function(component, event, helper) {
		alert('hi');	
	}
})