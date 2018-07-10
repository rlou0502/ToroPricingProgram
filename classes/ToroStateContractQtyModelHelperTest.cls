/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ToroStateContractQtyModelHelperTest {

     @TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		List<Revvy__MnStrategy4__c> toroQuoteItems = [
			SELECT
				Award_Price__c
				, DNet_Price__c
			FROM
				Revvy__MnStrategy4__c
		];

		for (Revvy__MnStrategy4__c tqi : toroQuoteItems) {
			tqi.Award_Price__c = 90;
			tqi.DNet_Price__c = 100;
		}

		update toroQuoteItems;
	}
	/**
	 *
	 * description
	 *
	 * @result the key result
	 */
	@isTest static void test_helper() {
		ToroStateContractQtyModelHelper helper = new ToroStateContractQtyModelHelper();
		System.assert(helper.getQuoteFields() != null);
		System.assert(helper.retrievePricingMethodOptions() != null);
		System.assert(helper.getQuoteLevelMSQPDNetEditable() != null);
		System.assert(helper.getToroQuoteItemSublineUpdatableFields() == null);
		System.assert(helper.getToroQuoteItemUpdatableFields() != null);
		System.assert(helper.getToroQuoteItemSummaryUpdatableFields() == null);
	}

	/**
	 *
	 * test_calculate_rebate_margin_impl
	 *
	 * @result the key result
	 */
	@isTest static void test_calculate_rebate_margin_impl() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroStateContractQtyModelHelper tlpp = new ToroStateContractQtyModelHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('StateofOR;Base_w_Qty_Model_Pricing');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		Test.stopTest();
	}
	@isTest static void test_state_of_nc() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroStateContractModelQtyHelper tlpp = new ToroStateContractModelQtyHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('StateofOR;Base_w_Qty_Model_Pricing');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		Test.stopTest();
	}
	@isTest static void test_calculate_rebate_margin_impl_2() {
		ToroCacheManager.refreshAllPricingPrograms();
		List<REVVY__MnStrategy2__c> pricngProgramLines = [select id from REVVY__MnStrategy2__c ];
		for(REVVY__MnStrategy2__c l : pricngProgramLines) {
			l.Rebate_as_a_Percent_of_DN__c = null;
			l.Distributor_Margin__c = 10;	
		}
		update pricngProgramLines;
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroStateContractQtyModelHelper tlpp = new ToroStateContractQtyModelHelper();
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('StateofOR;Base_w_Qty_Model_Pricing');
		tlpp.initialize(quote.Id);
		
		List<REVVY__MnStrategy4__c> quoteItems = [select id from REVVY__MnStrategy4__c ];
		for(REVVY__MnStrategy4__c l : quoteItems) {
			l.Rebate_as_a_of_DN__c = 0;
		}
		update quoteItems;
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		Test.stopTest();
	}
}