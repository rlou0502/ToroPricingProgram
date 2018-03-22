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
	}

	/**
	 *
	 * test_calculate_rebate_margin_impl
	 *
	 * @result the key result
	 */
	@isTest static void test_calculate_rebate_margin_impl() {
		ToroContractChartPPHelper helper = new ToroContractChartPPHelper();

		Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		String priceProgram = 'STILargePackageProgram';
		String priceMethod = 'Total Award $';

		List<Revvy__MnStrategy4__c> quoteItemList = [
			SELECT
			 	Off_MSRP__c
				, MSRP_Price__c
				, Award_Price__c
				, Award_of_DN__c
				, DNet_Price__c
			FROM
				Revvy__MnStrategy4__c];


		helper.calculateRebateMarginImpl(quoteId, priceProgram, priceMethod, quoteItemList);
	}
}