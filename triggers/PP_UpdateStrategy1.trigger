trigger PP_UpdateStrategy1 on REVVY__MnStrategy1__c (after update) {
	ToroCacheManager.refreshAllPricingPrograms();    
}