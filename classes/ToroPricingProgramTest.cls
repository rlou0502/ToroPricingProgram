@isTest
private class ToroPricingProgramTest { 
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
	 @isTest static void unitTest() {
	 	//@TestVisible
		ToroDefaultPricingProgramHelper helper = new ToroDefaultPricingProgramHelper();
		List<Schema.FieldSetMember> fs = helper.getToroQuoteItemDNetFields();
		
		fs = helper.getToroQuoteItemSublineDNetFields(); 
		
		List<ToroSelectOption> options = helper.retrievePricingMethodOptions();
		List<String> apiName =helper.getQuoteFieldAPINames();
		helper.getQuoteFieldAPINameQuery('');
		String query = helper.getToroQuoteFieldAPINameQuery('');
		helper.loadDesignatedPriceList('Demo'); 
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		//helper.retrieveSetupFeeQuoteItem(quote.Id);
		//List<Revvy__MnStrategy4__c>
		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		helper.initialize(quote.Id);
		Revvy__MnStrategy1__c pricingProgram = [select id from Revvy__MnStrategy1__c where externalId__c = 'MarketSupportChartLargePackage' limit 1];
	 	pricingProgram.UseDesignatedPriceList__c=true;
	 	pricingProgram.Previous_Price_Date__c = Date.today();
	 	pricingProgram.Copy_From_Price_Field__c = 'MSRP';
	 	update pricingProgram;
	 	helper.loadMSRPPriceFromPricelist('MarketSupportChartLargePackage;Large_Package',helper.quoteItems);
	 	pricingProgram.Copy_From_Price_Field__c = 'DNET';
	 	update pricingProgram;
	 	helper.loadMSRPPriceFromPricelist('MarketSupportChartLargePackage;Large_Package',helper.quoteItems);
	 }
	
}