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
	            }
	        }
	    );
		$A.enqueueAction(action);
	},
	recalcAura: function(cmp, quote, quoteItems, supportPlusItems, pricingProgram) {
		console.log('@ToroSupportPlusHelper:recalcAura');
		var action = cmp.get('c.recalculate'); 
		this.showSpinner();
		action.setParams({ 
			  quote               : quote
			, quoteItemsJSON      : JSON.stringify(quoteItems)
			, supportPlusItemsJSON: JSON.stringify(supportPlusItems)
			, pricingProgram      : pricingProgram
			, baseDNetTotalWithoutSecondary : cmp.get('v.baseDNetTotalWithoutSecondary')
			, baseAwardTotalWithoutSecondary : cmp.get('v.baseAwardTotalWithoutSecondary')
		});
		action.setCallback(this
			, function(response) {
				if (cmp.isValid() && response.getState() == 'SUCCESS') {
					var supportPlusData = response.getReturnValue();
					this.hideSpinner();
					console.log('supportPlusData:');
					console.log(supportPlusData);

					var quoteItems = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.qiWrappers);
					quoteItems = this.restoreUiState(cmp.get('v.quoteItems'), quoteItems);
					var supportPlusItems = this.updateDistributorResponsibility(supportPlusData.quote, supportPlusData.addNewWrappers);
					var distributorResponsibilities = supportPlusData.distributorResponsibilities;

					cmp.set('v.supportPlusPlans', supportPlusData.supportPlusPlans);
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
		if (previousQuoteItems.length > 0) {
			var prevItemMap = {};
			for (var i = 0; i < previousQuoteItems.length; i++) {
				var quoteItemId = previousQuoteItems[i].sfid;
				var quoteItem = previousQuoteItems[i];
				prevItemMap[quoteItemId] = quoteItem;
			}

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
	addProduct: function(cmp, productId, dnetPrice, awardPrice, spQuantity, distributorResponsibility) {
		console.log('@ToroSupportPlusHelper:addProduct');
		var action = cmp.get('c.addSupportPlusItem');
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