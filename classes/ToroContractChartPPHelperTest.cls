@isTest
private class ToroContractChartPPHelperTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		List<Revvy__MnStrategy4__c> toroQuoteItems = [
			SELECT
				Award_Price__c
				, DNet_Price__c
			FROM
				Revvy__MnStrategy4__c
		];

		for (Revvy__MnStrategy4__c tqi : toroQuoteItems) {
			tqi.Award_Price__c = 90;
			tqi.DNet_Price__c = 100;
		}

		update toroQuoteItems;
	}

	/**
	 *
	 * description
	 *
	 * @result the key result
	 */
	@isTest static void test_helper() {
		ToroContractChartPPHelper helper = new ToroContractChartPPHelper();
		System.assert(helper.getQuoteFields() != null);
		System.assert(helper.retrievePricingMethodOptions() != null);
		System.assert(helper.getQuoteLevelMSQPDNetEditable() != null);
		System.assert(helper.getToroQuoteItemUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(helper.skipMSRPRangeCheck() != null);
	}

	/**
	 *
	 * test_calculate_rebate_margin_impl
	 *
	 * @result the key result
	 */
	@isTest static void test_calculate_rebate_margin_impl_total_award_percent() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroContractChartPPHelper tlpp = new ToroContractChartPPHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Total Award $', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Gross Profit %', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% of DNET', tlpp.quoteItems, true);
		Test.stopTest();
	}

	
}