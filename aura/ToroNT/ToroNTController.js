({
	initialize : function(cmp, event, helper) {
		cmp.find('cmpNTHeader').updateTotals();
		helper.initialize(cmp);
	},
    returnToPricing: function (cmp, event, helper) {
    	console.log('@ToroSupportPlusController:returnToPricing');
    	var quoteId = cmp.get("v.quoteId");
    	document.location = '/apex/PricingProgramLgtnOut?Id=' + quoteId;
	},
	addNewItem: function(cmp, event, helper) {
		console.log('@ToroNTController:addNewItem');
		var newItemProductId = event.getParam('newItemProductId');
		var newItemMSRPPrice = event.getParam('newItemMSRPPrice');
		var newItemDNetPrice = event.getParam('newItemDNetPrice');
		var newItemAwardPrice = event.getParam('newItemAwardPrice');
		var newItemQuantity = event.getParam('newItemSPQuantity');
		var newItemDescription = event.getParam('newItemDescription');

		console.log('newItemProductId: ' + newItemProductId);
		console.log('newItemMSRPPrice: ' + newItemMSRPPrice);
		console.log('newItemDNetPrice: ' + newItemDNetPrice);        
		console.log('newItemAwardPrice: ' + newItemAwardPrice);
		console.log('newItemQuantity: ' + newItemQuantity);
		console.log('newItemDescription: ' + newItemDescription); 

		var inputIsValid = true;
		var errorMessage = 'The following values are required: ';

		if (!newItemProductId) {
			inputIsValid = false;
			errorMessage += ' Product ID';
		}

		if (!newItemQuantity) {
			inputIsValid = false;
			errorMessage += ', Quantity';
		}

		if (!inputIsValid) {
			alert(errorMessage);
		}

        else {
        	helper.addProduct(cmp, newItemProductId, newItemMSRPPrice, newItemDNetPrice, newItemAwardPrice, newItemQuantity, newItemDescription);
        }
	},
	handleNTValueChange: function(cmp, event, helper) {
		console.log('ToroNTController:handleNTValueChange');
		cmp.find('cmpNTHeader').updateTotals();
	},
	handleShowAddNewModal: function(cmp, event, helper) {
		cmp.find('cmpAddNew').showModal();
	},
	handleSave: function(cmp, event, helper) {
		console.log('@ToroNTController:handleSave');
		cmp.find('cmpNTHeader').updateTotals();
		var quote = cmp.get('v.quote');
		var quoteItems = cmp.get('v.quoteItems');
		console.log('quoteItems:');
		console.log(quoteItems);
		helper.saveChanges(cmp, quote, quoteItems, false);
	},
	handleSaveAndClose: function (cmp, event, helper) {
		var quote = cmp.get('v.quote');
		var quoteItems = cmp.get('v.quoteItems');
		helper.saveChanges(cmp, quote, quoteItems, true);
	},
	handleNTDelete: function(cmp, event, helper) {
		console.log('@ToroNTController:handleNTDelete');
		var productExtId = event.getParam('productExtId');
		var quoteItems = cmp.get('v.quoteItems');
		for (var i = 0; i < quoteItems.length; i++) {
			if (quoteItems[i].productId == productExtId) {
				if (quoteItems[i].sfid == null) {
					// just remove it from attribute
					quoteItems.splice(i, 1);
					cmp.set('v.quoteItems', quoteItems);
				}

				else {
					var action = cmp.get('c.deleteQuoteItem');
					document.getElementById('spinner').style.display = 'block';
					action.setParams({
						quoteItemId: quoteItems[i].sfid
					});
					action.setCallback(this
						, function(response) {
							if (cmp.isValid() && response.getState() == 'SUCCESS') {
								document.getElementById('spinner').style.display = 'none';
								quoteItems.splice(i, 1);
								cmp.set('v.quoteItems', quoteItems);
							}
						}
					);
					$A.enqueueAction(action);
				}
				break;
			}
		}
	}
})