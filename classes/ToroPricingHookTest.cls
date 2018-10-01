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
private class ToroPricingHookTest {

     @TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		
	}
	
   static testMethod void test_preQuoteItemsCreationHook() {
    	Revvy__MnQuote__c qt = [Select Id, Is_Dirty__c From Revvy__MnQuote__c limit 1];
    	List<Revvy__MnQuoteItem__c> qis = [Select Id, Name From Revvy__MnQuoteItem__c where Revvy__Quote__c = :qt.Id ];
    	List<Revvy__MnQuoteItem__c> qisList = ToroPricingHook.preQuoteItemsCreationHook(qt,qis);
    	System.assert(qisList.size()>0);
    }

   static testMethod void test_productDetailPriceHook() {
    	Revvy__MnQuote__c qt = [Select Id, Is_Dirty__c From Revvy__MnQuote__c limit 1];
    	List<Revvy__MnQuoteItem__c> qis = [Select Id, Name From Revvy__MnQuoteItem__c where Revvy__Quote__c = :qt.Id ];

    	REVVY.CMnPricingParams pricingParams = new REVVY.CMnPricingParams();
    	pricingParams.QuoteId = qt.Id;

    	Decimal dresult = ToroPricingHook.productDetailPriceHook(pricingParams,'TEST',0);
    	System.assert(dresult==0);
    }

   static testMethod void test_productSearchPriceHook() {
    	Revvy__MnQuote__c qt = [Select Id, Is_Dirty__c, REVVY__Segment__c From Revvy__MnQuote__c limit 1];
    	qt.Exchange_Rate__c = 1.1;
    	update qt;
    	
    	List<Revvy__MnQuoteItem__c> qis = [Select Id, Name, REVVY__Product_ID_F__c, REVVY__Price__c From Revvy__MnQuoteItem__c where Revvy__Quote__c = :qt.Id ];
		Map<String, Decimal> prodsMap = new Map<String, Decimal>();
		for(Revvy__MnQuoteItem__c qi:qis) {
			prodsMap.put(qi.REVVY__Product_ID_F__c,qi.REVVY__Price__c);
		}
		

    	REVVY.CMnPricingParams pricingParams = new REVVY.CMnPricingParams();
    	pricingParams.QuoteId = qt.Id;
    	pricingParams.qtSegment = qt.REVVY__Segment__c;

		Map<String, Decimal> result = ToroPricingHook.productSearchPriceHook(pricingParams, prodsMap);
    	System.assert(result.size()>0);
    }
    
    //List<Revvy__MnQuoteItem__c> postQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis)

   static testMethod void test_postQuoteItemsCreationHook() {
    	Revvy__MnQuote__c qt = [Select Id, Is_Dirty__c, REVVY__Segment__c From Revvy__MnQuote__c limit 1];
    	qt.Exchange_Rate__c = 1.1;
    	update qt;
    	
    	List<Revvy__MnQuoteItem__c> qis = [Select Id, Name, REVVY__Product_ID_F__c, REVVY__Price__c, REVVY__FloorPrice__c 
    	                                        ,  (Select Id, REVVY__Price__c, REVVY__FloorPrice__c From REVVY__QuoteItemSubLine__r)
    	                                     From Revvy__MnQuoteItem__c where Revvy__Quote__c = :qt.Id ];
		Map<String, Decimal> prodsMap = new Map<String, Decimal>();
		for(Revvy__MnQuoteItem__c qi:qis) {
			prodsMap.put(qi.REVVY__Product_ID_F__c,qi.REVVY__Price__c);
		}
		

    	REVVY.CMnPricingParams pricingParams = new REVVY.CMnPricingParams();
    	pricingParams.QuoteId = qt.Id;
    	pricingParams.qtSegment = qt.REVVY__Segment__c;

		List<Revvy__MnQuoteItem__c> result = ToroPricingHook.postQuoteItemsCreationHook(qt,qis);
    	System.assert(result.size()>0);
    }
		
	/*
   static testMethod void test_preQuoteItemsCreationHook() {
    	Revvy__MnQuote__c quote = [Select Id, Is_Dirty__c From Revvy__MnQuote__c limit 1];
    	REVVY.CMnPricingParams pricingParams = new REVVY.CMnPricingParams();
    	pricingParams.QuoteId = quote.Id;
    	
		ToroPostConfigPricingHook ph = new ToroPostConfigPricingHook();
		ph.preBOMUpdateHook(pricingParams);
		
    	Revvy__MnQuote__c result = [Select Id, Is_Dirty__c From Revvy__MnQuote__c where Id = :quote.Id];
		System.assert(result.Is_Dirty__c);        
    }
	*/
}