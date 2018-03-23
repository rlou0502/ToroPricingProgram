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

	@isTest static void test_constructor() {
		final Revvy__MnStrategy1__c pricingProgram = [SELECT Id FROM Revvy__MnStrategy1__c WHERE ExternalId__c = 'STILargePackageProgram'];
		Revvy__MnStrategy2__c pricingProgramLine = [SELECT Id, ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		final String previousApplicableProducts = pricingProgramLine.ApplicableProducts__c;

		ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(pricingProgramLine);
		ToroPricingProgramLineProductSelector controller = new ToroPricingProgramLineProductSelector(stdController);

		Integer expectedNumberOfSelectedProducts = [SELECT Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Type__c = 'Product'].size();
		System.assertEquals(expectedNumberOfSelectedProducts, controller.selectedProducts.size());

		// set to applicable products to 'All'
		controller.selectAllProducts = true;
		controller.toggleAllProducts();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assertEquals('All', pricingProgramLine.ApplicableProducts__c);

		// switch applicable products to previously selected
		controller.selectAllProducts = false;
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
			if (selectedProduct.selected && selectedProduct.prod == controller.toBeDeleted) {
				containsDeletedProduct = true;
			}
		}
		System.assert(!containsDeletedProduct);

		// add a product
		controller.dummyHeader.SelectProduct__c = [SELECT Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Revvy__Id__c = :controller.toBeDeleted].Revvy__Id__c;
		controller.addProduct();
		pricingProgramLine = [SELECT ApplicableProducts__c FROM Revvy__MnStrategy2__c WHERE PricingProgram__c = :pricingProgram.Id LIMIT 1];
		System.assert(pricingProgramLine.ApplicableProducts__c.contains(controller.dummyHeader.SelectProduct__c));
	}
}