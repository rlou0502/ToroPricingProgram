@isTest
private class ToroPricingProgramLineProductSelectTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();

		Revvy__MnStrategy1__c pricingProgram = [
			SELECT
				Id
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

		applicableProducts = applicableProducts.removeEnd(',');

		delete [SELECT Id FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id];

		List<Revvy__MnStrategy2__c> pricingProgramLines = new List<Revvy__MnStrategy2__c> {
			new Revvy__MnStrategy2__c(
				PricingProgram__c = pricingProgram.Id
				, ApplicableProducts__c = applicableProducts
			)
		};
		insert pricingProgramLines;
	}

	@isTest static void test_pricing_program_line_product_selector() {
		final Revvy__MnStrategy1__c pricingProgram = [SELECT Id FROM Revvy__MnStrategy1__c WHERE ExternalId__c = 'STILargePackageProgram'];
		Revvy__MnStrategy2__c pricingProgramLine = [SELECT Id, ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		final String previousApplicableProducts = pricingProgramLine.ApplicableProducts__c;

		ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pricingProgramLine);
		ToroPricingProgramLineProductSelector controller = new ToroPricingProgramLineProductSelector(stdController);

		Integer expectedNumberOfSelectedProducts = [SELECT Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Type__c = 'Product'].size();
		System.assertEquals(expectedNumberOfSelectedProducts, controller.selectedProducts.size());

		// set to applicable products to 'All'
		controller.allProductsSelected = true;
		controller.toggleAllProducts();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assertEquals('All', pricingProgramLine.ApplicableProducts__c);

		// switch applicable products to previously selected
		controller.allProductsSelected = false;
		controller.toggleAllProducts();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assertEquals(previousApplicableProducts, pricingProgramLine.ApplicableProducts__c);

		// delete a product
		controller.toBeDeleted = pricingProgramLine.ApplicableProducts__c.split(',')[0];
		controller.deleteProduct();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assert(!pricingProgramLine.ApplicableProducts__c.contains(controller.toBeDeleted));

		Boolean containsDeletedProduct = false;
		for (ToroPricingProgramLineProductSelector.Wrapper selectedProduct : controller.selectedProducts) {
			if (selectedProduct.revvyId == controller.toBeDeleted) {
				containsDeletedProduct = true;
			}
		}
		System.assert(!containsDeletedProduct);

		// add a product
		Revvy__MnCatalogNode__c productToBeAdded = [SELECT Id, Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Id__c = :controller.toBeDeleted];
		controller.dummyHeader.SelectProduct__c = productToBeAdded.Id;
		controller.addProduct();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assert(pricingProgramLine.ApplicableProducts__c.contains(productToBeAdded.Revvy__Id__c));
	}
}