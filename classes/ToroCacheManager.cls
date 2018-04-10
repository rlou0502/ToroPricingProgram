public with sharing class ToroCacheManager {
	public static final string constPartitionName='local.PricingProgram';
	
	public static Map<Id, decimal> getPercentOffMSRP() {
		if(Cache.Session.getPartition(ToroCacheManager.constPartitionName).get('PercentOffMSRP') == null) {
			Cache.Session.getPartition(ToroCacheManager.constPartitionName).put('PercentOffMSRP', new Map<Id, decimal>());	
		}
		return (Map<Id, decimal>) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get('PercentOffMSRP');	
	}
	public static  void setPercentOffMSRP(Map<Id, decimal> msrpData) {		
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).put('PercentOffMSRP', msrpData);		
	}
	
	public static Map<String,Decimal> getPerformancePartMap() {
		return (Map<String,Decimal>) Cache.Org.getPartition(ToroCacheManager.constPartitionName).get(ToroPerformancePartCache.class, 'Commercial');		
	}
	public static Toro_PricingProgram__c getPricingProgram(String externalId) {
		system.debug('ToroCacheManager  ToroCacheManager.constPartitionName = ' + ToroCacheManager.constPartitionName);
		system.debug('ToroCacheManager  Cache.Session.getPartition(ToroCacheManager.constPartitionName) = ' + Cache.Session.getPartition(ToroCacheManager.constPartitionName));
		system.debug('ToroCacheManager  ToroPricingProgramCache.class = ' + ToroPricingProgramCache.class);
		system.debug('ToroCacheManager  externalId = ' + externalId);
		return (Toro_PricingProgram__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramCache.class, externalId);	
	}
	
	public static REVVY__MnQuote__c refreshQuote(Id quoteId) {
		REVVY__MnQuote__c q = null;
		if(String.isNotBlank(quoteId)){
			system.debug(logginglevel.info, 'initializeQuoteHeader -- getQuote-------'+quoteId);
			Cache.Session.getPartition(ToroCacheManager.constPartitionName).remove(quoteId);	
			q = ToroCacheManager.getQuote(quoteId);
			system.debug('initializeQuoteHeader --refresh quote-------' + q);
			if(ToroCacheManager.getPercentOffMSRP() != null) {
				//Cache.Session.getPartition(ToroCacheManager.constPartitionName).put('PercentOffMSRP', new Map<Id, decimal>());	
			}
			
		}
		return q;	
	}   
	public static REVVY__MnQuote__c getQuote(Id quoteId) {
		return ToroQuoteCache.getQuote(quoteId);	
	} 
	public static void putQuote(Revvy__MnQuote__c quote) {
		ToroQuoteCache.putQuote(quote);		
	}   
	
}