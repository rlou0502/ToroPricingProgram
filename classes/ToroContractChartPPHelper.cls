public with sharing class ToroContractChartPPHelper extends ToroPricingProgram  {
	public override List<Schema.FieldSetMember> getQuoteFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}

	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		List<Schema.FieldSetMember> fsl = SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
		return fsl;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Summary_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryUpdatableFields() { 
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_QI_Summary_Updatable_Cols.getFields();
	}
//Large_Package_Quote_Line_Cols
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		}
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.pricingProgramExternalId = priceProgram;
		helper.quoteItemList = quoteItemList;	
			
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {

			helper.convertAwardPriceToDNetPercent().calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
			quoteItemList = helper.quoteItemList;
			for (Toro_QuoteItem__c qi : quoteItemList) {
				if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0 ) {
					qi.Off_MSRP__c = ((qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c)*100;
				}
				if(qi.Award_of_DN__c != null) {
					if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							decimal dnet = (qis.TPP_Line_Item__c == true) ? CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) : CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
							if(qis.MSRP_Price__c != null && qis.MSRP_Price__c != 0) {
								qis.Percent_Off_MSRP__c = ((qis.MSRP_Price__c-qis.Award_Price__c)/qis.MSRP_Price__c)*100;
							}
						}
					}
				}
			}

		} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
			helper.convertGPPercentToDNetPercent().calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
		} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {			
			helper.calculateBlendedDNetPercentFromMSRP().calculateExtensionFields();	
		} else if('% of DNET'.equalsIgnoreCase(priceMethod)) {
			helper.calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
		}
		quoteItemList = helper.quoteItemList;
		return quoteItemList;
	}	    
}