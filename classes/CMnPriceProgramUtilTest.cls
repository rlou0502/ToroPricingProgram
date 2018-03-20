@isTest
private class CMnPriceProgramUtilTest {

	@testSetup static void setupTestData() {
		ToroTestData.loadTestData();
	}

	@isTest static void test_collect_price_program() {
		final String priceProgramExternalId = 'STI Large Package Program';
		CMnPriceProgramUtil.PriceProgramInfo ppi = CMnPriceProgramUtil.collectPriceProgram(priceProgramExternalId);
		System.assert(ppi.rebateMap != null);
		System.assert(ppi.rebateMap.keySet().size() > 0);
		System.assert(ppi.rebateApplicableProducts != null);
		System.assert(ppi.rebateApplicableProducts.keySet().size() > 0);
	}
}