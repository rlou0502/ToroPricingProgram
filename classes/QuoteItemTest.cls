@isTest
private class QuoteItemTest {
	@testSetup static void setupData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
	@isTest static void test_method_one() {
		List<REVVY__MnQuoteItem__c> quoteItems = [select REVVY__Product_Name_F__c, Description__c, (select Description__c, REVVY__Catalog_Node__r.Name from REVVY__QuoteItemSubLine__r) from REVVY__MnQuoteItem__c];
		QuoteItem qi = new QuoteItem(quoteItems[0]);
		QuoteItem.PricingProgramSelector selector = new QuoteItem.PricingProgramSelector(null, 'test','test', 0,0,0);
		system.assertEquals(null, selector.sfdcId);
		system.assertEquals('test', selector.pricingProgram);
		system.assertEquals('test', selector.pricingMethod);
		system.assertEquals(0, selector.percentOffMSRP);
		system.assertEquals(0, selector.originalPercentOffMSRP);
		system.assertEquals(0, selector.awardPercentOfDNet);
	}
	
	@isTest static void test_method_two() {
		QuoteItem qi = new QuoteItem();
		qi.ppSelectors = null;
		qi.qiTypeList = null;
		qi.qiType = null;
		qi.qidType = null;
	}
	
}