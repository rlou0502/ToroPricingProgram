({
	initialize: function (cmp) {
		console.log('ToroNTHelper:initialize');
		var action = cmp.get('c.retrieveNTData');
		action.setParams({
			quoteId: cmp.get('v.quoteId')
		});
		action.setCallback(
			this, function(response) {
				if (cmp.isValid() && response.getState() === 'SUCCESS') {
					var ntData = response.getReturnValue();
					cmp.set('v.quote', ntData.quote);
					cmp.set('v.quoteItems', ntData.qiWrappers);

					console.log('ntData:');
					console.log(ntData);

				}
			}
		);

		$A.enqueueAction(action);
	},
	addProduct: function(cmp, productId, msrpPrice, dnetPrice, awardPrice, quantity, description) {
		console.log('ToroNTHelper:addProduct');
		var action = cmp.get('c.addNonToroItem');
		action.setParams({
			  quoteId  : cmp.get('v.quoteId')
			, productId: productId
			, msrpPrice: msrpPrice
            , dnetPrice: dnetPrice
			, awardPrice: awardPrice
			, quantity : quantity
			, description: description
		});
		action.setCallback(this
			, function(response) {
				var state = response.getState();
				if (cmp.isValid() && state === 'SUCCESS') {
					var retVal = response.getReturnValue();
					console.log('addProduct retVal:');
					console.log(retVal);
					if (retVal) {
						var quoteItems = cmp.get('v.quoteItems');
						quoteItems.push(retVal);
						cmp.set('v.quoteItems', quoteItems);
						cmp.find('cmpAddNew').hideModal();
					}
				}

				else if (state === 'INCOMPLETE') {

				}

				else if (state === 'ERROR') {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log('addProduct error: ' + errors[0].message);
						} else {
							console.log('addProduct Unknown error');
						}
					}
				}
			}
		);
		$A.enqueueAction(action);
	},
	saveChanges: function(cmp, quote, quoteItems, goBackToPricingPage) {
		console.log('@ToroNTHelper:saveChanges');
		var action = cmp.get('c.saveChanges');
		this.showSpinner();
		console.log("---quoteItemsJSON ="+ JSON.stringify(quoteItems));
		action.setParams({
			'quote': quote
			, 'quoteItemsJSON' : JSON.stringify(quoteItems)
		});
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					this.initialize(cmp);
					this.hideSpinner();
					if (goBackToPricingPage) {
						document.location = '/apex/PricingProgramLgtnOut?Id=' + quote.Id;
					}
				}
			}
		);
		$A.enqueueAction(action);
	},
	showSpinner: function (node) {
		document.getElementById("spinner").style.display = "block";
	},
	hideSpinner: function (node) {
		document.getElementById("spinner").style.display = "none";
	}
})