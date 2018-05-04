public with sharing class ToroPricingProgramProductSelector {

	public class Wrapper {
		// public boolean selected { get; set; }
		public String revvyId 		{ get; set; }
		public String productName 	{ get; set; }

		public Wrapper(REVVY__MnCatalogNode__c product) {
			this.revvyId     = product.REVVY__Id__c;
			this.productName = product.Name;
		}
	}

	private ApexPages.StandardController ctrl;
	private Id pricingProgramId;
	private String previouslySelectedProducts;

	public Revvy__MnStrategy1__c pricingProgram { get; set; } // Revvy__MnStrategy1__c -> Revvy__MnStrategy1__c

	public Boolean allProductsSelected 			{ get; set; }
	public List<Wrapper> selectedProducts 		{ get; set; }
	public String toBeDeleted 					{ get; set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroPricingProgramProductSelector(ApexPages.StandardController controller){
		ctrl             = controller;
		pricingProgramId = controller.getRecord().Id;
		selectedProducts = new List<wrapper>();
		loadPageVariables();
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public void loadPageVariables() {
		this.selectedProducts.clear();
		pricingProgram = [
			SELECT
				Id, r.Name
				, r.SelectProduct__c, r.ApplicableProductsLong__c
			FROM
				Revvy__MnStrategy1__c r
			WHERE
				Id = :pricingProgramId
		];

		if (pricingProgram.ApplicableProductsLong__c == 'All') {
			this.allProductsSelected = true;
		}

		else {
			this.allProductsSelected = false;
		}

		if (String.isNotBlank(pricingProgram.ApplicableProductsLong__c)) {
			final List<String> productExtIds = pricingProgram.ApplicableProductsLong__c.split(',');

			List<Revvy__MnCatalogNode__c> catalogNodes = [
				SELECT
					Id, Revvy__Id__c, Name
				FROM
					Revvy__MnCatalogNode__c
				WHERE
					Revvy__Id__c IN :productExtIds
			];

			for (Revvy__MnCatalogNode__c product : catalogNodes) {
				selectedProducts.add(new Wrapper(product));
			}
		}
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public PageReference toggleAllProducts() {
		if (allProductsSelected) {
			previouslySelectedProducts = pricingProgram.ApplicableProductsLong__c;
			pricingProgram.ApplicableProductsLong__c = 'All';
			update pricingProgram;
		}

		else {
			pricingProgram.ApplicableProductsLong__c = previouslySelectedProducts;
			update pricingProgram;
		}

		loadPageVariables();
		return null;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public void addProduct() {
		List<Revvy__MnCatalogNode__c> products = [
			SELECT
				Name, Revvy__Id__c
			FROM
				Revvy__MnCatalogNode__c
			WHERE
				Id = :pricingProgram.SelectProduct__c
		];

		Set<String> newProdSet = new Set<String>{products[0].revvy__Id__c};
		List<String> prodList = new List<String>();
		if (pricingProgram.ApplicableProductsLong__c != null) {
			prodList = pricingProgram.ApplicableProductsLong__c.split(',');
		}

		newProdSet.addAll(prodList);
		newProdSet.remove('All');
		prodList = new List<String>(newProdSet);
		pricingProgram.ApplicableProductsLong__c = String.join(prodList, ',');
		update pricingProgram;
		loadPageVariables();

	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public PageReference deleteProduct() {
		if (String.isNotBlank(pricingProgram.ApplicableProductsLong__c)) {
			Set<String> existingProducts = new Set<String>(pricingProgram.ApplicableProductsLong__c.split(','));
			existingProducts.remove(toBeDeleted);
			List<String> newProdList = new List<String>(existingProducts);
			pricingProgram.ApplicableProductsLong__c = String.join(newProdList, ',');
			update pricingProgram;
			loadPageVariables();
		}

		return null;
	}

	/*
	public PageReference cancel() {
		PageReference pg = new PageReference('/'+pricingProgramId);
		pg.setRedirect(true);
		return pg;
	}
	*/
}