public with sharing class ToroPricingProgramHelperCache implements Cache.CacheBuilder {
	public Object doLoad(String pricingProgramHelper) {
        //Cache.OrgPartition orgPart = Cache.Org.getPartition(constPartitionName);
		List<Toro_PricingProgramHelperFactory__c> pricingProgramSettings = Toro_PricingProgramHelperFactory__c.getAll().values();
		Map<String, ToroPricingProgram> pricingProgramHelperMap = new Map<String, ToroPricingProgram>();
		for(Toro_PricingProgramHelperFactory__c pp : pricingProgramSettings) {
			system.debug(pp);
			ToroPricingProgram tpp = ToroPriceProgramFactory.newPricingProgramInstance(pp.ClassName__c);
			pricingProgramHelperMap.put(pp.PricingProgramName__c, tpp);								
		} 
		pricingProgramHelperMap.put('defaultPricingProgram', new ToroDefaultPricingProgramHelper());				
		return pricingProgramHelperMap;
    }    
    
}