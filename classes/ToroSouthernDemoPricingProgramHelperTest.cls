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
private class ToroSouthernDemoPricingProgramHelperTest {

    @testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}

	@isTest static void test_get_field_methods() {
		Test.startTest();
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroSouthernDemoPricingProgramHelper tlpp = new ToroSouthernDemoPricingProgramHelper();
		tlpp.performancePartFlag=true;
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Total Award $', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, 'Gross Profit %', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% of DNET', tlpp.quoteItems, true);
		Test.stopTest();
	}
	@isTest static void test_method_two() {
		Test.startTest();
		ToroSouthernDemoPricingProgramHelper tlpp = new ToroSouthernDemoPricingProgramHelper();
		tlpp.displayPerformancePart();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryUpdatableFields() != null);
		
		tlpp.retrieveDemoPricingProgramOptions();
		Test.stopTest();
	}
	@isTest static void test_secondary_program() {
		Test.startTest();
        String pricingProgram = 'SouthernDemo;Southern_Demo';
        ToroSouthernDemoSecondaryPricingProgram tlpp = new ToroSouthernDemoSecondaryPricingProgram();
		tlpp.loadModelIdChartABPricingProgramMap('SouthernDemo;Southern_Demo');
        ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
        ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        pp.initialize(quote.Id);
        tlpp.retrieveRebatePercentBasedOnBlendedDNet(pp.quoteItems[0],110,'SouthernDemo','SouthernDemoChartA');
    	Test.stopTest();
    	
	}
}