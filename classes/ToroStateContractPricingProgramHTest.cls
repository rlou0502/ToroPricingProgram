@isTest
private class ToroStateContractPricingProgramHTest {

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
		ToroStateContractPricingProgramHelper helper = new ToroStateContractPricingProgramHelper();
		System.assert(helper.getQuoteFields() != null);
		System.assert(helper.retrievePricingMethodOptions() != null);
		System.assert(helper.getQuoteLevelMSQPDNetEditable() != null);
		System.assert(helper.getToroQuoteItemSublineUpdatableFields() == null);
		System.assert(helper.getToroQuoteItemUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSummaryUpdatableFields() == null);
		
		
	}

	/**
	 *
	 * test_calculate_rebate_margin_impl
	 *
	 * @result the key result
	 */
	@isTest static void test_calculate_rebate_margin_impl() {

		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroStateContractPricingProgramHelper tlpp = new ToroStateContractPricingProgramHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('Buyboard;Base');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}
	@isTest static void test_calculate_rebate_margin_impl_2() {
		ToroCacheManager.refreshAllPricingPrograms();
		List<REVVY__MnStrategy2__c> pricngProgramLines = [select id from REVVY__MnStrategy2__c ];
		for(REVVY__MnStrategy2__c l : pricngProgramLines) {
			l.Rebate_as_a_Percent_of_DN__c = null;
			l.Distributor_Margin__c = 10;	
		}
		update pricngProgramLines;
		
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroStateContractPricingProgramHelper tlpp = new ToroStateContractPricingProgramHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('Buyboard;Base');
		tlpp.initialize(quote.Id);
		
		List<REVVY__MnStrategy4__c> quoteItems = [select id from REVVY__MnStrategy4__c ];
		for(REVVY__MnStrategy4__c l : quoteItems) {
			l.Rebate_as_a_of_DN__c = 0;
		}
		update quoteItems;
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}

}