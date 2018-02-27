public with sharing class ToroCacheManager {
	public static final string constPartitionName='local.PricingProgram';
	public static final String constCachedSetupFee = 'setupFee';
	public static decimal getSetupFee() {
		decimal setupFee = null;
		system.debug(logginglevel.info, 'entering getSetupFee');
		if(Cache.Session.getPartition(ToroCachemanager.constPartitionName) != null){
			system.debug(logginglevel.info, '++++getSetupFee =' + Cache.Session.getPartition(ToroCachemanager.constPartitionName).get(ToroCachemanager.constCachedSetupFee));
    		setupFee = (decimal) Cache.Session.getPartition(ToroCachemanager.constPartitionName).get(ToroCachemanager.constCachedSetupFee);		
    	} else {
    		//need to get it from first quote, if not exist, then pricing program
    	}	
    	return setupFee;
	}  
	public static void setSetupFee(decimal fee) {
		if(!Cache.Session.getPartition(ToroCachemanager.constPartitionName).contains(ToroCachemanager.constCachedSetupFee)){
    		Cache.Session.getPartition(ToroCachemanager.constPartitionName).put(ToroCachemanager.constCachedSetupFee, fee, 3600, Cache.Visibility.ALL, true);		
    	}	
	}  
}