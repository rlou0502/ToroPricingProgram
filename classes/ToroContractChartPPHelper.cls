public with sharing class ToroContractChartPPHelper extends ToroStateContractPricingProgramHelper  {
	
	public override List<Toro_QuoteItem__c> baseCalculateImplementation(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.pricingProgramExternalId = priceProgram;
		helper.quoteItemList = quoteItemList;
		if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
			helper.calculateBlendedDNetPercentFromMSRP().calculateExtensionFields();
		} 
		quoteItemList = helper.quoteItemList;
		return quoteItemList;
	}	    
}