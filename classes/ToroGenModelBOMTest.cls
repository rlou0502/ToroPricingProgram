@isTest
private class ToroGenModelBOMTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadGenericTestData();
	}

	@isTest static void test_gen_bom() {
		ToroGenModelBOM.genBOM();
	}

	@isTest static void test_get_stock_order() {
		ToroGenModelBOM.getStockOrder();
	}

	@isTest static void test_inner_classes() {
		ToroGenModelBOM.ProductModelView pmv1 = new ToroGenModelBOM.ProductModelView();
		System.assert(pmv1 != null);

		ToroGenModelBOM.ProductModelView pmv2 = new ToroGenModelBOM.ProductModelView(
			'modelname'
			, 'productab'
			, 'description'
			, 9.99
			, 9.99
			, 100
			, 999
		);
		System.assert(pmv2 != null);
	}

}