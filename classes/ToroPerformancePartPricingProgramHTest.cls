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
		System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
	}

	@isTest static void test_calculate_rebate_margin_impl() {
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		REVVY__MnQuote__c quote = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1];
		final String priceProgramExternalId = '';
		final String priceMethod = '';
		List<Revvy__MnStrategy4__c> quoteItemWrapperList = new List<Revvy__MnStrategy4__c>();
		List<Revvy__MnStrategy4__c> result = tlpp.calculateRebateMarginImpl(quote.Id, priceProgramExternalId, priceMethod, quoteItemWrapperList);
	}

}