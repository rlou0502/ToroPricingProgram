public class ToroPriceProgramFactory {
	public static final string constPartitionName='local.PricingProgram';
	public static final string constPricingProgramKey='pricingProgramHelpers';
	
	public static ToroPricingProgram newPricingProgramInstance(String className) {
		system.debug('newPricingProgramInstance=' + className);
		ToroPricingProgram pp = null;
		if(String.isNotBlank(classname)) {
			Type t = Type.forName(className);
            if(t != null){
            	pp = (ToroPricingProgram)t.newInstance();    
            } else {
                pp = new ToroDefaultPricingProgramHelper();
            }  		
		} else {
			pp = new ToroDefaultPricingProgramHelper();
		}
		return pp;	
	} 
	public static void refreshAllPricingProgramHelpers() {
		Cache.Org.getPartition(ToroCacheManager.constPartitionName).remove(ToroPricingProgramHelperCache.class, constPricingProgramKey);
	}
	
	public static ToroPricingProgram getPricingProgramHelperInstance(String pricingProgram) {
		system.debug('getPricingProgramHelper=' + constPricingProgramKey);
		system.debug('getPricingProgramHelperpricingProgram=' + pricingProgram);
		Map<String, ToroPricingProgram> pricingProgramHelperMap = (Map<String, ToroPricingProgram>) Cache.Org.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramHelperCache.class, constPricingProgramKey);		
		if(!pricingProgramHelperMap.containsKey(pricingProgram)) {
			pricingProgram = 'defaultPricingProgram';
		}
		return (ToroPricingProgram) pricingProgramHelperMap.get(pricingProgram);
	}
	
	public static ToroPricingProgram getPricingProgramHelper(String pricingProgram)  {
		Toro_PricingProgramHelperFactory__c ppf = Toro_PricingProgramHelperFactory__c.getInstance(pricingProgram);	
		return ToroPriceProgramFactory.newPricingProgramInstance(ppf.ClassName__c);
	}
    
}