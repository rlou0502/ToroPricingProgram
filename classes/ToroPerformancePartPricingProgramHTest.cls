@isTest
private class ToroPerformancePartPricingProgramHTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		Revvy__MnSequenceGen__c sequence = new Revvy__MnSequenceGen__c(Revvy__ObjectName__c='MnQuoteItem__c', REVVY__CurrentValue__c=1);
		insert sequence;
		List<REVVY__MnPriceListLine__c> plls = [select id, REVVY__SUGGESTEDPRICE__C, REVVY__PriceField4__c from REVVY__MnPriceListLine__c];
		for(REVVY__MnPriceListLine__c pll : plls) {
			pll.REVVY__PriceField4__c = pll.REVVY__SUGGESTEDPRICE__C * 0.8;		
		}
		update plls;
		//REVVY__PriceField3__c
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
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper largePackageHelper = new ToroLargePackagePricingProgramHelper();
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		largePackageHelper.initialize(quote.Id);

		Boolean result = ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(true
																								, largePackageHelper.quoteItems[0]
																								, ppMap
																								, '% off MSRP');
		result = ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(null
																								, largePackageHelper.quoteItems[0]
																								, ppMap
																								, '% of DNET');
		Test.StopTest();																						
	}

	@isTest static void test_apply_performance_part_for_subline() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroLargePackagePricingProgramHelper largePackageHelper = new ToroLargePackagePricingProgramHelper();
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		largePackageHelper.initialize(quote.Id);

		List<REVVY__MnStrategy5__c> sublines = largePackageHelper.quoteItems[0].Toro_Quote_Item_Sub_Lines__r;
		ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(true
																						, sublines[0]
																						, ppMap
																						, '% off MSRP');
		ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(true
																						, sublines[0]
																						, ppMap
																						, '% of DNET');
		ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(false
																						, sublines[0]
																						, ppMap
																						, '% off MSRP');
		ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(null
																						, sublines[1]
																						, ppMap
																						, '% of DNET');
		Test.StopTest();																				
	}
}