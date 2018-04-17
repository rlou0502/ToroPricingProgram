({
	initialize: function(cmp, event, helper) {
        helper.initialize(cmp);
    },
    addNewSupportPlusItem: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:addNewSupportPlusItem');
        var newItemProductId  = event.getParam('newItemProductId');
        var newItemDNetPrice  = event.getParam('newItemDNetPrice');
        var newItemSPQuantity = event.getParam('newItemSPQuantity');
        var newItemDistributorResponsibility = event.getParam('newItemDistributorResponsibility');

        var inputIsValid = true;
        var errorMessage = 'The following values are required: ';

        if (!newItemProductId) {
            inputIsValid = false;
            errorMessage += ' Product ID';
        }

        if (!newItemSPQuantity) {
            inputIsValid = false;
            errorMessage += ', SP Quantity';
        }

        if (!inputIsValid) {
            alert(errorMessage);
        }

        else {
            helper.addProduct(cmp, newItemProductId, newItemDNetPrice, newItemSPQuantity, newItemDistributorResponsibility);
        }
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
        var quote            = cmp.get('v.quote');
        var quoteItems       = cmp.get('v.quoteItems');
        var supportPlusItems = cmp.get('v.supportPlusItems');
        var allowance        = quote.Toro_Support_Plus_Allowance__c;

        cmp.set('v.quoteItems', helper.updateDistributorResponsibility(quote, quoteItems));
        cmp.set('v.supportPlusItems', helper.updateDistributorResponsibility(quote, supportPlusItems));
        cmp.set('v.quote', helper.recalculateQuoteSupportPlusTotals(quote, quoteItems, supportPlusItems));

        /*
        var spQuantity = 1;
        var spContribution = 50;
        var spDNetPrice = 5.55;
        var cmpRollingTotals = cmp.find("cmpRollingTotal");
        cmpRollingTotals.updateRollingTotals(spQuantity, spContribution, spDNetPrice);
        */
    },
    handleDistRespChange: function(cmp, event, helper) {
        var quote = cmp.get('v.quote');
        quote.Distributor_Responsibility__c = event.getParam('distributorResponsibility');
        cmp.set('v.quote', quote);
        cmp.find('cmpRollingTotal').updateRollingTotals();

    },
    handleShowAddNewModal: function (cmp, event, helper) {
        cmp.find('cmpAddNew').showModal();
    },
    handleAddNewSupportPlusItem: function(cmp, event, helper) {
        var productId         = cmp.get('v.newItemProductId');
        var newItemSPQuantity = cmp.get('v.newItemSPQuantity');

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

        if (!inputIsValid) {
            alert(errorMessage);
        }

        else {
            helper.addProduct(cmp, productId, newItemSPQuantity);
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