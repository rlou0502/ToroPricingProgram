public with sharing class ToroContractPriceListPPHelper extends ToroStateContractPricingProgramHelper { 
	public override List<Toro_QuoteItem__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return ToroPricingProgramUtil.loadPricesFromPricelist(priceProgram, quoteItemList);
	}     
}