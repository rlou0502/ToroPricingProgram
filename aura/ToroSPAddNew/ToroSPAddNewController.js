({
    showModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.addClass(modal, 'hideDiv');
        cmp.set('v.searchResults', null);

        cmp.set('v.newItemProductId', '');
        cmp.set('v.newItemSPQuantity', 1);
        // cmp.set('v.newItemDistributorResponsibility', 50);

        cmp.set('v.newItemProductName', '');
        cmp.set('v.newItemDNetPrice', '');
        cmp.set('v.newItemDescription', '');

        cmp.set('v.previousSearchTerm', '');
        cmp.set('v.currentSearchTerm', '');
        cmp.set('v.wasAutoCompleted', false);
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
    },
    addNewSupportPlusItem: function(cmp, event, helper) {
        console.log('ToroSPAddNewController:addNewSupportPlusItem');
        var cmpEvent = cmp.getEvent("addNew");
        cmpEvent.setParams({
            'newItemProductId': cmp.get('v.newItemProductId'),
            'newItemDNetPrice': cmp.get('v.newItemDNetPrice'),
            'newItemSPQuantity': cmp.get('v.newItemSPQuantity'),
            'newItemDistributorResponsibility': cmp.get('v.newItemDistributorResponsibility')
        });
        cmpEvent.fire();
    }
})