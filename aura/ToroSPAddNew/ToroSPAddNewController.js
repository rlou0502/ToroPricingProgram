({
    initialize: function (cmp, event, helper) {
        console.log('@ToroSPAddNewController:initialize');
        console.log('searchType: ' + cmp.get('v.searchType'));
    },
    showModal: function (cmp, event, helper) {
        console.log('@ToroSPAddNewController:showModal');
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
        cmp.set('v.newItemMSRPPrice', '');
        cmp.set('v.newItemAwardPrice', '');
        cmp.set('v.newItemDescription', '');

        cmp.set('v.spSearchTypeValue', '');
        cmp.set('v.previousSearchTerm', '');
        cmp.set('v.currentSearchTerm', '');
        cmp.set('v.wasAutoCompleted', false);
        cmp.set('v.searchResults', null);
    },
    handleSpSearchTypeChange: function(cmp, event, helper) {
        cmp.set('v.newItemProductId', '');
        cmp.set('v.newItemSPQuantity', 1);
        // cmp.set('v.newItemDistributorResponsibility', 50);

        cmp.set('v.newItemProductName', '');
        cmp.set('v.newItemDNetPrice', '');
        cmp.set('v.newItemMSRPPrice', '');
        cmp.set('v.newItemAwardPrice', '');
        cmp.set('v.newItemDescription', '');

        cmp.set('v.previousSearchTerm', '');
        cmp.set('v.currentSearchTerm', '');
        cmp.set('v.wasAutoCompleted', false);
        cmp.set('v.searchResults', null);
    },
    handleAddNewProductIdChange: function (cmp, event, helper) {
        if (cmp.get('v.searchType') == 'supportplus') {
            console.log('handleAddNewProductIdChange');
            cmp.set('v.wasAutoCompleted', false);
            cmp.set('v.newItemProductName', '');
            cmp.set('v.newItemDNetPrice', '');
            cmp.set('v.newItemMSRPPrice', '');
            cmp.set('v.newItemAwardPrice', '');
            cmp.set('v.newItemDescription', '');

            var previousValue = event.getParam('oldValue');
            var currentValue = event.getParam('value');
            var searchType = cmp.get('v.searchType');

            if (currentValue.length == 3) {
                helper.refreshSearchResults(cmp, previousValue, currentValue, searchType);
            }

            else {
                cmp.set('v.previousSearchTerm', previousValue);
                cmp.set('v.currentSearchTerm', currentValue);
            }
        }
    },
    populateAddNewModalFields: function (cmp, event, helper) {
        var dataset = event.currentTarget.dataset;
        cmp.set('v.newItemProductId', dataset.productid);
        cmp.set('v.newItemProductName', dataset.productname);
        cmp.set('v.newItemDNetPrice', dataset.dnetprice);
        cmp.set('v.newItemMSRPPrice', dataset.msrpprice);
        cmp.set('v.newItemAwardPrice', dataset.awardprice);
        cmp.set('v.newItemDescription', dataset.description);
        cmp.set('v.wasAutoCompleted', true);
    },
    addNewSupportPlusItem: function(cmp, event, helper) {
        console.log('ToroSPAddNewController:addNewSupportPlusItem');
        var cmpEvent = cmp.getEvent("addNew");
        cmpEvent.setParams({
            'newItemProductId'                : cmp.get('v.newItemProductId'),
            'newItemDNetPrice'                : cmp.get('v.newItemDNetPrice'),
            'newItemMSRPPrice'                : cmp.get('v.newItemMSRPPrice'),
            'newItemAwardPrice'               : cmp.get('v.newItemAwardPrice'),
            'newItemSPQuantity'               : cmp.get('v.newItemSPQuantity'),
            'newItemDistributorResponsibility': cmp.get('v.newItemDistributorResponsibility'),
            'newItemDescription'              : cmp.get('v.newItemDescription')
        });
        cmpEvent.fire();
    }
})