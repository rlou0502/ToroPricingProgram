@isTest
private class ToroSupportPlusHelperTest {

	@TestSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		
		REVVY__MnQuote__c quote = [SELECT Pricing_Program_Name__c FROM REVVY__MnQuote__c LIMIT 1];
		quote.Pricing_Program_Name__c = 'MarketSupportChartLargePackage;Large_Package';
		update quote;

		insert new Revvy__MnSequenceGen__c(
			  Revvy__ObjectName__c   = 'MnQuoteItem__c'
			, REVVY__CurrentValue__c = 1
		);
	}

	@isTest static void test_sequence_gen() {
		System.assert(ToroSupportPlusHelper.generateQiExtId() != null);
		Decimal extId = ToroSupportPlusHelper.generateQiExtId();
		System.assert(extid != null);
		ToroSupportPlusHelper.saveSequenceGen();
		System.assertEQUALS(extId, [SELECT REVVY__CurrentValue__c FROM REVVY__MnSequenceGen__c WHERE REVVY__ObjectName__c = 'MnQuoteItem__c' LIMIT 1].REVVY__CurrentValue__c);
	}

	@isTest static void test_support_plus_query_utils() {
		Test.startTest();
		REVVY__MnQuote__c quote = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1];
		List<Support_Plus_Contribution__c> spContribs = ToroSupportPlusHelper.getSupportPlusContributions(quote.Id);
		System.assert(spContribs != null);

		List<Support_Plus_Plan__c> spPlans = ToroSupportPlusHelper.getSupportPlusPlans('MarketSupportChartLargePackage');
		System.assert(spPlans != null);

		Test.stopTest();
	}

	@isTest static void test_quote_query_utils() {
		Test.startTest();
		REVVY__MnQuote__c tempQuote = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1];
		
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(tempQuote.Id);
		System.assert(quote != null);
		
		List<REVVY__MnQuoteItem__c> quoteItems = ToroSupportPlusHelper.getQuoteItems(quote.Id);
		System.assert(quoteItems != null);

		Map<Id,ToroSupportPlusItem> qiWrapperMap = ToroSupportPlusHelper.buildQuoteItemWrapperMap(buildWrappers(quoteItems));
		System.assert(qiWrapperMap != null);
		
		REVVY__MnStrategy1__c pricingProgram = ToroSupportPlusHelper.getPricingProgram(quote);
		System.assert(pricingProgram != null);

		Test.stopTest();
	}

	private static List<ToroSupportPlusItem> buildWrappers(List<REVVY__MnQuoteItem__c> quoteItems) {
		List<ToroSupportPlusItem> result = new List<ToroSupportPlusItem>();
		for (REVVY__MnQuoteItem__c qi : quoteItems) {
			result.add(new ToroSupportPlusItem(qi));
		}

		return result;
	}
}