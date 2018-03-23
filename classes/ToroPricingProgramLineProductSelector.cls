public with sharing class ToroPricingProgramLineProductSelector {

	public class Wrapper {
		public Boolean selected { get; set; }
		public String prod 		{ get; set; }
		public String prodName 	{ get; set; }

		public Wrapper(Boolean selected, String prod, String prodName) {
			this.selected = selected;
			this.prod     = prod;
			this.prodName = prodName;
		}
	}

	private ApexPages.StandardController ctrl;
	public Id recordId 								{ get; set; }
	public List<Wrapper> selectedProducts 			{ get; set; }

	public String toBeDeleted 						{ get; set; }
	public String previousSelectedProduct 			{ get; set; }

	public Boolean allProductsSelected 				{ get; set; }
	public Revvy__MnStrategy1__c dummyHeader 		{ get; set; }
	public Revvy__MnStrategy2__c pricingProgramLine { get; set; }

	/**
	 *
	 * constructor
	 *
	 * @param  controller    standard controller for Revvy__MnStrategy2__c (Pricing Program Subline)
	 */
	public ToroPricingProgramLineProductSelector(ApexPages.StandardController controller) {
		ctrl             = controller;
		recordId         = controller.getRecord().Id;
		selectedProducts = new List<wrapper>();
		loadPageVariables();
	}

	/**
	 *
	 * initializes the pages with selected products
	 *
	 */
	public void loadPageVariables() {
		selectedProducts.clear();
		pricingProgramLine = [
			SELECT
				PricingProgram__c
				, ApplicableProducts__c
			FROM
				Revvy__MnStrategy2__c
			WHERE
				Id = :recordId
		];

		dummyHeader = new Revvy__MnStrategy1__c(); // this is created so we can use "SelectProduct__c (REVVY__MnCatalogNode__c)
													// in input field in visualforce

		if (pricingProgramLine.ApplicableProducts__c == 'All') {
			allProductsSelected = true;
		}

		else if (String.isNotBlank(pricingProgramLine.ApplicableProducts__c)) {
			allProductsSelected = false;
			final List<String> productIds = pricingProgramLine.ApplicableProducts__c.split(',');
			List<REVVY__MnCatalogNode__c> catalogNodes = [
				SELECT
					REVVY__Id__c, Name
				FROM
					REVVY__MnCatalogNode__c
				WHERE
					REVVY__Id__c in :productIds];
			for (REVVY__MnCatalogNode__c p : catalogNodes) {
				selectedProducts.add(new Wrapper(false, p.REVVY__Id__c, p.Name));
			}
		}
	}

	public PageReference toggleAllProducts() {
		if (allProductsSelected) {
			previousSelectedProduct = pricingProgramLine.ApplicableProducts__c;
			pricingProgramLine.ApplicableProducts__c = 'All';
			update pricingProgramLine;
		}

		else {
			pricingProgramLine.ApplicableProducts__c = previousSelectedProduct;
			update pricingProgramLine;
		}

		loadPageVariables();
		return null;
	}

	/**
	 *
	 * delete the product by Revvy__Id__c "toBeDeleted"
	 *
	 * @return refresh the page
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

	/**
	 *
	 * redirect back to pricing program line
	 *
	 * @return pricing program line detail page
	 */
	public PageReference cancel() {
		PageReference pg = new PageReference('/' + recordId);
		pg.setRedirect(true);
		return pg;
	}

	/**
	 *
	 * add a product specified by SFID (dummyHeader.SelectProduct__c)
	 *
	 */
	public void addProduct() {
		List<REVVY__MnCatalogNode__c> products = [SELECT Name, REVVY__Id__c FROM REVVY__MnCatalogNode__c WHERE Id = :dummyHeader.SelectProduct__c];
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
}