@isTest
private class ToroLargePackagePricingProgramHelperTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
	
	
	@isTest static void test_Info_Popup() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		List<Revvy__MnStrategy4__c> qiExtensions = [select id from Revvy__MnStrategy4__c where mn_quote__c = :quote.Id];
		ToroPricingProgramInfoBoxController.getInfoBoxFieldSets();
		ToroPricingProgramInfoBoxController.loadQuoteHeader(quote.Id);
		ToroPricingProgramInfoBoxController.resetQuoteApproval(quote.Id);
		Test.stopTest();
	}
	
	@isTest static void test_Info_Popup_std_user() {
		Test.startTest();
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User u = new User(Alias = 'standt', Email='standarduser@test-toro.com', 
	    			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	      			LocaleSidKey='en_US', ProfileId = p.Id, 
	      			TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test-toro.com');
	
	    System.runAs(u) {       	
			ToroPricingProgramInfoBoxController.getInfoBoxFieldSets();
	    }
      	Test.stopTest();
	}
	
      
	@isTest static void test_get_field_methods() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		List<Revvy__MnStrategy4__c> qiExtensions = [select id from Revvy__MnStrategy4__c where mn_quote__c = :quote.Id];
		for(Revvy__MnStrategy4__c qi : qiExtensions) {
			qi.Off_MSRP_Overridden__c = true;
			break;		
		}
		update qiExtensions;
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		options.sort();
		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Total Award $', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Gross Profit %', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% of DNET', tlpp.quoteItems, true);
		
		ToroDefaultPricingProgramHelper defaultHelper = new ToroDefaultPricingProgramHelper();
		defaultHelper.getQuoteFields();
		defaultHelper.getQuoteFields();
		defaultHelper.getToroQuoteItemFields();
		defaultHelper.getToroQuoteItemUpdatableFields();
		defaultHelper.getToroQuoteItemSublineFields();
		defaultHelper.getToroQuoteItemSublineUpdatableFields();
		defaultHelper.getToroQuoteItemSummaryFields();
		defaultHelper.getToroQuoteItemSummaryUpdatableFields();
		List<Schema.FieldSetMember> fieldSet = defaultHelper.getQuoteFields();   	
    	List<Schema.FieldSetMember> dNetfieldSet = defaultHelper.getToroQuoteDNetFields();
    	fieldSet = defaultHelper.removeDNetFieldsFromSet(fieldSet, dNetfieldSet);
		Test.stopTest();
	}

	@isTest static void test_method_two() {
		Test.startTest();
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
		tlpp.displayPerformancePart();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
		tlpp.retrieveDemoPricingProgramOptions();
		tlpp.getToroQuoteItemSummaryUpdatableFields();
		Test.stopTest();
	}
}