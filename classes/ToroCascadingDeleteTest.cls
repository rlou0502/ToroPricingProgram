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
private class ToroCascadingDeleteTest {
	private static final Id RECTYPE_ACCOUNT_END_USER        = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void pricingProgramCascadingDeleteTest() {
        Revvy__MnStrategy1__c pricingProgram = [
			SELECT
				Id, ApplicableProductsLong__c
			FROM
				Revvy__MnStrategy1__c
			WHERE
				ExternalId__c = 'SmallPackage'
		];
		List<Revvy__MnStrategy2__c> items = [select Id from Revvy__MnStrategy2__c where pricingprogram__c = :pricingProgram.Id];
		System.assert(items.size() != 0);
        delete pricingProgram;
        items = [select Id from Revvy__MnStrategy2__c where pricingprogram__c = :pricingProgram.Id];
        System.assert(items.size() == 0);
    } 
    static testMethod void quoteItemCascadingDeleteTest() {
    	
    	REVVY__MnQuote__c quote = [select Id from REVVY__MnQuote__c limit 1];
    	
    	List<REVVY__MnStrategy4__c> qiExts = [select id from REVVY__MnStrategy4__c];
    	List<REVVY__MnStrategy5__c> qisExts = [select id from REVVY__MnStrategy5__c];
    	system.assert(qiExts.size() !=0);
    	system.assert(qisExts.size() !=0);
    	
    	delete [select Id from REVVY__MnQuoteItemSubLine__c where REVVY__QuoteItem__r.REVVY__Quote__c = :quote.Id];
    	delete [select Id from REVVY__MnQuoteItem__c where REVVY__Quote__c = :quote.Id];
    	delete quote;
    	qiExts = [select id from REVVY__MnStrategy4__c];
    	qisExts = [select id from REVVY__MnStrategy5__c];
    	system.debug(qiExts.size());
    	system.debug(qisExts.size());
    	system.assert(qiExts.size() ==0);
    	system.assert(qisExts.size() ==0);
    	
    }
}