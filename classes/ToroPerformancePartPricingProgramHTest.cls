@isTest
private class ToroPerformancePartPricingProgramHTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}

	@isTest static void test_get_field_methods() {
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		//System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
	}

	@isTest static void test_calculate_rebate_margin_impl() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('GreenwayGolf;Standard');
		tlpp.initialize(quote.Id);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}
}