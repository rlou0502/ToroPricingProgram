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
private class ToroQuoteExportTest {
	@testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void myUnitTest() {
        REVVY__MnQuote__c q = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1];

		Test.startTest();
		PageReference pageRef = Page.ToroQuoteExport;
		pageRef.getParameters().put('Id', q.Id);
    	Test.setCurrentPage(pageRef);
		ToroQuoteExport cntrlr = 
            new ToroQuoteExport(new ApexPages.StandardController(q));
        cntrlr =  new ToroQuoteExport();
        cntrlr.getSOCMergeAcross();
        String header = cntrlr.xlsHeader;    
		Test.stopTest();
        
    }
}