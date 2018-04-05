({
	initialize : function(cmp) {
		debugger;
		console.log('@ToroSupportPlusHelper:initialize');
        var action = cmp.get('c.retrieveSupportPlusData');
        var qId = cmp.get('v.quoteId');
		action.setParams({ quoteId : qId });
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() === "SUCCESS" ) {
	                var retResponse = response.getReturnValue();
                    cmp.set('v.quote', retResponse.quote);
                    cmp.set('v.quoteItemList', retResponse.quoteItemList);
                    cmp.set('v.supportPlusList', retResponse.supportPlusList);
                    cmp.set('v.Distributor_Responsibility', retResponse.Distributor_Responsibility);
	            }
	        }
	    );
		$A.enqueueAction(action);
	},
	retrieveAutocompleteResults: function(cmp, searchText) {
		console.log('@ToroSupportPlusHelper:retrieveAutocompleteResults');
		var lastSearchTerm = cmp.get('v.lastSearchTerm');
		if (searchText.indexOf(lastSearchTerm) == -1 && searchText.length >= 3 && searchText.length != lastSearchTerm.length) {
			console.log('show autocomplete section');
			var action = cmp.get('c.getProductCodesAura');
			action.setStorable();
			action.setParams({ searchTerm : searchText });
			action.setCallback(this
				, function (response) {
					var state = response.getState();
					if (cmp.isValid() && state === "SUCCESS") {
						console.log('getProductCodesAura response:');
						console.log(response.getReturnValue());
						cmp.set('v.lastSearchTerm', searchText);
						cmp.set('v.searchResult', response.getReturnValue());
					}
				}
			);
			$A.enqueueAction(action);
		}

		else {
			console.log('hide autocomplete section');
		}
	},
	showAddModal: function(cmp) {
		var modal = cmp.find("addModal");
		$A.util.removeClass(modal, 'hideDiv');
	},
	hideAddModal: function(cmp) {
		var modal = cmp.find("addModal");
		$A.util.addClass(modal, 'hideDiv');
	},
	toggleAddProductModal: function(cmp) {
		console.log('@ToroSupportPlusHelper:toggleAddProductModal');
		var modal = cmp.find('addModal');
		if (modal.classList.contains('hideDiv')) {
			$A.util.removeClass(modal, 'hideDiv');
		}

		else {
			$A.util.addClass(modal, 'hideDiv');
		}
	},
	hideAutoComplete: function(cmp) {
		var autoCompleteSection = cmp.find('autocomplete_section');
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