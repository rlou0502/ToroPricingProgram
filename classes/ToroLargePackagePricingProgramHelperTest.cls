@isTest
private class ToroLargePackagePricingProgramHelperTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}

	@isTest static void test_get_field_methods() {
		ToroLargePackagePricingProgramHelper helper = new ToroLargePackagePricingProgramHelper();
		System.assert(helper.getQuoteFields() != null);
		System.assert(helper.getToroQuoteItemFields() != null);
		System.assert(helper.getToroQuoteItemUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSublineFields() != null);
		System.assert(helper.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSummaryFields() != null);
		System.assert(helper.retrievePricingMethodOptions() != null);
		System.assert(helper.retrieveDemoPricingProgramOptions() != null);
		System.assert(helper.displayPerformancePart());

	}

	@isTest static void test_calculate_rebate_margin() {
		ToroLargePackagePricingProgramHelper helper = new ToroLargePackagePricingProgramHelper();

		Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		String priceProgram = 'STILargePackageProgram';
		String priceMethod = helper.retrievePricingMethodOptions()[0].value;

		List<Revvy__MnStrategy4__c> quoteItemList = [
			SELECT
			 	Off_MSRP__c
				, MSRP_Price__c
				, Award_Price__c
				, Award_of_DN__c
				, DNet_Price__c
				, Product_Id__c
				, Performance_Parts_Product__c
				, Product_Name__c
				, Product__r.Toro_Product_Type__c
			FROM
				Revvy__MnStrategy4__c];

		helper.preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);

		helper.postCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
	}
}