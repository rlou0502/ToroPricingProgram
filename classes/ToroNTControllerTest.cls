@isTest
private class ToroNTControllerTest {

	@TestSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		REVVY__MnCatalogNode__c product = [
			SELECT
				Non_Toro_Product__c
				, REVVY__Id__c
			FROM
				REVVY__MnCatalogNode__c
			WHERE
				REVVY__Id__c = '114-5419']; // "2.5"" dia. Full Front Roller Asm"

		product.Non_Toro_Product__c = true;
		update product;

		REVVY__MnQuote__c quote = [SELECT Pricing_Program_Name__c FROM REVVY__MnQuote__c LIMIT 1];
		quote.Pricing_Program_Name__c = 'MarketSupportChartLargePackage;Large_Package';
		update quote;

		insert new Revvy__MnSequenceGen__c(
			  Revvy__ObjectName__c   = 'MnQuoteItem__c'
			, REVVY__CurrentValue__c = 1
		);
	}

	@isTest static void test_constructor() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;

		Test.startTest();
		PageReference pageRef = Page.ToroNTLgtnOut;
		pageRef.getParameters().put('Id', quoteId);
    	Test.setCurrentPage(pageRef);
		ToroNTController controller = new ToroNTController();

		ToroNTData ntData = ToroNTController.retrieveNTData(quoteId);
		System.assert(ntData != null);
		Test.stopTest();
	}

	@isTest static void test_add_non_toro_item() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		ToroNTData data = new ToroNTData(quoteId);

		Test.startTest();
		ToroQIBase ntItem = ToroNTController.addNonToroItem(quoteId, '114-5419', 100, 200, 300, 5, 'description');
		data.qiWrappers.add(ntItem);
		Boolean success = ToroNTController.saveChanges(quote, JSON.serialize(data.qiWrappers));
		System.assert(ntItem != null);
		Test.stopTest();
	}

	@isTest static void test_save_changes() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		ToroNTData data = new ToroNTData(quoteId);

		Test.startTest();
		Boolean success = ToroNTController.saveChanges(quote, JSON.serialize(data.qiWrappers));
		Test.stopTest();
	}

	@isTest static void test_delete() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		ToroNTData data = new ToroNTData(quoteId);

		Test.startTest();
		Boolean success = ToroNTController.deleteQuoteItem(data.qiWrappers[0].qiObj.Id);
		System.assert(success);
		Test.stopTest();
	}
}