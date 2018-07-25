@isTest
private class ToroSupportPlusControllerTest {

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

	@isTest static void test_constructor() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;

		Test.startTest();
		PageReference pageRef = Page.ToroSupportPlusLgtnOut;
		pageRef.getParameters().put('Id', quoteId);
    	Test.setCurrentPage(pageRef);
		ToroSupportPlusController controller = new ToroSupportPlusController();
		Test.stopTest();
	}

	@isTest static void test_retrieve_support_plus_data() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		Test.startTest();
		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);
		System.assert(data != null);
		Test.stopTest();
	}

	/**
	 *
	 * description
	 *
	 * @result the key result
	 */
	@isTest static void test_fetch_search_results() {
		String searchTerm = '114';
		String searchType = 'supportplus';
		String spSearchType = 'model';
		List<REVVY__MnPriceListLine__c> results = ToroSupportPlusController.fetchSearchResults(searchTerm, searchType, spSearchType);
		System.assert(results != null);

		searchTerm = 'Greensmaster';
		searchType = 'supportplus';
		spSearchType = 'description';
		results = ToroSupportPlusController.fetchSearchResults(searchTerm, searchType, spSearchType);
		System.assert(results != null);

		searchTerm = 'Greensmaster';
		searchType = 'nontoro';
		results = ToroSupportPlusController.fetchSearchResults(searchTerm, searchType, spSearchType);
		System.assert(results != null);
	}

	/**
	 *
	 * test_delete_quote_item
	 *
	 * @result the key result
	 */
	@isTest static void test_delete_quote_item() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		Test.startTest();
		Boolean success = ToroSupportPlusController.deleteQuoteItem(
			quoteId
			, data.qiWrappers[0].qiObj.Id
		);
		Test.stopTest();
	}

	/**
	 *
	 * test_add_support_plustItem
	 *
	 * @result the key result
	 */
	@isTest static void test_add_support_plus_item() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;

		Test.startTest();
		ToroSupportPlusItem newItem = ToroSupportPlusController.addSupportPlusItem(quoteId, '04656', 100, 200, 5);
		System.assert(newItem != null);
		Test.stopTest();
	}

	/**
	 *
	 * test_recalculate
	 *
	 * @result the key result
	 */
	@isTest static void test_recalculate() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
		REVVY__MnStrategy1__c pricingProgram = ToroSupportPlusHelper.getPricingProgram(quote);

		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		data.qiWrappers[0].spQuantity = 1;

		Test.startTest();
		ToroSupportPlusData newData = ToroSupportPlusController.recalculate(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
			, pricingProgram
			, data.baseDNetTotalWithoutSecondary
			, data.baseAwardTotalWithoutSecondary
		);

		System.assert(newData != null);
		Test.stopTest();
	}

	/**
	 *
	 * test_split_and_save_items
	 *
	 * @result the key result
	 */
	@isTest static void test_split_and_save_items() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);

		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		data.qiWrappers[0].spQuantity = 1;
		data.qiWrappers[0].sublines[0].spQuantity = 1;

		Test.startTest();
		Boolean success = ToroSupportPlusController.splitAndSaveItems(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
		);

		System.assert(success);
		Test.stopTest();
	}

	/**
	 *
	 * test_add_new_support_plus_item_and_save
	 *
	 * @result the key result
	 */
	@isTest static void test_add_new_support_plus_item_and_save() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);

		ToroSupportPlusData data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);


		Test.startTest();
		ToroSupportPlusItem newItem = ToroSupportPlusController.addSupportPlusItem(quoteId, '04656', 100, 200, 5);
		data.addNewWrappers.add(newItem);

		Boolean success = ToroSupportPlusController.splitAndSaveItems(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
		);

		System.assert(newItem != null);
		Test.stopTest();
	}

	/**
	 *
	 * test_update_support_plus_quantity
	 *
	 * @result the key result
	 */
	 /*
	@isTest static void test_update_support_plus_quantity() {
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

		data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		Test.startTest();
		data.qiWrappers[0].spQuantity = 2;
		data.qiWrappers[0].sublines[0].spQuantity = 2;

		success = ToroSupportPlusController.splitAndSaveItems(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
		);

		System.assert(success);
		Test.stopTest();
	}
	*/

	/**
	 *
	 * test_remove_support_plus_quantity
	 *
	 * @result the key result
	 */
	 /*
	@isTest static void test_remove_support_plus_quantity() {
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

		data = ToroSupportPlusController.retrieveSupportPlusData(quoteId);

		Test.startTest();
		data.qiWrappers[0].spQuantity = 0;
		data.qiWrappers[0].sublines[0].spQuantity = 0;

		success = ToroSupportPlusController.splitAndSaveItems(
			quote
			, JSON.serialize(data.qiWrappers)
			, JSON.serialize(data.addNewWrappers)
		);

		System.assert(success);
		Test.stopTest();
	}
	*/
}