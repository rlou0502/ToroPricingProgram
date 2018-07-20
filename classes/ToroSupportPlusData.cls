/**
 * ToroSupportPlusData
 *
 * Data wrapper class for Support Plus page
 *
 */
public with sharing class ToroSupportPlusData {


	@AuraEnabled public Boolean success                             	 { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 						 { get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> qiWrappers 			 { get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> addNewWrappers 		 { get; set; }
	@AuraEnabled public List<DistRespOption> distributorResponsibilities { get; private set; }
	@AuraEnabled public Boolean distRespIsEditable            			 { get; set; }
	@AuraEnabled public Boolean showDNet 								 { get; private set; }
	@AuraEnabled public Boolean showToroAward 							 { get; private set; }
	@AuraEnabled public REVVY__MnStrategy1__c pricingProgram             { get; private set; }
	public List<REVVY__MnStrategy4__c> quoteItemList					 {get; set;}
	@AuraEnabled public Decimal baseDNetTotal                  { get; private set; } // total dnet with support plus items re-added
	@AuraEnabled public Decimal baseAwardTotal                 { get; private set; } // total award with support plus items re-added
	@AuraEnabled public Decimal baseDNetTotalWithoutSecondary  { get; private set; } // total dnet excluding quote items assigned to a secondary program
	@AuraEnabled public Decimal baseAwardTotalWithoutSecondary { get; private set; } // total award excluding quote items assigned to a secondary program


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusData() {
		this.qiWrappers                  = new List<ToroSupportPlusItem>();
		this.addNewWrappers              = new List<ToroSupportPlusItem>();
		this.distributorResponsibilities = new List<DistRespOption>();
		this.success                     = true;

		this.showDNet      = true;
		this.showToroAward = true;

		// this.distRespIsEditable = Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible();
		this.distRespIsEditable = Schema.SObjectType.Support_Plus_Contribution__c.fields.Split_Access__c.isAccessible();
	}


	/**
	 *
	 * builds support plus data for the passed in quote id. uses the pricing program
	 * linked to the quote.
	 *
	 * @param  quoteId    the id of the quote
	 */
	public ToroSupportPlusData(Id quoteId) {
		this();
		try {
			// this.quote = ToroSupportPlusHelper.getQuote(quoteId);
			this.quote = ToroCacheManager.getQuote(quoteId);
			final String pricingProgramExtId = this.quote.Pricing_Program_Name__c.split(';')[0];
			this.pricingProgram = ToroSupportPlusHelper.getPricingProgram(pricingProgramExtId);
			intializeWrappers(quoteId );
			recalculateQuoteValues();
		}

		catch (Exception e) {
			this.success = false;
			throw e;
		}
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusData(REVVY__MnQuote__c quote
								, String quoteItemsJSON
								, String supportPlusItemsJSON
								, REVVY__MnStrategy1__c pricingProgram
	) {

	}


	/**
	 *
	 * builds support plus data for the passed in quote id. overrides the quotes
	 * pricing program and uses the passed in id
	 *
	 * @param  quoteId                the id of the quote
	 * @param  pricingProgramExtId    the ExternalId__c of the pricing program to use
	 */
	public ToroSupportPlusData(Id quoteId, String pricingProgramExtId, List<Revvy__MnStrategy4__c> quoteItemList) {
		this();
		try {
			// this.quote = ToroSupportPlusHelper.getQuote(quoteId);
			this.quote = ToroCacheManager.getQuote(quoteId);
			this.pricingProgram = ToroSupportPlusHelper.getPricingProgram(pricingProgramExtId);
			this.quoteItemList = quoteItemList;
			intializeWrappers(quoteId);
			recalculateQuoteValues();
		}

		catch (Exception e) {
			this.success = false;
			throw e;
		}
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private void intializeWrappers(Id quoteId) {
		// get the quote items and support plus items
		// build a map of the main quote item to its support plus line item
		// (note that support plus items added by "add new" are not handled here)
		final List<REVVY__MnQuoteItem__c> allQuoteItems = ToroSupportPlusHelper.getQuoteItems(quoteId);
		System.debug('\n\n@@allQuoteItems: ' + allQuoteItems + '\n\n');
		Map<Id, Revvy__MnStrategy4__c> extensions = new Map<Id, Revvy__MnStrategy4__c>();
		if(quoteItemList != null) {
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				extensions.put(qi.Id, qi);		
			}
		}
		final List<REVVY__MnQuoteItem__c> addNewQuoteItems = new List<REVVY__MnQuoteItem__c>();

		final Map<Id,REVVY__MnQuoteItem__c> qItemIdToSpItemObjMAP = new Map<Id,REVVY__MnQuoteItem__c>();
		for (REVVY__MnQuoteItem__c qiObj : allQuoteItems) {
			if (qiObj.Support_Plus_Original_Item__c != null) {
				// this is a support plus item since it points to a main item
				qItemIdToSpItemObjMAP.put(qiObj.Support_Plus_Original_Item__c, qiObj);
			}
			System.debug('qiObj.Quote_Item_Extension__c: ' + qiObj.Quote_Item_Extension__c);
			if(qiObj.Quote_Item_Extension__c != null) {
				Revvy__MnStrategy4__c qi = extensions.get(qiObj.Quote_Item_Extension__c);
				System.debug('qiObj.Quote_Item_Extension__c: qi=' + qi);
				if(qi != null) {
					System.debug('qiObj.Quote_Item_Extension__c: Pricing_Program__c=' + qi.Pricing_Program__c);
					qiObj.Quote_Item_Extension__r.Pricing_Program__c = qi.Pricing_Program__c;	
				}
			}
			
			system.debug('intializeWrappers pricing Program =' + qiObj.Quote_Item_Extension__r.Pricing_Program__c);
		}

		// create wrappers for the main quote items. here, we need to differentiate between main quote items
		// and support plus items added by "add new".
		this.qiWrappers = new List<ToroSupportPlusItem>();
		this.addNewWrappers = new List<ToroSupportPlusItem>();
		for (REVVY__MnQuoteItem__c quoteItem : allQuoteItems) {

			// support plus items added in "add new"
			if (quoteItem.Support_Plus_From_Add_New__c) {
				this.addNewWrappers.add(new ToroSupportPlusItem(quoteItem));
			}

			else if (quoteItem.Support_Plus_Original_Item__c != null) {
				// skip
			}
			// quote items with support plus
			else if (qItemIdToSpItemObjMAP.containsKey(quoteItem.Id)) {
				REVVY__MnQuoteItem__c supportPlusItem = qItemIdToSpItemObjMAP.get(quoteItem.Id);
				this.qiWrappers.add(new ToroSupportPlusItem(quoteItem, supportPlusItem));
				System.debug('\n\n@@quoteItem: ' + quoteItem + '\n\n');
				System.debug('\n\n@@supportPlusItem: ' + supportPlusItem + '\n\n');
			}

			// quote items without support plus
			else {
				this.qiWrappers.add(new ToroSupportPlusItem(quoteItem));
			}
		}
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private void recalculateQuoteValues() {
		// ============================================================================
		// calculate base DNet and Award
		this.baseDNetTotal = this.quote.Toro_Total_DNet__c;
		this.baseAwardTotal = this.quote.Toro_Award__c;
		this.baseDNetTotalWithoutSecondary = this.quote.Toro_Total_DNet__c;
		this.baseAwardTotalWithoutSecondary = this.quote.Toro_Award__c;

		
		// remove secondary program items from base DNet and base Award
		ToroPricingProgram tempPricingProgramInstance = ToroSupportPlusHelper.getPricingProgramWithoutSecondaryProgramItems(this.quote.Id, this.pricingProgram.ExternalId__c, this.quoteItemList);
		this.baseDNetTotalWithoutSecondary = tempPricingProgramInstance.quote.Toro_Total_DNet__c;
		this.baseAwardTotalWithoutSecondary = tempPricingProgramInstance.quote.Toro_Award__c;
		/*
		for (ToroSupportPlusItem quoteItem : this.qiWrappers) {
			if (
				quoteItem.qiPricingProgramOverridden
				&& quoteItem.qiPricingProgramExtId != this.pricingProgram.ExternalId__c
			) {
				this.baseDNetTotalWithoutSecondary -= quoteItem.dnetPrice * quoteItem.quantity;
				this.baseAwardTotalWithoutSecondary -= quoteItem.awardPrice * quoteItem.quantity;

				if (!quoteItem.sublines.isEmpty()) {
					for (ToroSupportPlusItem subline : quoteItem.sublines) {
						this.baseDNetTotalWithoutSecondary -= subline.dnetPrice * subline.quantity;
						this.baseAwardTotalWithoutSecondary -= subline.awardPrice * subline.quantity;
					}
				}
			}
		}
		*/

		// re-add SP+ extended totals
		for (ToroSupportPlusItem quoteItem : this.qiWrappers) {
			Decimal spQty = quoteItem.spQuantity != null ? quoteItem.spQuantity : 0;
			Decimal dnetPrice = quoteItem.dnetPrice != null ? quoteItem.dnetPrice : 0;
			Decimal awardPrice = quoteItem.awardPrice != null ? quoteItem.awardPrice : 0;

			this.baseDNetTotal += dnetPrice * spQty;
			this.baseAwardTotal += awardPrice * spQty;
			// this.baseDNetTotalWithoutSecondary += dnetPrice * spQty;
			// this.baseAwardTotalWithoutSecondary += awardPrice * spQty;
			if (!quoteItem.sublines.isEmpty()) {
				for (ToroSupportPlusItem subline : quoteItem.sublines) {
					Decimal sublineSpQty = subline.spQuantity;
					Decimal sublineDnetPrice = subline.dnetPrice != null ? subline.dnetPrice : 0;
					Decimal sublineAwardPrice = subline.awardPrice != null ? subline.awardPrice : 0;

					this.baseDNetTotal += sublineDnetPrice * sublineSpQty;
					this.baseAwardTotal += sublineAwardPrice * sublineSpQty;
					// this.baseDNetTotalWithoutSecondary += sublineDnetPrice * sublineSpQty;
					// this.baseAwardTotalWithoutSecondary += sublineAwardPrice * sublineSpQty;
				}
			}
		}

		// ============================================================================
		// calculate distributor responsibility
		Decimal defaultDistRespValue = 50.0;
		Set<Decimal> distRespValueSet = new Set<Decimal>();
		List<Support_Plus_Contribution__c> contribs = ToroSupportPlusHelper.getSupportPlusContributions(this.pricingProgram.ExternalId__c);
		for (Support_Plus_Contribution__c contrib : contribs) {
			distRespValueSet.add(contrib.Distributor_Contribution__c);
			if (
				this.quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
				&& this.quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
			) {
				defaultDistRespValue = contrib.Distributor_Contribution__c;
			}
		}
		
		if (this.quote.Distributor_Responsibility__c == null || this.quote.Is_Dirty__c) {
			this.quote.Distributor_Responsibility__c = defaultDistRespValue;
		}
		
		this.distributorResponsibilities = new List<DistRespOption>();
		for (Decimal value : distRespValueSet) {
			DistRespOption option = new DistRespOption(value);
			if (value == defaultDistRespValue) option.setAsDefault();
			if (value == this.quote.Distributor_Responsibility__c) option.setAsSelected();
			this.distributorResponsibilities.add(option);
		}

		if (this.quote.Distributor_Responsibility__c == null) return;

		// ============================================================================
		// calculate quote total values
		Decimal distributorResponsibilityPercent = this.quote.Distributor_Responsibility__c * 0.01;
		Decimal toroResponsibilityPercent = (100 - this.quote.Distributor_Responsibility__c) * 0.01;

		Decimal spSplitDNetTotal = 0;
		Decimal spSplitAwardTotal = 0;
		for (ToroSupportPlusItem quoteItem : this.qiWrappers) {
			Decimal spQty = quoteItem.spQuantity != null ? quoteItem.spQuantity : 0;
			Decimal dnetPrice = quoteItem.dnetPrice != null ? quoteItem.dnetPrice : 0;
			Decimal awardPrice = quoteItem.awardPrice != null ? quoteItem.awardPrice : 0;
			spSplitDNetTotal += dnetPrice * spQty;
			spSplitAwardTotal += awardPrice * spQty;
			if (!quoteItem.sublines.isEmpty()) {
				for (ToroSupportPlusItem subline : quoteItem.sublines) {
					Decimal sublineSpQty = subline.spQuantity;
					Decimal sublineDnetPrice = subline.dnetPrice != null ? subline.dnetPrice : 0;
					Decimal sublineAwardPrice = subline.awardPrice != null ? subline.awardPrice : 0;
					spSplitDNetTotal += sublineDnetPrice * sublineSpQty;
					spSplitAwardTotal += sublineAwardPrice * sublineSpQty;
				}
			}
		}

		Decimal spAddNewDNetTotal = 0;
		Decimal spAddNewAwardTotal = 0;
		for (ToroSupportPlusItem addNewItem : this.addNewWrappers) {
			Decimal spQty = addNewItem.spQuantity != null ? addNewItem.spQuantity : 0;
			Decimal dnetPrice = addNewItem.dnetPrice != null ? addNewItem.dnetPrice : 0;
			Decimal awardPrice = addNewItem.awardPrice != null ? addNewItem.awardPrice : 0;
			spAddNewDNetTotal += dnetPrice * spQty;
			spAddNewAwardTotal += awardPrice * spQty;
		}

		if (this.pricingProgram.Determines_Support_Plus_Allowance__c == 'Award Only') {
			this.quote.Toro_Support_Plus_Allowance_Used__c = spSplitAwardTotal + spAddNewAwardTotal;
		}

		else {
			this.quote.Toro_Support_Plus_Allowance_Used__c = spSplitDNetTotal + spAddNewDNetTotal;
		}

		this.quote.Support_Plus__c               = this.quote.Toro_Support_Plus_Allowance_Used__c > 0;
		this.quote.SP_Total_Extended_DNET__c     = this.baseDNetTotal - spSplitDNetTotal;
		this.quote.SP_Adjusted_Toro_Award__c     = this.baseAwardTotal - spSplitAwardTotal;
		this.quote.SP_Adjusted_Ext_Award__c      = spSplitAwardTotal;
		this.quote.SP_Toro_Responsibility__c     = toroResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);
		this.quote.Toro_Contribution__c          = toroResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);

		if (this.baseDNetTotal != null && this.baseDNetTotal != 0) {
			this.quote.SP_Ext_Dist_Responsibility__c = (this.baseDNetTotal - spSplitDNetTotal) / this.baseDNetTotal;
		}
		
		this.quote.Distributor_Contribution__c   = distributorResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);

		// ============================================================================
		// calculate support plus allowance
		List<Support_Plus_Plan__c> supportPlusPlans = ToroSupportPlusHelper.getSupportPlusPlans(this.pricingProgram.ExternalId__c);
		this.quote.Toro_Support_Plus_Allowance__c = 0;
		if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_AWARD) {
			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (this.baseAwardTotalWithoutSecondary >= plan.Total_DNet_Low__c
					&& this.baseAwardTotalWithoutSecondary < plan.Total_DNet_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}
		}

		else if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET) {
			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (this.baseDNetTotalWithoutSecondary >= plan.Total_DNet_Low__c
					&& this.baseDNetTotalWithoutSecondary < plan.Total_DNet_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}
		}

		else if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET_AND_AWARD) { // STI does not allow secondary programs
			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (this.quote.Toro_Total_DNet__c >= plan.Total_DNet_Low__c
					&& this.quote.Toro_Total_DNet__c < plan.Total_DNet_High__c
					&& this.quote.Toro_Blended_Percent_of_DN__c >= plan.Award_Price_as_Percent_of_DN_Low__c
					&& this.quote.Toro_Blended_Percent_of_DN__c < plan.Award_Price_as_Percent_of_DN_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = (this.quote.Toro_Total_DNet__c * plan.Maximum_Support_Percent__c) / 100;
					break;
				}
			}
		}
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public void updateQuoteValues(REVVY__MnQuote__c targetQuote) {
		targetQuote.Support_Plus__c                     = this.quote.Support_Plus__c;
		targetQuote.Distributor_Responsibility__c       = this.quote.Distributor_Responsibility__c;
		targetQuote.Toro_Support_Plus_Allowance__c      = this.quote.Toro_Support_Plus_Allowance__c;
		targetQuote.Toro_Support_Plus_Allowance_Used__c = this.quote.Toro_Support_Plus_Allowance_Used__c;
		targetQuote.SP_Total_Extended_DNET__c           = this.quote.SP_Total_Extended_DNET__c;
		targetQuote.SP_Adjusted_Toro_Award__c           = this.quote.SP_Adjusted_Toro_Award__c;
		targetQuote.SP_Adjusted_Ext_Award__c            = this.quote.SP_Adjusted_Ext_Award__c;
		targetQuote.SP_Toro_Responsibility__c           = this.quote.SP_Toro_Responsibility__c;
		targetQuote.Toro_Contribution__c                = this.quote.Toro_Contribution__c;
		targetQuote.SP_Ext_Dist_Responsibility__c       = this.quote.SP_Ext_Dist_Responsibility__c;
	}


	// ============================================================================
	// DISTRIBUTOR RESPONSIBILITY OPTIONS FOR DROPDOWN
	// ============================================================================
	public class DistRespOption implements Comparable {
		@AuraEnabled public Decimal value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		public DistRespOption(Decimal value) {
			this.value = value;
			this.label = value.format() + '%';
			this.selected = false;
		}

		public void setAsDefault() { this.label += ' (chart)'; }
		public void setAsSelected() { this.selected = true; }

		public Integer compareTo(Object compareTo) {
			DistRespOption compareToObj = (DistRespOption) compareTo;
			if (this.value == compareToObj.value) return 0;
			if (this.value > compareToObj.value) return 1;
			return -1;
		}
	}
}