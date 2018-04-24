({
	initialize : function(cmp) {
        var action = cmp.get('c.retrieveSupportPlusData');
        var qId = cmp.get('v.quoteId');
		action.setParams({ quoteId : qId });
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() === "SUCCESS" ) {
					var supportPlusData = response.getReturnValue();

					console.log('supportPlusData:');
					console.log(supportPlusData);

					cmp.set('v.quoteItems', this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.quoteItems));
					cmp.set('v.supportPlusItems', this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.supportPlusOnlyItems));
					cmp.set('v.distributorResponsibilities', supportPlusData.distributorResponsibilities);
					cmp.set('v.quote', this.recalculateQuoteSupportPlusTotals(
											supportPlusData.quote
											, supportPlusData.quoteItems
											, supportPlusData.supportPlusOnlyItems));
	            }
	        }
	    );
		$A.enqueueAction(action);
	},
	refreshSearchResults: function(cmp, previousSearchTerm, currentSearchTerm) {
		var action = cmp.get('c.fetchSearchResults');
		action.setStorable();
		action.setParams({ searchTerm: currentSearchTerm });
		action.setCallback(this
			, function (response) {
				var state = response.getState();
				if (cmp.isValid() && state === "SUCCESS") {
					cmp.set('v.searchResults', response.getReturnValue());
					cmp.set('v.previousSearchTerm', previousSearchTerm);
					cmp.set('v.currentSearchTerm', currentSearchTerm);
				}
			}
		);

		$A.enqueueAction(action);
	},
	addProduct: function(cmp, productId, dnetPrice, spQuantity, distributorResponsibility) {
		console.log('@ToroSupportPlusHelper:addProduct');
		var action = cmp.get('c.addSupportPlustItem');
		action.setParams({
			  quoteId                  : cmp.get('v.quoteId')
			, productId                : productId
			, dnetPrice                : dnetPrice
			, spQuantity               : spQuantity
			, distributorResponsibility: distributorResponsibility
		});
		action.setCallback(this
			, function(response) {
				var state = response.getState();
				if (cmp.isValid() && state === 'SUCCESS') {
					var retVal = response.getReturnValue();
					if (retVal) {
						var supportPlusItems = cmp.get('v.supportPlusItems');
						supportPlusItems.push(retVal);
						cmp.set('v.supportPlusItems', supportPlusItems);
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
	saveChanges: function(cmp, quote, quoteItems, supportPlusItems) {
		console.log('@ToroSupportPlusHelper:saveChanges');
		var action = cmp.get('c.splitAndSaveItems');
		this.showSpinner();
		// console.log(JSON.stringify(quoteItems));
		// console.log(JSON.stringify(supportPlusItems));
		action.setParams({
			  quote               : quote
			, quoteItemsJSON      : JSON.stringify(quoteItems)
			, supportPlusItemsJSON: JSON.stringify(supportPlusItems)
		});
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					this.hideSpinner();
				}
			}
		);
		$A.enqueueAction(action);
	},
	recalculateQuoteSupportPlusTotals: function(quote, quoteItems, supportPlusItems) {
		console.log('-recalculateQuoteSupportPlusTotals');
		console.log('quote.Distributor_Responsibility__c: ' + quote.Distributor_Responsibility__c);
		var distRespPct = quote.Distributor_Responsibility__c * 0.01;
		var toroResp = (100 - quote.Distributor_Responsibility__c) * 0.01;

		var quoteItemContrib = 0;
		for (var i = 0; i < quoteItems.length; i++) {
			var spQty     = quoteItems[i].spQuantity;
			var dnetPrice = quoteItems[i].dnetPrice;

			quoteItemContrib += dnetPrice * spQty * toroResp;

			if (quoteItems[i].sublines != null) {
				for (var j = 0; j < quoteItems[i].sublines.length; j++) {
					var sublineSpQty     = quoteItems[i].sublines[j].spQuantity;
					var sublineDnetPrice = quoteItems[i].sublines[j].dnetPrice;

					quoteItemContrib += sublineDnetPrice * sublineSpQty * toroResp;
				}
			}
		}

		var supportPlusOnlyItemsContrib = 0; // amount paid by toro
		for (var i = 0; i < supportPlusItems.length; i++) {
			var spQuantity = supportPlusItems[i].spQuantity;
			var dnetPrice = supportPlusItems[i].dnetPrice;
			supportPlusOnlyItemsContrib += dnetPrice * spQuantity * toroResp;
		}

		quote.Toro_Support_Plus_Allowance_Used__c = quote.Toro_Support_Plus_Allowance__c - (quoteItemContrib + supportPlusOnlyItemsContrib);
		quote.SP_Total_Extended_DNET__c = quote.Toro_Total_DNet__c - quoteItemContrib;
		quote.SP_Toro_Responsibility__c = quoteItemContrib + supportPlusOnlyItemsContrib;
		quote.SP_Ext_Dist_Responsibility__c = (quote.Toro_Total_DNet__c - quoteItemContrib) / quote.Toro_Total_DNet__c;
		return quote;
	},
	updateDistributorResponsibility: function(quote, items) {
		for (var i = 0; i < items.length; i++) {
			items[i].distributorResponsibility = items[i].spQuantity > 0 ? quote.Distributor_Responsibility__c : null;
			if (items[i].sublines != null) {
				for (var j = 0; j < items[i].sublines.length; j++) {
					items[i].sublines[j].distributorResponsibility = items[i].sublines[j].spQuantity > 0 ? quote.Distributor_Responsibility__c : null;
				}
			}
		}

		return items;
	},
	showSpinner: function (node) {
		document.getElementById("spinner").style.display = "block";
	},
	hideSpinner: function (node) {
		document.getElementById("spinner").style.display = "none";
	}
})