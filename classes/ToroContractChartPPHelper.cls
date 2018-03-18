public with sharing class ToroContractChartPPHelper extends ToroPricingProgram  {
	public override List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		return ret;
	}
	public override boolean getQuoteLevelMSQPDNetEditable() { 
		return false;
	}
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.pricingProgramExternalId = priceProgram;
		helper.quoteItemList = quoteItemList;
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {

			helper.convertAwardPriceToDNetPercent().calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
			quoteItemList = helper.quoteItemList;
			for (Revvy__MnStrategy4__c qi : quoteItemList) {
				qi.Off_MSRP__c = ((qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c)*100;
				if(qi.Award_of_DN__c != null) {
					if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							decimal dnet = (qis.TPP_Line_Item__c == true) ? CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) : CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
							qis.Percent_Off_MSRP__c = ((qis.MSRP_Price__c-qis.Award_Price__c)/qis.MSRP_Price__c)*100;
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