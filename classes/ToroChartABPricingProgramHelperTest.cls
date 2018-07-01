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
private class ToroChartABPricingProgramHelperTest {
	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void unitTestMSRP() {
    	Test.startTest();
        String pricingProgram = 'ChartAB;Market_Chart';
        ToroPriceProgramFactory.refreshAllPricingProgramHelpers();
        ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
        ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
        //ToroChartABPricingProgramHelper chartABHelper = (ToroChartABPricingProgramHelper) pp;
        //system.assert(chartABHelper != null);
        //Map<String, Set<String>> m = chartABHelper.loadModelIdChartABPricingProgramMap(pricingProgram);
        //system.debug('map=' + m);
        ToroPriceProgramFactory.getPricingProgramHelper(null);
        ToroPriceProgramFactory.getPricingProgramHelper('any_type');
        pp.retrievePricingMethodOptions();
        pp.getQuoteFields();
		pp.getToroQuoteItemUpdatableFields();
		pp.getToroQuoteItemSublineUpdatableFields();
		pp.getToroQuoteItemSummaryUpdatableFields();
		pp.displayPerformancePart();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        pp.initialize(quote.Id);
        for(REVVY__MnStrategy4__c qi : pp.quoteItems) {
        	qi.Off_MSRP__c = 23.0;
        	for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
        		qis.Percent_Off_MSRP__c = 23.0;	
        	}
        }
		pp.quoteItems = pp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', pp.quoteItems, true);
		
		List<REVVY__MnStrategy4__c> quoteitems = [select id,Product_Id__c, Pricing_Program__c, Rebate_as_a_of_DN__c, Award_of_DN__c,Toro_Gross_Profit_Percent__c, Off_MSRP__c, Toro_Blend_Of_DN__c  from REVVY__MnStrategy4__c where Product_Id__c='04055' and Pricing_program__c='ChartA'];
    	System.assert(quoteitems.size() != 0);
    	System.debug('rebate = ' + quoteitems);
    	quoteitems = [select id from REVVY__MnStrategy4__c where Product_Id__c='04238' and Pricing_Program__c='ChartB'];
    	System.assert(quoteitems.size() != 0);
    	Test.stopTest();
    }
    static testMethod void unitTestDNET() {
    	Test.startTest();
        String pricingProgram = 'ChartAB;Market_Chart';
        ToroPriceProgramFactory.refreshAllPricingProgramHelpers();
        ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
        ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
        //ToroChartABPricingProgramHelper chartABHelper = (ToroChartABPricingProgramHelper) pp;
        //system.assert(chartABHelper != null);
        //Map<String, Set<String>> m = chartABHelper.loadModelIdChartABPricingProgramMap(pricingProgram);
        //system.debug('map=' + m);
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        pp.initialize(quote.Id);
        for(REVVY__MnStrategy4__c qi : pp.quoteItems) {
        	qi.Award_of_DN__c = 110.0;
        	for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
        		qis.Percent_of_DNet__c = 110.0;	
        	}
        }
		pp.quoteItems = pp.calculateRebateMargin(quote.Id, ppd.externalId, '% of DNET', pp.quoteItems, true);
		List<REVVY__MnStrategy4__c> quoteitems = [select id,Product_Id__c, Pricing_Program__c, Rebate_as_a_of_DN__c, Award_of_DN__c, Toro_Gross_Profit_Percent__c, Off_MSRP__c, Toro_Blend_Of_DN__c  from REVVY__MnStrategy4__c where Product_Id__c='04055' and Pricing_program__c='ChartA'];
    	System.assert(quoteitems.size() != 0);
    	System.debug('rebate = ' + quoteitems);
    	quoteitems = [select id from REVVY__MnStrategy4__c where Product_Id__c='04238' and Pricing_Program__c='ChartB'];
    	System.assert(quoteitems.size() != 0);
    	Test.stopTest();
    }
    static testMethod void unitTestGPPercent() {
    	Test.startTest();
        String pricingProgram = 'ChartAB;Market_Chart';
        ToroPriceProgramFactory.refreshAllPricingProgramHelpers();
        ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
        ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
        //ToroChartABPricingProgramHelper chartABHelper = (ToroChartABPricingProgramHelper) pp;
        //system.assert(chartABHelper != null);
        //Map<String, Set<String>> m = chartABHelper.loadModelIdChartABPricingProgramMap(pricingProgram);
        //system.debug('map=' + m);
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        pp.initialize(quote.Id);
        for(REVVY__MnStrategy4__c qi : pp.quoteItems) {
        	qi.Toro_Gross_Profit_Percent__c = 17.4;
        	for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
        		qis.Gross_Profit_Percent__c = 17.4;	
        	}
        }
		pp.quoteItems = pp.calculateRebateMargin(quote.Id, ppd.externalId, 'Gross Profit %', pp.quoteItems, true);
		List<REVVY__MnStrategy4__c> quoteitems = [select id,Product_Id__c, Pricing_Program__c, Rebate_as_a_of_DN__c, Award_of_DN__c, Toro_Gross_Profit_Percent__c, Off_MSRP__c, Toro_Blend_Of_DN__c  from REVVY__MnStrategy4__c where Product_Id__c='04055' and Pricing_program__c='ChartA'];
    	System.assert(quoteitems.size() != 0);
    	System.debug('rebate = ' + quoteitems);
    	quoteitems = [select id from REVVY__MnStrategy4__c where Product_Id__c='04238' and Pricing_Program__c='ChartB'];
    	System.assert(quoteitems.size() != 0);
    	Test.stopTest();
    }
    static testMethod void unitTestTotalAwardPrice() {
    	Test.startTest();
        String pricingProgram = 'ChartAB;Market_Chart';
        ToroPriceProgramFactory.refreshAllPricingProgramHelpers();
        ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
        ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
        //ToroChartABPricingProgramHelper chartABHelper = (ToroChartABPricingProgramHelper) pp;
        //system.assert(chartABHelper != null);
        //Map<String, Set<String>> m = chartABHelper.loadModelIdChartABPricingProgramMap(pricingProgram);
        //system.debug('map=' + m);
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        pp.initialize(quote.Id);
        for(REVVY__MnStrategy4__c qi : pp.quoteItems) {
        	qi.Award_Price__c = 100;
        	for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
        		qis.Award_Price__c = 100;	
        	}
        }
		pp.quoteItems = pp.calculateRebateMargin(quote.Id, ppd.externalId, 'Total Award $', pp.quoteItems, true);
		List<REVVY__MnStrategy4__c> quoteitems = [select id,Product_Id__c, Pricing_Program__c, Rebate_as_a_of_DN__c, Award_of_DN__c, Toro_Gross_Profit_Percent__c, Off_MSRP__c, Toro_Blend_Of_DN__c  from REVVY__MnStrategy4__c where Product_Id__c='04055' and Pricing_program__c='ChartA'];
    	System.assert(quoteitems.size() != 0);
    	System.debug('rebate = ' + quoteitems);
    	quoteitems = [select id from REVVY__MnStrategy4__c where Product_Id__c='04238' and Pricing_Program__c='ChartB'];
    	System.assert(quoteitems.size() != 0);
    	Test.stopTest();
    }
    
}