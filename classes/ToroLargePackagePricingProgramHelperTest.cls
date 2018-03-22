@isTest
private class ToroLargePackagePricingProgramHelperTest {

	@testSetup static void setupData() {
		CMnQuoteUtil.setupData();
		
	}

	@isTest static void test_get_field_methods() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Total Award $', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Gross Profit %', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% of DNET', tlpp.quoteItems, true);
		
		
	}

	@isTest static void test_method_two() {
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
		tlpp.displayPerformancePart();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
		tlpp.retrieveDemoPricingProgramOptions();
	}

}