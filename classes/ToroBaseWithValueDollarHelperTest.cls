@isTest
private class ToroBaseWithValueDollarHelperTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}

	@isTest static void test_get_field_methods() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];

		ToroBaseWithValueDollarHelper helper = new ToroBaseWithValueDollarHelper();

		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		helper.initialize(quote.Id);

		System.assert(!helper.getQuoteLevelMSQPDNetEditable());
		System.assert(helper.retrievePricingMethodOptions() != null);
		System.assert(helper.getToroQuoteItemSublineUpdatableFields() == null);
		System.assert(helper.getToroQuoteItemFields() != null);
		System.assert(helper.getToroQuoteItemUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSublineFields() != null);
		System.assert(helper.getToroQuoteItemSummaryFields() != null);
		System.assert(helper.getToroQuoteItemSummaryUpdatableFields() == null);

		Test.stopTest();
	}

	@isTest static void test_calculate() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];

		ToroBaseWithValueDollarHelper helper = new ToroBaseWithValueDollarHelper();

		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		helper.initialize(quote.Id);

		helper.quoteItems = helper.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', helper.quoteItems, false);
	}
}