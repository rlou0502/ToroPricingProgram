@isTest
private class ToroSupportPlusDataTest {

	@TestSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		REVVY__MnQuote__c quote = [SELECT Pricing_Program_Name__c FROM REVVY__MnQuote__c LIMIT 1];
		quote.Pricing_Program_Name__c = 'MarketSupportChartLargePackage;Large_Package';
		update quote;

		REVVY__MnStrategy1__c pricingProgram = [SELECT Determines_Support_Plus_Allowance__c FROM REVVY__MnStrategy1__c WHERE ExternalId__c = 'MarketSupportChartLargePackage'];
		pricingProgram.Determines_Support_Plus_Allowance__c = ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET;
		update pricingProgram;

		insert new Revvy__MnSequenceGen__c(
			  Revvy__ObjectName__c   = 'MnQuoteItem__c'
			, REVVY__CurrentValue__c = 1
		);
	}

	@isTest static void test_default_constructor() {
		Test.startTest();
		ToroSupportPlusData data = new ToroSupportPlusData();
		System.assert(data != null);
		Test.stopTest();
	}

	@isTest static void test_constructor_quoteId() {
		Test.startTest();
		Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		ToroSupportPlusData data = new ToroSupportPlusData(quoteId);
		System.assert(data != null);

		Test.stopTest();
	}

	@isTest static void test_constructor_for_removing_secondary_program_items() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		REVVY__MnStrategy1__c pricingProgram = ToroSupportPlusHelper.getPricingProgram(quote);

		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		List<Revvy__MnStrategy4__c> qiExtObjs = new List<Revvy__MnStrategy4__c>();
		for (ToroSupportPlusItem qi : data.qiWrappers) {
			qiExtObjs.add(qi.qiExtObj);
		}

		Test.startTest();
		ToroSupportPlusData newData = new ToroSupportPlusData(
			quoteId
			, pricingProgram.ExternalId__c
			, qiExtObjs
		);

		System.assert(newData != null);
		Test.stopTest();
	}

	/**
	 *
	 * test_allowance_based_on_award
	 *
	 * @result the key result
	 */
	@isTest static void test_allowance_based_on_award() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		REVVY__MnStrategy1__c pricingProgram = ToroSupportPlusHelper.getPricingProgram(quote);
		pricingProgram.Determines_Support_Plus_Allowance__c = ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_AWARD;
		update pricingProgram;
		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);
	}

	/**
	 *
	 * test_allowance_based_on_dnet_and_award
	 *
	 * @result the key result
	 */
	@isTest static void test_allowance_based_on_dnet_and_award() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		REVVY__MnStrategy1__c pricingProgram = ToroSupportPlusHelper.getPricingProgram(quote);
		pricingProgram.Determines_Support_Plus_Allowance__c = ToroSupportPlusHelper.DETERMINES_SP_ALLOWANCE_DNET_AND_AWARD;
		update pricingProgram;
		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);
	}
}