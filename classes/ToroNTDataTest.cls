@isTest
private class ToroNTDataTest {

	@TestSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();

		REVVY__MnCatalogNode__c product = [
			SELECT
				Non_Toro_Product__c
				, REVVY__Id__c
			FROM
				REVVY__MnCatalogNode__c
			WHERE
				REVVY__Id__c = '114-5419']; // "2.5"" dia. Full Front Roller Asm"

		product.Non_Toro_Product__c = true;
		update product;

		REVVY__MnQuote__c quote = [SELECT Pricing_Program_Name__c FROM REVVY__MnQuote__c LIMIT 1];
		quote.Pricing_Program_Name__c = 'MarketSupportChartLargePackage;Large_Package';
		update quote;

		insert new Revvy__MnSequenceGen__c(
			  Revvy__ObjectName__c   = 'MnQuoteItem__c'
			, REVVY__CurrentValue__c = 1
		);
	}

	@isTest static void test_constructor() {
		Test.startTest();
		ToroNTData data = new ToroNTData();
		System.assert(data != null);
		Test.stopTest();
	}

	@isTest static void test_constructor_quote() {
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		Test.startTest();
		ToroNTData data = new ToroNTData(quoteId);
		System.assert(data != null);
		Test.stopTest();
	}

	@isTest static void test_exception() {
		Test.startTest();
		final Id quoteId = [SELECT Id FROM REVVY__MnQuote__c LIMIT 1].Id;
		ToroNTData data = new ToroNTData(quoteId);

		Boolean exceptionCaught = false;
		try {
			ToroNTData data2 = new ToroNTData(data.qiWrappers[0].qiObj.Id); // will fail
		}

		catch (Exception e) {
			exceptionCaught = true;
		}

		System.assert(exceptionCaught);
		Test.stopTest();
	}
}