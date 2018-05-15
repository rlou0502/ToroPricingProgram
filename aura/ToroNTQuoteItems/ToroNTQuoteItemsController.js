({
	handleDeleteClick : function(cmp, event, helper) {
		console.log('ToroNTQuoteItemsController:handleDeleteClick');
		var cmpEvent = cmp.getEvent('ntDeleteEvent');
		var productExtId = event.getSource().get('v.name');
		cmpEvent.setParams({
			'productExtId': productExtId
		});

		cmpEvent.fire();
	}
})