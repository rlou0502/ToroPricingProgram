({
    supportPlusQtyChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:supportPlusQtyChange');
        var cmpEvent = cmp.getEvent("supportPlusQtyChangeEvent");
        cmpEvent.fire();
    },
    supportPlusContributionChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:supportPlusContributionChange');
        var cmpEvent = cmp.getEvent("supportPlusQtyChangeEvent");
        cmpEvent.fire();
    },
    toggleSection: function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:toggleSection');
        var section = event.currentTarget.closest('.slds-section');
        if (section.classList.contains('slds-is-open')) {
            section.classList.remove('slds-is-open');
        }

        else {
            section.classList.add('slds-is-open');
        }
    }
})