@isTest
private class ToroPerformancePartPricingProgramHTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		Revvy__MnSequenceGen__c sequence = new Revvy__MnSequenceGen__c(Revvy__ObjectName__c='MnQuoteItem__c', REVVY__CurrentValue__c=1);
		insert sequence;
	}

	@isTest static void test_reset() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper largePackageHelper = new ToroLargePackagePricingProgramHelper();
		largePackageHelper.initialize(quote.Id);

		ToroPerformancePartPricingProgramHelper.reset(quote.Id
														, 'MarketSupportChartLargePackage'
														, '% off MSRP'
														, true
														, largePackageHelper.quoteItems);
	}

	@isTest static void test_retrieve_performance_part() {
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		System.assert(ppMap != null);
	}

	@isTest static void test_apply_performance_part_for_quote_item() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper largePackageHelper = new ToroLargePackagePricingProgramHelper();
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		largePackageHelper.initialize(quote.Id);

		Boolean result = ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(true
																								, largePackageHelper.quoteItems[0]
																								, ppMap
																								, '% off MSRP');
	}

	@isTest static void test_apply_performance_part_for_subline() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper largePackageHelper = new ToroLargePackagePricingProgramHelper();
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		largePackageHelper.initialize(quote.Id);

		List<REVVY__MnStrategy5__c> sublines = largePackageHelper.quoteItems[0].Toro_Quote_Item_Sub_Lines__r;
		ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(true
																						, sublines[0]
																						, ppMap
																						, '% off MSRP');
	}
}