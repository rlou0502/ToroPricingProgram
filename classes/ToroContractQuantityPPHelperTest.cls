@isTest
private class ToroContractQuantityPPHelperTest {
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
	@isTest static void test_helper() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroContractQuantityPPHelper tlpp = new ToroContractQuantityPPHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('NASPOBoiseID;Base_w_Qty_Pricing');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}

	
}