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
		
	 }
	
}