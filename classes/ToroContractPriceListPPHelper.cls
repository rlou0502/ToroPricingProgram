public with sharing class ToroContractPriceListPPHelper extends ToroStateContractPricingProgramHelper { 
	public override List<Revvy__MnStrategy4__c> preCalculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		return ToroPricingProgramUtil.loadPricesFromPricelist(priceProgram, quoteItemList);
	}     
}