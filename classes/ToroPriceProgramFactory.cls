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
	
	public static ToroSecondaryPricingProgram newSecondaryPricingProgramInstance(String className) {
		system.debug('newSecondaryPricingProgramInstance=' + className);
		ToroSecondaryPricingProgram pp = null;
		if(String.isNotBlank(classname)) {
			Type t = Type.forName(className);
			system.debug('newSecondaryPricingProgramInstance type=' + t);
            if(t != null){
            	pp = (ToroSecondaryPricingProgram)t.newInstance();    
            } else {
                pp = new ToroSecondaryPricingProgram();
            }  		
		} else {
			pp = new ToroSecondaryPricingProgram();
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
		system.debug('getPricingProgramHelper=' + pricingProgram);
		String className = null;
		if(String.isNotBlank(pricingProgram)) {
			Toro_PricingProgramHelperFactory__c ppf = Toro_PricingProgramHelperFactory__c.getInstance(pricingProgram);	
			system.debug('getPricingProgramHelper ppf=' + ppf);
			if(ppf != null) {
				className = ppf.ClassName__c;	
			}	
		}
		
		return ToroPriceProgramFactory.newPricingProgramInstance(className);
	}
	
	public static ToroSecondaryPricingProgram getSecondaryPricingProgram(String pricingProgram)  {
		List<Toro_SecondaryPricingProgramFactory__mdt> secondary = [Select DeveloperName,ClassName__c From Toro_SecondaryPricingProgramFactory__mdt where DeveloperName = :pricingProgram];
		String className = null;
		if(secondary.size() > 0) {
			className = secondary[0].ClassName__c;	
		} 
		return ToroPriceProgramFactory.newSecondaryPricingProgramInstance(className); 
		
	}
    
}