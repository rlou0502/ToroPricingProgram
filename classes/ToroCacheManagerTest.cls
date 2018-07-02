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
private class ToroCacheManagerTest {
@testSetup static void setupData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
	static testMethod void myUnitTest() {
        String largePackageExtId = 'MarketSupportChartLargePackage';
       	Revvy__MnStrategy1__c pp = ToroCacheManager.getPricingProgram(largePackageExtId);
        system.assertEquals('Large Package', pp.name);
        system.assertEquals(21, pp.PricingProgramLines__r.size());
        List<REVVY__MnStrategy4__c> qiExts = [select id, product_name__c, MSRP_Price__c, DNet_Price__c from REVVY__MnStrategy4__c];
        system.assertEquals(4, qiExts.size());
        for(REVVY__MnStrategy4__c qi : qiExts) {
        	system.debug('qi ext = name =' + qi.product_name__c + ' msrp=' + qi.msrp_price__c + ' dnet=' + qi.dnet_price__c );	
        }
        List<REVVY__MnStrategy5__c> qisExts = [select id, product_name__c, MSRP_Price__c, DNet_Price__c from REVVY__MnStrategy5__c];
        for(REVVY__MnStrategy5__c qis : qisExts) {
        	system.debug('qis ext = name =' + qis.product_name__c + ' msrp=' + qis.msrp_price__c + ' dnet=' + qis.dnet_price__c );	
        }
        system.assertEquals(10, qisExts.size());
        ToroCacheManager.refreshAllPricingPrograms();
        
    } 
    static testMethod void testQuoteCache() {
    	List<REVVY__MnPriceListLine__c> plls = [select id, REVVY__ListedPrice__c from REVVY__MnPriceListLine__c];
    	for(REVVY__MnPriceListLine__c pll : plls) {
    		pll.REVVY__PriceField4__c = pll.REVVY__ListedPrice__c;	
    	}
    	update plls;
    	Test.startTest();
    	REVVY__MnQuote__c q = [select id from  REVVY__MnQuote__c limit 1];
    	q = ToroCacheManager.getQuote(q.Id);
    	system.debug('-------q.Setup_Fee__c=' + q.Setup_Fee__c);
    	q.Setup_Fee__c = 2;
    	
    	q = ToroCacheManager.getQuote(q.Id);
    	
    	system.debug('-------' + q.Setup_Fee__c);
    	ToroCacheManager.putQuote(q);
    	system.assert(q.Setup_Fee__c == null);
    	q = ToroCacheManager.refreshQuote(q.Id);
    	system.assert(q.Setup_Fee__c == null);
    	q.Setup_Fee__c = 3;
    	update q;
    	q = ToroCacheManager.getQuote(q.Id);
    	system.assert(q.Setup_Fee__c == 3);
    	
    	ToroCacheManager.getPerformancePartMap();
    	system.assert(ToroCacheManager.getPricingProgram(null) == null);
    	ToroCacheManager.setPercentOffMSRP(new Map<Id, decimal>());
    	Test.stopTest();

    }   
}