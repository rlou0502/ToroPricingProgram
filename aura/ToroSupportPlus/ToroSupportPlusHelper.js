({
	initialize : function(cmp) {
		console.log('@ToroSupportPlusHelper:initialize');
        var action = cmp.get('c.retrieveSupportPlusData');
        var qId = cmp.get('v.quoteId');
		action.setParams({ quoteId : qId });
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() === "SUCCESS" ) {
					var supportPlusData = response.getReturnValue();
					console.log('- supportPlusData: ');
					console.log(supportPlusData);
                    cmp.set('v.quote', supportPlusData.quote);
					cmp.set('v.quoteItems', supportPlusData.quoteItems);
					cmp.set('v.supportPlusItems', supportPlusData.supportPlusItems);
					cmp.set('v.Distributor_Responsibility', supportPlusData.Distributor_Responsibility);
	            }
	        }
	    );
		$A.enqueueAction(action);
	},
	retrieveAutocompleteResults: function(cmp, searchText) {
		console.log('@ToroSupportPlusHelper:retrieveAutocompleteResults');
		var lastSearchTerm = cmp.get('v.lastSearchTerm');
		if (searchText.indexOf(lastSearchTerm) == -1 && searchText.length == 3) {
			var action = cmp.get('c.getProductCodesAura');
			action.setStorable();
			action.setParams({ searchTerm : searchText });
			action.setCallback(this
				, function (response) {
					var state = response.getState();
					if (cmp.isValid() && state === "SUCCESS") {
						console.log('getProductCodesAura response:');
						console.log(response.getReturnValue());
						cmp.set('v.searchResult', response.getReturnValue());
					}
				}
			);

			$A.enqueueAction(action);
		}
		cmp.set('v.lastSearchTerm', searchText);
	},
	addProduct: function(cmp, productId, newItemSPQuantity, newItemDistributorResponsibility) {
		console.log('@ToroSupportPlusHelper:addProduct');
		var action = cmp.get('c.addSupportPlustItem');
		action.setParams({
			quoteId: cmp.get('v.quoteId')
			, productId: productId
			, newItemSPQuantity: newItemSPQuantity
			, newItemDistributorResponsibility: newItemDistributorResponsibility
		});
		action.setCallback(this
			, function(response) {
				var state = response.getState();
				if (cmp.isValid() && state === 'SUCCESS') {
					var retVal = response.getReturnValue();
					if (retVal) {
						console.log(retVal);

						var supportPlusItems = cmp.get('v.supportPlusItems');
						console.log(supportPlusItems);
						supportPlusItems.push(retVal);
						console.log(supportPlusItems);
						cmp.set('v.supportPlusItems', supportPlusItems);
						cmp.set('v.searchResult', null);
						cmp.set('v.lastSearchTerm', null);

						var modal = cmp.find("addModal");
						$A.util.addClass(modal, 'hideDiv');
					}
				}

				else if (state === 'INCOMPLETE') {

				}

				else if (state === 'ERROR') {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log('addProduct error: ' + errors[0].message);
						}

						else {
							console.log('addProduct Unknown error');
						}
					}
				}
			}
		);
		$A.enqueueAction(action);
	},
	submit: function(quote, quoteItems) {
		console.log('@ToroSupportPlusHelper:submit');
		var action = cmp.get('c.submitSupportPlus');
		action.setParams({
			quote: quote
			, quoteItems: quoteItems
		});
		acion.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					// todo
				}
			}
		);
		$A.enqueueAction(action);
	}
})