({
	initialize: function(cmp, event, helper) {
        helper.initialize(cmp);
    },
    handleSupportPlusQtyChange: function(cmp, event, helper) {
        var childCmp = cmp.find("cmpRollingTotal");
        childCmp.updateRollingTotals();
    },
    handleProductInputKeyup: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:handleProductInputKeyup');
        var searchText = event.target.value;
        console.log('searchText: ' + searchText);
        if (searchText.length >= 3) {
            helper.retrieveAutocompleteResults(cmp, searchText);
        }
    },
    toggleAddProductModal: function(cmp, event, helper) {
        helper.toggleAddProductModal(cmp);
    },
    showAddModal: function (cmp, event, helper) {
        helper.showAddModal(cmp);
    },
    hideAddModal: function (cmp, event, helper) {
        helper.hideAddModal(cmp);
    },
    handleHideAutoComplete: function (cmp, event, helper) {
        helper.hideAutoComplete(cmp);
    },
    addProduct: function(cmp, event, helper) {
        alert('add product placeholder');
    },
    submit: function(cmp, event, helper) {
        alert ('submit placeholder');
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItemList');
        helper.submit(quote, quoteItems);
    }
})