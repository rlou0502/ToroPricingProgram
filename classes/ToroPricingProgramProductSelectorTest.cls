@isTest
private class ToroPricingProgramProductSelectorTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();

		Revvy__MnStrategy1__c pricingProgram = [
			SELECT
				Id, ApplicableProducts__c
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

		pricingProgram.ApplicableProducts__c = applicableProducts.removeEnd(',');
		update pricingProgram;
	}

	@isTest static void test_pricing_program_line_product_selector() {
		Revvy__MnStrategy1__c pricingProgram = [SELECT Id, ApplicableProducts__c FROM Revvy__MnStrategy1__c WHERE ExternalId__c = 'STILargePackageProgram'];
		final String previousApplicableProducts = pricingProgram.ApplicableProducts__c;

		ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pricingProgram);
		ToroPricingProgramProductSelector controller = new ToroPricingProgramProductSelector(stdController);

		Integer expectedNumberOfSelectedProducts = [SELECT Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Type__c = 'Product'].size();
		System.assertEquals(expectedNumberOfSelectedProducts, controller.selectedProducts.size());

		// set to applicable products to 'All'
		controller.allProductsSelected = true;
		controller.toggleAllProducts();
		pricingProgram = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assertEquals('All', pricingProgram.ApplicableProducts__c);

		// switch applicable products to previously selected
		controller.allProductsSelected = false;
		controller.toggleAllProducts();
		pricingProgram = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assertEquals(previousApplicableProducts, pricingProgram.ApplicableProducts__c);

		// delete a product
		controller.toBeDeleted = pricingProgram.ApplicableProducts__c.split(',')[0];
		controller.deleteProduct();
		pricingProgram = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assert(!pricingProgram.ApplicableProducts__c.contains(controller.toBeDeleted));

		Boolean containsDeletedProduct = false;
		for (ToroPricingProgramProductSelector.Wrapper selectedProduct : controller.selectedProducts) {
			if (selectedProduct.revvyId == controller.toBeDeleted) {
				containsDeletedProduct = true;
			}
		}
		System.assert(!containsDeletedProduct);

		// add a product
		Revvy__MnCatalogNode__c productToBeAdded = [SELECT Id, Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Id__c = :controller.toBeDeleted];
		controller.dummyProduct.REVVY__Parent__c = productToBeAdded.Id;
		controller.addProduct();
		pricingProgram = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy1__c WHERE Id = :pricingProgram.Id LIMIT 1];
		System.assert(pricingProgram.ApplicableProducts__c.contains(productToBeAdded.Revvy__Id__c));
	}
}