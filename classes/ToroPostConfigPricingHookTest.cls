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
private class ToroPostConfigPricingHookTest {

     @TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}

   static testMethod void test_preBOMUpdateHook() {
    	Revvy__MnQuote__c quote = [Select Id, Is_Dirty__c, REVVY__Segment__c From Revvy__MnQuote__c limit 1];
    	REVVY.CMnPricingParams pricingParams = new REVVY.CMnPricingParams();
    	pricingParams.QuoteId = quote.Id;
    	pricingParams.qtSegment = quote.REVVY__Segment__c;
    	List<Revvy__MnQuoteItem__c> qis = [Select Id, Name, REVVY__Product_ID_F__c, REVVY__Price__c, REVVY__FloorPrice__c, REVVY__PriceListLine__c
    	                                        ,  (Select Id, REVVY__Price__c, REVVY__FloorPrice__c,REVVY__PriceListLine__c From REVVY__QuoteItemSubLine__r)
    	                                     From Revvy__MnQuoteItem__c where Revvy__Quote__c = :quote.Id ];
		
		List<REVVY__MnQuoteItemSubLine__c> qiSublines = new List<REVVY__MnQuoteItemSubLine__c>();
		for(Revvy__MnQuoteItem__c qi:qis) {
			if(qi.REVVY__QuoteItemSubLine__r != null) {
				for(REVVY__MnQuoteItemSubLine__c sub : qi.REVVY__QuoteItemSubLine__r) {
					qiSublines.add(sub);	
				}
			}
		}
		pricingParams.qiList = qis;
		pricingParams.qiSubLineList = qiSublines;
		
		ToroPostConfigPricingHook ph = new ToroPostConfigPricingHook();
		system.debug('--------------');
		ph.preBOMUpdateHook(pricingParams);
		system.debug('--------------');
    	Revvy__MnQuote__c result = [Select Id, Is_Dirty__c From Revvy__MnQuote__c where Id = :quote.Id];
		System.assert(result.Is_Dirty__c);        
    }
}