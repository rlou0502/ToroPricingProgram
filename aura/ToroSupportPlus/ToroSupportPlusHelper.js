({
	initialize : function(cmp) {
        var action = cmp.get('c.retrieveSupportPlusData');
		var qId = cmp.get('v.quoteId');
		console.log('quoteId: ' + qId);
		action.setParams({ quoteId : qId });
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() === "SUCCESS" ) {
					var supportPlusData = response.getReturnValue();

					console.log('supportPlusData:');
					console.log(supportPlusData);
					console.log('supportPlusData.quote.Toro_Total_DNet__c: ' + supportPlusData.quote.Toro_Total_DNet__c);
					console.log('supportPlusData.quote.SP_Adjusted_Toro_Award__c: ' + supportPlusData.quote.SP_Adjusted_Toro_Award__c);

					var quoteItems                  = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.qiWrappers);
					quoteItems = this.restoreUiState(cmp.get('v.quoteItems'), quoteItems);
					var supportPlusItems            = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.addNewWrappers);
					var distributorResponsibilities = supportPlusData.distributorResponsibilities;
					var recalcQuote = this.recalculateQuoteSupportPlusTotals(supportPlusData.quote, supportPlusData.qiWrappers, supportPlusData.addNewWrappers, supportPlusData.pricingProgram);

					cmp.set('v.quoteItems', quoteItems);
					cmp.set('v.supportPlusItems', supportPlusItems);
					cmp.set('v.distributorResponsibilities', distributorResponsibilities);
					cmp.set('v.quote', recalcQuote);
					// cmp.set('v.quote', supportPlusData.quote);
					cmp.set('v.distRespIsEditable', supportPlusData.distRespIsEditable);
					cmp.set('v.showDNet', supportPlusData.showDNet);
					cmp.set('v.showToroAward', supportPlusData.showToroAward);
					cmp.set('v.pricingProgram', supportPlusData.pricingProgram);
	            }
	        }
	    );
		$A.enqueueAction(action);
	},
	restoreUiState: function(previousQuoteItems, currentQuoteItems) {
		console.log('previousQuoteItems:');
		console.log(previousQuoteItems);
		console.log('currentQuoteItems:');
		console.log(currentQuoteItems);
		if (previousQuoteItems.length > 0) {
			var prevItemMap = {};
			for (var i = 0; i < previousQuoteItems.length; i++) {
				var quoteItemId = previousQuoteItems[i].sfid;
				var quoteItem = previousQuoteItems[i];

				prevItemMap[quoteItemId] = quoteItem;
			}

			console.log('prevItemMap:');
			console.log(prevItemMap);

			for (var i = 0; i < currentQuoteItems.length; i++) {
				var prevQuoteItem = prevItemMap[currentQuoteItems[i].sfid];
				if (prevQuoteItem.chevronStyle == 'bottom') {
					currentQuoteItems[i].chevronStyle = prevQuoteItem.chevronStyle;

					for (var j = 0; j < currentQuoteItems[i].sublines.length; j++) {
						currentQuoteItems[i].sublines[j].displayStyle = 'display';
					}
				}
			}
		}

		return currentQuoteItems;
	},
	/*
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
	},*/
	addProduct: function(cmp, productId, dnetPrice, awardPrice, spQuantity, distributorResponsibility) {
		console.log('@ToroSupportPlusHelper:addProduct');
		var action = cmp.get('c.addSupportPlustItem');
		action.setParams({
			  quoteId                  : cmp.get('v.quoteId')
			, productId                : productId
			, dnetPrice                : dnetPrice
			, awardPrice               : awardPrice
			, spQuantity               : spQuantity
		});
		action.setCallback(this
			, function(response) {
				var state = response.getState();
				if (cmp.isValid() && state === 'SUCCESS') {
					var retVal = response.getReturnValue();
					if (retVal) {
						var quote = cmp.get('v.quote');
						var quoteItems = cmp.get('v.quoteItems');
						var supportPlusItems = cmp.get('v.supportPlusItems');
						var pricingProgram = cmp.get('v.pricingProgram');
						retVal.distributorResponsibility = quote.Distributor_Responsibility__c;
						supportPlusItems.push(retVal);
						quote = this.recalculateQuoteSupportPlusTotals(quote, quoteItems, supportPlusItems, pricingProgram);
						cmp.set('v.quote', quote);
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
	saveChanges: function(cmp, quote, quoteItems, supportPlusItems, goBackToPricingPage) {
		console.log('@ToroSupportPlusHelper:saveChanges');
		var action = cmp.get('c.splitAndSaveItems');
		this.showSpinner();
		// console.log(JSON.stringify(quoteItems));
		// console.log(JSON.stringify(supportPlusItems));
		console.log('quoteItems:');
		console.log(quoteItems);
		console.log('supportPlusItems:');
		console.log(supportPlusItems);
		action.setParams({
			  quote               : quote
			, quoteItemsJSON      : JSON.stringify(quoteItems)
			, supportPlusItemsJSON: JSON.stringify(supportPlusItems)
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
	recalculateQuoteSupportPlusTotals: function(quote, quoteItems, supportPlusItems, pricingProgram) {
		console.log('@recalculateQuoteSupportPlusTotals');
		console.log('quote.Distributor_Responsibility__c: ' + quote.Distributor_Responsibility__c);
		console.log(pricingProgram);
		var distRespPct = quote.Distributor_Responsibility__c * 0.01;
		var toroResp = (100 - quote.Distributor_Responsibility__c) * 0.01;

		var spSplitDNetTotal = 0;
		var spSplitAwardTotal = 0;
		for (var i = 0; i < quoteItems.length; i++) {
			var spQty     = quoteItems[i].spQuantity;
			var dnetPrice = quoteItems[i].dnetPrice;
			var awardPrice = quoteItems[i].awardPrice != null ? quoteItems[i].awardPrice : 0;

			spSplitDNetTotal += dnetPrice * spQty;
			spSplitAwardTotal += awardPrice * spQty;

			if (quoteItems[i].sublines != null) {
				for (var j = 0; j < quoteItems[i].sublines.length; j++) {
					var sublineSpQty     = quoteItems[i].sublines[j].spQuantity;
					var sublineDnetPrice = quoteItems[i].sublines[j].dnetPrice;
					var sublineAwardPrice = quoteItems[i].sublines[j].awardPrice != null ? quoteItems[i].sublines[j].awardPrice : 0;

					spSplitDNetTotal += sublineDnetPrice * sublineSpQty;
					spSplitAwardTotal += sublineAwardPrice * sublineSpQty;
				}
			}
		}
		console.log('spSplitDNetTotal: ' + spSplitDNetTotal);
		console.log('spSplitAwardTotal: ' + spSplitAwardTotal);

		var addNewDNetTotal = 0; // amount paid by toro
		var addNewAwardTotal = 0;
		for (var i = 0; i < supportPlusItems.length; i++) {
			var spQuantity = supportPlusItems[i].spQuantity;
			var dnetPrice = supportPlusItems[i].dnetPrice;
			var awardPrice = supportPlusItems[i].awardPrice;
			addNewDNetTotal += dnetPrice * spQuantity;
			addNewAwardTotal += awardPrice * spQuantity;
		}

		console.log('spSplitDNetTotal: ' + spSplitDNetTotal);
		console.log('spSplitAwardTotal: ' + spSplitAwardTotal);

		if (pricingProgram.Determines_Support_Plus_Allowance__c == 'Award Only') {
			quote.Toro_Support_Plus_Allowance_Used__c = spSplitAwardTotal + addNewAwardTotal;
		}

		else {
			quote.Toro_Support_Plus_Allowance_Used__c = spSplitDNetTotal + addNewDNetTotal;
		}

		quote.SP_Total_Extended_DNET__c           = quote.Toro_Total_DNet__c - spSplitDNetTotal;
		quote.SP_Adjusted_Toro_Award__c           = quote.Toro_Award__c - spSplitAwardTotal;
		quote.SP_Adjusted_Ext_Award__c            = spSplitAwardTotal;
		quote.SP_Toro_Responsibility__c           = toroResp * (spSplitDNetTotal + addNewDNetTotal);
		quote.SP_Ext_Dist_Responsibility__c       = (quote.Toro_Total_DNet__c - spSplitDNetTotal) / quote.Toro_Total_DNet__c;

		console.log('quote.SP_Total_Extended_DNET__c: ' + quote.SP_Total_Extended_DNET__c);
		console.log('quote.SP_Adjusted_Toro_Award__c: ' + quote.SP_Adjusted_Toro_Award__c);

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