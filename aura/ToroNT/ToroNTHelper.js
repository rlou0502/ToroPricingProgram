({
	initialize: function (cmp) {
		console.log('ToroNTHelper:initialize');
		var action = cmp.get('c.retrieveNTData');
		action.setParams({
			quoteId: cmp.get('v.quoteId')
		});
		action.setCallback(
			this, function(response) {
				if (cmp.isValid() && response.getState() === 'SUCCESS') {
					var ntData = response.getReturnValue();
					cmp.set('v.quote', ntData.quote);
					cmp.set('v.quoteItems', ntData.qiWrappers);

					console.log('ntData:');
					console.log(ntData);

				}
			}
		);

		$A.enqueueAction(action);
	}
})