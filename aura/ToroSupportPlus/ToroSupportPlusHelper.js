({
	initialize : function(cmp) {
        var action = cmp.get('c.retrieveSupportPlusData');
		var qId = cmp.get('v.quoteId');
		console.log('quoteId: ' + qId);
		
		cmp.set('v.isDirty', false);

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
					
					cmp.set('v.supportPlusPlans', supportPlusData.supportPlusPlans);
					console.log('@@supportPlusPlans: ');
					console.log(supportPlusData.supportPlusPlans);

					// calculate total DNet and total Award WITHOUT SP items
					cmp.set('v.baseDNetTotal', supportPlusData.baseDNetTotal);
					cmp.set('v.baseAwardTotal', supportPlusData.baseAwardTotal);
					cmp.set('v.baseDNetTotalWithoutSecondary', supportPlusData.baseDNetTotalWithoutSecondary);
					cmp.set('v.baseAwardTotalWithoutSecondary', supportPlusData.baseAwardTotalWithoutSecondary);
					
					/*
					var dnetTotal = supportPlusData.quote.Toro_Total_DNet__c;
					var awardTotal = supportPlusData.quote.Toro_Award__c;
					for (var i = 0; i < quoteItems.length; i++) {
						var spQty = quoteItems[i].spQuantity;
						var dnetPrice = quoteItems[i].dnetPrice;
						var awardPrice = quoteItems[i].awardPrice != null ? quoteItems[i].awardPrice : 0;

						dnetTotal += dnetPrice * spQty;
						awardTotal += awardPrice * spQty;
						if (quoteItems[i].sublines != null) {
							for (var j = 0; j < quoteItems[i].sublines.length; j++) {
								var sublineSpQty = quoteItems[i].sublines[j].spQuantity;
								var sublineDnetPrice = quoteItems[i].sublines[j].dnetPrice;
								var sublineAwardPrice = quoteItems[i].sublines[j].awardPrice != null ? quoteItems[i].sublines[j].awardPrice : 0;

								dnetTotal += sublineDnetPrice * sublineSpQty;
								awardTotal += sublineAwardPrice * sublineSpQty;
							}
						}
					}
					console.log('dnetTotal: ' + dnetTotal);
					console.log('awardTotal: ' + awardTotal);
					cmp.set('v.dnetTotal', dnetTotal);
					cmp.set('v.awardTotal', awardTotal);
					*/

					var recalcQuote = this.recalculateQuoteSupportPlusTotals(cmp, supportPlusData.quote, supportPlusData.qiWrappers, supportPlusData.addNewWrappers, supportPlusData.pricingProgram);

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
	recalcAura: function(cmp, quote, quoteItems, supportPlusItems, pricingProgram) {
		console.log('@ToroSupportPlusHelper:recalcAura');
		var action = cmp.get('c.recalculate');
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
			, pricingProgram      : pricingProgram
		});
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					var supportPlusData = response.getReturnValue();
					// this.initialize(cmp);
					this.hideSpinner();
					console.log('supportPlusData:');
					console.log(supportPlusData);
					console.log('supportPlusData.quote.Toro_Total_DNet__c: ' + supportPlusData.quote.Toro_Total_DNet__c);
					console.log('supportPlusData.quote.SP_Adjusted_Toro_Award__c: ' + supportPlusData.quote.SP_Adjusted_Toro_Award__c);

					var quoteItems = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.qiWrappers);
					quoteItems = this.restoreUiState(cmp.get('v.quoteItems'), quoteItems);
					var supportPlusItems = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.addNewWrappers);
					var distributorResponsibilities = supportPlusData.distributorResponsibilities;

					cmp.set('v.supportPlusPlans', supportPlusData.supportPlusPlans);
					console.log('@@supportPlusPlans: ');
					console.log(supportPlusData.supportPlusPlans);

					// calculate total DNet and total Award WITHOUT SP items
					cmp.set('v.baseDNetTotal', supportPlusData.baseDNetTotal);
					cmp.set('v.baseAwardTotal', supportPlusData.baseAwardTotal);
					cmp.set('v.baseDNetTotalWithoutSecondary', supportPlusData.baseDNetTotalWithoutSecondary);
					cmp.set('v.baseAwardTotalWithoutSecondary', supportPlusData.baseAwardTotalWithoutSecondary);
					cmp.set('v.quoteItems', quoteItems);
					cmp.set('v.supportPlusItems', supportPlusItems);
					cmp.set('v.distributorResponsibilities', distributorResponsibilities);
					cmp.set('v.quote', supportPlusData.quote);
					cmp.set('v.distRespIsEditable', supportPlusData.distRespIsEditable);
					cmp.set('v.showDNet', supportPlusData.showDNet);
					cmp.set('v.showToroAward', supportPlusData.showToroAward);
					cmp.set('v.pricingProgram', supportPlusData.pricingProgram);

					cmp.set('v.isDirty', false);
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
						quote = this.recalculateQuoteSupportPlusTotals(cmp, quote, quoteItems, supportPlusItems, pricingProgram);
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

					cmp.set('v.isDirty', false);
				}
			}
		);
		$A.enqueueAction(action);
	},
	recalculateQuoteSupportPlusTotals: function(cmp, quote, quoteItems, supportPlusItems, pricingProgram) {
		/*
		console.log('@recalculateQuoteSupportPlusTotals');
		console.log('quote.Distributor_Responsibility__c: ' + quote.Distributor_Responsibility__c);
		console.log(pricingProgram);
		
		var supportPlusPlans = cmp.get('v.supportPlusPlans');

		var distRespPct = quote.Distributor_Responsibility__c * 0.01;
		var toroResp = (100 - quote.Distributor_Responsibility__c) * 0.01;

		// calculate sum of split SP items
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

		// calculate sum of add new SP items
		var spAddNewDNetTotal = 0; // amount paid by toro
		var spAddNewAwardTotal = 0;
		for (var i = 0; i < supportPlusItems.length; i++) {
			var spQuantity = supportPlusItems[i].spQuantity;
			var dnetPrice = supportPlusItems[i].dnetPrice;
			var awardPrice = supportPlusItems[i].awardPrice;
			spAddNewDNetTotal += dnetPrice * spQuantity;
			spAddNewAwardTotal += awardPrice * spQuantity;
		}

		console.log('spSplitDNetTotal: ' + spSplitDNetTotal);
		console.log('spSplitAwardTotal: ' + spSplitAwardTotal);

		if (pricingProgram.Determines_Support_Plus_Allowance__c == 'Award Only') {
			quote.Toro_Support_Plus_Allowance_Used__c = spSplitAwardTotal + spAddNewAwardTotal;
		}

		else {
			quote.Toro_Support_Plus_Allowance_Used__c = spSplitDNetTotal + spAddNewDNetTotal;
		}

		var baseDNetTotal = cmp.get('v.baseDNetTotal'); // total DNet with SP+ DNet total reincluded
		var baseAwardwardTotal = cmp.get('v.baseAwardTotal'); // total Award with SP+ Award total reincluded
		
		var baseDNetTotalWithoutSecondary = cmp.get('v.baseDNetTotalWithoutSecondary');
		var baseAwardTotalWithoutSecondary = cmp.get('v.baseAwardTotalWithoutSecondary');

		// quote.SP_Total_Extended_DNET__c           = quote.Toro_Total_DNet__c - spSplitDNetTotal;
		// quote.SP_Total_Extended_DNET__c = baseDNetTotal - spSplitDNetTotal;
		quote.SP_Total_Extended_DNET__c = baseDNetTotalWithoutSecondary - spSplitDNetTotal;

		// quote.SP_Adjusted_Toro_Award__c           = quote.Toro_Award__c - spSplitAwardTotal;
		// quote.SP_Adjusted_Toro_Award__c = baseAwardwardTotal - spSplitAwardTotal;
		quote.SP_Adjusted_Toro_Award__c = baseAwardTotalWithoutSecondary - spSplitAwardTotal;

		quote.SP_Adjusted_Ext_Award__c            = spSplitAwardTotal;
		quote.SP_Toro_Responsibility__c           = toroResp * (spSplitDNetTotal + spAddNewDNetTotal);

		// quote.SP_Ext_Dist_Responsibility__c       = (quote.Toro_Total_DNet__c - spSplitDNetTotal) / quote.Toro_Total_DNet__c;
		// quote.SP_Ext_Dist_Responsibility__c = (baseDNetTotal - spSplitDNetTotal) / baseDNetTotal;
		quote.SP_Ext_Dist_Responsibility__c = (baseDNetTotalWithoutSecondary - spSplitDNetTotal) / baseDNetTotalWithoutSecondary;

		quote.Distributor_Contribution__c = distRespPct * (spSplitDNetTotal + spAddNewDNetTotal);

		console.log('quote.SP_Total_Extended_DNET__c: ' + quote.SP_Total_Extended_DNET__c);
		console.log('quote.SP_Adjusted_Toro_Award__c: ' + quote.SP_Adjusted_Toro_Award__c);
		console.log('quote.Distributor_Contribution__c: ' + quote.Distributor_Contribution__c);
		
		// ============================================================================
		// calculate support plus allowance
		if (pricingProgram.Determines_Support_Plus_Allowance__c == 'Award Only') {
			for (var i = 0; i < supportPlusPlans.length; i++) {
				var plan = supportPlusPlans[i];
				if ((baseAwardTotalWithoutSecondary - spSplitAwardTotal) >= plan.dnetLow
					&& (baseAwardTotalWithoutSecondary - spSplitAwardTotal) < plan.dnetHigh
				) {
					quote.Toro_Support_Plus_Allowance__c = plan.maximumSupport;
					break;
				}
			}
		}

		else if (pricingProgram.Determines_Support_Plus_Allowance__c == 'Total DNet Only') {
			for (var i = 0; i < supportPlusPlans.length; i++) {
				var plan = supportPlusPlans[i];
				if ((baseDNetTotalWithoutSecondary - spSplitDNetTotal) >= plan.dnetLow
					&& (baseDNetTotalWithoutSecondary - spSplitDNetTotal) < plan.dnetHigh
				) {
					quote.Toro_Support_Plus_Allowance__c = plan.maximumSupport;
					break;
				}
			}
		}

		else if (pricingProgram.Determines_Support_Plus_Allowance__c == 'Total DNet and Award') {
			for (var i = 0; i < supportPlusPlans.length; i++) {
				var plan = supportPlusPlans[i];
				if ((baseDNetTotalWithoutSecondary - spSplitDNetTotal) >= plan.dnetLow
					&& (baseDNetTotalWithoutSecondary - spSplitDNetTotal) < plan.dnetHigh
					&& quote.Toro_Blended_Percent_of_DN__c >= plan.awardPriceasPercentOfDNLow
					&& quote.Toro_Blended_Percent_of_DN__c < plan.awardPriceasPercentOfDNHigh
				) {
					quote.Toro_Support_Plus_Allowance__c = plan.maximumSupport;
					break;
				}
			}
		}
		*/
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