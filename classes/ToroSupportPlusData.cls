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
	@AuraEnabled public List<SupportPlusPlan> supportPlusPlans           { get; private set; }
	@AuraEnabled public Boolean distRespIsEditable            			 { get; set; }
	@AuraEnabled public Boolean showDNet 								 { get; private set; }
	@AuraEnabled public Boolean showToroAward 							 { get; private set; }
	@AuraEnabled public REVVY__MnStrategy1__c pricingProgram             { get; private set; }

	public List<REVVY__MnStrategy4__c> quoteItemList					 { get; set; }

	@AuraEnabled public Decimal baseDNetTotalWithoutSecondary  			 { get; private set; } // total dnet excluding quote items assigned to a secondary program
	@AuraEnabled public Decimal baseAwardTotalWithoutSecondary 			 { get; private set; } // total award excluding quote items assigned to a secondary program
	@AuraEnabled public Decimal blendedPercentOfDNWithoutSecondary 		 { get; private set; }

	@AuraEnabled public Boolean overrideDistResp 						 { get; private set; }

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
		this.supportPlusPlans            = new List<SupportPlusPlan>();
		this.success                     = true;

		this.showDNet      = true;
		this.showToroAward = true;

		// this.distRespIsEditable = Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible();
		this.distRespIsEditable = Schema.SObjectType.Support_Plus_Contribution__c.fields.Split_Access__c.isAccessible();
		this.overrideDistResp = true;
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
			initializeWrappers(quoteId);
			initializeBaseTotals();
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
								, Decimal baseDNetTotalWithoutSecondary
								, Decimal baseAwardTotalWithoutSecondary
	) {
		this();
		try {
			// this.quote = quote;
			this.quote = ToroCacheManager.getQuote(quote.Id);
			this.qiWrappers = ToroSupportPlusHelper.buildQuoteItemWrapperMap((List<ToroSupportPlusItem>)JSON.deserializeStrict(quoteItemsJSON,List<ToroSupportPlusItem>.class)).values();
			this.addNewWrappers = (List<ToroSupportPlusItem>)JSON.deserializeStrict(supportPlusItemsJSON,List<ToroSupportPlusItem>.class);
			this.pricingProgram = pricingProgram;
			this.baseDNetTotalWithoutSecondary = baseDNetTotalWithoutSecondary;
			this.baseAwardTotalWithoutSecondary = baseAwardTotalWithoutSecondary;
			// initializeBaseTotals();
			recalculateQuoteValues();
		}

		catch (Exception e) {
			this.success = false;
			throw e;
		}
	}


	/**
	 *
	 * builds support plus data for the passed in quote id. overrides the quotes
	 * pricing program and uses the passed in id
	 *
	 * @param  quoteId                the id of the quote
	 * @param  pricingProgramExtId    the ExternalId__c of the pricing program to use
	 */
	public ToroSupportPlusData(Id quoteId
								, String pricingProgramExtId
								, List<Revvy__MnStrategy4__c> quoteItemList
	) {
		this();
		try {
			// this.quote = ToroSupportPlusHelper.getQuote(quoteId);
			this.quote = ToroCacheManager.getQuote(quoteId);
			this.pricingProgram = ToroSupportPlusHelper.getPricingProgram(pricingProgramExtId);
			this.quoteItemList = quoteItemList;
			initializeWrappers(quoteId);
			initializeBaseTotals();
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
	private void initializeWrappers(Id quoteId) {
		// get the quote items and support plus items
		// build a map of the main quote item to its support plus line item
		// (note that support plus items added by "add new" are not handled here)
		final List<REVVY__MnQuoteItem__c> allQuoteItems = ToroSupportPlusHelper.getQuoteItems(quoteId);
		System.debug('\n\n@@allQuoteItems: ' + allQuoteItems + '\n\n');
		Map<Id, Revvy__MnStrategy4__c> extensions = new Map<Id, Revvy__MnStrategy4__c>();
		if (quoteItemList != null) {
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
			if (qiObj.Quote_Item_Extension__c != null) {
				if (extensions.containsKey(qiObj.Quote_Item_Extension__c)) {
					Revvy__MnStrategy4__c qi = extensions.get(qiObj.Quote_Item_Extension__c);
					System.debug('qiObj.Quote_Item_Extension__c: qi=' + qi);
					if (qi != null) {
						System.debug('qiObj.Quote_Item_Extension__c: Pricing_Program__c=' + qi.Pricing_Program__c);
						qiObj.Quote_Item_Extension__r.Pricing_Program__c = qi.Pricing_Program__c;
					}
				}
			}

			system.debug('initializeWrappers pricing Program =' + qiObj.Quote_Item_Extension__r.Pricing_Program__c);
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


	private void initializeBaseTotals() {
		// ============================================================================
		// calculate base DNet and Award
		this.baseDNetTotalWithoutSecondary = this.quote.Toro_Total_DNet__c;
		this.baseAwardTotalWithoutSecondary = this.quote.Toro_Award__c;


		// remove secondary program items from base DNet and base Award
		System.debug('\n\n@@before this.quote: ' + this.quote + '\n\n');
		ToroPricingProgram tempPricingProgramInstance = ToroSupportPlusHelper.getPricingProgramWithoutSecondaryProgramItems(this.quote.Id, this.pricingProgram.ExternalId__c, this.quoteItemList);
		this.baseDNetTotalWithoutSecondary = tempPricingProgramInstance.quote.Toro_Total_DNet__c;
		this.baseAwardTotalWithoutSecondary = tempPricingProgramInstance.quote.Toro_Award__c;
		this.blendedPercentOfDNWithoutSecondary = tempPricingProgramInstance.quote.Toro_Blended_Percent_of_DN__c;
		System.debug('\n\n@@after this.quote: ' + this.quote + '\n\n');

		// re-add SP+ extended totals
		for (ToroSupportPlusItem quoteItem : this.qiWrappers) {
			Decimal spQty = quoteItem.spQuantity != null ? quoteItem.spQuantity : 0;
			Decimal dnetPrice = quoteItem.dnetPrice != null ? quoteItem.dnetPrice : 0;
			Decimal awardPrice = quoteItem.awardPrice != null ? quoteItem.awardPrice : 0;

			this.baseDNetTotalWithoutSecondary += dnetPrice * spQty;
			this.baseAwardTotalWithoutSecondary += awardPrice * spQty;
			if (!quoteItem.sublines.isEmpty()) {
				for (ToroSupportPlusItem subline : quoteItem.sublines) {
					Decimal sublineSpQty = subline.spQuantity;
					Decimal sublineDnetPrice = subline.dnetPrice != null ? subline.dnetPrice : 0;
					Decimal sublineAwardPrice = subline.awardPrice != null ? subline.awardPrice : 0;

					this.baseDNetTotalWithoutSecondary += sublineDnetPrice * sublineSpQty;
					this.baseAwardTotalWithoutSecondary += sublineAwardPrice * sublineSpQty;
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
	private void recalculateQuoteValues() {
		System.debug('\n\n@@recalculateQuoteValues\n\n');

		// ============================================================================
		// calculate quote total values
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

		final Decimal previousExtDNet   = this.quote.SP_Total_Extended_DNET__c;
		final Decimal previousToroAward = this.quote.SP_Adjusted_Toro_Award__c;

		this.quote.Support_Plus__c               = this.quote.Toro_Support_Plus_Allowance_Used__c > 0;
		this.quote.SP_Total_Extended_DNET__c     = this.baseDNetTotalWithoutSecondary - spSplitDNetTotal;
		this.quote.SP_Adjusted_Toro_Award__c     = this.baseAwardTotalWithoutSecondary - spSplitAwardTotal;
		this.quote.SP_Adjusted_Ext_Award__c      = spSplitAwardTotal;

		// ============================================================================
		// calculate distributor responsibility
		Decimal defaultDistRespValue = 50.0;
		Set<Decimal> distRespValueSet = new Set<Decimal>();
		List<Support_Plus_Contribution__c> contribs = ToroSupportPlusHelper.getSupportPlusContributions(this.pricingProgram.ExternalId__c);
		for (Support_Plus_Contribution__c contrib : contribs) {
			distRespValueSet.add(contrib.Distributor_Contribution__c);

			Decimal blendedDNetPct = 0;
			Decimal adjAward       = this.baseAwardTotalWithoutSecondary - spSplitAwardTotal;
			Decimal adjDNet        = this.baseDNetTotalWithoutSecondary - spSplitDNetTotal;

			System.debug('\n\n@@adjAward: ' + adjAward + '\n\n');
			System.debug('\n\n@@adjDNet: ' + adjDNet + '\n\n');

			if (adjDNet != 0) {
				blendedDNetPct = (adjAward / adjDNet) * 100;
			}

			if (blendedDNetPct >= contrib.Award_Price_Low__c
				&& blendedDNetPct < contrib.Award_Price_High__c
			) {
				defaultDistRespValue = contrib.Distributor_Contribution__c;
			}
		}

		if (this.overrideDistResp) {
			if (this.quote.Distributor_Responsibility__c == null
				|| this.quote.Is_Dirty__c
				|| previousExtDNet != this.baseDNetTotalWithoutSecondary - spSplitDNetTotal
				|| previousToroAward != this.baseAwardTotalWithoutSecondary - spSplitAwardTotal
			) {
				this.quote.Distributor_Responsibility__c = defaultDistRespValue;
			}
		}

		this.distributorResponsibilities = new List<DistRespOption>();
		for (Decimal value : distRespValueSet) {
			DistRespOption option = new DistRespOption(value);
			if (value == defaultDistRespValue) option.setAsDefault();
			if (value == this.quote.Distributor_Responsibility__c) option.setAsSelected();
			this.distributorResponsibilities.add(option);
		}

		Decimal distributorResponsibilityPercent = this.quote.Distributor_Responsibility__c * 0.01;
		Decimal toroResponsibilityPercent = (100 - this.quote.Distributor_Responsibility__c) * 0.01;

		if (this.quote.Distributor_Responsibility__c == null) return;

		// ============================================================================
		// calcualte quote values dpeendent on distributor responsibility
		this.quote.SP_Toro_Responsibility__c     = toroResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);
		this.quote.Toro_Contribution__c          = toroResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);

		if (this.baseAwardTotalWithoutSecondary != null && this.baseAwardTotalWithoutSecondary != 0) {
			this.quote.SP_Ext_Dist_Responsibility__c = (this.baseAwardTotalWithoutSecondary - spSplitDNetTotal) / this.baseAwardTotalWithoutSecondary;
		}

		this.quote.Distributor_Contribution__c   = distributorResponsibilityPercent * (spSplitDNetTotal + spAddNewDNetTotal);

		// ============================================================================
		// calculate support plus allowance
		List<Support_Plus_Plan__c> supportPlusPlans = ToroSupportPlusHelper.getSupportPlusPlans(this.pricingProgram.ExternalId__c);
		for (Support_Plus_Plan__c planObj : supportPlusPlans) {
			this.supportPlusPlans.add(new SupportPlusPlan(planObj));
		}

		this.quote.Toro_Support_Plus_Allowance__c = 0;
		if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_AWARD) {
			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if ( (this.baseAwardTotalWithoutSecondary - spSplitAwardTotal) >= plan.Total_DNet_Low__c
					&&  (this.baseAwardTotalWithoutSecondary - spSplitAwardTotal) < plan.Total_DNet_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}
		}

		else if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET) {
			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if ( (this.baseDNetTotalWithoutSecondary - spSplitDNetTotal) >= plan.Total_DNet_Low__c
					&&  (this.baseDNetTotalWithoutSecondary - spSplitDNetTotal) < plan.Total_DNet_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}
		}

		else if (this.pricingProgram.Determines_Support_Plus_Allowance__c == ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET_AND_AWARD) { // STI does not allow secondary programs
			Decimal baseAwardTotalWithoutSecondaryAndSupportPlus = (this.baseAwardTotalWithoutSecondary - spSplitAwardTotal);
			Decimal baseDNetWithoutSecondaryAndSupportPlus = (this.baseDNetTotalWithoutSecondary - spSplitDNetTotal);

			Decimal blendedPercentOfDNWithoutSecondaryAndSupportPlus = 0;

			if (baseDNetWithoutSecondaryAndSupportPlus != 0) {
				blendedPercentOfDNWithoutSecondaryAndSupportPlus = (baseAwardTotalWithoutSecondaryAndSupportPlus / baseDNetWithoutSecondaryAndSupportPlus) * 100;
			}

			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (baseDNetWithoutSecondaryAndSupportPlus >= plan.Total_DNet_Low__c
					&& baseDNetWithoutSecondaryAndSupportPlus < plan.Total_DNet_High__c
					&& blendedPercentOfDNWithoutSecondaryAndSupportPlus >= plan.Award_Price_as_Percent_of_DN_Low__c
					&& blendedPercentOfDNWithoutSecondaryAndSupportPlus < plan.Award_Price_as_Percent_of_DN_High__c
				) {
					this.quote.Toro_Support_Plus_Allowance__c = (baseDNetWithoutSecondaryAndSupportPlus * plan.Maximum_Support_Percent__c) / 100;
					break;
				}
			}
		}

		ToroCacheManager.putQuote(quote);
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
	// SUPPORT PLUS PLAN WRAPPER
	// ============================================================================
	public class SupportPlusPlan {
		@AuraEnabled public Decimal maximumSupport;
		@AuraEnabled public Decimal dnetLow;
		@AuraEnabled public Decimal dnetHigh;
		@AuraEnabled public Decimal awardPriceasPercentOfDNLow;
		@AuraEnabled public Decimal awardPriceasPercentOfDNHigh;

		public SupportPlusPlan(Support_Plus_Plan__c planObj) {
			this.maximumSupport              = planObj.Maximum_Support__c;
			this.dnetLow                     = planObj.Total_DNet_Low__c;
			this.dnetHigh                    = planObj.Total_DNet_High__c;
			this.awardPriceasPercentOfDNLow  = planObj.Award_Price_as_Percent_of_DN_Low__c;
			this.awardPriceasPercentOfDNHigh = planObj.Award_Price_as_Percent_of_DN_High__c;
		}
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