@isTest
private class ToroContractPriceListPPHelperTest {

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

	@isTest static void test_pre_calculate_rebate_margin() {
		ToroContractPriceListPPHelper helper = new ToroContractPriceListPPHelper();

		Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		String priceProgram = 'STILargePackageProgram';
		String priceMethod = '';

		List<Revvy__MnStrategy4__c> quoteItemList = [
			SELECT
			 	Off_MSRP__c
				, MSRP_Price__c
				, Award_Price__c
				, Award_of_DN__c
				, DNet_Price__c
				, Product_Id__c
			FROM
				Revvy__MnStrategy4__c];


		helper.preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
	}
}