({
    /*
    updateRollingTotals : function(cmp, event) {
        console.log('@ToroSPRollingTotalController:updateRollingTotals');
        var quote = cmp.get('v.quote');
        console.log(quote);
    },*/
    handleDistRespChange: function(cmp, event) {
        console.log('@ToroSPRollingTotalController:handleDistRespChange');
        var quote = cmp.get('v.quote');
        console.log('quote: ');
        console.log(quote.distributorResponsibility);
        var cmpEvent = cmp.getEvent('spDistRespChangeEvent');
        cmpEvent.setParams({
            distributorResponsibility: cmp.get('v.selectedDistributorResponsibility')
        });
        cmpEvent.fire();
    },
    setDistributorResponsibility: function(cmp, event, helper) {
    	var params = event.getParam('arguments');
        if(params) { 
            var responsibility = params.distributorResponsibility;
            cmp.set('v.selectedDistributorResponsibility', responsibility);
        }
    }
})