@isTest
private class ToroSupportPlusItemTest {

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

	@isTest static void test_constructor() {
		Test.startTest();
		Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		ToroSupportPlusData data = new ToroSupportPlusData(quoteId);
		System.assert(data != null);

		System.assert(data.qiWrappers[0] != null);
		// System.assert(data.qiWrappers[0].distributorResponsibility != null);
		// System.assert(data.qiWrappers[0].qiPricingProgramExtId != null);
		Test.stopTest();
	}


	@isTest static void test_subline_constructor() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);

		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		data.qiWrappers[0].spQuantity = 1;
		data.qiWrappers[0].sublines[0].spQuantity = 1;


		Boolean success = ToroSupportPlusController.splitAndSaveItems(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
		);

		System.assert(success);

		Test.startTest();
		data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		ToroSupportPlusItem sublineWrapper = new ToroSupportPlusItem(
			data.qiWrappers[0].qiObj
			, data.qiWrappers[0].sublines[0].sublineObj
			, data.qiWrappers[0].sublines[0].sublineSpObj
		);

		Test.stopTest();
	}
}