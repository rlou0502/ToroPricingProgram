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
private class ToroGSAPricingProgramHelperTest {
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void myUnitTest() {
    	Test.startTest();
        ToroGSAPricingProgramHelper tlpp = new ToroGSAPricingProgramHelper();
        System.assertEquals(false, tlpp.displaySetupFee());
        System.assertEquals(false, tlpp.displayPerformancePart());
        System.assertEquals(null, tlpp.retrieveAwardPrice(null));
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		tlpp.initialize(quote.Id);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, 'Army', '% off MSRP', tlpp.quoteItems, false);
		Test.stopTest();
    }
    static testMethod void myUnitTest2() {
    	REVVY__MnStrategy1__c pp = [select id from REVVY__MnStrategy1__c where ExternalID__c ='Army' limit 1];
    	pp.DrivenByGP__c = true;
    	update pp;
    	Test.startTest();
    	ToroGSAPricingProgramHelper tlpp = new ToroGSAPricingProgramHelper();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		tlpp.initialize(quote.Id);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, 'Army', '% off MSRP', tlpp.quoteItems, false);
		Test.stopTest();
    }
     static testMethod void myUnitTest3() {
    	REVVY__MnStrategy1__c pp = [select id from REVVY__MnStrategy1__c where ExternalID__c ='Army' limit 1];
    	pp.DrivenByGP__c = true;
    	pp.UseDesignatedPriceList__c=true;
    	pp.Previous_Price_Date__c=Date.today().addYears(-3);
    	update pp;
    	Test.startTest();
        ToroGSAPricingProgramHelper tlpp = new ToroGSAPricingProgramHelper();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		tlpp.initialize(quote.Id);
		for(REVVY__MnStrategy4__c qi : tlpp.quoteItems) {
			qi.OnlyExistedInCPL__c = false;
			for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
				qis.OnlyExistedInCPL__c = false;	
			}	
		}
		
		tlpp.quoteItems = tlpp.calculateRebateMarginImpl(quote.Id, 'Army', '% off MSRP', tlpp.quoteItems);
		Test.stopTest();
    }
}