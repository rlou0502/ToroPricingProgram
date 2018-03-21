@isTest
private class ToroLargePackagePricingProgramHelperTest {

	@testSetup static void setup() {
		ToroTestData.loadTestData();
	}

	@isTest static void test_get_field_methods() {
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
	}

	@isTest static void test_method_two() {
		ToroLargePackagePricingProgramHelper tlpp = new ToroLargePackagePricingProgramHelper();
	}

}