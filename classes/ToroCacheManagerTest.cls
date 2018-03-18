@isTest
private class ToroCacheManagerTest {
	@testSetup static void methodName() {
		List<sObject> disti = Test.loadData(Account.sObjectType, 'TestData_PP_Distributor');
		Id RecordTypeIdDisti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
		List<User_Distributor__c> userDistributors = new List<User_Distributor__c>();
		for(sObject s : disti) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdDisti;
			userDistributors.add(new User_Distributor__c(User_Name__c=userInfo.getUserId(), Distributor__c=s.Id));
		}
		update disti;
		insert userDistributors;
		
		List<sObject> corporateAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CorporateAccount');
		Id RecordTypeIdCorporate = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
		for(sObject s : corporateAccount) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdCorporate;
		}
		update corporateAccount;
		List<sObject> customerAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CustomerAccount');
		for(sObject s : customerAccount) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdCorporate;
		}
		update customerAccount;
		List<sObject> pricingProgram = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_PricingProgram');
		List<sObject> eligilibility = Test.loadData(Revvy__MnStrategy3__c.sObjectType, 'TestData_PP_Eligibility');
		
		List<sObject> pricingProgramLine = Test.loadData(Revvy__MnStrategy2__c.sObjectType, 'TestData_PP_PricingProgramLine');
		List<sObject> priceList = Test.loadData(Revvy__MnPriceList__c.sObjectType, 'TestData_PP_PriceList');
		List<sObject> products = Test.loadData(Revvy__MnCatalogNode__c.sObjectType, 'TestData_PP_CatalogNode');
		List<sObject> quote = Test.loadData(Revvy__MnQuote__c.sObjectType, 'TestData_PP_Quote');
		system.debug('------------quote=' + quote[0].get('REVVY__Id__c'));
		List<sObject> quoteItem = Test.loadData(Revvy__MnQuoteItem__c.sObjectType, 'TestData_PP_QuoteItem');
		List<sObject> quoteItemSubline = Test.loadData(Revvy__MnQuoteItemSubline__c.sObjectType, 'TestData_PP_QuoteItemSubline');
		
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
    	system.assert(q.Setup_Fee__c == 2);
    	q = ToroCacheManager.refreshQuote(q.Id);
    	system.assert(q.Setup_Fee__c != 2);
    	q.Setup_Fee__c = 3;
    	update q;
    	q = ToroCacheManager.getQuote(q.Id);
    	system.assert(q.Setup_Fee__c == 3);
    	
    	//system.assertEquals('Commercial', q.REVVY__Segment__c);
    }   
}