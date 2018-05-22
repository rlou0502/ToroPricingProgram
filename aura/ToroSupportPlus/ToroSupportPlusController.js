({
	initialize: function(cmp, event, helper) {
        helper.initialize(cmp);
    },
    returnToPricing: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:returnToPricing');
        var quoteId = cmp.get("v.quoteId");
        document.location = '/apex/PricingProgramLgtnOut?Id=' + quoteId;
    },
    addNewSupportPlusItem: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:addNewSupportPlusItem');
        var newItemProductId  = event.getParam('newItemProductId');
        var newItemDNetPrice  = event.getParam('newItemDNetPrice');
        var newItemAwardPrice = event.getParam('newItemAwardPrice');
        var newItemSPQuantity = event.getParam('newItemSPQuantity');
        var newItemDistributorResponsibility = event.getParam('newItemDistributorResponsibility');
        console.log('newItemDistributorResponsibility: ' + newItemDistributorResponsibility);

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
            helper.addProduct(cmp, newItemProductId, newItemDNetPrice, newItemAwardPrice, newItemSPQuantity, newItemDistributorResponsibility);
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
    },
    handleSPDelete: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:handleSPDelete');
        var productExtId = event.getParam('productExtId');
        var supportPlusItems = cmp.get('v.supportPlusItems');
        for (var i = 0; i < supportPlusItems.length; i++) {
            if (supportPlusItems[i].productId == productExtId) {
                if (supportPlusItems[i].sfid == null) {
                    // just remove it from attribute
                    supportPlusItems.splice(i, 1);
                    cmp.set('v.supportPlusItems', supportPlusItems);
                    var quote = cmp.get('v.quote');
                    var quoteItems = cmp.get('v.quoteItems');
                    quote = helper.recalculateQuoteSupportPlusTotals(quote, quoteItems, supportPlusItems);
                    cmp.set('v.quote', quote);
                }

                else {
                    var action = cmp.get('c.deleteQuoteItem');
                    document.getElementById("spinner").style.display = "block";
                    action.setParams({
                        quoteItemId: supportPlusItems[i].sfid
                    });
                    action.setCallback(this
                        , function (response) {
                            if (cmp.isValid() && response.getState() == 'SUCCESS') {
                                document.getElementById("spinner").style.display = "none";
                                supportPlusItems.splice(i, 1);
                                cmp.set('v.supportPlusItems', supportPlusItems);
                                var quote = cmp.get('v.quote');
                                var quoteItems = cmp.get('v.quoteItems');
                                quote = helper.recalculateQuoteSupportPlusTotals(quote, quoteItems, supportPlusItems);
                                cmp.set('v.quote', quote);
                            }
                        }
                    );
                    $A.enqueueAction(action);
                }
                break;
            }
        }
    },
    handleToggleSublines: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:handleToggleSublines');
        var quoteItemId = event.getParam('quoteItemId');
        var quoteItems = cmp.get('v.quoteItems');
        for (var i = 0; i < quoteItems.length; i++) {
            if (quoteItems[i].sfid == quoteItemId) {
                if (quoteItems[i].chevronStyle == 'bottom') {
                    quoteItems[i].chevronStyle = 'right';
                }

                else {
                    quoteItems[i].chevronStyle = 'bottom';
                }

                if (quoteItems[i].sublines != null) {
                    var displayStyle = 'display';
                    if (quoteItems[i].sublines[0].displayStyle == 'display') {
                        displayStyle = 'display:none;';
                    }
                    for (var j = 0; j < quoteItems[i].sublines.length; j++) {
                        quoteItems[i].sublines[j].displayStyle = displayStyle;
                    }
                }
            }
        }
        cmp.set('v.quoteItems', quoteItems);
    },
    handleDistRespChange: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:handleDistRespChange');
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItems');
        var supportPlusItems = cmp.get('v.supportPlusItems');
        quote.Distributor_Responsibility__c = event.getParam('distributorResponsibility');
        console.log('quote.Distributor_Responsibility__c: ' + quote.Distributor_Responsibility__c);
        quoteItems = helper.updateDistributorResponsibility(quote, quoteItems);
        supportPlusItems = helper.updateDistributorResponsibility(quote, supportPlusItems);
        cmp.set('v.quoteItems', quoteItems);
        cmp.set('v.supportPlusItems', supportPlusItems);
        cmp.set('v.quote', helper.recalculateQuoteSupportPlusTotals(quote, quoteItems, supportPlusItems));

    },
    handleShowAddNewModal: function (cmp, event, helper) {
        cmp.find('cmpAddNew').showModal();
    },
    handleSave: function(cmp, event, helper) {
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItems');
        var supportPlusItems = cmp.get('v.supportPlusItems');
        helper.saveChanges(cmp, quote, quoteItems, supportPlusItems, false);
    },
    handleSaveAndClose: function(cmp, event, helper) {
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItems');
        var supportPlusItems = cmp.get('v.supportPlusItems');
        helper.saveChanges(cmp, quote, quoteItems, supportPlusItems, true);
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