@isTest
private class ToroPricingProgramTest { 
	ToroDefaultPricingProgramHelper helper = new ToroDefaultPricingProgramHelper();
	List<Schema.FieldSetMember> fs = helper.getToroQuoteItemDNetFields();
	/*
	fs = helper.getToroQuoteItemSublineDNetFields();
	
	List<ToroSelectOption> options = helper.retrievePricingMethodOptions();
	List<String> apiName =helper.getQuoteFieldAPINames();
	apiName =helper.getQuoteFieldAPINameQuery('');
	String query = helper.getToroQuoteFieldAPINameQuery('');
	helper.loadDesignatedPriceList('Demo');
	*/
}