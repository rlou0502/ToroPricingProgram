({
	handleDeleteClick : function(cmp, event, helper) {
		console.log('ToroNTQuoteItemsController:handleDeleteClick');
		var cmpEvent = cmp.getEvent('ntDeleteEvent');
		var productExtId = event.getSource().get('v.name');
		cmpEvent.setParams({
			'productExtId': productExtId
		});

		cmpEvent.fire();
	},
	handleQuantityChange: function(cmp, event, helper) {
		console.log('@ToroNTQuoteItemsController:handleQuantityChange');
		var qty = event.getSource().get('v.value');

		if (qty < 0) {
			event.getSource().set('v.value', 0);
		}

		var cmpEvent = cmp.getEvent('ntValueChangeEvent');
		cmpEvent.fire();
	},
	handleAwardPriceChange: function(cmp, event, helper) {
		console.log('@ToroNTQuoteItemsController:handleAwardPriceChange');

		var award = event.getSource().get('v.value');

		if (award < 0) {
			event.getSource().set('v.value', 0);
		}

		var cmpEvent = cmp.getEvent('ntValueChangeEvent');
		cmpEvent.fire();
	}
})