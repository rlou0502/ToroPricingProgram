@isTest
private class CMnQuoteUtilTest {
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		List<Revvy__MnStrategy4__c> toroQuoteItems = [
			SELECT
				Award_Price__c
				, DNet_Price__c
			FROM
				Revvy__MnStrategy4__c
		];

		for (Revvy__MnStrategy4__c tqi : toroQuoteItems) {
			tqi.Award_Price__c = 90;
			tqi.DNet_Price__c = 100;
		}

		update toroQuoteItems;
	}
	@isTest static void test_get_new_guid() {
		System.assert(CMnQuoteUtil.getNewGuid() != null);
		List<Revvy__MnStrategy4__c> toroQuoteItems = [
			SELECT
				Product__r.Toro_Product_Type__c,Adjusted_Quantity__c,Product_Name__c, Product__r.Name, Product__r.Id, Quantity__c
			FROM
				Revvy__MnStrategy4__c
		];
		CMnQuoteUtil.getNumberOfTractionUnits(toroQuoteItems);
		CMnQuoteUtil.checkForOutCrossProducts(toroQuoteItems);
		toroQuoteItems[0].Product__r.Name = 'OUTCROSS' + toroQuoteItems[0].Product__r.Name;
		update toroQuoteItems[0].Product__r;
		toroQuoteItems = [
			SELECT
				Product__r.Toro_Product_Type__c,Product_Name__c
			FROM
				Revvy__MnStrategy4__c
		];
		system.debug('-------'+toroQuoteItems);
		CMnQuoteUtil.checkForOutCrossProducts(toroQuoteItems);
		//CMnQuoteUtil.checkIfApprovalNeeded();
	}

	@isTest static void test_default_decimal() {
		System.assertEquals(10, CMnQuoteUtil.defaultDecimal(10));
		System.assertEquals(0, CMnQuoteUtil.defaultDecimal(null));
	}

	@isTest static void test_get_quote_query() {
		String extraFields = '';
		System.assert(CMnQuoteUtil.getQuoteQuery(extraFields) != null);
	}
	
	@isTest static void test_checkIfApprovalNeeded() {
		Test.StartTest();
		CMnQuoteUtil.getDefaultPriceList();
	  	Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
	  	ToroLargePackagePricingProgramHelper helper = new ToroLargePackagePricingProgramHelper();
	  	ToroPricingProgramData ppd = new ToroPricingProgramData('MarketSupportChartLargePackage;Large_Package');
		helper.initialize(quote.Id);
		helper.quoteItems[0].Product__r.name='OUTCROSS';
		
		List<REVVY__MnStrategy1__c> pricngPrograms = [select id from REVVY__MnStrategy1__c ];
		for(REVVY__MnStrategy1__c l : pricngPrograms) {
			l.OutCrossThreshold__c = 1000;	
			l.Blended_DNet_Threshold__c=1000;
		}
		update pricngPrograms;
		ToroCacheManager.refreshAllPricingPrograms();
		helper.quote.Toro_Total_DNet__c = 200;
		helper.quote.Toro_Blended_Percent_of_DN__c=200;
		update helper.quote;
		
		CMnQuoteUtil.checkIfApprovalNeeded(helper.quote, 'MarketSupportChartLargePackage', '', helper.quoteItems);	
	  	Test.stopTest();
	}
}