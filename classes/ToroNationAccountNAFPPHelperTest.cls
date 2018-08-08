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
private class ToroNationAccountNAFPPHelperTest {
	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void myUnitTest() {
    	Test.startTest();
        ToroNationAccountNAFPPHelper naf = new ToroNationAccountNAFPPHelper();
        naf.getQuoteFields();
        naf.retrievePricingMethodOptions();
        naf.getToroQuoteItemUpdatableFields();
        naf.displayPerformancePart();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        naf.initialize(quote.Id);
        naf.quoteItems = naf.calculateRebateMargin(quote.Id, 'NAF', '% off MSRP', naf.quoteItems, true);
        REVVY__MnStrategy4__c qi = [select id,Product_Id__c, Pricing_Program__c, Rebate_as_a_of_DN__c, Award_of_DN__c,Toro_Gross_Profit_Percent__c, Off_MSRP__c, Toro_Blend_Of_DN__c, Award_Price__c  from REVVY__MnStrategy4__c where Product_Id__c ='04055' limit 1];
        system.assert(qi.Award_Price__c == 7318.74);
        naf.overrideCommissions(naf.quoteItems);
        Test.stopTest();
    }
}