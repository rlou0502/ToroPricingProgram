public with sharing class ToroCacheManager {
	public static final string constPartitionName='local.PricingProgram';
	
	public static Revvy__MnStrategy1__c getPricingProgram(String externalId) {
		system.debug('ToroCacheManager  ToroCacheManager.constPartitionName = ' + ToroCacheManager.constPartitionName);
		system.debug('ToroCacheManager  Cache.Session.getPartition(ToroCacheManager.constPartitionName) = ' + Cache.Session.getPartition(ToroCacheManager.constPartitionName));
		system.debug('ToroCacheManager  ToroPricingProgramCache.class = ' + ToroPricingProgramCache.class);
		system.debug('ToroCacheManager  externalId = ' + externalId);
		return (Revvy__MnStrategy1__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramCache.class, externalId);	
	}
	
	public static REVVY__MnQuote__c refreshQuote(Id quoteId) {
		system.debug(logginglevel.info, 'initializeQuoteHeader -- getQuote-------'+quoteId);
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).remove(ToroQuoteCache.class, quoteId);	
		REVVY__MnQuote__c q = (REVVY__MnQuote__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroQuoteCache.class, quoteId);	
		system.debug('initializeQuoteHeader --refresh quote-------' + q);
		return q;	
	}   
	public static REVVY__MnQuote__c getQuote(Id quoteId) {
		system.debug(logginglevel.info, 'initializeQuoteHeader -- getQuote-------'+quoteId);
		REVVY__MnQuote__c q = (REVVY__MnQuote__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroQuoteCache.class, quoteId);	
		system.debug('initializeQuoteHeader --refresh quote-------' + q);
		return q;	
	}  
	
}