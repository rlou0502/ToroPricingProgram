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
        
    } 
    static testMethod void testQuoteCache() {
    	REVVY__MnQuote__c q = [select id from  REVVY__MnQuote__c limit 1];
    	q = ToroCacheManager.getQuote(q.Id);
    	system.debug('-------q.Setup_Fee__c=' + q.Setup_Fee__c);
    	q.Setup_Fee__c = 2;
    	
    	q = ToroCacheManager.getQuote(q.Id);
    	system.debug('-------' + q.Setup_Fee__c);
    	system.assert(q.Setup_Fee__c == null);
    	q = ToroCacheManager.refreshQuote(q.Id);
    	system.assert(q.Setup_Fee__c == null);
    	q.Setup_Fee__c = 3;
    	update q;
    	q = ToroCacheManager.getQuote(q.Id);
    	system.assert(q.Setup_Fee__c == 3);
    	
    	//system.assertEquals('Commercial', q.REVVY__Segment__c);
    }   
}