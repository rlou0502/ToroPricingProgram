public with sharing class ToroPricingProgramProductSelector {
	public class Wrapper {
		public Wrapper(boolean b, String p, String name) {
			selected = b;
			prod = p;
			prodName = name;
		}
		public boolean selected { get; set; }
		public String prod { get; set; }
		public String prodName { get; set; }
	}
	ApexPages.StandardController ctrl;
	public Id recordId { get; set; }
	public String toBeDeleted {get; set;}
	public String previousSelectedProduct { get; set;}
	public List<Wrapper> selectedProducts { get; set;}
	public boolean selectAllProducts {get; set;}
	public Revvy__MnStrategy1__c header { get; set; }
	public ToroPricingProgramProductSelector(ApexPages.StandardController controller){
		ctrl = 	controller;
		recordId = controller.getRecord().Id;
		selectedProducts = new List<wrapper>();
		loadPageVariables();
	}
	public PageReference toggleAllProducts() {
		system.debug('------selectAllProducts-----' + selectAllProducts);
		if(selectAllProducts) {
			previousSelectedProduct = header.ApplicableProducts__c;
			header.ApplicableProducts__c = 'All';
			update header;
		} else {
			header.ApplicableProducts__c = previousSelectedProduct;
			update header;
		}
		//header.ApplicableProducts__c = 'All';
		//update header;
		loadPageVariables();
		return null;
	}
	public PageReference deleteProduct() {
		//
		system.debug('-----toBeDeleted--' + toBeDeleted);
		if(String.isNotBlank(header.ApplicableProducts__c)){
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
	public void loadPageVariables() {
		selectedProducts.clear();
		header = [SELECT id, r.Name, r.SelectProduct__c, r.ExternalId__c, r.ApplicableProducts__c FROM Revvy__MnStrategy1__c r WHERE Id = :recordId];

		if (header.ApplicableProducts__c == 'All') {
			selectAllProducts = true;
		}

		else if (String.isNotBlank(header.ApplicableProducts__c)) {
			selectAllProducts = false;
			List<String> prodList =header.ApplicableProducts__c.split(',');
			List<Revvy__MnCatalogNode__c> catalogNodes = [SELECT Id, Revvy__Id__c, name FROM Revvy__MnCatalogNode__c where Revvy__Id__c in :prodList];

			for(Revvy__MnCatalogNode__c p : catalogNodes) {
				selectedProducts.add(new wrapper(false, p.revvy__Id__c, p.name));
			}
			system.debug('-----selectedProducts--' + selectedProducts);
		}
	}
	public PageReference cancel() {
		PageReference pg = new PageReference('/'+recordId);
		pg.setRedirect(true);
		return pg;
	}
	public PageReference saveSelectedProduct() {
		Revvy__MnCatalogNode__c p = [SELECT Name, Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Id = :header.SelectProduct__c];
		Set<String> newProdSet = new Set<String>{p.revvy__Id__c};
		for(Wrapper w : selectedProducts) {
			if(w.selected) {
				newProdSet.add(w.prod);
			}
		}
		List<String> newProdList = new List<String>(newProdSet);
		header.ApplicableProducts__c = String.join(newProdList, ',');
		update header;
		system.debug('product = ' + p.name + ' id =' + p.revvy__Id__c);
		return cancel();
	}

	public void addProduct() {
		List<Revvy__MnCatalogNode__c> products = [SELECT Name, Revvy__Id__c FROM Revvy__MnCatalogNode__c WHERE Id = :header.SelectProduct__c];

		Set<String> newProdSet = new Set<String>{products[0].revvy__Id__c};
		List<String> prodList = new List<String>();
		if(header.ApplicableProducts__c != null) {
			prodList =header.ApplicableProducts__c.split(',');
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
		for(Wrapper w : selectedProducts) {
			if(!w.selected) {
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