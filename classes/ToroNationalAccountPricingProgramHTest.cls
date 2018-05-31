@isTest
private class ToroNationalAccountPricingProgramHTest {
	
	@testSetup static void setupData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		
		Revvy__MnSequenceGen__c sequence = new Revvy__MnSequenceGen__c(Revvy__ObjectName__c='MnQuoteItem__c', REVVY__CurrentValue__c=1);
		insert sequence;
	}

	@isTest static void test_get_field_methods() {
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('Buyboard;Base');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}
	@isTest static void test_method_two() {
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.displayPerformancePart();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		tlpp.getToroQuoteItemSublineUpdatableFields();
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
		tlpp.retrieveDemoPricingProgramOptions();
	}
	
}