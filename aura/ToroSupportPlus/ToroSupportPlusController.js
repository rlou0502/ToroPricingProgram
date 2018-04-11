({
	initialize: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:initialize');
        helper.initialize(cmp);
    },
    handleAddNewInput: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:handleAddNewInput');

        cmp.set('v.wasAutoCompleted', false);
        cmp.set('v.newItemProductName', '');
        cmp.set('v.newItemDNetPrice', '');
        cmp.set('v.newItemDescription', '');

        var previousValue = event.getParam('oldValue');
        var currentValue  = event.getParam('value');

        if (currentValue.length == 3) {
            helper.refreshSearchResults(cmp, previousValue, currentValue);
        }

        else {
            cmp.set('v.previousSearchTerm', previousValue);
            cmp.set('v.currentSearchTerm', currentValue);
        }
    },
    handleSupportPlusQtyChange: function(cmp, event, helper) {
        var childCmp = cmp.find("cmpRollingTotal");
        childCmp.updateRollingTotals();
    },
    showAddModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideAddModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.addClass(modal, 'hideDiv');
        cmp.set('v.searchResults', null);
    },
    addProduct: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:addProduct');
        var productId                        = cmp.get('v.newItemProductId');
        var newItemSPQuantity                = cmp.get('v.newItemSPQuantity');
        var newItemDistributorResponsibility = cmp.get('v.newItemDistributorResponsibility');

        var inputIsValid = true;
        var errorMessage = 'The following values are required: ';

        if (!productId) {
            inputIsValid = false;
            errorMessage += ' Product ID';
        }

        if (!newItemSPQuantity) {
            inputIsValid = false;
            errorMessage += ', SP Quantity';
        }

        if (!newItemDistributorResponsibility) {
            inputIsValid = false;
            errorMessage += ', Distributor Responsibility';
        }



        if (!inputIsValid) {
            alert(errorMessage);
        }

        else {
            helper.addProduct(cmp, productId, newItemSPQuantity, newItemDistributorResponsibility);
        }
    },
    submit: function(cmp, event, helper) {
        alert ('submit placeholder');
        var quote = cmp.get('v.quote');

        // helper.submit(quote, quoteItems);
    },
    populateAddNew: function(cmp, event, helper) {
        var dataset = event.currentTarget.dataset;
        cmp.set('v.newItemProductId', dataset.productid);
        cmp.set('v.newItemProductName', dataset.productname);
        cmp.set('v.newItemDNetPrice', dataset.dnetprice);
        cmp.set('v.newItemDescription', dataset.description);
        cmp.set('v.wasAutoCompleted', true);
    }
})