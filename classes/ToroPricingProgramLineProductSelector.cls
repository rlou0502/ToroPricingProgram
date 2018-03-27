public with sharing class ToroPricingProgramLineProductSelector {

	public class Wrapper {
		public String revvyId 		{ get; set; }
		public String productName 	{ get; set; }

		public Wrapper(REVVY__MnCatalogNode__c product) {
			this.revvyId     = product.REVVY__Id__c;
			this.productName = product.Name;
		}
	}

	private ApexPages.StandardController ctrl;
	private Toro_PricingProgramLine__c pricingProgramLine; // Revvy__MnStrategy2__c -> Toro_PricingProgramLine__c
	private Id pricingProgramLineId;
	private String previouslySelectedProducts;

	public Boolean allProductsSelected 						{ get; set; }
	public List<Wrapper> selectedProducts 					{ get; private set; }
	public String toBeDeleted 								{ get; set; }
	public REVVY__MnCatalogNode__c dummyProduct 			{ get; set; }
	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroPricingProgramLineProductSelector(ApexPages.StandardController controller) {
		ctrl                 = controller;
		pricingProgramLineId = controller.getRecord().Id;
		selectedProducts     = new List<wrapper>();
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
		pricingProgramLine = [
			SELECT
				PricingProgram__c, ApplicableProducts__c
			FROM
				Toro_PricingProgramLine__c
			WHERE
				Id = :pricingProgramLineId
		];

		this.dummyProduct = new REVVY__MnCatalogNode__c();

		if (pricingProgramLine.ApplicableProducts__c == 'All') {
			this.allProductsSelected = true;
		}

		else {
			this.allProductsSelected = false;
		}

		if (String.isNotBlank(pricingProgramLine.ApplicableProducts__c)) {
			final List<String> productExtIds = pricingProgramLine.ApplicableProducts__c.split(',');
			List<REVVY__MnCatalogNode__c> catalogNodes = [
				SELECT
					REVVY__Id__c, Name
				FROM
					REVVY__MnCatalogNode__c
				WHERE
					REVVY__Id__c IN :productExtIds];

			for (REVVY__MnCatalogNode__c product : catalogNodes) {
				selectedProducts.add(new Wrapper(product));
			}
		}
	}

	public PageReference toggleAllProducts() {
		if (allProductsSelected) {
			previouslySelectedProducts = pricingProgramLine.ApplicableProducts__c;
			pricingProgramLine.ApplicableProducts__c = 'All';
			update pricingProgramLine;
		}

		else {
			pricingProgramLine.ApplicableProducts__c = previouslySelectedProducts;
			update pricingProgramLine;
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
		List<REVVY__MnCatalogNode__c> products = [
			SELECT
				Name, REVVY__Id__c
			FROM
				REVVY__MnCatalogNode__c
			WHERE
				Id = :dummyProduct.REVVY__Parent__c
		];

		Set<String> newProdSet = new Set<String> { products[0].REVVY__Id__c };
		List<String> prodList = new List<String>();
		if (pricingProgramLine.ApplicableProducts__c != null) {
			prodList = pricingProgramLine.ApplicableProducts__c.split(',');
		}

		newProdSet.addAll(prodList);
		newProdSet.remove('All');
		prodList = new List<String>(newProdSet);
		pricingProgramLine.ApplicableProducts__c = String.join(prodList, ',');
		update pricingProgramLine;
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
		if (String.isNotBlank(pricingProgramLine.ApplicableProducts__c)){
			Set<String> existingProducts = new Set<String>(pricingProgramLine.ApplicableProducts__c.split(','));
			existingProducts.remove(toBeDeleted);
			List<String> newProdList = new List<String>(existingProducts);
			pricingProgramLine.ApplicableProducts__c = String.join(newProdList, ',');
			update pricingProgramLine;
			loadPageVariables();
		}

		return null;
	}
}