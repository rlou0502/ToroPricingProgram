public with sharing class ToroPricingProgramProdSel {
	private static final String PRICING_PROGRAM_SOBJ_NAME = 'REVVY__MnStrategy1__c';
	private static final String PRICING_PROGRAM_LINE_SOBJ_NAME = 'REVVY__MnStrategy2__c';


	public class Wrapper {
		// public boolean selected { get; set; }
		public String revvyId 		{ get; set; }
		public String productName 	{ get; set; }

		public Wrapper(REVVY__MnCatalogNode__c product) {
			this.revvyId     = product.REVVY__Id__c;
			this.productName = product.Name;
		}
	}

	private Id recordId;
	private String previouslySelectedProducts;
	private String sObjName;

	public REVVY__MnStrategy1__c pricingProgram { get; set; }
	public REVVY__MnStrategy2__c pricingProgramLine { get; set; }

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
	public ToroPricingProgramProdSel(ApexPages.StandardController controller){
		SObject recObj = controller.getRecord();

		if (recObj instanceOf REVVY__MnStrategy1__c) {
			this.sObjName = PRICING_PROGRAM_SOBJ_NAME;
		} else {
			this.sObjName = PRICING_PROGRAM_LINE_SOBJ_NAME;
		}

		this.recordId = controller.getRecord().Id;
		this.selectedProducts = new List<wrapper>();
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
		final String selectClause = 'SELECT Id, Name, SelectProduct__c, ApplicableProductsLong__c';
		final String fromClause = ' FROM ' + this.sObjName;
		final String whereClause = ' WHERE Id = \'' + this.recordId + '\'';
		final String queryString = selectClause + fromClause + whereClause;

		this.pricingProgram = Database.query(queryString);
		if (pricingProgram.ApplicableProductsLong__c == 'All') {
			this.allProductsSelected = true;
		} else {
			this.allProductsSelected = false;
		}

		if (String.isNotBlank(pricingProgram.ApplicableProductsLong__c)) {
			final List<String> productExtIds = pricingProgram.ApplicableProductsLong__c.split(',');
			List<REVVY__MnCatalogNode__c> catalogNodes = [
				SELECT
					Id, REVVY__Id__c, Name
				FROM
					REVVY__MnCatalogNode__c
				WHERE
					REVVY__Id__c IN :productExtIds
			];

			for (REVVY__MnCatalogNode__c product : catalogNodes) {
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
		List<REVVY__MnCatalogNode__c> products = [
			SELECT
				Name, REVVY__Id__c
			FROM
				REVVY__MnCatalogNode__c
			WHERE
				Id = :pricingProgram.SelectProduct__c
		];

		Set<String> newProdSet = new Set<String>{products[0].REVVY__Id__c};
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
		PageReference pg = new PageReference('/'+recordId);
		pg.setRedirect(true);
		return pg;
	}
	*/
}