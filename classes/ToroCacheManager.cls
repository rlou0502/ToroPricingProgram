public with sharing class ToroCacheManager {
	public static final string constPartitionName='local.PricingProgram';
	public static final String constCachedSetupFee = 'setupFee';
	public static final String constCachedPerformancePart = 'performancePart';
	public static decimal getSetupFee() {
		decimal setupFee = null;
		system.debug(logginglevel.info, 'entering getSetupFee');
		if(Cache.Session.getPartition(ToroCacheManager.constPartitionName) != null){
			system.debug(logginglevel.info, '++++getSetupFee =' + Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroCacheManager.constCachedSetupFee));
    		setupFee = (decimal) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroCacheManager.constCachedSetupFee);		
    	} else {
    		//need to get it from first quote, if not exist, then pricing program
    	}	
    	return setupFee;
	}  
	public static void setSetupFee(decimal fee) {
		if(Cache.Session.getPartition(ToroCacheManager.constPartitionName) != null){
    		Cache.Session.getPartition(ToroCacheManager.constPartitionName).put(ToroCacheManager.constCachedSetupFee, fee, 3600, Cache.Visibility.ALL, true);		
    	}	
	}  
	public static boolean getPerformancePart() {
		boolean performancePart = false;
		
		if(Cache.Session.getPartition(ToroCacheManager.constPartitionName) != null){
			system.debug(logginglevel.info, '++++getPerformancePart =' + 
				Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroCacheManager.constCachedPerformancePart));
    		performancePart = (boolean) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroCacheManager.constCachedPerformancePart);		
    	} else {
    		//need to get it from first quote, if not exist, then pricing program
    	}	
    	return performancePart;
	}  
	public static void setPerformancePart(boolean performanceFee) {
		if(Cache.Session.getPartition(ToroCacheManager.constPartitionName) != null){
    		Cache.Session.getPartition(ToroCacheManager.constPartitionName).put(ToroCacheManager.constCachedPerformancePart, performanceFee, 3600, Cache.Visibility.ALL, true);		
    	}	
	}  
}