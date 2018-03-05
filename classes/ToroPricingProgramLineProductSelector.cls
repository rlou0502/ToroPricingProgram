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
	public Id recordId 										{ get; set; }
	public List<Wrapper> selectedProducts 					{ get; set; }

	public String toBeDeleted 								{ get; set; }
	public String previousSelectedProduct 					{ get; set; }

	public Boolean selectAllProducts 						{ get; set; }
	public Toro_PricingProgram__c header 				 	{ get; set; }
	public Toro_PricingProgramLine__c pricingProgramLine 	{ get; set; }

	public REVVY__MnCatalogNode__c selectedProduct 			{ get; set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroPricingProgramLineProductSelector(ApexPages.StandardController controller) {
		ctrl             = controller;
		recordId         = controller.getRecord().Id;
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
		selectedProducts.clear();
		pricingProgramLine = [
			SELECT
				PricingProgram__c
				, ApplicableProducts__c
			FROM
				Toro_PricingProgramLine__c
			WHERE
				Id = :recordId
		];

		header = [
			SELECT
				Id
				, Name
				, SelectProduct__c
				, ExternalId__c
				, ApplicableProducts__c
			FROM
				Toro_PricingProgram__c
			WHERE
				Id = :pricingProgramLine.PricingProgram__c
		];

		if (String.isNotBlank(pricingProgramLine.ApplicableProducts__c)) {
			final List<String> productIds = header.ApplicableProducts__c.split(',');
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
		if (selectAllProducts) {
			previousSelectedProduct = header.ApplicableProducts__c;
			header.ApplicableProducts__c = 'All';
			update header;
		}

		else {
			header.ApplicableProducts__c = previousSelectedProduct;
			update header;
		}

		loadPageVariables();
		return null;
	}

	public PageReference deleteProduct() {
		if (String.isNotBlank(header.ApplicableProducts__c)){
			Set<String> existingProducts = new Set<String>(header.ApplicableProducts__c.split(','));
			existingProducts.remove(toBeDeleted);

			List<String> newProdList = new List<String>(existingProducts);
			header.ApplicableProducts__c = String.join(newProdList, ',');
			system.debug('-----header.ApplicableProducts__c--' + header.ApplicableProducts__c);
			update header;
			loadPageVariables();
		}

		return null;
	}

	public PageReference cancel() {
		PageReference pg = new PageReference('/'+recordId);
		pg.setRedirect(true);
		return pg;
	}

	public PageReference saveSelectedProduct() {
		REVVY__MnCatalogNode__c p = [SELECT Name, REVVY__Id__c FROM REVVY__MnCatalogNode__c WHERE Id = :header.SelectProduct__c];
		Set<String> newProdSet = new Set<String>{p.REVVY__Id__c};
		for(Wrapper w : selectedProducts) {
			if(w.selected) {
				newProdSet.add(w.prod);
			}
		}
		List<String> newProdList = new List<String>(newProdSet);
		header.ApplicableProducts__c = String.join(newProdList, ',');
		update header;
		return cancel();
	}

	public void addProduct() {
		List<REVVY__MnCatalogNode__c> products = [SELECT Name, REVVY__Id__c FROM REVVY__MnCatalogNode__c WHERE Id = :header.SelectProduct__c];
		Set<String> newProdSet = new Set<String>{products[0].REVVY__Id__c};
		List<String> prodList = new List<String>();
		if(header.ApplicableProducts__c != null) {
			prodList = header.ApplicableProducts__c.split(',');
		}

		newProdSet.addAll(prodList);
		newProdSet.remove('All');
		prodList = new List<String>(newProdSet);
		header.ApplicableProducts__c = String.join(prodList, ',');

		update header;
		loadPageVariables();
	}

	public void deleteItems() {
		Set<String> newProdSet = new Set<String>();
		for (Wrapper w : selectedProducts) {
			if (!w.selected) {
				newProdSet.add(w.prod);
			}
		}

		List<String> newProdList = new List<String>(newProdSet);
		header.ApplicableProducts__c = String.join(newProdList, ',');
		update header;
		loadPageVariables();
	}

	public PageReference allProducts() {
		header.ApplicableProducts__c = 'All';
		update header;
		return cancel();
	}
}