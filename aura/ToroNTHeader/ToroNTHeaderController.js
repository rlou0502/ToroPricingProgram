({
	updateTotals: function (cmp, event, helper) {
		console.log('@ToroNTHeaderController:updateTotals');
		
		var totalAwardAllied   = 0;
		var totalAwardTradeIns = 0;
		var totalAwardServices = 0;

		var quoteItems = cmp.get('v.quoteItems');

		/*L01_Allied / L02_Service / L03_Trade

													<option value="L00001">Allied Product</option>
											<option value="L00002">Service Contract</option>
											<option value="L00004">Trade-In</option>
											*/
		for (var i = 0; i < quoteItems.length; i++) {
			var productExtId  = quoteItems[i].productId;
			var extTotalAward = quoteItems[i].quantity * quoteItems[i].awardPrice;

			if (productExtId == 'L00001') {
				totalAwardAllied += extTotalAward;
			} else if (productExtId == 'L00002') {
				totalAwardServices += extTotalAward;
			} else if (productExtId == 'L00004') {
				totalAwardTradeIns += extTotalAward;
			}
		}

		var totalAdjAward = (totalAwardAllied + totalAwardServices) - totalAwardTradeIns;

		cmp.set('v.totalAdjAward', totalAdjAward);
		cmp.set('v.totalAwardAllied', totalAwardAllied);
		cmp.set('v.totalAwardTradeIns', totalAwardTradeIns);
		cmp.set('v.totalAwardServices', totalAwardServices);
	}
})