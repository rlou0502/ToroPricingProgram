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

					cmp.set('v.quoteItems', supportPlusData.quoteItems);
					cmp.set('v.supportPlusItems', supportPlusData.supportPlusItems);
					cmp.set('v.quote', this.recalculateQuoteSupportPlusTotals(
						supportPlusData.quote
						, supportPlusData.quoteItems
						, supportPlusData.supportPlusItems));
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
	saveChanges: function(quote, quoteItems, supportPlusItems) {
		console.log('@ToroSupportPlusHelper:saveChanges');
		var action = cmp.get('c.save');
		action.setParams({
			quote: quote
			, quoteItems: quoteItems
			, supportPlusItems: supportPlusItems
		});
		acion.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					// todo
				}
			}
		);
		$A.enqueueAction(action);
	},
	recalculateQuoteSupportPlusTotals: function(quote, quoteItems, supportPlusItems) {
		console.log('-recalculateQuoteSupportPlusTotals');
		var rebate    = 0;
		var totalDNet = 0;

		for (var i = 0; i < quoteItems.length; i++) {
			var qty       = quoteItems[i].quantity;
			var spQty     = quoteItems[i].spQuantity;
			var dnetPrice = quoteItems[i].dnetPrice;

			rebate    += dnetPrice * spQty;
			totalDNet += dnetPrice * qty;

			for (var j = 0; j < quoteItems[i].sublines.length; j++) {
				var sublineQty       = quoteItems[i].sublines[j].quantity;
				var sublineSpQty     = quoteItems[i].sublines[j].spQuantity;
				var sublineDnetPrice = quoteItems[i].sublines[j].dnetPrice;
				var sublineDistResp  = quoteItems[i].sublines[j].distributorResponsibility

				rebate    += sublineDnetPrice * sublineSpQty;
				totalDNet += sublineDnetPrice * sublineQty;
			}
		}

		for (var i = 0; i < supportPlusItems.length; i++) {
			var spQty     = supportPlusItems[i].spQuantity;
			var dnetPrice = supportPlusItems[i].dnetPrice;

			rebate += dnetPrice * spQty;
		}

		quote.SP_Total_Extended_DNET__c     = totalDNet;
		quote.SP_Toro_Responsibility__c     = rebate;
		quote.SP_Ext_Dist_Responsibility__c = (totalDNet - rebate) / totalDNet;
		return quote;
	},
	updateDistributorResponsibility: function(quote, items) {
		for (var i = 0; i < items.length; i++) {
			items[i].distributorResponsibility = items[i].spQuantity > 0 ? quote.Distributor_Responsibility__c : null;
			for (var j = 0; j < items[i].sublines.length; j++) {
				items[i].sublines[j].distributorResponsibility = items[i].sublines[j].spQuantity > 0 ? quote.Distributor_Responsibility__c : null;
			}
		}

		return items;
	}
})