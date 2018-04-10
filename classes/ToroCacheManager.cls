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
		system.debug(logginglevel.info, 'initializeQuoteHeader -- getQuote-------'+quoteId);
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).remove(ToroQuoteCache.class, quoteId);	
		REVVY__MnQuote__c q = (REVVY__MnQuote__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroQuoteCache.class, quoteId);	
		system.debug('initializeQuoteHeader --refresh quote-------' + q);
		if(ToroCacheManager.getPercentOffMSRP() != null) {
			//Cache.Session.getPartition(ToroCacheManager.constPartitionName).put('PercentOffMSRP', new Map<Id, decimal>());	
		}
		return q;	
	}   
	public static REVVY__MnQuote__c getQuote(Id quoteId) {
		system.debug(logginglevel.info, 'initializeQuoteHeader -- getQuote-------'+quoteId);
		REVVY__MnQuote__c q = (REVVY__MnQuote__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroQuoteCache.class, quoteId);	
		system.debug('initializeQuoteHeader --refresh quote-------' + q);
		return q;	
	} 
	public static REVVY__MnQuote__c setQuote(Revvy__MnQuote__c quote) {
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).put(quote.Id, quote);	
		return quote;	
	}   
	
}