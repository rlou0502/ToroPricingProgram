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
	
	public static List<ToroSelectOption> getPricingProgramEligibility(String quoteId) {
		system.debug('getPricingProgramEligibility from cache');
		return (List<ToroSelectOption>) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramEligibility.class, quoteId);		
	}
	public static List<ToroSelectOption> refreshPricingProgramEligibility(String quoteId) {
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).remove(ToroPricingProgramEligibility.class, quoteId);
		return (List<ToroSelectOption>) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramEligibility.class, quoteId);		
	}
	
	public static Revvy__MnStrategy1__c getPricingProgram(String externalId) {
		if(String.isBlank(externalId)) {
			return null;	
		}
		system.debug('ToroCacheManager  ToroCacheManager.constPartitionName = ' + ToroCacheManager.constPartitionName);
		system.debug('ToroCacheManager  Cache.Session.getPartition(ToroCacheManager.constPartitionName) = ' + Cache.Session.getPartition(ToroCacheManager.constPartitionName));
		system.debug('ToroCacheManager  ToroPricingProgramCache.class = ' + ToroPricingProgramCache.class);
		system.debug('ToroCacheManager  externalId = ' + externalId);
		if(externalId.contains(';')) {
			ToroPricingProgramData ppd = new ToroPricingProgramData(externalId); 
			externalId = ppd.externalId;
		}
		system.debug('ToroCacheManager  externalId = ' + externalId);	
		return (Revvy__MnStrategy1__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(ToroPricingProgramCache.class, externalId);	
	}
	
	public static void refreshAllPricingPrograms() {
		List<Revvy__MnStrategy1__c> rebates = [Select ExternalId__c From Revvy__MnStrategy1__c ];
		for(Revvy__MnStrategy1__c pp : rebates) {
			if(String.isNotBlank(pp.ExternalId__c) && pp.ExternalId__c.isAlphanumeric()) {
				Cache.Session.getPartition(ToroCacheManager.constPartitionName).remove(ToroPricingProgramCache.class, pp.ExternalId__c);
			}		
		} 
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