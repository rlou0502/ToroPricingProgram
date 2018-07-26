@isTest
private class ToroNationalAccountPricingProgramHTest {
	
	@testSetup static void setupData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		
		Revvy__MnSequenceGen__c sequence = new Revvy__MnSequenceGen__c(Revvy__ObjectName__c='MnQuoteItem__c', REVVY__CurrentValue__c=1);
		insert sequence;
		
		
	}

	@isTest static void test_get_field_methods() {
		List<REVVY__MnCatalogNode__c> products = [select id from REVVY__MnCatalogNode__c];
		String[] tiers = new String[]{'Tier 1', 'Tier 2', 'Parts'};
		String[] productTypes = new String[]{'Finished Good', 'Semi-Finished Good', 'Non-Stock Material'};
		Integer index = 0;
		Integer ptIdx=0;
		for(REVVY__MnCatalogNode__c p: products) {
			p.Toro_Product_Tier__c = tiers[index++];
			index = Math.mod(index, tiers.size());
			p.Toro_Product_Type__c = productTypes[ptIdx++];	
			ptIdx = Math.mod(ptIdx, productTypes.size());
		}
		products[0].Toro_Product_Tier__c='Tier 3';
		update products;
		//Groundsmaster 4500/4700 Series
		List<REVVY__MnQuoteItem__c> quoteItems = [select id from REVVY__MnQuoteItem__c];
		quoteItems[0].Traction_Unit__c='Groundsmaster 4500/4700 Series';
		update quoteItems[0];
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.performancePartFlag=true;
		system.assert(tlpp.displaySetupFee());
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('GreenwayGolf;Standard');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}
	@isTest static void test_get_field_methods_2() {
		//04109
		List<REVVY__MnCatalogNode__c> products = [select id,REVVY__Id__c from REVVY__MnCatalogNode__c];
		String[] tiers = new String[]{'Tier 1', 'Tier 2', 'Parts'};
		Integer index = 0;
		for(REVVY__MnCatalogNode__c p: products) {
			if(p.REVVY__Id__c != '04109') {
				p.Toro_Product_Tier__c = tiers[index++];
				index = Math.mod(index, tiers.size());	
			} else {
				p.Toro_Product_Tier__c = 'Tier 3';
			}
			
			p.Toro_Product_Type__c = 'Semi-Finished Good';	
		}
		
		update products;
		//Groundsmaster 4500/4700 Series
		List<REVVY__MnQuoteItem__c> quoteItems = [select id from REVVY__MnQuoteItem__c];
		quoteItems[0].Traction_Unit__c='Groundsmaster 4500/4700 Series';
		update quoteItems[0];
		
		Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.performancePartFlag=true;
		system.assert(tlpp.displaySetupFee());
		List<ToroSelectOption> options = tlpp.retrievePricingMethodOptions();
		ToroPricingProgramData ppd = new ToroPricingProgramData('GreenwayGolf;Standard');
		tlpp.initialize(quote.Id);
		
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
		tlpp.quoteItems = tlpp.calculateRebateMargin(quote.Id, ppd.externalId, '% off MSRP', tlpp.quoteItems, false);
	}
	@isTest static void test_method_two() {
		ToroNationalAccountPricingProgramHelper tlpp = new ToroNationalAccountPricingProgramHelper();
		tlpp.displayPerformancePart();
		System.assert(tlpp.getQuoteFields() != null);
		System.assert(tlpp.getToroQuoteItemFields() != null);
		System.assert(tlpp.getToroQuoteItemUpdatableFields() != null);
		System.assert(tlpp.getToroQuoteItemSublineFields() != null);
		tlpp.getToroQuoteItemSublineUpdatableFields();
		System.assert(tlpp.getToroQuoteItemSummaryFields() != null);
		tlpp.retrieveDemoPricingProgramOptions();
	}
	
}