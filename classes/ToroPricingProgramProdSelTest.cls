@isTest
private class ToroPricingProgramProdSelTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();

		Revvy__MnStrategy1__c pricingProgram = [
			SELECT
				Id, ApplicableProductsLong__c
			FROM
				Revvy__MnStrategy1__c
			WHERE
				ExternalId__c = 'STILargePackageProgram'
		];

		List<Revvy__MnCatalogNode__c> products = [
			SELECT
				Revvy__Id__c
			FROM
				Revvy__MnCatalogNode__c
			WHERE
				Revvy__Type__c = 'Product'
		];

		String applicableProducts = '';
		for (Revvy__MnCatalogNode__c product : products) {
			applicableProducts += product.Revvy__Id__c + ',';
		}

		pricingProgram.ApplicableProductsLong__c = applicableProducts.removeEnd(',');
		update pricingProgram;
	}

	@isTest static void test_pricing_program_line_product_selector() {
		Revvy__MnStrategy1__c pricingProgram = [SELECT Id, ApplicableProductsLong__c FROM Revvy__MnStrategy1__c WHERE ExternalId__c = 'STILargePackageProgram'];
		final String previousApplicableProducts = pricingProgram.ApplicableProductsLong__c;

		ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pricingProgram);
		ToroPricingProgramProdSel controller = new ToroPricingProgramProdSel(stdController);

		Integer expectedNumberOfSelectedProducts = [SELECT Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Type__c = 'Product'].size();
		System.assertEquals(expectedNumberOfSelectedProducts, controller.selectedProducts.size());

		// set to applicable products to 'All'
		controller.allProductsSelected = true;
		controller.toggleAllProducts();
		pricingProgram = [SELECT ApplicableProductsLong__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assertEquals('All', pricingProgram.ApplicableProductsLong__c);

		// switch applicable products to previously selected
		controller.allProductsSelected = false;
		controller.toggleAllProducts();
		pricingProgram = [SELECT ApplicableProductsLong__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assertEquals(previousApplicableProducts, pricingProgram.ApplicableProductsLong__c);

		// delete a product
		controller.toBeDeleted = pricingProgram.ApplicableProductsLong__c.split(',')[0];
		controller.deleteProduct();
		pricingProgram = [SELECT ApplicableProductsLong__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assert(!pricingProgram.ApplicableProductsLong__c.contains(controller.toBeDeleted));

		Boolean containsDeletedProduct = false;
		for (ToroPricingProgramProdSel.Wrapper selectedProduct : controller.selectedProducts) {
			if (selectedProduct.revvyId == controller.toBeDeleted) {
				containsDeletedProduct = true;
			}
		}
		System.assert(!containsDeletedProduct);

		// add a product
		Revvy__MnCatalogNode__c productToBeAdded = [SELECT Id, Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Id__c = :controller.toBeDeleted];
		productToBeAdded.Toro_Product_Type__c='Finished Good';
		update productToBeAdded;
		//controller.dummyProduct.REVVY__Parent__c = productToBeAdded.Id;
		controller.pricingProgram.SelectProduct__c = productToBeAdded.Id;
		controller.addProduct();
		pricingProgram = [SELECT ApplicableProductsLong__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assert(pricingProgram.ApplicableProductsLong__c.contains(productToBeAdded.Revvy__Id__c));
	}
}