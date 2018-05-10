({
	initialize : function(quoteId) {
		var action = cmp.get('c.retrieveNTData');
		action.setParams({
			quoteId: quoteId
		});
		action.setCallback(
			this, function(response) {
				alert('retrievedNTData success');
			}
		);

		$A.enqueueAction(action);
	}
})