({
	initialize: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:initialize');
        helper.initialize(cmp);
    },
    handleAddNewProductIdChange: function(cmp, event, helper) {
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
    handleSPQuantityChange: function(cmp, event, helper) {
        console.log('@ToroSupportPlustController:handleSPQuantityChange');
        var spQuantity = 1;
        var spContribution = 50;
        var spDNetPrice = 5.55;

        var cmpRollingTotals = cmp.find("cmpRollingTotal");
        cmpRollingTotals.updateRollingTotals(spQuantity, spContribution, spDNetPrice);
    },
    handleDistributorResponsibilityChange: function(cmp, event, helper) {
        console.log('changed Distributor Responsibility');
    },
    handleShowAddNewModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.removeClass(modal, 'hideDiv');
    },
    handleCancelAddNewModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.addClass(modal, 'hideDiv');
        cmp.set('v.searchResults', null);
    },
    handleAddNewSupportPlusItem: function(cmp, event, helper) {
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
    handleSubmitClick: function(cmp, event, helper) {
        alert ('submit placeholder');
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItems');
        var supportPlusItems = cmp.get('v.supportPlusItems');

        helper.saveChanges(quote, quoteItems, supportPlusItems);
    },
    populateAddNewModalFields: function(cmp, event, helper) {
        var dataset = event.currentTarget.dataset;
        cmp.set('v.newItemProductId', dataset.productid);
        cmp.set('v.newItemProductName', dataset.productname);
        cmp.set('v.newItemDNetPrice', dataset.dnetprice);
        cmp.set('v.newItemDescription', dataset.description);
        cmp.set('v.wasAutoCompleted', true);
    }
})