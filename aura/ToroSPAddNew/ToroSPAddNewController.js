({
    showModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.addClass(modal, 'hideDiv');
        cmp.set('v.searchResults', null);
    },
    handleAddNewProductIdChange: function (cmp, event, helper) {
        console.log('handleAddNewProductIdChange');
        cmp.set('v.wasAutoCompleted', false);
        cmp.set('v.newItemProductName', '');
        cmp.set('v.newItemDNetPrice', '');
        cmp.set('v.newItemDescription', '');

        var previousValue = event.getParam('oldValue');
        var currentValue = event.getParam('value');

        if (currentValue.length == 3) {
            helper.refreshSearchResults(cmp, previousValue, currentValue);
        }

        else {
            cmp.set('v.previousSearchTerm', previousValue);
            cmp.set('v.currentSearchTerm', currentValue);
        }
    },
    populateAddNewModalFields: function (cmp, event, helper) {
        var dataset = event.currentTarget.dataset;
        cmp.set('v.newItemProductId', dataset.productid);
        cmp.set('v.newItemProductName', dataset.productname);
        cmp.set('v.newItemDNetPrice', dataset.dnetprice);
        cmp.set('v.newItemDescription', dataset.description);
        cmp.set('v.wasAutoCompleted', true);
    }
})