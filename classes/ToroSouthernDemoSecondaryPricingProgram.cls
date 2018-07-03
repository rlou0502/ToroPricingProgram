public class ToroSouthernDemoSecondaryPricingProgram extends ToroSecondaryPricingProgram {
	private Set<String> pricingProgramSet = new Set<String>();
	public Map<String, String> loadModelIdChartABPricingProgramMap(String pricingProgram) {
		system.debug(logginglevel.info, 'getAllowSupportPlus pricingProgram=' + pricingProgram);
		
		Map<String, String> modelIdPricingProgramMap = new Map<String, String>();
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		pricingProgramSet.add(ppd.externalId);
		system.debug(logginglevel.info, 'getAllowSupportPlus pricingProgram=' + ppd.externalId);
		List<Revvy__MnStrategy1__c> childrenPricingProgram = [Select Id, ExternalID__c, ApplicableProductsLong__c from Revvy__MnStrategy1__c where Parent_program__r.externalID__c = :ppd.externalId];
		for(Revvy__MnStrategy1__c pp : childrenPricingProgram) {
			pricingProgramSet.add(pp.ExternalID__c);
			if(String.isNotBlank(pp.ApplicableProductsLong__c)) {
				String[] parts = pp.ApplicableProductsLong__c.split(',');
				for(String p : parts) {
					modelIdPricingProgramMap.put(p, pp.ExternalID__c);	
				}
			}
		}
		system.debug('primary pp =' + ppd.externalId);
		Revvy__MnStrategy1__c southernDemo = ToroCacheManager.getPricingProgram(ppd.externalId);
		if(String.isNotBlank(southernDemo.ApplicableProductsLong__c)) {
			system.debug('primary ApplicableProductsLong__c =' + southernDemo.ApplicableProductsLong__c);
			String[] parts = southernDemo.ApplicableProductsLong__c.split(',');
			for(String p : parts) {
				modelIdPricingProgramMap.put(p, southernDemo.ExternalID__c);	
			}
		}
		return modelIdPricingProgramMap;	
	}
	
	public override decimal retrieveRebatePercentBasedOnBlendedDNet(Revvy__MnStrategy4__c qi, decimal dnetPercent, String ppExtId, String primaryExtId) {
		if(dnetPercent == null) {
			return 0;	
		}
		Map<String, String> model2pp = loadModelIdChartABPricingProgramMap(ppExtId);
		if(model2pp.containsKey(qi.Product_Id__c)) {
			system.debug('ToroSouthernDemoSecondaryPricingProgram 1');
			//qi.Pricing_Program__c=model2pp.get(qi.Product_Id__c);
			return retrieveRebatePercent(dnetPercent, model2pp.get(qi.Product_Id__c));		
		} else {
			system.debug('ToroSouthernDemoSecondaryPricingProgram 3');
			return 0;
		}
		
	}    
}