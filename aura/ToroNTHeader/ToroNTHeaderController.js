({
	updateTotals: function (cmp, event, helper) {
		console.log('@ToroNTHeaderController:updateTotals');
		
		var totalAdjAward      = event.getSource().get('v.totalAdjAward');
		var totalAwardAllied   = event.getSource().get('v.totalAwardAllied');
		var totalAwardTradeIns = event.getSource().get('v.totalAwardTradeIns');
		var totalAwardServices = event.getSource().get('v.totalAwardServices');

		cmp.set('v.totalAdjAward', totalAdjAward);
		cmp.set('v.totalAwardAllied', totalAwardAllied);
		cmp.set('v.totalAwardTradeIns', totalAwardTradeIns);
		cmp.set('v.totalAwardServices', totalAwardServices);
	}
})