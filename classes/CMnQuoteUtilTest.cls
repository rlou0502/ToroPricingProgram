@isTest
private class CMnQuoteUtilTest {

	@isTest static void test_get_new_guid() {
		System.assert(CMnQuoteUtil.getNewGuid() != null);
	}

	@isTest static void test_default_decimal() {
		System.assertEquals(10, CMnQuoteUtil.defaultDecimal(10));
		System.assertEquals(0, CMnQuoteUtil.defaultDecimal(null));
	}

	@isTest static void test_get_quote_query() {
		String extraFields = '';
		System.assert(CMnQuoteUtil.getQuoteQuery(extraFields) != null);
	}
}