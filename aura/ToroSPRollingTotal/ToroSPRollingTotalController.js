({
    /*
    updateRollingTotals : function(cmp, event) {
        console.log('@ToroSPRollingTotalController:updateRollingTotals');
        var quote = cmp.get('v.quote');
        console.log(quote);
    },*/
    handleDistRespChange: function(cmp, event) {
        var quote = cmp.get('v.quote');
        console.log('quote: ');
        console.log(quote.distributorResponsibility);
        var cmpEvent = cmp.getEvent('spDistRespChangeEvent');
        cmpEvent.setParams({
            distributorResponsibility: cmp.get('v.selectedDistributorResponsibility')
        });
        cmpEvent.fire();
    }
})