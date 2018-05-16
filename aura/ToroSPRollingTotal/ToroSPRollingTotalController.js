({
    /*
    updateRollingTotals : function(cmp, event) {
        console.log('@ToroSPRollingTotalController:updateRollingTotals');
        var quote = cmp.get('v.quote');
        console.log(quote);
    },*/
    handleDistRespChange: function(cmp, event) {
        console.log('@ToroSPRollingTotalController:handleDistRespChange');

        var value = event.getSource().get('v.value');

        if (value < 0) {
            event.getSource().set('v.value', 0);
        }

        else if (value > 100) {
            event.getSource().set('v.value', 100);
        }

        var cmpEvent = cmp.getEvent('spDistRespChangeEvent');
        cmpEvent.setParams({
            distributorResponsibility: cmp.get('v.selectedDistributorResponsibility')
        });
        cmpEvent.fire();
    }
})