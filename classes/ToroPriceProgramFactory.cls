public class ToroPriceProgramFactory {
	public static final string constPartitionName='local.PricingProgram';
	public static final string constPricingProgramKey='pricingProgramHelpers';
	
	public static ToroPricingProgram newPricingProgramInstance(String className) {
		ToroPricingProgram pp = null;
		if(String.isNotBlank(classname)) {
			Type t = Type.forName(className);
        	pp = (ToroPricingProgram)t.newInstance();	
		} else {
			pp = new ToroDefaultPricingProgramHelper();
		}
		return pp;	
	} 
	public static void removeAllPricingProgramHelpers() {
		//Toro_PricingProgramHelperFactory__c
		Cache.OrgPartition orgPart = Cache.Org.getPartition(constPartitionName);
		Set<String> keys = orgPart.getKeys();
		for(String key : keys) {
			orgPart.remove(key);	
		}
	}
	public static String generateHash(String inputString) {
	    Blob targetBlob = Blob.valueOf(inputString);
	    Blob hash = Crypto.generateDigest('SHA1', targetBlob);
	    return EncodingUtil.convertToHex(hash);
	}
	public static void initPricingProgramHelpers() {
		Cache.OrgPartition orgPart = Cache.Org.getPartition(constPartitionName);
		List<Toro_PricingProgramHelperFactory__c> pricingProgramSettings = Toro_PricingProgramHelperFactory__c.getAll().values();
		Map<String, ToroPricingProgram> pricingProgramHelperMap = new Map<String, ToroPricingProgram>();
		for(Toro_PricingProgramHelperFactory__c pp : pricingProgramSettings) {
			system.debug(pp);
			ToroPricingProgram tpp = ToroPriceProgramFactory.newPricingProgramInstance(pp.ClassName__c);
			pricingProgramHelperMap.put(pp.PricingProgramName__c, tpp);				
				
		} 
		pricingProgramHelperMap.put('defaultPricingProgram', new ToroDefaultPricingProgramHelper());	
			
		orgPart.put(constPricingProgramKey, pricingProgramHelperMap);	
	}
	public static ToroPricingProgram getPricingProgramHelper(String pricingProgram) {
		Cache.OrgPartition orgPart = Cache.Org.getPartition(constPartitionName);
		Map<String, ToroPricingProgram> pricingProgramHelperMap = new Map<String, ToroPricingProgram>();
		system.debug('-------------constPricingProgramKey=' + constPricingProgramKey);
		system.debug('-------------orgPart=' + orgPart);
		if(!orgPart.contains(constPricingProgramKey)) {
			system.debug('-------------before initPricingProgramHelpers');
			initPricingProgramHelpers();		
		}
		pricingProgramHelperMap=(Map<String, ToroPricingProgram>)orgPart.get(constPricingProgramKey);
		if(!pricingProgramHelperMap.containsKey(pricingProgram)) {
			pricingProgram = 'defaultPricingProgram';
		}
		return (ToroPricingProgram) pricingProgramHelperMap.get(pricingProgram);
	}
    
}